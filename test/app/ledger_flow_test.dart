import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../helpers/app_driver.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

/// Phase 2 journeys through the whole app: give credit, supplier purchase,
/// the running ledger, entry details and reversal (journey 2, WF-030,
/// WF-032, WF-023, WF-034, WF-035).
void main() {
  final en = l10nFor(AppLocales.english);

  late TestEnv env;

  setUp(() => env = AppDriver.configure());
  tearDown(getIt.reset);

  Future<String> addParty(
    WidgetTester tester,
    String name, {
    PartyRole role = PartyRole.customer,
    int? creditLimitRupees,
  }) async => (await tester.runAsync(
    () => env.addParty(
      SavePartyCommand(
        displayName: name,
        roles: {role},
        creditLimit: creditLimitRupees == null
            ? null
            : Money.fromPaise(creditLimitRupees * 100),
      ),
    ),
  ))!;

  Future<void> openParty(WidgetTester tester, String name) async {
    await tester.tapAndSettle(inNavBar(en.navParties));
    await tester.tapAndSettle(find.text(name));
  }

  Future<void> enterAmount(WidgetTester tester, String text) async {
    await tester.reveal(find.byType(MoneyAmountField));
    await tester.enterText(find.byType(MoneyAmountField), text);
    await tester.pumpAndSettle();
  }

  Future<int> count(WidgetTester tester, String table) async =>
      (await tester.runAsync(() => env.count(table)))!;

  testWidgets('give credit from the party page, then see it in the ledger', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    await addParty(tester, 'Ravi Kumar');
    await openParty(tester, 'Ravi Kumar');

    await tester.tapAndSettle(find.text(en.actionGiveCredit));
    expect(find.text(en.giveCreditTitle), findsOneWidget);
    // The customer is already chosen when coming from their page.
    expect(find.text('Ravi Kumar'), findsOneWidget);

    // Saving without an amount is refused and posts nothing.
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    expect(find.text(en.validationAmountPositive), findsOneWidget);
    expect(await count(tester, 'financial_transactions'), 0);

    await enterAmount(tester, '500');
    await tester.type(en.descriptionLabel, 'Grocery items');
    // Review: current balance, the credit, and the new balance in words.
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text(en.balanceSettled), findsOneWidget);
    expect(find.text('${en.balanceCustomerOwes} ₹500'), findsOneWidget);
    expect(find.text(en.chargeNoCashNote), findsOneWidget);

    await tester.tapAndSettle(find.text(en.actionSaveCredit));

    // Back on the party page with the committed balance.
    expect(
      find.text(en.creditSaved('${en.balanceCustomerOwes} ₹500')),
      findsOneWidget,
    );
    expect(find.text(en.balanceCustomerOwes), findsOneWidget);
    expect(await count(tester, 'financial_transactions'), 1);
    expect(await count(tester, 'money_movements'), 0);

    // A second credit straight away: the "saved" message from the first
    // must not cover this form's Save button.
    await tester.tapAndSettle(find.text(en.actionGiveCredit));
    expect(find.byType(SnackBar), findsNothing);
    await enterAmount(tester, '1300.50');
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    await tester.tapAndSettle(find.text(en.actionViewLedger));

    expect(find.text('₹1,800.50'), findsOneWidget); // header balance
    expect(find.text('${en.balanceCustomerOwes} ₹1,800.50'), findsOneWidget);
    expect(find.text('${en.balanceCustomerOwes} ₹500'), findsOneWidget);
    expect(find.text('Grocery items'), findsOneWidget);
    expect(find.text(en.txnCustomerCredit), findsNWidgets(2));
  });

  testWidgets('reverse a wrong entry: reason, confirmation, both lines stay', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    await addParty(tester, 'Ravi Kumar');
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionGiveCredit));
    await enterAmount(tester, '500');
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    await tester.waitForSnackBarToGo();

    // Open the entry from the party page.
    await tester.tapAndSettle(find.text(en.txnCustomerCredit));
    expect(find.text(en.transactionTitle), findsOneWidget);
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.text('${en.balanceCustomerOwes} ₹500'), findsOneWidget);
    // Reversal is offered; edit and delete are not.
    expect(find.text(en.actionEdit), findsNothing);

    await tester.tapAndSettle(find.text(en.actionReverse));
    expect(find.text(en.reverseExplain), findsOneWidget);
    expect(find.text(en.balanceSettled), findsOneWidget); // balance after

    // A reason is required before the confirmation is even asked.
    await tester.tapAndSettle(find.text(en.actionReviewReversal));
    expect(find.text(en.validationRequired), findsOneWidget);
    expect(find.text(en.reverseConfirmTitle), findsNothing);

    await tester.type(en.reasonLabel, 'Wrong amount');
    await tester.tapAndSettle(find.text(en.actionReviewReversal));
    expect(find.text(en.reverseConfirmTitle), findsOneWidget);

    // Cancelling the confirmation reverses nothing.
    await tester.tapAndSettle(find.text(en.actionCancel));
    expect(await count(tester, 'financial_transactions'), 1);

    await tester.tapAndSettle(find.text(en.actionReviewReversal));
    await tester.tapAndSettle(find.text(en.actionConfirmReverse));

    // Back on the entry: marked reversed, with the reason, no second
    // reversal offered, and a link to the reversing entry.
    expect(find.text(en.reversalSaved(en.balanceSettled)), findsOneWidget);
    expect(find.text(en.transactionReversedBanner), findsOneWidget);
    expect(find.text('Wrong amount'), findsOneWidget);
    expect(find.text(en.actionReverse), findsNothing);
    expect(await count(tester, 'financial_transactions'), 2);

    await tester.waitForSnackBarToGo();
    await tester.tapAndSettle(find.text(en.actionViewReversal));
    expect(find.text(en.transactionIsReversalBanner), findsOneWidget);
    expect(find.text(en.txnReversal), findsOneWidget);
    expect(find.text(en.actionReverse), findsNothing);

    // The party is settled; the ledger keeps both lines.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(en.balanceSettled), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionViewLedger));
    expect(find.text(en.txnCustomerCredit), findsOneWidget);
    expect(find.text(en.txnReversal), findsOneWidget);
    expect(find.text(en.ledgerReversedTag), findsOneWidget);
  });

  testWidgets('Quick Add: choose a customer, or create one without leaving', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddGiveCredit));

    // No customer yet: saving asks for one.
    expect(find.text(en.chooseCustomer), findsOneWidget);
    await enterAmount(tester, '250');
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    expect(find.text(en.validationPartyRequired), findsOneWidget);

    // Create the customer from inside the picker.
    await tester.tapAndSettle(find.text(en.chooseCustomer));
    expect(find.text(en.partiesEmptyCustomersTitle), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionAddNewCustomer).first);
    await tester.type(en.partyNameLabel, 'Suresh');
    await tester.tapAndSettle(find.text(en.actionSave));

    // Straight back on the credit form with the new customer chosen and
    // the amount still there.
    expect(find.text(en.giveCreditTitle), findsOneWidget);
    expect(find.text('Suresh'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text(en.validationPartyRequired), findsNothing);

    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    expect(
      find.text(en.creditSaved('${en.balanceCustomerOwes} ₹250')),
      findsOneWidget,
    );
    expect(await count(tester, 'party_ledger_entries'), 1);
  });

  testWidgets('Quick Add: supplier purchase with an existing supplier', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    await addParty(tester, 'ABC Distributors', role: PartyRole.supplier);
    await addParty(tester, 'Ravi Kumar');

    await tester.tapAndSettle(inNavBar(en.navQuickAdd));
    await tester.tapAndSettle(find.text(en.quickAddSupplierPurchase));
    expect(find.text(en.addPurchaseTitle), findsOneWidget);

    // The picker lists suppliers only.
    await tester.tapAndSettle(find.text(en.chooseSupplier));
    expect(find.text('ABC Distributors'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsNothing);
    await tester.tapAndSettle(find.text('ABC Distributors'));

    await enterAmount(tester, '2000');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text('${en.balanceYouOweSupplier} ₹2,000'), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionSavePurchase));

    expect(
      find.text(en.purchaseSaved('${en.balanceYouOweSupplier} ₹2,000')),
      findsOneWidget,
    );
    expect(await count(tester, 'money_movements'), 0);
  });

  testWidgets('crossing the credit limit warns and needs a clear choice', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    await addParty(tester, 'Ravi Kumar', creditLimitRupees: 1000);
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionGiveCredit));

    // Within the limit: no warning.
    await enterAmount(tester, '1000');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text(en.creditLimitWarning('₹1,000')), findsNothing);

    await enterAmount(tester, '1500');
    await tester.reveal(find.text(en.reviewNewBalance));
    expect(find.text(en.creditLimitWarning('₹1,000')), findsOneWidget);

    // Go back: nothing is posted and the form keeps its values.
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    expect(find.text(en.creditLimitConfirmTitle), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionGoBack));
    expect(await count(tester, 'financial_transactions'), 0);
    expect(find.text('1500'), findsOneWidget);

    // Save anyway: it is a warning, not a block.
    await tester.tapAndSettle(find.text(en.actionSaveCredit));
    await tester.tapAndSettle(find.text(en.actionSaveAnyway));
    expect(await count(tester, 'financial_transactions'), 1);
    expect(
      find.text(en.creditSaved('${en.balanceCustomerOwes} ₹1,500')),
      findsOneWidget,
    );
  });

  testWidgets('leaving a started entry asks before discarding', (tester) async {
    await tester.pumpSmartKhata(env);
    await addParty(tester, 'Ravi Kumar');
    await openParty(tester, 'Ravi Kumar');
    await tester.tapAndSettle(find.text(en.actionGiveCredit));
    await enterAmount(tester, '500');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text(en.discardTitle), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionKeepEditing));
    expect(find.text('500'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tapAndSettle(find.text(en.actionDiscard));
    expect(find.byType(MoneyAmountField), findsNothing);
    expect(await count(tester, 'financial_transactions'), 0);
  });

  testWidgets('an archived party offers no new entries but keeps its ledger', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env);
    final id = await addParty(tester, 'Ravi Kumar');
    await tester.runAsync(() => env.parties.setArchived(id, archived: true));

    await tester.tapAndSettle(inNavBar(en.navParties));
    await tester.tapAndSettle(find.text(en.filterArchived));
    await tester.tapAndSettle(find.text('Ravi Kumar'));

    expect(find.text(en.actionGiveCredit), findsNothing);
    expect(find.text(en.actionViewLedger), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
