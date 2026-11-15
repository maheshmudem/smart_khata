import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

import '../helpers/app_driver.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

/// Phase 4 journeys through the whole app: expenses and categories, the
/// cash book, money accounts, adjustments, and counting cash to close the
/// day (journey 5, WF-040 to WF-046).
void main() {
  final en = l10nFor(AppLocales.english);
  final today = BusinessDate(2026, 11, 15);

  late TestEnv env;

  setUp(() => env = AppDriver.configure());
  tearDown(getIt.reset);

  Money rupees(int value) => Money.fromPaise(value * 100);

  Future<T> db<T>(WidgetTester tester, Future<T> Function() read) async =>
      (await tester.runAsync(read)) as T;

  Future<Map<String, Money>> balances(WidgetTester tester) => db(
    tester,
    () async => {
      for (final MoneyAccount a in (await env.money.getAccounts()).valueOrNull!)
        a.name: a.balance,
    },
  );

  /// Puts opening cash in the book through the real use case.
  Future<void> addCash(WidgetTester tester, int amount) => db(
    tester,
    () async {
      final cash = (await env.money.getAccounts()).valueOrNull!.first.id;
      await env.recordAdjustment(
        RecordAdjustmentCommand(
          operationId: 'seed-cash-$amount',
          moneyAccountId: cash,
          direction: MovementDirection.inflow,
          amount: rupees(amount),
          reason: 'Opening cash',
        ),
      );
    },
  );

  Future<void> enterAmount(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(MoneyAmountField).first, text);
    await tester.pumpAndSettle();
  }

  /// The actions menu of the category row named [name].
  Finder actionsOf(String name) => find.descendant(
    of: find.widgetWithText(ListTile, name),
    matching: find.byTooltip(en.categoryActionsTooltip),
  );

  Future<void> openFromMore(WidgetTester tester, String tile) async {
    await tester.tapAndSettle(inNavBar(en.navMore));
    await tester.tapAndSettle(find.text(tile));
  }

  testWidgets('add an expense from Quick Add and find it in the cash book', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddExpense));
    expect(find.text(en.expenseTitle), findsOneWidget);

    // Amount and category are required; nothing is saved without them.
    await tester.tapAndSettle(find.text(en.actionSaveExpense));
    expect(find.text(en.validationAmountPositive), findsOneWidget);
    expect(find.text(en.validationCategoryRequired), findsOneWidget);
    expect(await db(tester, () => env.count('money_movements')), 0);

    await enterAmount(tester, '300');
    await tester.tapAndSettle(find.byType(DropdownButtonFormField<String>));
    await tester.tapAndSettle(find.text('Rent').last);
    await tester.type(en.payeeLabel, 'Landlord');
    // Review says which account the money leaves.
    expect(find.text('₹300'), findsOneWidget);

    await tester.tapAndSettle(find.text(en.actionSaveExpense));
    expect(find.text(en.expenseSaved), findsOneWidget);
    expect(await balances(tester), {'Cash': rupees(-300)});

    await openFromMore(tester, en.moreCashBook);
    expect(find.text(en.movementOut('₹300')), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text(en.cashBookNotIncomeNote), findsOneWidget);

    // The entry page shows the category and who was paid.
    await tester.tapAndSettle(find.text(en.txnExpense));
    expect(find.text(en.transactionTitle), findsOneWidget);
    expect(find.text('Landlord'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
  });

  testWidgets('manage expense categories: add, duplicate, rename, archive', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await openFromMore(tester, en.moreExpenseCategories);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Electricity'), findsOneWidget);

    // Add.
    await tester.tapAndSettle(find.byTooltip(en.actionAddCategory));
    await tester.type(en.categoryNameLabel, 'Tea');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(find.text('Tea'), findsOneWidget);

    // A name already in use is refused, and the dialog stays open.
    await tester.tapAndSettle(find.byTooltip(en.actionAddCategory));
    await tester.type(en.categoryNameLabel, 'rent');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(find.text(en.errorCategoryNameTaken), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionCancel));

    // Rename.
    await tester.tapAndSettle(actionsOf('Tea'));
    await tester.tapAndSettle(find.text(en.actionRename));
    await tester.type(en.categoryNameLabel, 'Tea and snacks');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(find.text('Tea and snacks'), findsOneWidget);
    expect(find.text('Tea'), findsNothing);

    // Archive: it stays in this list, marked in words.
    await tester.tapAndSettle(actionsOf('Tea and snacks'));
    await tester.tapAndSettle(find.text(en.actionArchive));
    expect(find.text(en.categoryArchivedTag), findsOneWidget);

    // … and is no longer offered for a new expense.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddExpense));
    await tester.tapAndSettle(find.byType(DropdownButtonFormField<String>));
    expect(find.text('Tea and snacks'), findsNothing);
    expect(find.text('Rent'), findsWidgets);
  });

  testWidgets('record opening cash as an adjustment with a reason', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await openFromMore(tester, en.moreCashBook);
    expect(find.text(en.cashBookEmpty), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip(en.moreActionsTooltip));
    await tester.tapAndSettle(find.text(en.actionRecordAdjustment));
    expect(find.text(en.adjustmentExplain), findsOneWidget);

    // A reason is required.
    await enterAmount(tester, '2000');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(find.text(en.validationRequired), findsOneWidget);
    expect(await db(tester, () => env.count('money_movements')), 0);

    await tester.type(en.reasonLabel, 'Opening cash');
    await tester.tapAndSettle(find.text(en.actionSave));

    expect(find.text(en.adjustmentSaved), findsOneWidget);
    expect(await balances(tester), {'Cash': rupees(2000)});
    // Back on the cash book, updated by itself.
    expect(find.text(en.movementIn('₹2,000')), findsOneWidget);
    expect(find.text('Opening cash'), findsOneWidget);
    expect(find.text('₹2,000'), findsWidgets);

    // Money taken out.
    await tester.tapAndSettle(find.byTooltip(en.moreActionsTooltip));
    await tester.tapAndSettle(find.text(en.actionRecordAdjustment));
    await tester.tapAndSettle(find.text(en.adjustmentRemove));
    await enterAmount(tester, '500');
    await tester.type(en.reasonLabel, 'Kept at home');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(await balances(tester), {'Cash': rupees(1500)});
  });

  testWidgets('add a bank account with an opening balance, then turn it off', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await openFromMore(tester, en.moreMoneyAccounts);
    expect(find.text('Cash'), findsOneWidget);
    // The cash drawer has no "turn off" menu.
    expect(find.byTooltip(en.accountActionsTooltip), findsNothing);

    await tester.tapAndSettle(find.byTooltip(en.actionAddAccount));
    // A name is required.
    await tester.tapAndSettle(find.text(en.actionAdd));
    expect(find.text(en.validationRequired), findsOneWidget);
    await tester.type(en.accountNameLabel, 'SBI current');
    await tester.enterText(find.byType(MoneyAmountField), '5000');
    await tester.tapAndSettle(find.text(en.actionAdd));

    expect(find.text('SBI current'), findsOneWidget);
    expect(find.text('${en.accountTypeBank} · ₹5,000'), findsOneWidget);
    expect(await balances(tester), {
      'Cash': Money.zero,
      'SBI current': rupees(5000),
    });

    await tester.tapAndSettle(find.byTooltip(en.accountActionsTooltip));
    await tester.tapAndSettle(find.text(en.actionDeactivate));
    expect(
      find.text(en.deactivateConfirmTitle('SBI current')),
      findsOneWidget,
    );
    await tester.tapAndSettle(
      find.widgetWithText(FilledButton, en.actionDeactivate),
    );
    expect(find.text(en.accountDeactivated), findsOneWidget);
    expect(find.text('SBI current'), findsNothing);
  });

  testWidgets('count cash, close the day, then record the difference', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await addCash(tester, 3400);

    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddCashCount));
    expect(find.text(en.cashCountTitle), findsOneWidget);
    expect(find.text(en.differenceShort('₹3,400')), findsOneWidget);

    // Seven ₹500 notes = ₹3,500.
    for (var i = 0; i < 7; i++) {
      await tester.tap(find.byTooltip(en.increaseTooltip).first);
    }
    await tester.pumpAndSettle();
    expect(find.text('₹3,500'), findsWidgets);
    expect(find.text(en.differenceExtra('₹100')), findsOneWidget);
    expect(find.text(en.closingNoAdjustNote), findsOneWidget);
    // Counting has not touched the book.
    expect(await balances(tester), {'Cash': rupees(3400)});

    await tester.tapAndSettle(find.text(en.actionSaveClosing));

    // Saved; the book is still untouched, and an adjustment is offered.
    expect(await db(tester, () => env.count('daily_closings')), 1);
    expect(await balances(tester), {'Cash': rupees(3400)});
    expect(find.text(en.differenceExtra('₹100')), findsWidgets);
    await tester.tapAndSettle(find.text(en.actionRecordAdjustment));

    // The adjustment form is pre-filled but still needs a reason.
    expect(find.text(en.adjustmentExplain), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(find.text(en.validationRequired), findsOneWidget);
    expect(await balances(tester), {'Cash': rupees(3400)});

    await tester.type(en.reasonLabel, 'Found a note while counting');
    await tester.tapAndSettle(find.text(en.actionSave));
    expect(await balances(tester), {'Cash': rupees(3500)});

    // History keeps the snapshot as it was when the day was closed.
    await openFromMore(tester, en.moreClosingHistory);
    expect(find.text(en.differenceExtra('₹100')), findsOneWidget);
    final closing = await db(
      tester,
      () async => (await env.closings.currentClosing(today)).valueOrNull!,
    );
    expect(closing.expectedCash, rupees(3400));
    expect(closing.countedCash, rupees(3500));
    expect(closing.count, const CashCount(quantities: {500: 7}));
  });

  testWidgets(
    'a matching count closes the day; closing again adds a revision',
    (
      tester,
    ) async {
      await tester.pumpSmartKhata(env, tallScreen: true);
      await addCash(tester, 1000);

      Future<void> countAndSave(int fiveHundreds) async {
        await tester.tapAndSettle(inNavBar(en.navQuickAdd));
        await tester.tapAndSettle(find.text(en.quickAddCashCount));
        for (var i = 0; i < fiveHundreds; i++) {
          await tester.tap(find.byTooltip(en.increaseTooltip).first);
        }
        await tester.pumpAndSettle();
        await tester.tapAndSettle(find.text(en.actionSaveClosing));
      }

      await countAndSave(2);
      // No difference: no adjustment is offered.
      expect(find.text(en.closingSaved), findsOneWidget);
      expect(find.text(en.actionRecordAdjustment), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Opening the count again says the day is already closed.
      await tester.tapAndSettle(inNavBar(en.navQuickAdd));
      await tester.tapAndSettle(find.text(en.quickAddCashCount));
      expect(find.text(en.closingAlreadyClosed), findsOneWidget);
      await tester.tap(find.byTooltip(en.increaseTooltip).first);
      await tester.pumpAndSettle();

      // Clearing the count asks first.
      await tester.tapAndSettle(find.text(en.actionResetCount));
      expect(find.text(en.resetCountTitle), findsOneWidget);
      await tester.tapAndSettle(
        find.widgetWithText(FilledButton, en.actionResetCount),
      );
      expect(find.text(en.differenceShort('₹1,000')), findsOneWidget);

      await tester.tap(find.byTooltip(en.increaseTooltip).first);
      await tester.pumpAndSettle();
      await tester.tapAndSettle(find.text(en.actionSaveClosing));
      // ₹500 short: decline the adjustment.
      await tester.tapAndSettle(find.text(en.actionClose));

      expect(await db(tester, () => env.count('daily_closings')), 2);
      await openFromMore(tester, en.moreClosingHistory);
      // One row for the day: its latest closing, marked as a revision.
      expect(find.text(en.differenceShort('₹500')), findsOneWidget);
      expect(find.text(en.closingRevision(2)), findsOneWidget);
      expect(find.text(en.differenceNone), findsNothing);
    },
  );

  testWidgets('the cash book switches account and period', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await addCash(tester, 2000);
    await tester.runAsync(
      () => env.createMoneyAccount(name: 'SBI', openingBalance: rupees(700)),
    );

    await openFromMore(tester, en.moreCashBook);
    expect(find.text(en.movementIn('₹2,000')), findsOneWidget);

    await tester.tapAndSettle(find.widgetWithText(ChoiceChip, 'SBI'));
    expect(find.text(en.cashBookEmpty), findsOneWidget);
    // The opening balance is the balance before the period.
    expect(find.text('₹700'), findsWidgets);

    await tester.tapAndSettle(find.widgetWithText(ChoiceChip, 'Cash'));
    await tester.tapAndSettle(
      find.widgetWithText(ChoiceChip, en.rangeAllTime),
    );
    expect(find.text(en.movementIn('₹2,000')), findsOneWidget);
  });
}
