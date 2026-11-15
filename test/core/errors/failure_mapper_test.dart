import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late RecordingLogger logger;

  setUp(() async {
    db = createTestDatabase();
    logger = RecordingLogger();
    await db.seedShop();
    await db.seedParty(id: 'party-1');
    await db.seedAccount(id: 'cust-1', partyId: 'party-1');
  });

  tearDown(() => db.close());

  Future<Failure?> failureOf(Future<void> Function() action) async {
    final result = await guard(action, logger: logger, operation: 'test.op');
    return result.failureOrNull;
  }

  group('guard maps real SQLite errors', () {
    test('a repeated operation ID is a duplicate operation', () async {
      await db.seedTransaction(
        id: 't1',
        accountId: 'cust-1',
        operationId: 'op',
      );
      expect(
        await failureOf(
          () => db.seedTransaction(
            id: 't2',
            accountId: 'cust-1',
            operationId: 'op',
          ),
        ),
        const DuplicateOperationFailure(),
      );
    });

    test('another unique key is a unique constraint failure', () async {
      expect(
        await failureOf(() => db.seedAccount(id: 'dup', partyId: 'party-1')),
        const ConstraintFailure(ConstraintKind.unique),
      );
    });

    test('a missing parent row is a foreign-key failure', () async {
      expect(
        await failureOf(() => db.seedParty(id: 'p2', shopId: 'missing')),
        const ConstraintFailure(ConstraintKind.foreignKey),
      );
    });

    test('a CHECK violation is a check failure', () async {
      expect(
        await failureOf(
          () => db.seedTransaction(
            id: 't1',
            accountId: 'cust-1',
            amountPaise: 0,
          ),
        ),
        const ConstraintFailure(ConstraintKind.check),
      );
    });

    test('an append-only trigger is a trigger failure', () async {
      await db.seedTransaction(id: 't1', accountId: 'cust-1');
      expect(
        await failureOf(
          () => db.exec("DELETE FROM financial_transactions WHERE id = 't1'"),
        ),
        const ConstraintFailure(ConstraintKind.trigger),
      );
    });

    test('invalid SQL is a database failure', () async {
      expect(
        await failureOf(() => db.exec('SELECT * FROM no_such_table')),
        isA<DatabaseFailure>(),
      );
    });
  });

  group('guard', () {
    test('returns the value on success and logs nothing', () async {
      final result = await guard(
        () async => 42,
        logger: logger,
        operation: 'test.op',
      );
      expect(result, isA<Ok<int>>());
      expect(result.valueOrNull, 42);
      expect(logger.records, isEmpty);
    });

    test('unwraps a FailureException thrown inside a transaction', () async {
      final failure = await failureOf(
        () => db.transaction(() async {
          await db.seedTransaction(id: 't1', accountId: 'cust-1');
          throw const FailureException(NotFoundFailure('party'));
        }),
      );
      expect(failure, const NotFoundFailure('party'));
      // The throw rolled the transaction back.
      expect(
        await db.scalar('SELECT COUNT(*) FROM financial_transactions'),
        0,
      );
    });

    test('anything else is unexpected', () async {
      expect(
        await failureOf(() async => throw StateError('boom')),
        const UnexpectedFailure(),
      );
    });

    test('logs the operation and failure code, not the data', () async {
      await failureOf(() => db.seedParty(id: 'p2', shopId: 'missing'));
      final record = logger.records.single;
      expect(record.level, LogLevel.error);
      expect(record.message, 'test.op failed: constraint_foreignKey');
    });
  });

  test('Result.map transforms a value and keeps a failure', () {
    expect(const Ok(2).map((v) => v * 2).valueOrNull, 4);
    const Result<int> err = Err(UnexpectedFailure());
    expect(err.map((v) => v * 2).failureOrNull, const UnexpectedFailure());
    expect(err.isOk, isFalse);
  });
}
