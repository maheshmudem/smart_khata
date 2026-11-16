import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

import '../../helpers/test_database.dart';
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

  void tick([Duration by = const Duration(minutes: 1)]) =>
      env.clock.now = env.clock.now.add(by);

  Future<Money> balanceOf(String accountId) async =>
      (await env.money.getAccounts()).valueOrNull!
          .firstWhere((a) => a.id == accountId)
          .balance;

  RecordExpenseCommand expense(
    int amount, {
    String? categoryId,
    String? accountId,
    PaymentMethod method = PaymentMethod.cash,
    BusinessDate? date,
    String? operationId,
    String? payee,
    String? note,
    bool noCategory = false,
  }) => RecordExpenseCommand(
    operationId: operationId ?? 'exp-${op++}',
    amount: rupees(amount),
    categoryId: noCategory ? null : (categoryId ?? rent),
    date: date ?? today,
    method: method,
    moneyAccountId: accountId ?? cash,
    payee: payee,
    note: note,
  );

  Future<String> spend(int amount, {BusinessDate? date}) async {
    tick();
    return (await env.recordExpense(expense(amount, date: date))).valueOrNull!;
  }

  Future<Result<String>> adjust(
    int amount, {
    MovementDirection direction = MovementDirection.inflow,
    String? accountId,
    String reason = 'Opening cash',
    String? operationId,
  }) {
    tick();
    return env.recordAdjustment(
      RecordAdjustmentCommand(
        operationId: operationId ?? 'adj-${op++}',
        moneyAccountId: accountId ?? cash,
        direction: direction,
        amount: rupees(amount),
        reason: reason,
      ),
    );
  }

  group('expense categories (SK-0601, WF-043)', () {
    Future<List<ExpenseCategory>> categories({bool archived = false}) =>
        env.expenses.watchCategories(includeArchived: archived).first;

    test('the shop starts with its default categories, by name', () async {
      final all = await categories();
      expect(all.map((c) => c.name), [
        'Electricity',
        'Other',
        'Rent',
        'Transport',
      ]);
      expect(all.every((c) => c.isDefault && c.isActive), isTrue);
    });

    test('default names that repeat are seeded once', () async {
      final other = TestEnv();
      addTearDown(other.dispose);
      await other.createShop(
        const CreateShopCommand(
          name: 'Shop',
          localeCode: 'en',
          cashAccountName: 'Cash',
          defaultExpenseCategories: ['Rent', ' rent ', 'RENT', '  ', 'Other'],
        ),
      );
      final names = (await other.expenses.getCategories()).valueOrNull!;
      expect(names.map((c) => c.name), ['Other', 'Rent']);
    });

    test('a category can be added and is not a default', () async {
      expect((await env.saveExpenseCategory(name: '  Tea  ')).isOk, isTrue);
      final tea = (await categories()).firstWhere((c) => c.name == 'Tea');
      expect(tea.isDefault, isFalse);
    });

    test('a blank or over-long name is rejected', () async {
      expect(
        (await env.saveExpenseCategory(name: ' ')).failureOrNull,
        const ValidationFailure({
          SaveExpenseCategory.nameField: ValidationError.required,
        }),
      );
      expect(
        (await env.saveExpenseCategory(name: 'a' * 41)).failureOrNull,
        const ValidationFailure({
          SaveExpenseCategory.nameField: ValidationError.tooLong,
        }),
      );
    });

    test(
      'two active categories cannot share a name, in any letter case',
      () async {
        final result = await env.saveExpenseCategory(name: 'rENT');
        expect(
          result.failureOrNull,
          const RuleFailure(RuleViolation.categoryNameTaken),
        );
        expect(await categories(), hasLength(4));
      },
    );

    test('renaming changes the category but not to a name in use', () async {
      expect(
        (await env.saveExpenseCategory(
          name: 'Shop rent',
          categoryId: rent,
        )).isOk,
        isTrue,
      );
      expect((await categories()).map((c) => c.name), contains('Shop rent'));
      // Renaming to its own name is fine; to another's is not.
      expect(
        (await env.saveExpenseCategory(
          name: 'shop RENT',
          categoryId: rent,
        )).isOk,
        isTrue,
      );
      expect(
        (await env.saveExpenseCategory(
          name: 'Other',
          categoryId: rent,
        )).failureOrNull,
        const RuleFailure(RuleViolation.categoryNameTaken),
      );
      expect(
        (await env.saveExpenseCategory(
          name: 'X',
          categoryId: 'missing',
        )).failureOrNull,
        const NotFoundFailure('expense_category'),
      );
    });

    test('an archived category leaves the list and frees its name', () async {
      await env.expenses.setCategoryActive(rent, active: false);

      expect((await categories()).map((c) => c.name), isNot(contains('Rent')));
      final archived = (await categories(archived: true)).last;
      expect(archived.name, 'Rent');
      expect(archived.isActive, isFalse);

      // The name can be used again …
      expect((await env.saveExpenseCategory(name: 'Rent')).isOk, isTrue);
      // … and then the old one cannot be restored under the same name.
      expect(
        (await env.expenses.setCategoryActive(
          rent,
          active: true,
        )).failureOrNull,
        const RuleFailure(RuleViolation.categoryNameTaken),
      );
    });
  });

  group('expense posting (SK-0602, FR-CASH-004)', () {
    test('validation: amount, category, account and date', () {
      Map<String, ValidationError> validate(RecordExpenseCommand c) =>
          RecordExpense.validate(c, today: today);

      expect(validate(expense(300)), isEmpty);
      expect(validate(expense(0)), {
        RecordExpenseCommand.amountField: ValidationError.amountMustBePositive,
      });
      expect(validate(expense(300, noCategory: true)), {
        RecordExpenseCommand.categoryField: ValidationError.categoryRequired,
      });
      expect(validate(expense(300, date: today.addDays(1))), {
        RecordExpenseCommand.dateField: ValidationError.dateInFuture,
      });
      expect(
        validate(
          RecordExpenseCommand(
            operationId: 'op',
            amount: rupees(300),
            categoryId: rent,
            date: today,
            method: PaymentMethod.cash,
          ),
        ),
        {RecordExpenseCommand.accountField: ValidationError.accountRequired},
      );
    });

    test(
      'writes header, detail with the category name, and the outflow',
      () async {
        final id = (await env.recordExpense(
          expense(300, payee: ' Landlord ', note: 'November'),
        )).valueOrNull!;

        final header = await env.db
            .select(env.db.financialTransactions)
            .getSingle();
        expect(header.id, id);
        expect(header.transactionType, TransactionType.expense);
        expect(header.amountPaise, 30000);
        // An expense belongs to no customer or supplier.
        expect(header.partyAccountId, isNull);
        expect(await env.count('party_ledger_entries'), 0);

        final detail = await env.db.select(env.db.expenses).getSingle();
        expect(detail.transactionId, id);
        expect(detail.categoryId, rent);
        expect(detail.categoryNameSnapshot, 'Rent');
        expect(detail.payee, 'Landlord');

        final movement = await env.db.select(env.db.moneyMovements).getSingle();
        expect(movement.moneyAccountId, cash);
        expect(movement.direction, MovementDirection.outflow);
        expect(movement.amountPaise, 30000);
        expect(await balanceOf(cash), rupees(-300));
      },
    );

    test('an expense paid by UPI leaves the bank account', () async {
      await env.recordExpense(
        expense(450, method: PaymentMethod.upi, accountId: bank),
      );
      expect(await balanceOf(bank), rupees(-450));
      expect(await balanceOf(cash), Money.zero);
    });

    test('cash cannot be paid from a bank account', () async {
      final result = await env.recordExpense(expense(300, accountId: bank));
      expect(
        result.failureOrNull,
        const ValidationFailure({
          RecordExpenseCommand.accountField: ValidationError.accountMismatch,
        }),
      );
      expect(await env.count('financial_transactions'), 0);
    });

    test(
      'detail and outflow are saved together or not at all (invariant 9)',
      () async {
        // The money movement is the last of the three inserts.
        await env.db.exec(
          'CREATE TRIGGER fail_move BEFORE INSERT ON money_movements '
          "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
        );

        final result = await env.recordExpense(expense(300));

        expect(result.failureOrNull, isA<ConstraintFailure>());
        expect(await env.count('financial_transactions'), 0);
        expect(await env.count('expenses'), 0);
        expect(await env.count('money_movements'), 0);
      },
    );

    test('the same operation ID with a different amount is refused', () async {
      await env.recordExpense(expense(300, operationId: 'same'));
      final edited = await env.recordExpense(
        expense(900, operationId: 'same'),
      );
      expect(edited.failureOrNull, const DuplicateOperationFailure());
      expect(await env.count('expenses'), 1);
      final log = (await env.db.select(env.db.auditLogs).get()).single;
      expect(log.action, 'expense_recorded');
    });

    test('repeating an operation posts once', () async {
      final command = expense(300, operationId: 'same');
      final first = (await env.recordExpense(command)).valueOrNull!;
      final second = (await env.recordExpense(command)).valueOrNull!;
      expect(second, first);
      expect(await env.count('expenses'), 1);
      expect(await balanceOf(cash), rupees(-300));
    });

    test('an archived category cannot take a new expense', () async {
      await env.expenses.setCategoryActive(rent, active: false);
      final result = await env.recordExpense(expense(300));
      expect(result.failureOrNull, const NotFoundFailure('expense_category'));
      expect(await env.count('money_movements'), 0);
    });

    test(
      'renaming or archiving a category keeps old expenses readable',
      () async {
        await spend(300);
        await env.saveExpenseCategory(name: 'Shop rent', categoryId: rent);
        await env.expenses.setCategoryActive(rent, active: false);

        final detail = await env.db.select(env.db.expenses).getSingle();
        expect(detail.categoryNameSnapshot, 'Rent');
        final line =
            (await env.cashBook
                    .watchLines(cash, const DateRange(), limit: 10)
                    .first)
                .single;
        expect(line.categoryName, 'Rent');
      },
    );

    test(
      'reversing an expense puts the money back and keeps both rows',
      () async {
        final id = await spend(300);
        tick();
        final result = await env.reverseTransaction(
          ReverseTransactionCommand(
            operationId: 'rev',
            transactionId: id,
            reason: 'Entered twice',
          ),
        );

        expect(result.isOk, isTrue);
        expect(await balanceOf(cash), Money.zero);
        final lines = await env.cashBook
            .watchLines(cash, const DateRange(), limit: 10)
            .first;
        expect(lines, hasLength(2));
        expect(
          lines.first.transactionType,
          TransactionType.transactionReversal,
        );
        expect(lines.first.isInflow, isTrue);
        // The reversal line still says which category it belongs to.
        expect(lines.first.categoryName, 'Rent');
        expect(lines.last.isReversed, isTrue);
      },
    );
  });

  group('adjustments (FR-CASH-008)', () {
    test('need an account, a positive amount and a reason', () {
      expect(
        RecordAdjustment.validate(
          const RecordAdjustmentCommand(
            operationId: 'op',
            moneyAccountId: null,
            direction: MovementDirection.inflow,
            amount: Money.zero,
            reason: '  ',
          ),
        ),
        {
          RecordAdjustmentCommand.accountField: ValidationError.accountRequired,
          RecordAdjustmentCommand.amountField:
              ValidationError.amountMustBePositive,
          RecordAdjustmentCommand.reasonField: ValidationError.required,
        },
      );
    });

    test(
      'money added to cash is a cash adjustment with its reason audited',
      () async {
        final id = (await adjust(
          2000,
          reason: '  Opening  cash ',
        )).valueOrNull!;

        expect(await balanceOf(cash), rupees(2000));
        final header = await env.db
            .select(env.db.financialTransactions)
            .getSingle();
        expect(header.id, id);
        expect(header.transactionType, TransactionType.cashAdjustment);
        expect(header.description, 'Opening cash');
        final audit = await env.db.select(env.db.auditLogs).getSingle();
        expect(audit.action, 'money_adjustment_recorded');
        expect(audit.reason, 'Opening cash');
        expect(audit.entityId, id);
      },
    );

    test('money taken out of a bank account is a bank adjustment', () async {
      await adjust(
        500,
        direction: MovementDirection.outflow,
        accountId: bank,
        reason: 'Bank charges',
      );
      expect(await balanceOf(bank), rupees(-500));
      final header = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(header.transactionType, TransactionType.bankAdjustment);
    });

    test('repeating an operation posts once', () async {
      await adjust(2000, operationId: 'same');
      await adjust(2000, operationId: 'same');
      expect(await balanceOf(cash), rupees(2000));
      expect(await env.count('money_movements'), 1);
    });

    test('a failed adjustment leaves nothing', () async {
      await env.db.exec('DROP TABLE audit_logs');
      final result = await adjust(2000);
      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(await env.count('money_movements'), 0);
      expect(await balanceOf(cash), Money.zero);
    });
  });

  group('money accounts (WF-041)', () {
    test('an opening balance is fixed when the account is created', () async {
      final id = (await env.createMoneyAccount(
        name: 'HDFC',
        openingBalance: rupees(5000),
      )).valueOrNull!;
      expect(await balanceOf(id), rupees(5000));
      // It is not a movement: the book starts from it.
      expect(await env.count('money_movements'), 0);
    });

    test(
      'a bank account can be turned off and on; its history stays',
      () async {
        await env.recordExpense(
          expense(450, method: PaymentMethod.upi, accountId: bank),
        );

        expect(
          (await env.cashBook.setAccountActive(bank, active: false)).isOk,
          isTrue,
        );
        final active = (await env.money.getAccounts()).valueOrNull!;
        expect(active.map((a) => a.id), [cash]);
        expect(await env.count('money_movements'), 1);
        // It is no longer offered for new entries.
        expect(
          (await env.recordExpense(
            expense(100, method: PaymentMethod.upi, accountId: bank),
          )).failureOrNull,
          const NotFoundFailure('money_account'),
        );

        await env.cashBook.setAccountActive(bank, active: true);
        expect((await env.money.getAccounts()).valueOrNull, hasLength(2));
        // The account's own trail (the expense above has a row of its own).
        final logs = (await env.db.select(env.db.auditLogs).get()).where(
          (l) => l.entityType == 'money_account',
        );
        expect(logs.map((l) => l.action), ['deactivated', 'reactivated']);
      },
    );

    test('the cash account cannot be turned off', () async {
      final result = await env.cashBook.setAccountActive(cash, active: false);
      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.cashAccountRequired),
      );
      expect((await env.money.getAccounts()).valueOrNull, hasLength(2));
    });
  });

  group('cash book (SK-0604, WF-040)', () {
    late String ravi;
    late String raviAccount;
    late String supplier;
    late String supplierAccount;

    setUp(() async {
      ravi = await env.addParty(
        const SavePartyCommand(
          displayName: 'Ravi',
          roles: {PartyRole.customer},
        ),
      );
      raviAccount = await env.accountId(ravi, 'customer');
      supplier = await env.addParty(
        const SavePartyCommand(
          displayName: 'ABC Distributors',
          roles: {PartyRole.supplier},
        ),
      );
      supplierAccount = await env.accountId(supplier, 'supplier');
    });

    Future<void> pay(int amount, PartyRole role) async {
      tick();
      await env.recordPayment(
        RecordPaymentCommand(
          operationId: 'pay-${op++}',
          role: role,
          partyId: role == PartyRole.customer ? ravi : supplier,
          accountId: role == PartyRole.customer ? raviAccount : supplierAccount,
          amount: rupees(amount),
          date: today,
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

    test('test plan cash fixture: 2000 + 800 - 300 - 500 = 2000', () async {
      await adjust(2000);
      await pay(800, PartyRole.customer);
      await spend(300);
      await pay(500, PartyRole.supplier);

      expect(await balanceOf(cash), rupees(2000));
      final summary = await env.cashBook
          .watchSummary(cash, const DateRange())
          .first;
      expect(summary.openingBalance, Money.zero);
      expect(summary.inflows, rupees(2800));
      expect(summary.outflows, rupees(800));
      expect(summary.closingBalance, rupees(2000));
    });

    test('lines are newest first and say what caused each movement', () async {
      await adjust(2000);
      await pay(800, PartyRole.customer);
      await spend(300);
      await pay(500, PartyRole.supplier);

      final lines = await env.cashBook
          .watchLines(cash, const DateRange(), limit: 10)
          .first;
      expect(
        lines.map(
          (l) => (
            l.transactionType,
            l.isInflow,
            l.amount,
            l.partyName ?? l.categoryName,
          ),
        ),
        [
          (
            TransactionType.supplierPayment,
            false,
            rupees(500),
            'ABC Distributors',
          ),
          (TransactionType.expense, false, rupees(300), 'Rent'),
          (TransactionType.customerPayment, true, rupees(800), 'Ravi'),
          (TransactionType.cashAdjustment, true, rupees(2000), null),
        ],
      );
      expect(lines.last.description, 'Opening cash');
    });

    test(
      'a period shows the balance before it and only its movements',
      () async {
        // Yesterday: ₹1,000 added and ₹200 spent. Today: ₹300 spent.
        await adjust(1000);
        await spend(200);
        env.clock.now = env.clock.now.add(const Duration(days: 1));
        final tomorrow = today.addDays(1);
        await env.recordExpense(expense(300, date: tomorrow));

        final range = DateRange(start: tomorrow, end: tomorrow);
        final summary = await env.cashBook.watchSummary(cash, range).first;
        expect(summary.openingBalance, rupees(800));
        expect(summary.inflows, Money.zero);
        expect(summary.outflows, rupees(300));
        expect(summary.closingBalance, rupees(500));

        final lines = await env.cashBook
            .watchLines(cash, range, limit: 10)
            .first;
        expect(lines.single.amount, rupees(300));

        final earlier = await env.cashBook
            .watchSummary(cash, DateRange(start: today, end: today))
            .first;
        expect(earlier.inflows, rupees(1000));
        expect(earlier.outflows, rupees(200));
      },
    );

    test('a backdated expense belongs to the day it is dated', () async {
      await spend(300, date: today.addDays(-3));
      final todayOnly = DateRange(start: today, end: today);

      expect(
        await env.cashBook.watchLines(cash, todayOnly, limit: 10).first,
        isEmpty,
      );
      final summary = await env.cashBook.watchSummary(cash, todayOnly).first;
      // It is part of the balance before today.
      expect(summary.openingBalance, rupees(-300));
      expect(summary.outflows, Money.zero);
    });

    test('each account has its own book', () async {
      await adjust(2000);
      await env.recordExpense(
        expense(450, method: PaymentMethod.upi, accountId: bank),
      );
      expect(
        (await env.cashBook
                .watchLines(cash, const DateRange(), limit: 10)
                .first)
            .single
            .transactionType,
        TransactionType.cashAdjustment,
      );
      expect(
        (await env.cashBook
                .watchLines(bank, const DateRange(), limit: 10)
                .first)
            .single
            .transactionType,
        TransactionType.expense,
      );
    });

    test('the book updates by itself and respects its limit', () async {
      final totals = env.cashBook
          .watchSummary(cash, const DateRange())
          .map((s) => s.closingBalance);
      final expectation = expectLater(
        totals,
        emitsInOrder([Money.zero, rupees(2000), rupees(1700)]),
      );
      await pumpEventQueue();
      await adjust(2000);
      await pumpEventQueue();
      await spend(300);
      await expectation;

      expect(
        await env.cashBook.watchLines(cash, const DateRange(), limit: 1).first,
        hasLength(1),
      );
    });
  });

  group('date range presets (WF-053)', () {
    test('cover the days they name, both ends included', () {
      expect(
        DateRange.preset(DateRangePreset.today, today),
        DateRange(start: today, end: today),
      );
      expect(
        DateRange.preset(DateRangePreset.last7Days, today),
        DateRange(start: BusinessDate(2026, 11, 9), end: today),
      );
      expect(
        DateRange.preset(DateRangePreset.thisMonth, today),
        DateRange(start: BusinessDate(2026, 11, 1), end: today),
      );
      expect(
        DateRange.preset(DateRangePreset.allTime, today),
        const DateRange(),
      );
    });
  });

  group('cash count (SK-0701)', () {
    test('adds up notes, coins and other cash', () {
      const count = CashCount(quantities: {500: 4, 200: 3, 100: 5, 10: 10});
      expect(count.subtotalOf(500), rupees(2000));
      expect(count.subtotalOf(50), Money.zero);
      expect(count.total, rupees(3200));
      expect(
        count.withOtherAmount(Money.fromPaise(1250)).total,
        Money.fromPaise(320000 + 1250),
      );
    });

    test('quantities cannot go below zero', () {
      final count = const CashCount()
          .withQuantity(100, 2)
          .withQuantity(100, -1);
      expect(count.quantityOf(100), 0);
      expect(count.isEmpty, isTrue);
      expect(const CashCount(quantities: {1: 1}).isEmpty, isFalse);
    });

    test('covers the common Indian notes and coins', () {
      expect(cashDenominations, [500, 200, 100, 50, 20, 10, 5, 2, 1]);
    });
  });

  group('daily closing (SK-0702, SK-0703, FR-CLOSE-001..004)', () {
    const counted3500 = CashCount(
      quantities: {500: 4, 200: 3, 100: 5, 50: 4, 20: 5, 10: 10},
    );

    Future<DailyClosing> close(
      CashCount count, {
      BusinessDate? date,
      String? note,
      String? operationId,
    }) async {
      tick();
      final result = await env.closeDay(
        CloseDayCommand(
          operationId: operationId ?? 'close-${op++}',
          businessDate: date ?? today,
          count: count,
          note: note,
        ),
      );
      expect(result.failureOrNull, isNull);
      return result.valueOrNull!;
    }

    test('expected cash is opening plus cash in minus cash out', () async {
      await adjust(2000);
      await spend(300);
      // A bank expense does not touch the drawer.
      await env.recordExpense(
        expense(450, method: PaymentMethod.upi, accountId: bank),
      );
      expect(
        (await env.closings.expectedCash(today)).valueOrNull,
        rupees(1700),
      );
    });

    test('a closing snapshots expected, counted and the difference', () async {
      await adjust(3400);
      final closing = await close(counted3500, note: ' Found a note ');

      expect(closing.businessDate, today);
      expect(closing.expectedCash, rupees(3400));
      expect(closing.countedCash, rupees(3500));
      expect(closing.variance, rupees(100));
      expect(closing.count, counted3500);
      expect(closing.note, 'Found a note');
      expect(closing.revisionNumber, 1);
      expect(closing.isRevised, isFalse);
      expect((await env.closings.currentClosing(today)).valueOrNull, closing);
    });

    test('counting never changes the cash book (invariant 12)', () async {
      await adjust(3400);
      final movementsBefore = await env.count('money_movements');

      await close(counted3500);

      expect(await balanceOf(cash), rupees(3400));
      expect(await env.count('money_movements'), movementsBefore);
      expect(
        (await env.closings.expectedCash(today)).valueOrNull,
        rupees(3400),
      );
    });

    test('a shortage is a negative difference', () async {
      await adjust(4000);
      final closing = await close(counted3500);
      expect(closing.variance, rupees(-500));
    });

    test('closing a day again adds a revision and keeps the first', () async {
      await adjust(3400);
      final first = await close(counted3500);
      await spend(100);
      final second = await close(
        counted3500.withQuantity(100, 4),
        note: 'Recounted',
      );

      expect(second.revisionNumber, 2);
      expect(second.isRevised, isTrue);
      expect(second.expectedCash, rupees(3300));
      expect(second.countedCash, rupees(3400));
      expect(await env.count('daily_closings'), 2);

      final rows = await env.db.select(env.db.dailyClosings).get();
      final firstRow = rows.firstWhere((r) => r.id == first.id);
      expect(firstRow.expectedCashPaise, 340000);
      expect(
        rows.firstWhere((r) => r.id == second.id).supersedesClosingId,
        first.id,
      );
      expect((await env.closings.currentClosing(today)).valueOrNull, second);
    });

    test('a saved closing cannot be changed or removed', () async {
      final closing = await close(counted3500);
      for (final sql in [
        'UPDATE daily_closings SET counted_cash_paise = 0 WHERE id = ?',
        'DELETE FROM daily_closings WHERE id = ?',
      ]) {
        await expectLater(env.db.exec(sql, [closing.id]), throwsA(anything));
      }
    });

    test(
      'history shows the current closing of each day, newest first',
      () async {
        final yesterday = today.addDays(-1);
        await close(const CashCount(quantities: {100: 1}), date: yesterday);
        await close(counted3500);
        await close(const CashCount(quantities: {100: 2}), date: yesterday);

        final history = await env.closings.watchHistory(limit: 10).first;
        expect(history.map((c) => (c.businessDate, c.revisionNumber)), [
          (today, 1),
          (yesterday, 2),
        ]);
        expect(history.last.countedCash, rupees(200));
        expect(await env.closings.watchHistory(limit: 1).first, hasLength(1));
      },
    );

    test('closing an earlier day ignores what happened after it', () async {
      final yesterday = today.addDays(-1);
      await adjust(1000); // today
      await spend(200, date: yesterday);

      final closing = await close(const CashCount(), date: yesterday);
      expect(closing.expectedCash, rupees(-200));
    });

    test('a repeated save of one closing adds no second revision', () async {
      await adjust(3500);
      final first = await close(counted3500, operationId: 'close-once');
      final again = await close(counted3500, operationId: 'close-once');
      expect(again.id, first.id);
      expect(await env.count('daily_closings'), 1);
      // A deliberate second closing is a new operation and a new revision.
      final recount = await close(counted3500, operationId: 'close-twice');
      expect(recount.revisionNumber, 2);
      // Each saved closing left one audit row; none holds an amount.
      final logs = await env.db
          .customSelect(
            'SELECT "action", reason FROM audit_logs '
            "WHERE entity_type = 'daily_closing'",
          )
          .get();
      expect(logs, hasLength(2));
      expect(logs.every((l) => l.data['reason'] == null), isTrue);
    });

    test('a future day cannot be closed', () async {
      final result = await env.closeDay(
        CloseDayCommand(
          operationId: 'close-future',
          businessDate: today.addDays(1),
          count: counted3500,
        ),
      );
      expect(
        result.failureOrNull,
        const ValidationFailure({
          CloseDayCommand.dateField: ValidationError.dateInFuture,
        }),
      );
      expect(await env.count('daily_closings'), 0);
    });

    test('a difference is corrected only by an explicit adjustment', () async {
      await adjust(3400);
      final closing = await close(counted3500);
      // The owner decides to record the ₹100 that was found.
      await adjust(
        closing.variance.paise ~/ 100,
        reason: 'Counted difference on 15 Nov',
      );

      expect(await balanceOf(cash), rupees(3500));
      // The earlier snapshot still shows what was true when it was taken.
      expect(
        (await env.closings.currentClosing(today)).valueOrNull!.variance,
        rupees(100),
      );
    });

    test('an uncounted day is not closed', () async {
      expect((await env.closings.currentClosing(today)).valueOrNull, isNull);
      expect(await env.closings.watchHistory(limit: 10).first, isEmpty);
    });
  });
}
