import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/daily_closing/presentation/closing_cubits.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/expenses/presentation/expense_cubits.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/money/presentation/money_cubits.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;
  late String cash;
  late String bank;
  late String rent;
  final today = BusinessDate(2026, 11, 15);

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

  Future<void> addCash(int amount, {String op = 'seed'}) =>
      env.recordAdjustment(
        RecordAdjustmentCommand(
          operationId: op,
          moneyAccountId: cash,
          direction: MovementDirection.inflow,
          amount: rupees(amount),
          reason: 'Opening cash',
        ),
      );

  group('ExpenseFormCubit (WF-042)', () {
    Future<ExpenseFormCubit> build() async {
      final cubit = ExpenseFormCubit(
        expenses: env.expenses,
        moneyAccounts: env.money,
        createMoneyAccount: env.createMoneyAccount,
        recordExpense: env.recordExpense,
        operationId: 'op-expense',
        today: today,
      );
      addTearDown(cubit.close);
      await settle();
      return cubit;
    }

    test(
      'starts with cash from the cash drawer and the active categories',
      () async {
        final cubit = await build();
        expect(cubit.state.method, PaymentMethod.cash);
        expect(cubit.state.moneyAccountId, cash);
        expect(cubit.state.account!.name, 'Cash');
        expect(cubit.state.categories.map((c) => c.name), contains('Rent'));
        expect(cubit.state.isDirty, isFalse);
      },
    );

    test('choosing UPI pays from a bank account', () async {
      final cubit = await build();
      cubit.methodChanged(PaymentMethod.upi);
      expect(cubit.state.moneyAccountId, bank);
    });

    test('a category archived elsewhere stops being the selection', () async {
      final cubit = await build();
      cubit.categoryChanged(rent);

      await env.expenses.setCategoryActive(rent, active: false);
      await settle();

      expect(cubit.state.categoryId, isNull);
      expect(cubit.state.categories.map((c) => c.id), isNot(contains(rent)));
    });

    test('missing fields show errors and post nothing', () async {
      final cubit = await build();
      await cubit.submit();
      expect(cubit.state.errors.keys, {
        RecordExpenseCommand.amountField,
        RecordExpenseCommand.categoryField,
      });
      expect(await env.count('money_movements'), 0);
    });

    test('tapping Save twice posts once', () async {
      final cubit = await build();
      cubit
        ..amountChanged(rupees(300))
        ..categoryChanged(rent);

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(await env.count('expenses'), 1);
    });

    test(
      'a failed save keeps the form; the retry posts exactly once',
      () async {
        final cubit = await build();
        cubit
          ..amountChanged(rupees(300))
          ..categoryChanged(rent)
          ..payeeChanged('Landlord')
          ..noteChanged('November');
        await env.db.exec(
          'CREATE TRIGGER fail_move BEFORE INSERT ON money_movements '
          "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
        );

        await cubit.submit();
        expect(cubit.state.status, SubmissionStatus.failure);
        expect(cubit.state.amount, rupees(300));
        expect(cubit.state.payee, 'Landlord');
        expect(await env.count('expenses'), 0);

        await env.db.exec('DROP TRIGGER fail_move');
        await cubit.submit();
        expect(cubit.state.status, SubmissionStatus.success);
        expect(await env.count('expenses'), 1);
      },
    );

    test('a bank account can be added and used for the expense', () async {
      final cubit = await build();
      cubit.methodChanged(PaymentMethod.bankTransfer);
      await cubit.addMoneyAccount('HDFC');
      expect(cubit.state.account!.name, 'HDFC');
    });
  });

  group('ExpenseCategoriesCubit (WF-043)', () {
    test('lists active then archived, and reports a refused name', () async {
      final cubit = ExpenseCategoriesCubit(
        expenses: env.expenses,
        save: env.saveExpenseCategory,
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);

      expect(await cubit.save('Tea'), isNull);
      expect(
        await cubit.save('rent'),
        const RuleFailure(RuleViolation.categoryNameTaken),
      );
      expect(await cubit.setActive(rent, active: false), isNull);
      await settle();

      expect(cubit.state.categories.last.name, 'Rent');
      expect(cubit.state.categories.last.isActive, isFalse);
      expect(cubit.state.categories.map((c) => c.name), contains('Tea'));
    });
  });

  group('CashBookCubit (WF-040)', () {
    Future<CashBookCubit> build() async {
      final cubit = CashBookCubit(
        accounts: env.money,
        cashBook: env.cashBook,
        today: today,
      );
      addTearDown(cubit.close);
      await settle();
      return cubit;
    }

    test('opens on the cash account for today and stays live', () async {
      final cubit = await build();
      expect(cubit.state.selectedAccount!.name, 'Cash');
      expect(cubit.state.preset, DateRangePreset.today);
      expect(cubit.state.lines, isEmpty);

      await addCash(2000);
      await settle();

      expect(cubit.state.selectedAccount!.balance, rupees(2000));
      expect(cubit.state.summary!.inflows, rupees(2000));
      expect(cubit.state.lines.single.amount, rupees(2000));
    });

    test('switching account or period shows that book', () async {
      await addCash(2000);
      final cubit = await build();

      cubit.accountSelected(bank);
      await settle();
      expect(cubit.state.lines, isEmpty);
      expect(cubit.state.summary!.closingBalance, Money.zero);

      cubit
        ..accountSelected(cash)
        ..presetSelected(DateRangePreset.allTime);
      await settle();
      expect(cubit.state.lines, hasLength(1));
      expect(cubit.state.status, LoadStatus.loaded);
    });

    test('an account turned off elsewhere falls back to cash', () async {
      final cubit = await build();
      cubit.accountSelected(bank);
      await settle();

      await env.cashBook.setAccountActive(bank, active: false);
      await settle();

      expect(cubit.state.selectedAccountId, cash);
      expect(cubit.state.accounts, hasLength(1));
    });
  });

  group('MoneyAccountsCubit (WF-041)', () {
    test('adds with an opening balance and refuses to turn off cash', () async {
      final cubit = MoneyAccountsCubit(
        accounts: env.money,
        cashBook: env.cashBook,
        create: env.createMoneyAccount,
      );
      addTearDown(cubit.close);
      await settle();

      expect(
        await cubit.add(
          name: 'HDFC',
          type: MoneyAccountType.bank,
          openingBalance: rupees(5000),
        ),
        isNull,
      );
      expect(
        await cubit.add(name: ' ', type: MoneyAccountType.bank),
        isA<ValidationFailure>(),
      );
      expect(
        await cubit.deactivate(cash),
        const RuleFailure(RuleViolation.cashAccountRequired),
      );
      expect(await cubit.deactivate(bank), isNull);
      await settle();

      expect(cubit.state.accounts.map((a) => (a.name, a.balance)), [
        ('Cash', Money.zero),
        ('HDFC', rupees(5000)),
      ]);
    });
  });

  group('AdjustmentFormCubit', () {
    AdjustmentFormCubit build({
      MovementDirection direction = MovementDirection.inflow,
      Money? amount,
      String? accountId,
    }) {
      final cubit = AdjustmentFormCubit(
        accounts: env.money,
        record: env.recordAdjustment,
        operationId: 'op-adjust',
        moneyAccountId: accountId,
        direction: direction,
        amount: amount,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('defaults to the cash account and previews the new balance', () async {
      await addCash(1000);
      final cubit = build();
      await settle();

      expect(cubit.state.account!.name, 'Cash');
      expect(cubit.state.newBalance, isNull);
      cubit.amountChanged(rupees(200));
      expect(cubit.state.newBalance, rupees(1200));
      cubit.directionChanged(MovementDirection.outflow);
      expect(cubit.state.newBalance, rupees(800));
    });

    test(
      'opened from a counted shortage it is pre-filled, not posted',
      () async {
        await addCash(1000);
        final cubit = build(
          direction: MovementDirection.outflow,
          amount: rupees(500),
        );
        await settle();

        expect(cubit.state.direction, MovementDirection.outflow);
        expect(cubit.state.amount, rupees(500));
        expect(cubit.state.isDirty, isFalse);
        expect(await env.count('money_movements'), 1);

        // It still needs a reason.
        await cubit.submit();
        expect(cubit.state.errors, {
          RecordAdjustmentCommand.reasonField: ValidationError.required,
        });

        cubit.reasonChanged('Counted difference');
        await Future.wait([cubit.submit(), cubit.submit()]);
        expect(cubit.state.status, SubmissionStatus.success);
        expect(await env.count('money_movements'), 2);
      },
    );

    test('an unknown account in the link falls back to cash', () async {
      final cubit = build(accountId: 'missing');
      await settle();
      expect(cubit.state.moneyAccountId, cash);
    });
  });

  group('DailyCloseCubit (WF-044, WF-045)', () {
    Future<DailyCloseCubit> build() async {
      final cubit = DailyCloseCubit(
        closings: env.closings,
        closeDay: env.closeDay,
        date: today,
      );
      addTearDown(cubit.close);
      await settle();
      return cubit;
    }

    test(
      'loads the expected cash and shows the difference while counting',
      () async {
        await addCash(3400);
        final cubit = await build();

        expect(cubit.state.expectedCash, rupees(3400));
        expect(cubit.state.existing, isNull);
        expect(cubit.state.difference, rupees(-3400));
        expect(cubit.state.isDirty, isFalse);

        for (var i = 0; i < 7; i++) {
          cubit.increment(500);
        }
        expect(cubit.state.countedCash, rupees(3500));
        expect(cubit.state.difference, rupees(100));

        cubit
          ..decrement(500)
          ..quantityChanged(100, 4)
          ..otherAmountChanged(Money.fromPaise(5050));
        expect(cubit.state.countedCash, Money.fromPaise(340000 + 5050));
        expect(cubit.state.isDirty, isTrue);
      },
    );

    test(
      'a quantity cannot go below zero, and reset clears the count',
      () async {
        final cubit = await build();
        cubit
          ..decrement(500)
          ..increment(100);
        expect(cubit.state.count.quantityOf(500), 0);

        cubit.reset();
        expect(cubit.state.count.isEmpty, isTrue);
      },
    );

    test('counting and saving never change the cash book', () async {
      await addCash(3400);
      final cubit = await build();
      cubit.quantityChanged(500, 7);

      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(cubit.state.saved!.variance, rupees(100));
      expect(
        (await env.money.getAccounts()).valueOrNull!.first.balance,
        rupees(3400),
      );
      expect(await env.count('money_movements'), 1);
    });

    test('tapping Save twice stores one closing', () async {
      final cubit = await build();
      cubit.quantityChanged(100, 2);

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(await env.count('daily_closings'), 1);
    });

    test('a day already closed is shown as such', () async {
      final first = await build();
      first.quantityChanged(100, 2);
      await first.submit();

      final second = await build();
      expect(second.state.existing!.countedCash, rupees(200));
      expect(second.state.existing!.revisionNumber, 1);
    });

    test('a failed save keeps the count for another try', () async {
      final cubit = await build();
      cubit
        ..quantityChanged(100, 2)
        ..noteChanged('Evening count');
      await env.db.exec(
        'CREATE TRIGGER fail_close BEFORE INSERT ON daily_closings '
        "BEGIN SELECT RAISE(ABORT, 'forced failure'); END",
      );

      await cubit.submit();
      expect(cubit.state.status, SubmissionStatus.failure);
      expect(cubit.state.count.quantityOf(100), 2);
      expect(cubit.state.note, 'Evening count');

      await env.db.exec('DROP TRIGGER fail_close');
      await cubit.submit();
      expect(cubit.state.status, SubmissionStatus.success);
    });
  });

  group('ClosingHistoryCubit (WF-046)', () {
    test('lists the current closing of each day and stays live', () async {
      final cubit = ClosingHistoryCubit(closings: env.closings);
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.closings, isEmpty);
      expect(cubit.state.hasMore, isFalse);

      final close = DailyCloseCubit(
        closings: env.closings,
        closeDay: env.closeDay,
        date: today,
      );
      addTearDown(close.close);
      await settle();
      close.quantityChanged(100, 2);
      await close.submit();
      await settle();

      expect(cubit.state.closings.single.countedCash, rupees(200));
    });
  });
}
