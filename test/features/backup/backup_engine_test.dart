import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:smart_khata/core/app_info.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/backup_support.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/backup/data/backup_codec.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

const passphrase = 'paddy field 42';

Money rupees(int value) => Money.fromPaise(value * 100);

AppDatabase fileDatabase(File file) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(
    DatabaseConnection(NativeDatabase(file), closeStreamsSynchronously: true),
  );
}

/// The backup error inside a failed result.
BackupError? errorOf(Result<Object?> result) => switch (result.failureOrNull) {
  BackupFailure(:final error) => error,
  _ => null,
};

void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
  });
  tearDown(() => env.dispose());

  /// Ravi: ₹500 credit, ₹200 paid in cash. Balance ₹300.
  Future<void> seed(TestEnv target) async {
    final cash = (await target.money.getAccounts()).valueOrNull!.first.id;
    final ravi = await target.addParty(
      const SavePartyCommand(displayName: 'Ravi', roles: {PartyRole.customer}),
    );
    final account = await target.accountId(ravi, 'customer');
    await target.recordCharge(
      RecordChargeCommand(
        operationId: 'seed-credit',
        role: PartyRole.customer,
        partyId: ravi,
        accountId: account,
        amount: rupees(500),
        date: BusinessDate(2026, 11, 15),
      ),
    );
    await target.recordPayment(
      RecordPaymentCommand(
        operationId: 'seed-payment',
        role: PartyRole.customer,
        partyId: ravi,
        accountId: account,
        amount: rupees(200),
        date: BusinessDate(2026, 11, 15),
        splits: [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: null,
          ),
        ],
      ),
    );
  }

  BackupManifest manifest({int schemaVersion = 1, int formatVersion = 1}) =>
      BackupManifest(
        backupId: 'b1',
        formatVersion: formatVersion,
        appVersion: '1.0.0',
        schemaVersion: schemaVersion,
        createdAt: DateTime.utc(2026, 11, 15, 6, 30),
        shopId: 'shop',
        shopName: 'Test Kirana',
        recordCounts: const {'parties': 1},
        ledgerTotalPaise: 30000,
        movementTotalPaise: 20000,
        databaseSha256: 'abc',
      );

  Future<Uint8List> seal(
    BackupManifest manifest,
    List<int> database, {
    String secret = passphrase,
  }) => BackupCodec.seal(
    manifest: manifest,
    database: Uint8List.fromList(database),
    passphrase: secret,
    salt: List<int>.generate(16, (i) => i),
    nonce: List<int>.generate(24, (i) => 100 + i),
    params: TestEnv.testKdf,
  );

  Future<BackupError?> openError(
    Uint8List file, [
    String secret = passphrase,
  ]) async {
    try {
      await BackupCodec.open(file, secret);
      return null;
    } on FailureException catch (e) {
      return (e.failure as BackupFailure).error;
    }
  }

  group('backup file format (SK-1103, SK-1104)', () {
    test('what goes in comes out with the right passphrase', () async {
      final file = await seal(manifest(), [1, 2, 3, 4, 5]);
      final contents = await BackupCodec.open(file, passphrase);
      expect(contents.manifest, manifest());
      expect(contents.database, [1, 2, 3, 4, 5]);
    });

    test('the manifest survives JSON', () {
      final json =
          jsonDecode(jsonEncode(manifest().toJson())) as Map<String, Object?>;
      expect(BackupManifest.fromJson(json), manifest());
      expect(
        () => BackupManifest.fromJson({...json}..remove('shop_id')),
        throwsFormatException,
      );
      expect(
        () => BackupManifest.fromJson({
          ...json,
          'record_counts': const {'parties': 'many'},
        }),
        throwsFormatException,
      );
    });

    test(
      'nothing readable is in the file: no shop name, no passphrase',
      () async {
        final file = await seal(manifest(), utf8.encode('Ravi owes 300'));
        final text = latin1.decode(file);
        expect(text, startsWith('SKBAK'));
        expect(text, isNot(contains('Test Kirana')));
        expect(text, isNot(contains('Ravi')));
        expect(text, isNot(contains(passphrase)));
      },
    );

    test('a wrong passphrase is refused', () async {
      final file = await seal(manifest(), [1, 2, 3]);
      expect(
        await openError(file, 'paddy field 43'),
        BackupError.wrongPassphraseOrDamaged,
      );
    });

    test('a change to any part of the file is detected', () async {
      final file = await seal(manifest(), List<int>.filled(64, 7));
      // Salt, nonce, ciphertext and tag.
      for (final index in [16, 40, 60, file.length - 20, file.length - 1]) {
        final altered = Uint8List.fromList(file)..[index] ^= 0x01;
        expect(
          await openError(altered),
          BackupError.wrongPassphraseOrDamaged,
          reason: 'byte $index',
        );
      }
      // Header fields are authenticated too: a changed cost is refused.
      final cost = Uint8List.fromList(file)..[14] = 2;
      expect(await openError(cost), BackupError.wrongPassphraseOrDamaged);
      // A cut-off file.
      expect(
        await openError(Uint8List.sublistView(file, 0, file.length - 9)),
        BackupError.wrongPassphraseOrDamaged,
      );
    });

    test(
      'other files, newer formats and absurd costs are told apart',
      () async {
        final file = await seal(manifest(), [1, 2, 3]);
        expect(
          await openError(
            Uint8List.fromList(utf8.encode('hello, not a backup')),
          ),
          BackupError.notABackup,
        );
        expect(await openError(Uint8List(200)), BackupError.notABackup);
        expect(
          await openError(Uint8List.fromList(file)..[5] = 2),
          BackupError.newerVersion,
        );
        expect(
          await openError(Uint8List.fromList(file)..[6] = 9),
          BackupError.newerVersion,
        );
        // A crafted header asking for 4 GiB of memory is refused unread.
        final greedy = Uint8List.fromList(file)
          ..[7] = 0xFF
          ..[8] = 0xFF;
        expect(await openError(greedy), BackupError.notABackup);
        expect(
          KdfParams.standard.isSane,
          isTrue,
        );
        expect(
          const KdfParams(memoryKib: 64, iterations: 99, parallelism: 1).isSane,
          isFalse,
        );
        expect(
          const KdfParams(memoryKib: 64, iterations: 1, parallelism: 0).isSane,
          isFalse,
        );
        // More than 64 MiB or 4 passes would get the app killed on a small
        // phone, because the stretching runs in Dart.
        expect(
          const KdfParams(
            memoryKib: 64 * 1024 + 1,
            iterations: 1,
            parallelism: 1,
          ).isSane,
          isFalse,
        );
        expect(
          const KdfParams(memoryKib: 64, iterations: 5, parallelism: 1).isSane,
          isFalse,
        );
      },
    );

    test('a passphrase needs at least eight characters', () {
      expect(PassphrasePolicy.validate(''), ValidationError.required);
      expect(
        PassphrasePolicy.validate('1234567'),
        ValidationError.passphraseTooShort,
      );
      expect(PassphrasePolicy.validate('12345678'), isNull);
    });

    test('the version in the manifest is the version in pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final version = RegExp(
        r'^version:\s*([0-9.]+)',
        multiLine: true,
      ).firstMatch(pubspec)!.group(1);
      expect(AppInfo.version, version);
    });
  });

  group('making a backup (SK-1102, WF-071)', () {
    test('a snapshot is described, encrypted and checked', () async {
      await seed(env);
      final backup = (await env.backup.prepare(passphrase)).valueOrNull!;

      expect(backup.fileName, 'smart-khata-backup-2026-11-15.skbak');
      final m = backup.manifest;
      expect(m.shopName, 'Test Kirana');
      expect(m.schemaVersion, env.db.schemaVersion);
      expect(m.appVersion, AppInfo.version);
      expect(m.createdAt, env.clock.now);
      expect(m.recordCounts['parties'], 1);
      expect(m.recordCounts['financial_transactions'], 2);
      expect(m.recordCounts['party_ledger_entries'], 2);
      expect(m.recordCounts['money_movements'], 1);
      expect(m.ledgerTotalPaise, 30000);
      expect(m.movementTotalPaise, 20000);

      final contents = await BackupCodec.open(backup.bytes, passphrase);
      expect(contents.manifest, m);
      expect(await BackupCodec.sha256Hex(contents.database), m.databaseSha256);
      // The plain snapshot does not stay behind in the cache.
      expect(env.workDirectory.listSync(), isEmpty);
    });

    test(
      'preparing is not a backup: nothing is recorded until saved',
      () async {
        final seen = <DateTime?>[];
        final subscription = env.backup.watchLastBackupAt().listen(seen.add);
        addTearDown(subscription.cancel);

        final backup = (await env.backup.prepare(passphrase)).valueOrNull!;
        await pumpEventQueue();
        expect(seen, [null]);
        expect(await env.count('backup_history'), 0);

        expect((await env.backup.recordSaved(backup)).isOk, isTrue);
        await pumpEventQueue();
        expect(seen.last, env.clock.now);
        final row = await env.db.select(env.db.backupHistory).getSingle();
        expect(row.status, BackupStatus.verified);
        expect(row.destinationLabel, isNull);
        expect(row.checksumSha256, backup.manifest.databaseSha256);
      },
    );

    test('the passphrase is never logged or stored', () async {
      await seed(env);
      final backup = (await env.backup.prepare(passphrase)).valueOrNull!;
      await env.backup.recordSaved(backup);
      await env.backup.stage(backup.bytes, 'a wrong passphrase');

      for (final record in env.logger.records) {
        expect(record.message, isNot(contains(passphrase)));
        expect(record.errorDescription ?? '', isNot(contains(passphrase)));
      }
      final snapshot = File(p.join(env.workDirectory.path, 'check.sqlite'));
      await env.db.backupDao.snapshotInto(snapshot.path);
      expect(
        latin1.decode(snapshot.readAsBytesSync()),
        isNot(contains(passphrase)),
      );
    });
  });

  group('ExportBackup (WF-071, FR-BKP-002/004)', () {
    test('a weak or mistyped passphrase stops before any work', () async {
      expect(
        (await env.exportBackup(
          passphrase: 'short',
          confirmation: 'short',
        )).failureOrNull,
        const ValidationFailure({
          ExportBackup.passphraseField: ValidationError.passphraseTooShort,
        }),
      );
      expect(
        (await env.exportBackup(
          passphrase: passphrase,
          confirmation: 'paddy field 4',
        )).failureOrNull,
        const ValidationFailure({
          ExportBackup.confirmationField: ValidationError.doesNotMatch,
        }),
      );
      expect(env.backupFiles.saved, isEmpty);
    });

    test('saved where the owner chose, then recorded', () async {
      final result = await env.exportBackup(
        passphrase: passphrase,
        confirmation: passphrase,
      );
      expect(result.valueOrNull, isTrue);
      expect(env.backupFiles.saved.keys.single, endsWith('.skbak'));
      expect(await env.count('backup_history'), 1);
    });

    test('cancelling the file picker records nothing', () async {
      env.backupFiles.cancelSave = true;
      final result = await env.exportBackup(
        passphrase: passphrase,
        confirmation: passphrase,
      );
      expect(result.valueOrNull, isFalse);
      expect(await env.count('backup_history'), 0);
    });

    test('a failed write is a failure and records nothing', () async {
      env.backupFiles.failSave = true;
      final result = await env.exportBackup(
        passphrase: passphrase,
        confirmation: passphrase,
      );
      expect(errorOf(result), BackupError.notSaved);
      expect(await env.count('backup_history'), 0);
    });
  });

  group('checking a backup before restore (SK-1106, WF-072)', () {
    test(
      'a good backup is staged with its details; live data is untouched',
      () async {
        await seed(env);
        final backup = (await env.backup.prepare(passphrase)).valueOrNull!;
        final before = await env.count('party_ledger_entries');

        final staged = (await env.backup.stage(
          backup.bytes,
          passphrase,
        )).valueOrNull!;
        expect(staged.manifest, backup.manifest);
        expect(File(staged.stagedPath).existsSync(), isTrue);
        final facts = DatabaseInspector.inspect(staged.stagedPath);
        expect(facts.shopName, 'Test Kirana');
        expect(facts.ledgerTotalPaise, 30000);

        expect(await env.count('party_ledger_entries'), before);
        expect(env.installer.installed, isEmpty);

        await env.backup.discard(staged);
        expect(File(staged.stagedPath).existsSync(), isFalse);
      },
    );

    test('a wrong passphrase or a damaged file stages nothing', () async {
      final backup = (await env.backup.prepare(passphrase)).valueOrNull!;
      expect(
        errorOf(await env.backup.stage(backup.bytes, 'not the passphrase')),
        BackupError.wrongPassphraseOrDamaged,
      );
      final damaged = Uint8List.fromList(backup.bytes)..[200] ^= 0xFF;
      expect(
        errorOf(await env.backup.stage(damaged, passphrase)),
        BackupError.wrongPassphraseOrDamaged,
      );
      expect(env.workDirectory.listSync(), isEmpty);
    });

    test('a backup from a newer app is refused', () async {
      final real = (await env.backup.prepare(passphrase)).valueOrNull!;
      final database = (await BackupCodec.open(
        real.bytes,
        passphrase,
      )).database;
      final newer = BackupManifest.fromJson({
        ...real.manifest.toJson(),
        'schema_version': env.db.schemaVersion + 1,
      });
      final file = await seal(newer, database);
      expect(
        errorOf(await env.backup.stage(file, passphrase)),
        BackupError.newerVersion,
      );
      expect(env.workDirectory.listSync(), isEmpty);
    });

    test('contents that do not match the manifest are refused', () async {
      await seed(env);
      final real = (await env.backup.prepare(passphrase)).valueOrNull!;
      final database = (await BackupCodec.open(
        real.bytes,
        passphrase,
      )).database;

      // The balance check: a manifest that claims a different total.
      final wrongTotal = BackupManifest.fromJson({
        ...real.manifest.toJson(),
        'ledger_total_paise': 1,
      });
      expect(
        errorOf(
          await env.backup.stage(await seal(wrongTotal, database), passphrase),
        ),
        BackupError.failedChecks,
      );

      // A wrong row count.
      final wrongCount = BackupManifest.fromJson({
        ...real.manifest.toJson(),
        'record_counts': {...real.manifest.recordCounts, 'parties': 99},
      });
      expect(
        errorOf(
          await env.backup.stage(await seal(wrongCount, database), passphrase),
        ),
        BackupError.failedChecks,
      );

      // The hash of the database does not match.
      final wrongHash = BackupManifest.fromJson({
        ...real.manifest.toJson(),
        'database_sha256': 'f' * 64,
      });
      expect(
        errorOf(
          await env.backup.stage(await seal(wrongHash, database), passphrase),
        ),
        BackupError.failedChecks,
      );

      // Not a database at all, with a matching hash.
      final junk = Uint8List.fromList(List<int>.filled(4096, 42));
      final junkManifest = BackupManifest.fromJson({
        ...real.manifest.toJson(),
        'database_sha256': await BackupCodec.sha256Hex(junk),
      });
      expect(
        errorOf(
          await env.backup.stage(await seal(junkManifest, junk), passphrase),
        ),
        BackupError.failedChecks,
      );
      expect(env.workDirectory.listSync(), isEmpty);
    });

    test('a backup whose database lost a trigger or gained a table is '
        'refused', () async {
      await seed(env);
      final real = (await env.backup.prepare(passphrase)).valueOrNull!;
      final database = (await BackupCodec.open(
        real.bytes,
        passphrase,
      )).database;

      /// The same backup with [sql] run on its database first, and a
      /// manifest that matches the changed file in every figure.
      Future<Uint8List> tampered(String sql) async {
        final file = File(p.join(env.workDirectory.path, 'tamper.sqlite'))
          ..writeAsBytesSync(database);
        sqlite3.open(file.path)
          ..execute(sql)
          ..close();
        final bytes = file.readAsBytesSync();
        file.deleteSync();
        final manifest = BackupManifest.fromJson({
          ...real.manifest.toJson(),
          'database_sha256': await BackupCodec.sha256Hex(bytes),
        });
        return seal(manifest, bytes);
      }

      // Counts, totals, hash and integrity all still pass; only the
      // schema differs.
      for (final sql in [
        'DROP TRIGGER party_ledger_entries_no_delete',
        'DROP TRIGGER allocation_event_validate_insert',
        'DROP INDEX parties_shop_name_idx',
        'CREATE TABLE extra (id INTEGER)',
        'PRAGMA user_version = 0',
      ]) {
        expect(
          errorOf(await env.backup.stage(await tampered(sql), passphrase)),
          BackupError.failedChecks,
          reason: sql,
        );
      }
      expect(env.workDirectory.listSync(), isEmpty);

      // An untouched copy still passes.
      final same = await tampered('SELECT 1');
      expect((await env.backup.stage(same, passphrase)).isOk, isTrue);
    });

    test(
      'install hands the checked file over; a failed swap is reported',
      () async {
        final backup = (await env.backup.prepare(passphrase)).valueOrNull!;
        final staged = (await env.backup.stage(
          backup.bytes,
          passphrase,
        )).valueOrNull!;

        env.installer.fail = true;
        expect(
          errorOf(await env.backup.install(staged)),
          BackupError.notInstalled,
        );
        env.installer.fail = false;
        expect((await env.backup.install(staged)).isOk, isTrue);
        expect(env.installer.installed, [staged.stagedPath]);
      },
    );
  });

  group('replacing the database file (SK-1107)', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('sk_swap_'));
    tearDown(() {
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows may still hold a handle; temp is cleared by the OS.
      }
    });

    File write(String name, String content) =>
        File(p.join(dir.path, name))..writeAsStringSync(content);

    test(
      'the new file goes in; the old one is kept as a safety copy',
      () async {
        final live = write('smart_khata.sqlite', 'old');
        write('smart_khata.sqlite-wal', 'old wal');
        write('smart_khata.sqlite-shm', 'old shm');
        final staged = write('staged.sqlite', 'new');

        await DatabaseFileSwap.install(live: live, staged: staged);

        expect(live.readAsStringSync(), 'new');
        expect(
          File(
            '${live.path}${DatabaseFileSwap.safetySuffix}',
          ).readAsStringSync(),
          'old',
        );
        expect(File('${live.path}-wal').existsSync(), isFalse);
        expect(File('${live.path}-shm').existsSync(), isFalse);
        expect(File('${live.path}.incoming').existsSync(), isFalse);
      },
    );

    test('a second restore replaces the earlier safety copy', () async {
      final live = write('smart_khata.sqlite', 'first');
      await DatabaseFileSwap.install(
        live: live,
        staged: write('a.sqlite', 'second'),
      );
      await DatabaseFileSwap.install(
        live: live,
        staged: write('b.sqlite', 'third'),
      );
      expect(live.readAsStringSync(), 'third');
      expect(
        File('${live.path}${DatabaseFileSwap.safetySuffix}').readAsStringSync(),
        'second',
      );
    });

    test('a missing staged file leaves the live database as it was', () async {
      final live = write('smart_khata.sqlite', 'old');
      await expectLater(
        DatabaseFileSwap.install(
          live: live,
          staged: File(p.join(dir.path, 'missing.sqlite')),
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(live.readAsStringSync(), 'old');
    });

    test('a fresh phone has no live file yet', () async {
      final live = File(p.join(dir.path, 'smart_khata.sqlite'));
      await DatabaseFileSwap.install(
        live: live,
        staged: write('staged.sqlite', 'new'),
      );
      expect(live.readAsStringSync(), 'new');
      expect(
        DatabaseFileSwap.liveFile(dir, 'smart_khata').path,
        live.path,
      );
    });

    test('a damaged database file fails inspection', () {
      final junk = write('junk.sqlite', 'this is not sqlite' * 100);
      expect(
        () => DatabaseInspector.inspect(junk.path),
        throwsA(isA<DatabaseInspectionException>()),
      );
    });

    test(
      'a backup made on one phone restores on another with every balance',
      () async {
        // Phone A: a database on disk with entries.
        final phoneA = TestEnv(
          database: fileDatabase(File(p.join(dir.path, 'a.sqlite'))),
        );
        await phoneA.setUpShop();
        await seed(phoneA);
        final backup = (await phoneA.backup.prepare(passphrase)).valueOrNull!;
        await phoneA.dispose();

        // Phone B: a new install with nothing in it.
        final liveB = File(p.join(dir.path, 'b.sqlite'));
        final phoneB = TestEnv(database: fileDatabase(liveB));
        expect(await phoneB.count('shops'), 0);
        final staged = (await phoneB.backup.stage(
          backup.bytes,
          passphrase,
        )).valueOrNull!;
        await phoneB.db.close();
        await DatabaseFileSwap.install(
          live: liveB,
          staged: File(staged.stagedPath),
        );

        // Reopened on the restored file.
        final restored = TestEnv(database: fileDatabase(liveB));
        addTearDown(restored.dispose);
        addTearDown(phoneB.dispose);
        expect(
          (await restored.shops.getShop()).valueOrNull!.name,
          'Test Kirana',
        );
        expect(await restored.count('party_ledger_entries'), 2);
        expect(
          await restored.db.scalar(
            'SELECT SUM(amount_paise) FROM party_ledger_entries',
          ),
          30000,
        );
        // The append-only guards came across with the schema.
        await expectLater(
          restored.db.customStatement('DELETE FROM party_ledger_entries'),
          throwsA(anything),
        );
        // And the restored shop can keep working.
        final cash = (await restored.money.getAccounts()).valueOrNull!.first;
        expect(cash.balance, rupees(200));
      },
    );
  });
}
