import 'dart:async';
import 'dart:typed_data';

import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/export/share_service.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// A clock that returns a fixed instant until the test moves it.
class FakeClock implements Clock {
  FakeClock([DateTime? start])
    : now = start ?? DateTime.utc(2026, 11, 15, 6, 30);

  DateTime now;

  @override
  DateTime nowUtc() => now;
}

/// One thing handed to the share sheet.
class SharedItem {
  const SharedItem({
    required this.content,
    this.fileName,
    this.mimeType,
    this.subject,
  });

  final String content;
  final String? fileName;
  final String? mimeType;
  final String? subject;

  bool get isFile => fileName != null;
}

/// Records what would be handed to the share sheet. Set [fail] to make
/// opening it fail.
class RecordingShareService implements ShareService {
  final List<SharedItem> shared = [];
  bool fail = false;

  @override
  Future<void> shareText(String text, {String? subject}) async {
    if (fail) throw StateError('share sheet unavailable');
    shared.add(SharedItem(content: text, subject: subject));
  }

  @override
  Future<void> shareFile({
    required String fileName,
    required String content,
    required String mimeType,
    String? subject,
  }) async {
    if (fail) throw StateError('share sheet unavailable');
    shared.add(
      SharedItem(
        content: content,
        fileName: fileName,
        mimeType: mimeType,
        subject: subject,
      ),
    );
  }
}

/// Secrets held in a map. Set [fail] to make every call throw.
class InMemorySecretStore implements SecretStore {
  final Map<String, String> values = {};
  bool fail = false;

  @override
  Future<String?> read(String key) async {
    if (fail) throw StateError('secure storage unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('secure storage unavailable');
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (fail) throw StateError('secure storage unavailable');
    values.remove(key);
  }
}

/// A phone with or without a fingerprint, whose prompt answers [accept].
class FakeBiometricAuth implements BiometricAuth {
  bool available = false;
  bool accept = true;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    prompts++;
    return accept;
  }
}

/// Stands in for Android's file picker. [saved] holds what was written;
/// [toPick] is what the next "open" returns.
class FakeBackupFiles implements BackupFilePort {
  final Map<String, Uint8List> saved = {};
  Uint8List? toPick;
  bool cancelSave = false;
  bool failSave = false;

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (failSave) throw StateError('destination not writable');
    if (cancelSave) return false;
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => toPick;
}

/// A backup repository with no files and no encryption, for screen
/// tests. (Widget tests run on a fake clock, where real file work never
/// finishes; the real repository has its own tests.)
class FakeBackupRepository implements BackupRepository {
  FakeBackupRepository({this.passphrase = 'paddy field 42'});

  /// The only passphrase [stage] accepts.
  final String passphrase;
  final List<PreparedBackup> saved = [];
  final List<StagedRestore> installed = [];
  bool failInstall = false;

  final StreamController<DateTime?> _last =
      StreamController<DateTime?>.broadcast();
  DateTime? _lastAt;

  static final BackupManifest manifest = BackupManifest(
    backupId: 'backup-1',
    formatVersion: 1,
    appVersion: '1.0.0',
    schemaVersion: 1,
    createdAt: DateTime.utc(2026, 11, 14, 6, 30),
    shopId: 'shop-1',
    shopName: 'శ్రీ లక్ష్మీ కిరాణా అండ్ జనరల్ స్టోర్స్',
    recordCounts: const {'parties': 152, 'financial_transactions': 99999},
    ledgerTotalPaise: 0,
    movementTotalPaise: 0,
    databaseSha256: 'abc',
  );

  @override
  Stream<DateTime?> watchLastBackupAt() async* {
    yield _lastAt;
    yield* _last.stream;
  }

  @override
  Future<Result<PreparedBackup>> prepare(String passphrase) async => Ok(
    PreparedBackup(
      fileName: 'smart-khata-backup-2026-11-15.skbak',
      bytes: Uint8List.fromList([1, 2, 3]),
      manifest: manifest,
    ),
  );

  @override
  Future<Result<void>> recordSaved(PreparedBackup backup) async {
    saved.add(backup);
    _lastAt = backup.manifest.createdAt;
    _last.add(_lastAt);
    return const Ok(null);
  }

  @override
  Future<Result<StagedRestore>> stage(
    Uint8List bytes,
    String passphrase,
  ) async => passphrase == this.passphrase
      ? Ok(StagedRestore(manifest: manifest, stagedPath: 'staged.sqlite'))
      : const Err(BackupFailure(BackupError.wrongPassphraseOrDamaged));

  @override
  Future<Result<void>> install(StagedRestore restore) async {
    if (failInstall) {
      return const Err(BackupFailure(BackupError.notInstalled));
    }
    installed.add(restore);
    return const Ok(null);
  }

  @override
  Future<void> discard(StagedRestore restore) async {}
}

/// Records the database a restore would put in place.
class RecordingRestoreInstaller implements RestoreInstaller {
  final List<String> installed = [];
  bool fail = false;

  @override
  Future<void> install(String stagedPath) async {
    if (fail) throw StateError('swap failed');
    installed.add(stagedPath);
  }
}

/// Stands in for the phone's notifications: [scheduled] maps a
/// notification number to when it will show.
class FakeReminderNotifier implements ReminderNotifier {
  final Map<int, DateTime> scheduled = {};
  final List<ReminderTexts> texts = [];
  bool permission = true;
  bool failSchedule = false;

  @override
  Future<bool> ensurePermission() async => permission;

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required ReminderTexts texts,
  }) async {
    if (failSchedule) throw StateError('alarm not set');
    scheduled[id] = at;
    this.texts.add(texts);
  }

  @override
  Future<void> cancel(int id) async => scheduled.remove(id);
}

/// Collects log records so tests can assert on them.
class RecordingLogger extends AppLogger {
  factory RecordingLogger() => RecordingLogger._([]);

  RecordingLogger._(this.records) : super(sink: records.add);

  final List<LogRecord> records;
}

/// Settings held in memory. Set [failWrites] to make every save fail.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository({
    this.localeCode,
    this.onboardingComplete = false,
  });

  String? localeCode;
  bool onboardingComplete;
  bool failWrites = false;

  @override
  Future<Result<String?>> readLocaleCode() async => Ok(localeCode);

  @override
  Future<Result<void>> saveLocaleCode(String localeCode) async {
    if (failWrites) return const Err(DatabaseFailure());
    this.localeCode = localeCode;
    return const Ok(null);
  }

  @override
  Future<Result<bool>> isOnboardingComplete() async => Ok(onboardingComplete);

  @override
  Future<Result<void>> markOnboardingComplete() async {
    if (failWrites) return const Err(DatabaseFailure());
    onboardingComplete = true;
    return const Ok(null);
  }
}
