import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';

import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

void main() {
  late TestEnv env;
  late String cash;
  late String bank;
  late String rent;
  final today = BusinessDate(2026, 11, 15);
  var op = 0;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    cash = (await env.money.getAccounts()).valueOrNull!.single.id;
    bank = (await env.createMoneyAccount(name: 'SBI')).valueOrNull!;
    rent = (await env.expenses.getCategories()).valueOrNull!
        .firstWhere((c) => c.name == 'Rent')
        .id;
  });
  tearDown(() => env.dispose());

  void tick() => env.clock.now = env.clock.now.add(const Duration(minutes: 1));

  /// Adds a party with one role and returns `(partyId, accountId)`.
  Future<(String, String)> party(
    String name, {
    PartyRole role = PartyRole.customer,
  }) async {
    final id = await env.addParty(
      SavePartyCommand(displayName: name, roles: {role}),
    );
    return (id, await env.accountId(id, role.code));
  }

  Future<String> charge(
    (String, String) who,
    int amount, {
    PartyRole role = PartyRole.customer,
    BusinessDate? date,
    BusinessDate? dueDate,
    String? description,
  }) async {
    tick();
    final result = await env.recordCharge(
      RecordChargeCommand(
        operationId: 'chg-${op++}',
        role: role,
        partyId: who.$1,
        accountId: who.$2,
        amount: rupees(amount),
        date: date ?? today,
        dueDate: dueDate,
        description: description,
      ),
    );
    expect(result.failureOrNull, isNull);
    return result.valueOrNull!.transactionId;
  }

  Future<String> pay(
    (String, String) who,
    int amount, {
    PartyRole role = PartyRole.customer,
    BusinessDate? date,
    List<PaymentSplit>? splits,
  }) async {
    tick();
    final result = await env.recordPayment(
      RecordPaymentCommand(
        operationId: 'pay-${op++}',
        role: role,
        partyId: who.$1,
        accountId: who.$2,
        amount: rupees(amount),
        date: date ?? today,
        splits:
            splits ??
            [
              PaymentSplit(
                method: PaymentMethod.cash,
                moneyAccountId: cash,
                amount: null,
              ),
            ],
      ),
    );
    expect(result.failureOrNull, isNull);
    return result.valueOrNull!.transactionId;
  }

  Future<String> spend(
    int amount, {
    BusinessDate? date,
    String? categoryId,
  }) async {
    tick();
    final result = await env.recordExpense(
      RecordExpenseCommand(
        operationId: 'exp-${op++}',
        amount: rupees(amount),
        categoryId: categoryId ?? rent,
        date: date ?? today,
        method: PaymentMethod.cash,
        moneyAccountId: cash,
      ),
    );
    expect(result.failureOrNull, isNull);
    return result.valueOrNull!;
  }

  Future<void> reverse(String transactionId) async {
    tick();
    final result = await env.reverseTransaction(
      ReverseTransactionCommand(
        operationId: 'rev-${op++}',
        transactionId: transactionId,
        reason: 'Entered by mistake',
      ),
    );
    expect(result.failureOrNull, isNull);
  }

  Future<DashboardSummary> dashboard() =>
      env.reports.watchDashboard(today).first;

  Future<OutstandingReport> outstanding(
    PartyRole role, {
    int limit = 200,
  }) async => (await env.reports.outstanding(
    role: role,
    today: today,
    limit: limit,
  )).valueOrNull!;

  group('dashboard (SK-0801, FR-REP-001, PRD 9.5)', () {
    test('a new shop shows zeros and no parties', () async {
      final summary = await dashboard();
      expect(summary.partyCount, 0);
      expect(summary.customerOutstanding, Money.zero);
      expect(summary.supplierPayable, Money.zero);
      expect(summary.todayCredit, Money.zero);
      expect(summary.todayCollections, Money.zero);
      expect(summary.todayExpenses, Money.zero);
      expect(summary.overdueCustomers, 0);
    });

    test('each figure follows its definition', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      final abc = await party('ABC', role: PartyRole.supplier);

      await charge(
        ravi,
        300,
        date: BusinessDate(2026, 11, 1),
        dueDate: BusinessDate(2026, 11, 5),
      );
      await charge(ravi, 500);
      await pay(ravi, 100);
      await pay(sita, 200); // Nothing due: an advance.
      await charge(
        abc,
        1000,
        role: PartyRole.supplier,
        dueDate: BusinessDate(2026, 11, 20),
      );
      await spend(50);
      await spend(70, date: BusinessDate(2026, 11, 14));

      final summary = await dashboard();
      expect(summary.partyCount, 3);
      expect(summary.customerOutstanding, rupees(700));
      expect(summary.customersWithDues, 1);
      // The payment went to the oldest charge, which is still part open.
      expect(summary.overdueCustomers, 1);
      // The advance is its own figure and is not taken off the dues.
      expect(summary.customerAdvances, rupees(200));
      expect(summary.supplierPayable, rupees(1000));
      expect(summary.suppliersWithDues, 1);
      expect(summary.overdueSuppliers, 0);
      expect(summary.supplierAdvances, Money.zero);
      expect(summary.todayCredit, rupees(500));
      expect(summary.todayCollections, rupees(300));
      expect(summary.todayExpenses, rupees(50));
    });

    test(
      'customer and supplier accounts of one party are not netted',
      () async {
        final id = await env.addParty(
          const SavePartyCommand(
            displayName: 'Both',
            roles: {PartyRole.customer, PartyRole.supplier},
          ),
        );
        final asCustomer = (id, await env.accountId(id, 'customer'));
        final asSupplier = (id, await env.accountId(id, 'supplier'));
        await charge(asCustomer, 400);
        await charge(asSupplier, 400, role: PartyRole.supplier);

        final summary = await dashboard();
        expect(summary.customerOutstanding, rupees(400));
        expect(summary.supplierPayable, rupees(400));
      },
    );

    test('a reversed entry leaves every figure', () async {
      final ravi = await party('Ravi');
      final credit = await charge(
        ravi,
        500,
        dueDate: BusinessDate(2026, 11, 15),
      );
      final expense = await spend(80);
      await reverse(credit);
      await reverse(expense);

      final summary = await dashboard();
      expect(summary.customerOutstanding, Money.zero);
      expect(summary.customersWithDues, 0);
      expect(summary.todayCredit, Money.zero);
      expect(summary.todayExpenses, Money.zero);
    });

    test('due today is not overdue; a settled charge is not overdue', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 100, dueDate: today);
      expect((await dashboard()).overdueCustomers, 0);

      final sita = await party('Sita');
      await charge(
        sita,
        100,
        date: BusinessDate(2026, 11, 1),
        dueDate: BusinessDate(2026, 11, 2),
      );
      expect((await dashboard()).overdueCustomers, 1);
      await pay(sita, 100);
      expect((await dashboard()).overdueCustomers, 0);
    });

    test('the stream emits again after a new entry', () async {
      final ravi = await party('Ravi');
      final seen = <Money>[];
      final subscription = env.reports
          .watchDashboard(today)
          .listen((s) => seen.add(s.customerOutstanding));
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      await charge(ravi, 250);
      await pumpEventQueue();
      expect(seen.first, Money.zero);
      expect(seen.last, rupees(250));
    });

    test(
      'recent activity is newest first and marks reversed entries',
      () async {
        final ravi = await party('Ravi');
        final credit = await charge(ravi, 500, description: 'Rice');
        await spend(80);
        await reverse(credit);

        final items = await env.reports.watchRecentActivity(limit: 2).first;
        expect(items, hasLength(2));
        expect(items.first.type, TransactionType.transactionReversal);
        expect(items.last.type, TransactionType.expense);
        expect(items.last.categoryName, 'Rent');

        final all = await env.reports.watchRecentActivity(limit: 10).first;
        final original = all.firstWhere((i) => i.transactionId == credit);
        expect(original.isReversed, isTrue);
        expect(original.partyName, 'Ravi');
        expect(original.description, 'Rice');
        expect(original.amount, rupees(500));
      },
    );
  });

  group('outstanding and aging (SK-0802, FR-REP-002/003, WF-051)', () {
    test('bucket edges: 7, 15 and 30 days', () {
      BusinessDate ago(int days) => today.addDays(-days);
      expect(AgingBucket.of(today.addDays(3), today), AgingBucket.upTo7Days);
      expect(AgingBucket.of(ago(7), today), AgingBucket.upTo7Days);
      expect(AgingBucket.of(ago(8), today), AgingBucket.days8To15);
      expect(AgingBucket.of(ago(15), today), AgingBucket.days8To15);
      expect(AgingBucket.of(ago(16), today), AgingBucket.days16To30);
      expect(AgingBucket.of(ago(30), today), AgingBucket.days16To30);
      expect(AgingBucket.of(ago(31), today), AgingBucket.over30Days);
    });

    test('open amounts fall in the bucket of their entry date', () async {
      final ravi = await party('Ravi');
      for (final (days, amount) in [
        (0, 100),
        (7, 200),
        (8, 300),
        (15, 400),
        (16, 500),
        (30, 600),
        (31, 700),
      ]) {
        await charge(ravi, amount, date: today.addDays(-days));
      }

      final report = await outstanding(PartyRole.customer);
      expect(report.asOf, today);
      expect(report.totals.upTo7Days, rupees(300));
      expect(report.totals.days8To15, rupees(700));
      expect(report.totals.days16To30, rupees(1100));
      expect(report.totals.over30Days, rupees(700));
      expect(report.totals.total, rupees(2800));

      final row = report.rows.single;
      expect(row.partyName, 'Ravi');
      expect(row.aging, report.totals);
      expect(row.openEntryCount, 7);
      expect(
        BusinessDate.fromInstant(
          row.oldestAgingDate,
          ShopTimeZone.resolve(null),
        ),
        today.addDays(-31),
      );
      // The dashboard and the report agree.
      expect((await dashboard()).customerOutstanding, report.totals.total);
    });

    test('aging is of what is still open after payments', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 700, date: today.addDays(-31));
      await charge(ravi, 600, date: today.addDays(-20));
      await charge(ravi, 100);
      // Oldest first: clears the 700 and 100 of the 600.
      await pay(ravi, 800);

      final report = await outstanding(PartyRole.customer);
      expect(report.totals.over30Days, Money.zero);
      expect(report.totals.days16To30, rupees(500));
      expect(report.totals.upTo7Days, rupees(100));
      expect(report.rows.single.openEntryCount, 2);
    });

    test('a due date, when set, is what an amount ages from', () async {
      final ravi = await party('Ravi');
      await charge(
        ravi,
        900,
        date: today.addDays(-40),
        dueDate: today.addDays(-2),
      );
      final report = await outstanding(PartyRole.customer);
      expect(report.totals.upTo7Days, rupees(900));
      expect(report.totals.over30Days, Money.zero);
    });

    test('largest first, totals cover every party, list can be cut', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      final gopal = await party('Gopal');
      await charge(ravi, 100);
      await charge(sita, 900);
      await charge(gopal, 500);

      final all = await outstanding(PartyRole.customer);
      expect(all.rows.map((r) => r.partyName), ['Sita', 'Gopal', 'Ravi']);
      expect(all.isTruncated, isFalse);

      final cut = await outstanding(PartyRole.customer, limit: 2);
      expect(cut.rows.map((r) => r.partyName), ['Sita', 'Gopal']);
      expect(cut.isTruncated, isTrue);
      expect(cut.totals.total, rupees(1500));
    });

    test('advances are listed apart and never reduce the dues', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      await charge(ravi, 400);
      await pay(sita, 150);

      final report = await outstanding(PartyRole.customer);
      expect(report.totals.total, rupees(400));
      expect(report.rows.single.partyName, 'Ravi');
      expect(report.advances.single.partyName, 'Sita');
      expect(report.advances.single.amount, rupees(150));
      expect(report.totalAdvances, rupees(150));
    });

    test('a role sees only its own accounts; reversed charges go', () async {
      final ravi = await party('Ravi');
      final abc = await party('ABC', role: PartyRole.supplier);
      final wrong = await charge(ravi, 400);
      await charge(abc, 250, role: PartyRole.supplier);
      await reverse(wrong);

      final customers = await outstanding(PartyRole.customer);
      expect(customers.rows, isEmpty);
      expect(customers.totals, AgingAmounts.zero);
      final suppliers = await outstanding(PartyRole.supplier);
      expect(suppliers.role, PartyRole.supplier);
      expect(suppliers.rows.single.partyName, 'ABC');
      expect(suppliers.totals.total, rupees(250));
    });
  });

  group('period report (SK-0803, FR-REP-004/005)', () {
    test('totals by kind, method, category and day', () async {
      final ravi = await party('Ravi');
      final abc = await party('ABC', role: PartyRole.supplier);
      final transport = (await env.expenses.getCategories()).valueOrNull!
          .firstWhere((c) => c.name == 'Transport')
          .id;
      final yesterday = today.addDays(-1);

      await charge(ravi, 1000, date: yesterday);
      await charge(ravi, 500);
      await pay(
        ravi,
        600,
        splits: [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: rupees(400),
          ),
          PaymentSplit(
            method: PaymentMethod.upi,
            moneyAccountId: bank,
            amount: rupees(200),
          ),
        ],
      );
      await charge(abc, 2000, role: PartyRole.supplier);
      await pay(abc, 700, role: PartyRole.supplier);
      await spend(300, date: yesterday);
      await spend(120, categoryId: transport);
      // Outside the period and reversed entries are left out.
      await charge(ravi, 9000, date: today.addDays(-10));
      await reverse(await charge(ravi, 77));
      await reverse(await spend(33));

      final report = (await env.reports.period(
        DateRange(start: yesterday, end: today),
      )).valueOrNull!;
      expect(report.creditGiven, rupees(1500));
      expect(report.collections, rupees(600));
      expect(report.collectionsByMethod, {
        PaymentMethod.cash: rupees(400),
        PaymentMethod.upi: rupees(200),
      });
      expect(report.purchases, rupees(2000));
      expect(report.supplierPayments, rupees(700));
      expect(report.salesReturns, Money.zero);
      expect(report.expenses, rupees(420));
      expect(report.expensesByCategory.entries.map((e) => (e.key, e.value)), [
        ('Rent', rupees(300)),
        ('Transport', rupees(120)),
      ]);
      expect(report.hasMoreDays, isFalse);
      expect(report.days, [
        DayTotals(
          date: today,
          creditGiven: rupees(500),
          collections: rupees(600),
          expenses: rupees(120),
        ),
        DayTotals(
          date: yesterday,
          creditGiven: rupees(1000),
          collections: Money.zero,
          expenses: rupees(300),
        ),
      ]);
    });

    test('an open range covers everything; an empty period is zeros', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 9000, date: today.addDays(-10));

      final all = (await env.reports.period(const DateRange())).valueOrNull!;
      expect(all.creditGiven, rupees(9000));

      final none = (await env.reports.period(
        DateRange(start: today, end: today),
      )).valueOrNull!;
      expect(none.creditGiven, Money.zero);
      expect(none.days, isEmpty);
      expect(none.collectionsByMethod, isEmpty);
    });
  });

  group('party statement (SK-0901, FR-LED-009, WF-052)', () {
    test('opening balance, lines with running balance, closing', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      await charge(ravi, 1000, date: today.addDays(-10));
      await charge(ravi, 500, date: today.addDays(-2), description: 'Rice');
      await pay(ravi, 300, date: today.addDays(-1));
      await charge(ravi, 50);
      await charge(sita, 9999, date: today.addDays(-1));

      final statement = (await env.reports.statement(
        accountId: ravi.$2,
        range: DateRange(start: today.addDays(-3), end: today.addDays(-1)),
      )).valueOrNull!;
      expect(statement.partyName, 'Ravi');
      expect(statement.role, PartyRole.customer);
      expect(statement.openingBalance, rupees(1000));
      expect(statement.lines.map((l) => (l.type, l.amount, l.balanceAfter)), [
        (TransactionType.customerCredit, rupees(500), rupees(1500)),
        (TransactionType.customerPayment, rupees(-300), rupees(1200)),
      ]);
      expect(statement.lines.first.description, 'Rice');
      expect(statement.closingBalance, rupees(1200));
      expect(statement.isTruncated, isFalse);
    });

    test('a reversal shows as its own line and the balance returns', () async {
      final ravi = await party('Ravi');
      final wrong = await charge(ravi, 400);
      await reverse(wrong);

      final statement = (await env.reports.statement(
        accountId: ravi.$2,
        range: const DateRange(),
      )).valueOrNull!;
      expect(statement.openingBalance, Money.zero);
      expect(statement.lines.map((l) => (l.type, l.isReversed)), [
        (TransactionType.customerCredit, true),
        (TransactionType.transactionReversal, false),
      ]);
      expect(statement.closingBalance, Money.zero);
    });

    test('a cut statement keeps the newest lines and true balances', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 100, date: today.addDays(-3));
      await charge(ravi, 200, date: today.addDays(-2));
      await charge(ravi, 300, date: today.addDays(-1));

      final statement = (await env.reports.statement(
        accountId: ravi.$2,
        range: const DateRange(),
        limit: 2,
      )).valueOrNull!;
      expect(statement.isTruncated, isTrue);
      expect(statement.openingBalance, Money.zero);
      expect(statement.lines.map((l) => (l.amount, l.balanceAfter)), [
        (rupees(200), rupees(300)),
        (rupees(300), rupees(600)),
      ]);
      expect(statement.closingBalance, rupees(600));
    });

    test('an advance is a negative balance; unknown account is null', () async {
      final sita = await party('Sita');
      await pay(sita, 150);
      final statement = (await env.reports.statement(
        accountId: sita.$2,
        range: const DateRange(),
      )).valueOrNull!;
      expect(statement.closingBalance, rupees(-150));

      final missing = await env.reports.statement(
        accountId: 'nope',
        range: const DateRange(),
      );
      expect(missing.isOk, isTrue);
      expect(missing.valueOrNull, isNull);
    });
  });

  test('reports fail cleanly before shop setup', () async {
    final empty = TestEnv();
    addTearDown(empty.dispose);
    expect((await empty.reports.period(const DateRange())).isOk, isFalse);
    expect(
      (await empty.reports.outstanding(
        role: PartyRole.customer,
        today: today,
      )).isOk,
      isFalse,
    );
    expect(
      (await empty.reports.statement(
        accountId: 'x',
        range: const DateRange(),
      )).isOk,
      isFalse,
    );
  });
}
