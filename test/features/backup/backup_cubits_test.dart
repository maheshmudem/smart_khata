import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/backup/data/backup_codec.dart';
import 'package:smart_khata/features/backup/data/drift_backup_repository.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/backup/presentation/backup_cubits.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';

import '../../helpers/test_env.dart';

const passphrase = 'paddy field 42';

Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
  });
  tearDown(() => env.dispose());

  Future<Uint8List> backupFile() async =>
      (await env.backup.prepare(passphrase)).valueOrNull!.bytes;

  group('CreateBackupCubit (WF-071)', () {
    CreateBackupCubit build() {
      final cubit = CreateBackupCubit(export: env.exportBackup);
      addTearDown(cubit.close);
      return cubit;
    }

    test('field errors come back without making anything', () async {
      final cubit = build();
      await cubit.create(passphrase: 'short', confirmation: 'short');
      expect(cubit.state.status, SubmissionStatus.idle);
      expect(cubit.state.errors, {
        ExportBackup.passphraseField: ValidationError.passphraseTooShort,
      });
      expect(env.backupFiles.saved, isEmpty);
    });

    test('success is reported only after the file was saved', () async {
      final cubit = build();
      final states = <SubmissionStatus>[];
      final subscription = cubit.stream.listen((s) => states.add(s.status));
      addTearDown(subscription.cancel);

      await cubit.create(passphrase: passphrase, confirmation: passphrase);
      await settle();
      expect(states, [SubmissionStatus.submitting, SubmissionStatus.success]);
      expect(env.backupFiles.saved, hasLength(1));
    });

    test('a cancelled file picker is not a backup', () async {
      env.backupFiles.cancelSave = true;
      final cubit = build();
      await cubit.create(passphrase: passphrase, confirmation: passphrase);
      expect(cubit.state.wasCancelled, isTrue);
      expect(cubit.state.status, SubmissionStatus.idle);
    });

    test('a failed save shows the failure', () async {
      env.backupFiles.failSave = true;
      final cubit = build();
      await cubit.create(passphrase: passphrase, confirmation: passphrase);
      expect(cubit.state.status, SubmissionStatus.failure);
      expect(cubit.state.failure, const BackupFailure(BackupError.notSaved));
    });
  });

  group('RestoreCubit (WF-072)', () {
    RestoreCubit build() {
      final cubit = RestoreCubit(
        repository: env.backup,
        files: env.backupFiles,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('choose, unlock, preview, then install', () async {
      env.backupFiles.toPick = await backupFile();
      final cubit = build();
      expect(cubit.state.step, RestoreStep.chooseFile);

      await cubit.chooseFile();
      expect(cubit.state.step, RestoreStep.enterPassphrase);

      await cubit.check('the wrong words');
      expect(cubit.state.step, RestoreStep.enterPassphrase);
      expect(
        cubit.state.failure,
        const BackupFailure(BackupError.wrongPassphraseOrDamaged),
      );
      expect(cubit.state.isBusy, isFalse);

      await cubit.check(passphrase);
      expect(cubit.state.step, RestoreStep.preview);
      expect(cubit.state.staged!.manifest.shopName, 'Test Kirana');
      // Nothing is installed by checking.
      expect(env.installer.installed, isEmpty);

      await cubit.install();
      expect(env.installer.installed, hasLength(1));
      expect(cubit.state.step, RestoreStep.installing);
    });

    test('cancelling the picker stays on the first step', () async {
      final cubit = build();
      await cubit.chooseFile();
      expect(cubit.state.step, RestoreStep.chooseFile);
      expect(cubit.state.isBusy, isFalse);
      // Checking with no file does nothing.
      await cubit.check(passphrase);
      expect(cubit.state.step, RestoreStep.chooseFile);
    });

    test('a file that is not a backup is refused', () async {
      env.backupFiles.toPick = Uint8List.fromList(List.filled(300, 1));
      final cubit = build();
      await cubit.chooseFile();
      await cubit.check(passphrase);
      expect(cubit.state.failure, const BackupFailure(BackupError.notABackup));
    });

    test('a failed install returns to the preview with the failure', () async {
      env.backupFiles.toPick = await backupFile();
      env.installer.fail = true;
      final cubit = build();
      await cubit.chooseFile();
      await cubit.check(passphrase);
      await cubit.install();
      expect(cubit.state.step, RestoreStep.preview);
      expect(
        cubit.state.failure,
        const BackupFailure(BackupError.notInstalled),
      );
    });

    test('starting over or leaving removes the checked file', () async {
      env.backupFiles.toPick = await backupFile();
      final cubit = build();
      await cubit.chooseFile();
      await cubit.check(passphrase);
      expect(env.workDirectory.listSync(), hasLength(1));

      await cubit.reset();
      expect(cubit.state.step, RestoreStep.chooseFile);
      expect(env.workDirectory.listSync(), isEmpty);

      await cubit.chooseFile();
      await cubit.check(passphrase);
      await cubit.close();
      expect(env.workDirectory.listSync(), isEmpty);
    });
  });

  group('last backup date (FR-BKP-009)', () {
    test('the backup page and Home follow the last saved backup', () async {
      final status = BackupStatusCubit(repository: env.backup);
      addTearDown(status.close);
      final dashboard = DashboardCubit(
        reports: env.reports,
        shops: env.shops,
        backup: env.backup,
        today: () => BusinessDate(2026, 11, 15),
      );
      addTearDown(dashboard.close);
      await settle();
      expect(status.state.isLoaded, isTrue);
      expect(status.state.lastBackupAt, isNull);
      expect(dashboard.state.lastBackupAt, isNull);

      await env.exportBackup(passphrase: passphrase, confirmation: passphrase);
      await settle();
      expect(status.state.lastBackupAt, env.clock.now);
      expect(dashboard.state.lastBackupAt, env.clock.now);
    });

    test('before shop setup it reads as no backup', () async {
      final empty = TestEnv();
      addTearDown(empty.dispose);
      final status = BackupStatusCubit(repository: empty.backup);
      addTearDown(status.close);
      await settle();
      expect(status.state.isLoaded, isTrue);
      expect(status.state.lastBackupAt, isNull);
    });
  });

  test(
    'the real key stretching and a second isolate make a file that opens',
    () async {
      final repository = DriftBackupRepository(
        dao: env.db.backupDao,
        shop: env.shops,
        clock: env.clock,
        ids: env.ids,
        logger: env.logger,
        installer: env.installer,
        workDirectory: () async => env.workDirectory,
        schemaVersion: env.db.schemaVersion,
      );
      final backup = (await repository.prepare(passphrase)).valueOrNull!;
      // The header records the standard cost.
      expect(backup.bytes[14], KdfParams.standard.iterations);
      final staged = await repository.stage(backup.bytes, passphrase);
      expect(staged.valueOrNull!.manifest, backup.manifest);
    },
  );
}
