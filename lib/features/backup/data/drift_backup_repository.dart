import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:smart_khata/core/app_info.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/backup_support.dart';
import 'package:smart_khata/core/database/daos/backup_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/backup/data/backup_codec.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';

/// Runs heavy work (key stretching, encryption) off the UI thread.
typedef HeavyRunner = Future<R> Function<R>(Future<R> Function() work);

/// On another isolate.
Future<R> runOnIsolate<R>(Future<R> Function() work) => Isolate.run(work);

/// On the calling isolate (tests).
Future<R> runInline<R>(Future<R> Function() work) => work();

final class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
    required this._installer,
    required this._workDirectory,
    required this._schemaVersion,
    this._run = runOnIsolate,
    this._kdf = KdfParams.standard,
    Random? random,
  }) : _random = random ?? Random.secure();

  final BackupDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;
  final RestoreInstaller _installer;

  /// The app's private cache folder, for the snapshot and the staged
  /// restore. Nothing is left there after a backup.
  final Future<Directory> Function() _workDirectory;

  /// The newest database version this app understands.
  final int _schemaVersion;
  final HeavyRunner _run;
  final KdfParams _kdf;
  final Random _random;

  /// Plain (unencrypted) work files in the app's cache. Each is deleted
  /// as soon as it has been used; startup clears any left by a crash.
  static const String snapshotName = 'backup_snapshot.sqlite';
  static const String stagedName = 'restore_staged.sqlite';

  @override
  Stream<DateTime?> watchLastBackupAt() =>
      Stream.fromFuture(_shop.requireShopId())
          .asyncExpand(_dao.watchLastVerifiedAt)
          .mapErrorsToFailures(logger: _logger, operation: 'backup.last');

  @override
  Future<Result<PreparedBackup>> prepare(String passphrase) => guard(
    () async {
      final directory = await _workDirectory();
      final snapshot = File(p.join(directory.path, snapshotName));
      if (snapshot.existsSync()) await snapshot.delete();

      final Uint8List database;
      final DatabaseFacts facts;
      try {
        await _dao.snapshotInto(snapshot.path);
        // Described from the copy itself, so the manifest matches the
        // bytes even if entries are added meanwhile.
        facts = _inspect(snapshot.path);
        database = await snapshot.readAsBytes();
      } finally {
        if (snapshot.existsSync()) await snapshot.delete();
      }

      final now = _clock.nowUtc();
      final manifest = BackupManifest(
        backupId: _ids.newId(),
        formatVersion: BackupCodec.formatVersion,
        appVersion: AppInfo.version,
        schemaVersion: facts.schemaVersion,
        createdAt: now,
        shopId: facts.shopId,
        shopName: facts.shopName,
        recordCounts: facts.recordCounts,
        ledgerTotalPaise: facts.ledgerTotalPaise,
        movementTotalPaise: facts.movementTotalPaise,
        databaseSha256: await BackupCodec.sha256Hex(database),
      );
      final salt = _randomBytes(BackupCodec.saltLength);
      final nonce = _randomBytes(BackupCodec.nonceLength);
      final kdf = _kdf;

      // Encrypt, then open the result again and compare: success is not
      // reported for a file that cannot be read back (FR-BKP-004).
      final bytes = await _run(
        _sealJob(manifest, database, passphrase, salt, nonce, kdf),
      );

      final day = BusinessDate.fromInstant(now, ShopTimeZone.resolve(null));
      return PreparedBackup(
        fileName: 'smart-khata-backup-${day.toIso()}.skbak',
        bytes: bytes,
        manifest: manifest,
      );
    },
    logger: _logger,
    operation: 'backup.prepare',
  );

  @override
  Future<Result<void>> recordSaved(PreparedBackup backup) => guard(
    () async {
      final manifest = backup.manifest;
      await _dao.insertHistory(
        db.BackupHistoryCompanion.insert(
          id: _ids.newId(),
          shopId: await _shop.requireShopId(),
          backupId: manifest.backupId,
          schemaVersion: manifest.schemaVersion,
          appVersion: manifest.appVersion,
          createdAt: manifest.createdAt,
          recordCountsJson: jsonEncode(manifest.recordCounts),
          checksumSha256: manifest.databaseSha256,
          // Where the owner saved it is not recorded: it is their
          // business, and a path can name a person or an account.
          destinationLabel: const Value(null),
          status: BackupStatus.verified,
        ),
      );
    },
    logger: _logger,
    operation: 'backup.recordSaved',
  );

  @override
  Future<Result<StagedRestore>> stage(Uint8List bytes, String passphrase) =>
      guard(
        () async {
          final contents = await _run(_openJob(bytes, passphrase));
          final manifest = contents.manifest;
          if (manifest.formatVersion > BackupCodec.formatVersion ||
              manifest.schemaVersion > _schemaVersion) {
            throw const FailureException(
              BackupFailure(BackupError.newerVersion),
            );
          }

          final directory = await _workDirectory();
          final staged = File(p.join(directory.path, stagedName));
          await staged.writeAsBytes(contents.database, flush: true);
          try {
            final facts = _inspect(staged.path);
            // The file must have exactly this app's tables, indexes and
            // triggers. Without this a file could arrive with the
            // append-only guards removed and still pass every count.
            // (Only schema 1 exists. The first schema change must teach
            // this check what an older version looks like.)
            final expected = await _dao.schemaObjects();
            final matches =
                facts.schemaVersion == _schemaVersion &&
                _sameObjects(facts.schemaObjects, expected) &&
                facts.schemaVersion == manifest.schemaVersion &&
                facts.shopId == manifest.shopId &&
                facts.ledgerTotalPaise == manifest.ledgerTotalPaise &&
                facts.movementTotalPaise == manifest.movementTotalPaise &&
                _sameCounts(facts.recordCounts, manifest.recordCounts);
            if (!matches) {
              throw const FailureException(
                BackupFailure(BackupError.failedChecks),
              );
            }
          } on Object {
            if (staged.existsSync()) await staged.delete();
            rethrow;
          }
          return StagedRestore(manifest: manifest, stagedPath: staged.path);
        },
        logger: _logger,
        operation: 'backup.stage',
      );

  @override
  Future<Result<void>> install(StagedRestore restore) async {
    try {
      await _installer.install(restore.stagedPath);
      return const Ok(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        'backup.install failed',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      return const Err(BackupFailure(BackupError.notInstalled));
    }
  }

  @override
  Future<void> discard(StagedRestore restore) async {
    final staged = File(restore.stagedPath);
    if (staged.existsSync()) await staged.delete();
  }

  // The jobs below are built in static functions so that what crosses to
  // the other isolate is only their arguments, never this repository.

  static Future<Uint8List> Function() _sealJob(
    BackupManifest manifest,
    Uint8List database,
    String passphrase,
    Uint8List salt,
    Uint8List nonce,
    KdfParams kdf,
  ) => () async {
    final sealed = await BackupCodec.seal(
      manifest: manifest,
      database: database,
      passphrase: passphrase,
      salt: salt,
      nonce: nonce,
      params: kdf,
    );
    final reopened = await BackupCodec.open(sealed, passphrase);
    final sameDatabase =
        await BackupCodec.sha256Hex(reopened.database) ==
        manifest.databaseSha256;
    if (reopened.manifest != manifest || !sameDatabase) {
      throw const FailureException(BackupFailure(BackupError.failedChecks));
    }
    return sealed;
  };

  static Future<BackupContents> Function() _openJob(
    Uint8List bytes,
    String passphrase,
  ) => () async {
    final opened = await BackupCodec.open(bytes, passphrase);
    final hash = await BackupCodec.sha256Hex(opened.database);
    if (hash != opened.manifest.databaseSha256) {
      throw const FailureException(BackupFailure(BackupError.failedChecks));
    }
    return opened;
  };

  DatabaseFacts _inspect(String path) {
    try {
      return DatabaseInspector.inspect(path);
    } on DatabaseInspectionException {
      throw const FailureException(BackupFailure(BackupError.failedChecks));
    }
  }

  static bool _sameObjects(Map<String, String> a, Map<String, String> b) =>
      a.length == b.length &&
      a.entries.every((entry) => b[entry.key] == entry.value);

  static bool _sameCounts(Map<String, int> a, Map<String, int> b) =>
      a.length == b.length &&
      a.entries.every((entry) => b[entry.key] == entry.value);

  Uint8List _randomBytes(int length) => Uint8List.fromList(
    List<int>.generate(length, (_) => _random.nextInt(256)),
  );
}
