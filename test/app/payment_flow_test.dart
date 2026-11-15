import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../helpers/app_driver.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

/// Phase 3 journeys through the whole app: receive a payment, pay a
/// supplier, advances, split payment, manual allocation, paid-now and
/// returns (journeys 3 and 4, WF-031, WF-032, WF-033).
void main() {
  final en = l10nFor(AppLocales.english);
  final today = BusinessDate(2026, 11, 15);

  late TestEnv env;
  var op = 0;

  setUp(() => env = AppDriver.configure());
  tearDown(getIt.reset);

  Future<String> addParty(
    WidgetTester tester,
    String name, {
    PartyRole role = PartyRole.customer,
  }) async => (await tester.runAsync(
    () => env.addParty(SavePartyCommand(displayName: name, roles: {role})),
  ))!;

  /// Posts a credit (or purchase) through the real use case.
  Future<String> credit(
    WidgetTester tester,
    String partyId,
    int rupees, {
    PartyRole role = PartyRole.customer,
  }) async => (await tester.runAsync(() async {
    env.clock.now = env.clock.now.add(const Duration(minutes: 1));
    final result = await env.recordCharge(
      RecordChargeCommand(
        operationId: 'seed-${op++}',
        role: role,
        partyId: partyId,
        accountId: await env.accountId(partyId, role.code),
        amount: Money.fromPaise(rupees * 100),
        date: today,
      ),
    );
    return result.valueOrNull!.transactionId;
  }))!;

  Future<void> openParty(WidgetTester tester, String name) async {
    await tester.tapAndSettle(inNavBar(en.navParties));
    if (find.text(name).evaluate().isEmpty) {
      await tester.tapAndSettle(find.text(en.partiesTabSuppliers));
    }
    await tester.tapAndSettle(find.text(name));
  }

  Future<void> enterAmount(
    WidgetTester tester,
    String text, {
    int index = 0,
  }) async {
    // Fields are addressed by position, so these tests run on a tall
    // screen where the whole form is built.
    await tester.enterText(find.byType(MoneyAmountField).at(index), text);
    await tester.pumpAndSettle();
  }

  Future<T> db<T>(WidgetTester tester, Future<T> Function() read) async =>
      (await tester.runAsync(read)) as T;

  Future<Map<String, Money>> moneyBalances(WidgetTester tester) => db(
    tester,
    () async => {
      for (final MoneyAccount a in (await env.money.getAccounts()).valueOrNull!)
        a.name: a.balance,
    },
  );

  Future<Money?> openAmount(WidgetTester tester, String transactionId) => db(
    tester,
    () async => (await env.ledger.getTransaction(
      transactionId,
    )).valueOrNull!.openAmount,
  );

  Money rupees(int value) => Money.fromPaise(value * 100);

  testWidgets('receive a part payment: review, save, receipt', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    final first = await credit(tester, ravi, 300);
    final second = await credit(tester, ravi, 500);
    await openParty(tester, 'Ravi Kumar');

    await tester.tapAndSettle(find.text(en.actionReceivePayment));
    expect(find.text(en.receivePaymentTitle), findsWidgets);

    // Nothing is saved without an amount.
    await tester.tapAndSettle(find.text(en.actionSavePayment));
    expect(find.text(en.validationAmountPositive), findsOneWidget);
    expect(await db(tester, () => env.count('money_movements')), 0);

    await enterAmount(tester, '400');
    // Oldest dues first is the default and is said in words.
    await tester.reveal(find.text(en.allocationOldestFirst));
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text('${en.balanceCustomerOwes} ₹800'), findsOneWidget);
    expect(find.text('${en.balanceCustomerOwes} ₹400'), findsOneWidget);
    expect(find.text(en.reviewAdvanceCreated), findsNothing);

    await tester.tapAndSettle(find.text(en.actionSavePayment));
    expect(
      find.text(en.paymentSaved('${en.balanceCustomerOwes} ₹400')),
      findsOneWidget,
    );

    // Ledger and cash book moved together.
    expect(await moneyBalances(tester), {'Cash': rupees(400)});
    expect(await openAmount(tester, first), Money.zero);
    expect(await openAmount(tester, second), rupees(400));

    // The payment's page: receipt number, how it was paid, dues settled.
    await tester.waitForSnackBarToGo();
    await tester.tapAndSettle(find.text(en.txnCustomerPayment));
    await tester.reveal(find.text(en.movementLine(en.methodCash, 'Cash')));
    await tester.reveal(find.text(en.transactionSettled));
    await tester.reveal(find.text('RCP-0001'));
  });

  testWidgets('a payment above the dues is shown as an advance before saving', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    await credit(tester, ravi, 600);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionReceivePayment));

    await enterAmount(tester, '800');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text(en.reviewAdvanceCreated), findsOneWidget);
    expect(find.text('₹200'), findsOneWidget);
    expect(find.text(en.advanceNote), findsOneWidget);
    // The result is named an advance, never an amount owed.
    expect(find.text('${en.balanceCustomerAdvance} ₹200'), findsOneWidget);

    await tester.tapAndSettle(find.text(en.actionSavePayment));
    expect(
      find.text(en.paymentSaved('${en.balanceCustomerAdvance} ₹200')),
      findsOneWidget,
    );
    // The whole ₹800 is in the cash book.
    expect(await moneyBalances(tester), {'Cash': rupees(800)});
    await tester.scrollToTop();
    expect(find.text(en.balanceCustomerAdvance), findsOneWidget);
  });

  testWidgets('UPI needs a bank account, which can be added on the spot', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    await credit(tester, ravi, 500);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionReceivePayment));
    await enterAmount(tester, '500');

    await tester.tapAndSettle(find.text(en.methodUpi));
    // No bank account yet: saving asks for one and posts nothing.
    await tester.tapAndSettle(find.text(en.actionSavePayment));
    expect(find.text(en.validationAccountRequired), findsOneWidget);
    expect(await db(tester, () => env.count('money_movements')), 0);

    await tester.tapAndSettle(find.text(en.actionAddBankAccount).first);
    // An empty name is refused.
    await tester.tapAndSettle(find.text(en.actionAdd));
    expect(find.text(en.validationRequired), findsOneWidget);
    await tester.type(en.accountNameLabel, 'SBI current');
    await tester.tapAndSettle(find.text(en.actionAdd));
    expect(find.text('SBI current'), findsOneWidget);

    await tester.type(en.referenceLabel, 'UTR12345');
    await tester.tapAndSettle(find.text(en.actionSavePayment));

    // The money is in the bank account, not in the cash drawer.
    expect(await moneyBalances(tester), {
      'Cash': Money.zero,
      'SBI current': rupees(500),
    });
  });

  testWidgets('a split payment must add up, then moves through both accounts', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await tester.runAsync(() => env.createMoneyAccount(name: 'SBI'));
    final ravi = await addParty(tester, 'Ravi Kumar');
    await credit(tester, ravi, 1000);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionReceivePayment));
    await enterAmount(tester, '1000');

    await tester.tapAndSettle(find.text(en.actionAddAnotherMethod));
    // Total, then one amount per part: cash ₹600, UPI ₹300 (₹100 short).
    await enterAmount(tester, '600', index: 1);
    await enterAmount(tester, '300', index: 2);
    await tester.tapAndSettle(find.text(en.actionSavePayment));
    expect(find.text(en.validationSplitMismatch), findsOneWidget);
    expect(await db(tester, () => env.count('money_movements')), 0);

    await enterAmount(tester, '400', index: 2);
    await tester.tapAndSettle(find.text(en.actionSavePayment));

    expect(await moneyBalances(tester), {
      'Cash': rupees(600),
      'SBI': rupees(400),
    });
    await tester.scrollToTop();
    expect(find.text(en.balanceSettled), findsOneWidget);
  });

  testWidgets('the owner can choose which dues a payment settles', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    final older = await credit(tester, ravi, 300);
    final newer = await credit(tester, ravi, 500);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionReceivePayment));
    await enterAmount(tester, '400');

    await tester.tapAndSettle(find.text(en.actionChangeAllocation));
    expect(find.text(en.allocationEditorTitle), findsOneWidget);
    final inSheet = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(MoneyAmountField),
    );
    // Oldest first is pre-filled: ₹300 then ₹100.
    expect(find.text(en.allocationApplied('₹400')), findsOneWidget);

    // Move everything to the newer due; a mismatch blocks Done.
    await tester.enterText(inSheet.at(0), '');
    await tester.pumpAndSettle();
    expect(find.text(en.allocationMustMatch('₹400')), findsOneWidget);
    await tester.enterText(inSheet.at(1), '400');
    await tester.pumpAndSettle();
    expect(find.text(en.allocationMustMatch('₹400')), findsNothing);
    await tester.tapAndSettle(find.text(en.actionDone));

    await tester.reveal(find.text(en.allocationManual));
    await tester.tapAndSettle(find.text(en.actionSavePayment));

    expect(await openAmount(tester, older), rupees(300));
    expect(await openAmount(tester, newer), rupees(100));
  });

  testWidgets('pay a supplier from Quick Add', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final abc = await addParty(
      tester,
      'ABC Distributors',
      role: PartyRole.supplier,
    );
    await credit(tester, abc, 2000, role: PartyRole.supplier);

    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddPaySupplier));
    expect(find.text(en.paySupplierTitle), findsOneWidget);
    await tester.tapAndSettle(find.text(en.chooseSupplier));
    await tester.tapAndSettle(find.text('ABC Distributors'));

    await enterAmount(tester, '1000');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text('${en.balanceYouOweSupplier} ₹1,000'), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionSavePayment));

    expect(
      find.text(en.paymentSaved('${en.balanceYouOweSupplier} ₹1,000')),
      findsOneWidget,
    );
    // Money left the cash drawer.
    expect(await moneyBalances(tester), {'Cash': rupees(-1000)});
  });

  testWidgets('a supplier purchase with an amount paid now', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await addParty(tester, 'ABC Distributors', role: PartyRole.supplier);
    await openParty(tester, 'ABC Distributors');
    await tester.tapAndSettle(find.text(en.actionAddPurchase));

    await enterAmount(tester, '2000');
    // Paid now cannot be more than the purchase.
    await enterAmount(tester, '2500', index: 1);
    await tester.tapAndSettle(find.text(en.actionSavePurchase));
    expect(find.text(en.validationPaidNowExceedsTotal), findsOneWidget);
    expect(await db(tester, () => env.count('financial_transactions')), 0);

    await enterAmount(tester, '500', index: 1);
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text(en.reviewPaidNow), findsOneWidget);
    // Payable is the unpaid part.
    expect(find.text('${en.balanceYouOweSupplier} ₹1,500'), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionSavePurchase));

    expect(
      find.text(en.purchaseSaved('${en.balanceYouOweSupplier} ₹1,500')),
      findsOneWidget,
    );
    // A purchase and its linked payment, and the cash that left.
    expect(await db(tester, () => env.count('financial_transactions')), 2);
    expect(await moneyBalances(tester), {'Cash': rupees(-500)});
  });

  testWidgets('a sales return lowers the due and records no money', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    await credit(tester, ravi, 800);
    await openParty(tester, 'Ravi Kumar');

    await tester.tapAndSettle(find.byTooltip(en.moreActionsTooltip));
    await tester.tapAndSettle(find.text(en.salesReturnTitle));
    expect(find.text(en.salesReturnTitle), findsOneWidget);
    // A return has no due date.
    expect(find.text(en.dueDateLabel), findsNothing);

    await enterAmount(tester, '300');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text('${en.balanceCustomerOwes} ₹500'), findsOneWidget);
    expect(find.text(en.returnNoCashNote), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionSaveReturn));

    expect(
      find.text(en.returnSaved('${en.balanceCustomerOwes} ₹500')),
      findsOneWidget,
    );
    expect(await db(tester, () => env.count('money_movements')), 0);
  });

  testWidgets('reversing a payment reopens the due and takes the cash back', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    final ravi = await addParty(tester, 'Ravi Kumar');
    final sale = await credit(tester, ravi, 500);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionReceivePayment));
    await enterAmount(tester, '500');
    await tester.tapAndSettle(find.text(en.actionSavePayment));
    await tester.waitForSnackBarToGo();
    expect(await moneyBalances(tester), {'Cash': rupees(500)});

    await tester.tapAndSettle(find.text(en.txnCustomerPayment));
    await tester.tapAndSettle(find.text(en.actionReverse));
    await tester.type(en.reasonLabel, 'Entered for the wrong customer');
    await tester.reveal(find.text(en.reverseBalanceAfter));
    expect(find.text('${en.balanceCustomerOwes} ₹500'), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionReviewReversal));
    await tester.tapAndSettle(find.text(en.actionConfirmReverse));

    expect(find.text(en.transactionReversedBanner), findsOneWidget);
    expect(await moneyBalances(tester), {'Cash': Money.zero});
    expect(await openAmount(tester, sale), rupees(500));
    // Both movements stay in the cash book.
    expect(await db(tester, () => env.count('money_movements')), 2);
  });
}
