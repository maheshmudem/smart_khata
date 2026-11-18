import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/data/drift_ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

/// Fails on the audit row, the last write of a posting.
class _FailingAuditPartiesDao extends PartiesDao {
  _FailingAuditPartiesDao(super.attachedDatabase);

  @override
  Future<void> insertAudit(db.AuditLogsCompanion row) =>
      throw StateError('simulated late failure');
}

Money rupees(int r) => Money.fromPaise(r * 100);

void main() {
  group('allocateOldestFirst', () {
    final t = DateTime.utc(2026, 11);
    OpenItem item(String id, int r, {int day = 1, int? dueDay}) => OpenItem(
      entryId: id,
      open: rupees(r),
      effectiveAt: t.add(Duration(days: day)),
      dueAt: dueDay == null ? null : t.add(Duration(days: dueDay)),
    );

    test('pays the earliest due first and stops at the amount', () {
      final shares = allocateOldestFirst(rupees(700), [
        item('late', 500, dueDay: 20),
        item('early', 500, day: 5, dueDay: 10),
      ]);
      expect(shares, [
        AllocationShare('early', rupees(500)),
        AllocationShare('late', rupees(200)),
      ]);
    });

    test('without a due date the effective date counts, then the ID', () {
      final shares = allocateOldestFirst(rupees(900), [
        item('b', 300, day: 2),
        item('a', 300, day: 2),
        item('z', 300),
      ]);
      expect(shares.map((s) => s.entryId), ['z', 'a', 'b']);
    });

    test('never allocates more than is open; the rest is left over', () {
      final shares = allocateOldestFirst(rupees(800), [item('only', 600)]);
      expect(shares, [AllocationShare('only', rupees(600))]);
    });

    test('a zero amount or nothing open allocates nothing', () {
      expect(allocateOldestFirst(Money.zero, [item('a', 1)]), isEmpty);
      expect(allocateOldestFirst(rupees(5), []), isEmpty);
    });
  });

  group('DriftLedgerRepository', () {
    late db.AppDatabase database;
    late SequenceIdGenerator ids;
    var op = 0;

    setUp(() async {
      database = createTestDatabase();
      ids = SequenceIdGenerator();
      await database.seedShop();
      await database.seedMoneyAccount();
      await database.seedParty(id: 'p1');
      await database.seedAccount(id: 'c1', partyId: 'p1');
      await database.seedAccount(id: 's1', partyId: 'p1', role: 'supplier');
    });
    tearDown(() => database.close());

    DriftLedgerRepository repo({PartiesDao? parties}) => DriftLedgerRepository(
      database: database,
      ledger: database.ledgerDao,
      parties: parties ?? database.partiesDao,
      shops: database.shopDao,
      clock: FakeClock(),
      ids: ids,
      logger: RecordingLogger(),
    );

    Future<Result<PostedEntry>> post(
      EntryType type,
      int r, {
      String account = 'c1',
      PaymentMethod? method,
      String? operationId,
      DriftLedgerRepository? using,
    }) => (using ?? repo()).post(
      EntryPosting(
        accountId: account,
        type: type,
        amount: rupees(r),
        operationId: operationId ?? 'op-${op++}',
        method: method ?? (type.isPayment ? PaymentMethod.cash : null),
      ),
    );

    Future<int> count(String table) =>
        database.scalar('SELECT COUNT(*) FROM $table');

    Future<int> balance(String account) => database.scalar(
      'SELECT COALESCE(SUM(amount_paise), 0) FROM party_ledger_entries '
      'WHERE party_account_id = ?',
      [account],
    );

    test(
      'credit adds a positive entry, an audit row and moves no cash',
      () async {
        final result = await post(EntryType.customerCredit, 500);

        expect(result.valueOrNull?.balanceAfter, rupees(500));
        expect(await count('financial_transactions'), 1);
        expect(await count('party_ledger_entries'), 1);
        expect(await count('money_movements'), 0);
        expect(await count('audit_logs'), 1);
      },
    );

    test('customer fixture: 300 + 1500 + 500 − 1000 = 1300 (§5.3)', () async {
      for (final r in [300, 1500, 500]) {
        await post(EntryType.customerCredit, r);
      }
      final paid = await post(EntryType.customerPayment, 1000);

      expect(paid.valueOrNull?.balanceAfter, rupees(1300));
      final lines = (await repo().watchLedger('c1', 10).first).valueOrNull!;
      expect(lines.first.runningBalance, rupees(1300));
      expect(lines.last.runningBalance, rupees(300));
      expect(lines.first.method, PaymentMethod.cash);
    });

    test('a payment is a ledger decrease and a cash inflow together', () async {
      await post(EntryType.customerCredit, 600);
      await post(EntryType.customerPayment, 400);

      expect(
        await database.scalar(
          "SELECT amount_paise FROM money_movements WHERE direction = 'inflow' "
          "AND money_account_id = 'cash-1'",
        ),
        40000,
      );
      expect(
        await database.scalar(
          'SELECT SUM(amount_paise) FROM ledger_allocation_events',
        ),
        40000,
      );
    });

    test('payments settle the oldest charge first', () async {
      await post(EntryType.customerCredit, 300); // id-? oldest
      await post(EntryType.customerCredit, 1500);
      await post(EntryType.customerPayment, 500);

      // 300 fully paid, 200 of the 1500.
      final open = await database.ledgerDao.openCharges('c1');
      expect(open.single.openPaise, 130000);
    });

    test('an excess receipt leaves a negative balance (advance)', () async {
      await post(EntryType.customerCredit, 600);
      final result = await post(EntryType.customerPayment, 800);

      expect(result.valueOrNull?.balanceAfter, rupees(-200));
      final advances = await database.ledgerDao.openSettlements('c1');
      expect(advances.single.openPaise, 20000);
    });

    test('a new credit uses up an advance the customer holds', () async {
      await post(EntryType.customerPayment, 200);
      await post(EntryType.customerCredit, 500);

      expect(await database.ledgerDao.openSettlements('c1'), isEmpty);
      expect(
        (await database.ledgerDao.openCharges('c1')).single.openPaise,
        30000,
      );
      expect(await balance('c1'), 30000);
    });

    test(
      'supplier fixture: 400 + 2000 − 1000 = 1400, money goes out',
      () async {
        await post(EntryType.supplierPurchase, 400, account: 's1');
        await post(EntryType.supplierPurchase, 2000, account: 's1');
        final paid = await post(
          EntryType.supplierPayment,
          1000,
          account: 's1',
        );

        expect(paid.valueOrNull?.balanceAfter, rupees(1400));
        expect(
          await database.scalar(
            "SELECT COUNT(*) FROM money_movements WHERE direction = 'outflow'",
          ),
          1,
        );
      },
    );

    test('customer and supplier accounts of one party stay apart', () async {
      await post(EntryType.customerCredit, 500);
      await post(EntryType.supplierPurchase, 300, account: 's1');
      expect(await balance('c1'), 50000);
      expect(await balance('s1'), 30000);
    });

    test('UPI and bank transfers land in one bank account, made once', () async {
      await post(EntryType.customerPayment, 100, method: PaymentMethod.upi);
      await post(
        EntryType.customerPayment,
        100,
        method: PaymentMethod.bankTransfer,
      );

      expect(
        await database.scalar(
          "SELECT COUNT(*) FROM money_accounts WHERE account_type = 'bank'",
        ),
        1,
      );
      expect(
        await database.scalar(
          "SELECT COUNT(*) FROM money_movements WHERE money_account_id = 'cash-1'",
        ),
        0,
      );
    });

    test('a repeated operation ID posts once', () async {
      await post(EntryType.customerCredit, 500, operationId: 'same');
      final again = await post(
        EntryType.customerCredit,
        500,
        operationId: 'same',
      );

      expect(again.failureOrNull, const DuplicateOperationFailure());
      expect(await count('party_ledger_entries'), 1);
    });

    test('a supplier entry on a customer account is refused', () async {
      final result = await post(EntryType.supplierPurchase, 100);
      expect(result.failureOrNull, const NotFoundFailure('party_account'));
      expect(await count('financial_transactions'), 0);
    });

    test('an archived party takes no new entries', () async {
      await database.exec(
        "UPDATE parties SET status = 'archived' WHERE id = 'p1'",
      );
      final result = await post(EntryType.customerCredit, 100);
      expect(
        result.failureOrNull,
        const BusinessRuleFailure(BusinessRule.partyArchived),
      );
    });

    test('a failure on the last step leaves no rows anywhere', () async {
      await post(EntryType.customerCredit, 600);
      final before = {
        for (final t in [
          'financial_transactions',
          'party_ledger_entries',
          'ledger_allocation_events',
          'money_movements',
          'audit_logs',
        ])
          t: await count(t),
      };

      final result = await post(
        EntryType.customerPayment,
        400,
        using: repo(parties: _FailingAuditPartiesDao(database)),
      );

      expect(result, isA<Err<PostedEntry>>());
      for (final MapEntry(key: table, value: n) in before.entries) {
        expect(await count(table), n, reason: table);
      }
    });
  });

  group('PostEntry validation', () {
    test(
      'needs a party, a positive amount and, for a payment, a method',
      () async {
        final result = await const PostEntry(_UnusedLedger()).call(
          const PostEntryCommand(
            type: EntryType.customerPayment,
            accountId: null,
            amount: null,
            operationId: 'op',
          ),
        );
        expect(
          result.failureOrNull,
          const ValidationFailure({
            EntryFields.party: ValidationError.required,
            EntryFields.amount: ValidationError.amountMustBePositive,
            EntryFields.method: ValidationError.required,
          }),
        );
      },
    );
  });
}

class _UnusedLedger implements LedgerRepository {
  const _UnusedLedger();

  @override
  Future<Result<PostedEntry>> post(EntryPosting posting) =>
      throw StateError('must not be reached');

  @override
  Stream<Result<List<LedgerLine>>> watchLedger(String accountId, int limit) =>
      throw StateError('must not be reached');
}
