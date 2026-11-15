import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';

/// What a backup says about itself (FR-BKP-003). It travels inside the
/// encrypted part of the file; nothing here is a secret or a key.
class BackupManifest extends Equatable {
  const BackupManifest({
    required this.backupId,
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.shopId,
    required this.shopName,
    required this.recordCounts,
    required this.ledgerTotalPaise,
    required this.movementTotalPaise,
    required this.databaseSha256,
  });

  /// Reads a manifest; throws [FormatException] when a field is missing
  /// or of the wrong kind.
  factory BackupManifest.fromJson(Map<String, Object?> json) {
    T field<T>(String name) {
      final value = json[name];
      if (value is T) return value;
      throw FormatException('manifest field', name);
    }

    return BackupManifest(
      backupId: field<String>('backup_id'),
      formatVersion: field<int>('backup_format_version'),
      appVersion: field<String>('app_version'),
      schemaVersion: field<int>('schema_version'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        field<int>('created_at_utc_ms'),
        isUtc: true,
      ),
      shopId: field<String>('shop_id'),
      shopName: field<String>('shop_name'),
      recordCounts: {
        for (final MapEntry(:key, :value) in field<Map<String, Object?>>(
          'record_counts',
        ).entries)
          key: value is int
              ? value
              : throw FormatException('manifest count', key),
      },
      ledgerTotalPaise: field<int>('ledger_total_paise'),
      movementTotalPaise: field<int>('movement_total_paise'),
      databaseSha256: field<String>('database_sha256'),
    );
  }

  final String backupId;
  final int formatVersion;
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final String shopId;
  final String shopName;

  /// Table name → rows.
  final Map<String, int> recordCounts;

  /// Sum of every signed party ledger amount, in paise: a balance check
  /// that a restore recomputes (WF-072).
  final int ledgerTotalPaise;
  final int movementTotalPaise;
  final String databaseSha256;

  Map<String, Object?> toJson() => {
    'backup_id': backupId,
    'backup_format_version': formatVersion,
    'app_version': appVersion,
    'schema_version': schemaVersion,
    'created_at_utc_ms': createdAt.millisecondsSinceEpoch,
    'shop_id': shopId,
    'shop_name': shopName,
    'record_counts': recordCounts,
    'ledger_total_paise': ledgerTotalPaise,
    'movement_total_paise': movementTotalPaise,
    'database_sha256': databaseSha256,
  };

  @override
  List<Object?> get props => [
    backupId,
    formatVersion,
    appVersion,
    schemaVersion,
    createdAt,
    shopId,
    shopName,
    recordCounts,
    ledgerTotalPaise,
    movementTotalPaise,
    databaseSha256,
  ];
}

/// An encrypted backup that has been made and checked, but not yet saved
/// anywhere the owner can keep it. It is not a backup until it is saved
/// outside the app (WF-070).
class PreparedBackup {
  const PreparedBackup({
    required this.fileName,
    required this.bytes,
    required this.manifest,
  });

  final String fileName;
  final Uint8List bytes;
  final BackupManifest manifest;
}

/// A backup file that was decrypted and passed every check, waiting for
/// the owner to confirm the restore.
class StagedRestore extends Equatable {
  const StagedRestore({required this.manifest, required this.stagedPath});

  final BackupManifest manifest;

  /// The checked database file in the app's private cache.
  final String stagedPath;

  @override
  List<Object?> get props => [manifest, stagedPath];
}

/// The rule for a backup passphrase. It is the only thing protecting the
/// file once it leaves the phone, so very short ones are refused.
abstract final class PassphrasePolicy {
  static const int minLength = 8;

  /// `null` when [passphrase] is acceptable.
  static ValidationError? validate(String passphrase) {
    if (passphrase.isEmpty) return ValidationError.required;
    return passphrase.length < minLength
        ? ValidationError.passphraseTooShort
        : null;
  }
}

/// Where a backup file goes to and comes from: a place the owner picks
/// through Android's file picker (FR-BKP-002).
abstract interface class BackupFilePort {
  /// Asks where to save and writes [bytes] there. `false` when the owner
  /// cancelled.
  Future<bool> save({required String fileName, required Uint8List bytes});

  /// Asks for a file and returns its contents; `null` when the owner
  /// cancelled.
  Future<Uint8List?> pick();
}

/// Puts a checked database in place of the live one and restarts the app
/// on it.
// One method on purpose: an injection seam.
// ignore: one_member_abstracts
abstract interface class RestoreInstaller {
  Future<void> install(String stagedPath);
}

/// Encrypted, portable backup and restore (E11).
///
/// The passphrase is used to derive the file's key and is then dropped:
/// it is never stored, logged or put in the file.
abstract interface class BackupRepository {
  /// When the newest backup saved outside the app was made.
  Stream<DateTime?> watchLastBackupAt();

  /// Snapshots the database, encrypts it and proves the result can be
  /// decrypted and matches (FR-BKP-004). Nothing leaves the app yet.
  Future<Result<PreparedBackup>> prepare(String passphrase);

  /// Records that [backup] was saved outside the app.
  Future<Result<void>> recordSaved(PreparedBackup backup);

  /// Decrypts [bytes] and checks everything WF-072 lists. The live
  /// database is not touched.
  Future<Result<StagedRestore>> stage(Uint8List bytes, String passphrase);

  /// Replaces the live database with [restore] (FR-BKP-007). The earlier
  /// database is kept as a safety copy; on failure it stays in place.
  Future<Result<void>> install(StagedRestore restore);

  /// Deletes a staged restore the owner decided not to use.
  Future<void> discard(StagedRestore restore);
}

/// Makes a backup and saves it where the owner chooses. Success is only
/// reported after the file was written there (WF-071 step 7).
class ExportBackup {
  const ExportBackup(this._repository, this._files);

  final BackupRepository _repository;
  final BackupFilePort _files;

  /// `Ok(true)` when saved, `Ok(false)` when the owner cancelled the
  /// file picker (nothing is recorded as a backup).
  Future<Result<bool>> call({
    required String passphrase,
    required String confirmation,
  }) async {
    final error = PassphrasePolicy.validate(passphrase);
    if (error != null) {
      return Err(ValidationFailure({passphraseField: error}));
    }
    if (passphrase != confirmation) {
      return const Err(
        ValidationFailure({confirmationField: ValidationError.doesNotMatch}),
      );
    }

    final prepared = await _repository.prepare(passphrase);
    final PreparedBackup backup;
    switch (prepared) {
      case Ok(:final value):
        backup = value;
      case Err(:final failure):
        return Err(failure);
    }

    final bool saved;
    try {
      saved = await _files.save(fileName: backup.fileName, bytes: backup.bytes);
    } on Object {
      return const Err(BackupFailure(BackupError.notSaved));
    }
    if (!saved) return const Ok(false);

    final recorded = await _repository.recordSaved(backup);
    return recorded.map((_) => true);
  }

  static const String passphraseField = 'passphrase';
  static const String confirmationField = 'confirmation';
}
