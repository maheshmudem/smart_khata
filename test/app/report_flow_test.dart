import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../helpers/app_driver.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

/// Phase 5 journeys through the whole app: the Home dashboard, dues and
/// aging, the period summary, and a party statement that is shared
/// (WF-010, WF-050 to WF-053).
void main() {
  final en = l10nFor(AppLocales.english);
  final today = BusinessDate(2026, 11, 15);

  late TestEnv env;

  setUp(() => env = AppDriver.configure());
  tearDown(getIt.reset);

  Money rupees(int value) => Money.fromPaise(value * 100);

  /// Ravi owes ₹300 (₹500 credit due 10 Nov, ₹200 paid today); the shop
  /// owes ABC ₹1,000; ₹50 rent was paid today.
  Future<void> seed() async {
    final cash = (await env.money.getAccounts()).valueOrNull!.first.id;
    final ravi = await env.addParty(
      const SavePartyCommand(
        displayName: 'Ravi',
        roles: {PartyRole.customer},
      ),
    );
    final raviAccount = await env.accountId(ravi, 'customer');
    final abc = await env.addParty(
      const SavePartyCommand(
        displayName: 'ABC Traders',
        roles: {PartyRole.supplier},
      ),
    );
    final abcAccount = await env.accountId(abc, 'supplier');

    await env.recordCharge(
      RecordChargeCommand(
        operationId: 'seed-credit',
        role: PartyRole.customer,
        partyId: ravi,
        accountId: raviAccount,
        amount: rupees(500),
        date: BusinessDate(2026, 11, 1),
        dueDate: BusinessDate(2026, 11, 10),
        description: 'Rice',
      ),
    );
    await env.recordPayment(
      RecordPaymentCommand(
        operationId: 'seed-payment',
        role: PartyRole.customer,
        partyId: ravi,
        accountId: raviAccount,
        amount: rupees(200),
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
    await env.recordCharge(
      RecordChargeCommand(
        operationId: 'seed-purchase',
        role: PartyRole.supplier,
        partyId: abc,
        accountId: abcAccount,
        amount: rupees(1000),
        date: today,
      ),
    );
    final rent = (await env.expenses.getCategories()).valueOrNull!
        .firstWhere((c) => c.name == 'Rent')
        .id;
    await env.recordExpense(
      RecordExpenseCommand(
        operationId: 'seed-expense',
        amount: rupees(50),
        categoryId: rent,
        date: today,
        method: PaymentMethod.cash,
        moneyAccountId: cash,
      ),
    );
  }

  testWidgets('Home guides a new shop to add its first party', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true);

    expect(find.text('Test Kirana'), findsOneWidget);
    expect(find.text(en.dashNoBackup), findsOneWidget);
    expect(find.text(en.dashFirstRunTitle), findsOneWidget);
    expect(find.text(en.dashCustomersCount(0)), findsOneWidget);
    expect(find.text(en.partyNoEntries), findsOneWidget);

    await tester.tapAndSettle(
      find.widgetWithText(FilledButton, en.actionAddCustomer),
    );
    expect(find.text(en.partyFormAddTitle), findsOneWidget);
  });

  testWidgets('Home shows dues, today and recent entries', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true, seed: seed);

    expect(find.text(en.dashFirstRunTitle), findsNothing);
    // Dues with the count and what is past its due date.
    expect(find.text('₹300'), findsOneWidget);
    expect(
      find.text('${en.dashCustomersCount(1)} · ${en.dashOverdueCount(1)}'),
      findsOneWidget,
    );
    expect(find.text(en.dashSuppliersCount(1)), findsOneWidget);
    // Today: nothing given on credit, ₹200 collected, ₹50 spent.
    expect(find.text('₹200'), findsWidgets);
    expect(find.text('₹50'), findsWidgets);
    // No advances: their rows are absent rather than zero.
    expect(find.text(en.dashCustomerAdvances), findsNothing);

    await tester.tapAndSettle(find.byTooltip(en.dashInfoTitle));
    expect(find.textContaining(en.dashInfoToday), findsOneWidget);
    await tester.tapAndSettle(find.text(en.actionClose));

    // A recent entry opens its details.
    await tester.tapAndSettle(find.text('ABC Traders'));
    expect(find.text(en.transactionTitle), findsOneWidget);
  });

  testWidgets('from dues to the ledger to a shared statement', (tester) async {
    await tester.pumpSmartKhata(env, tallScreen: true, seed: seed);

    await tester.tapAndSettle(find.text(en.dashCustomerOutstanding));
    expect(find.text(en.outstandingTitle), findsOneWidget);
    expect(find.text(en.outstandingMeasureCustomer), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    // Due 10 Nov: five days old, so all of it is in the first bucket.
    expect(find.text('${en.agingUpTo7}: ₹300'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip(en.actionExportCsv));
    final dues = env.share.shared.single;
    expect(dues.fileName, 'dues-customer-2026-11-15.csv');
    expect(dues.content, contains('Ravi,300.00,300.00,0.00,0.00,0.00'));
    expect(dues.content, isNot(contains('ABC Traders')));

    await tester.tapAndSettle(find.text(en.partiesTabSuppliers));
    expect(find.text('ABC Traders'), findsOneWidget);
    expect(find.text('Ravi'), findsNothing);
    await tester.tapAndSettle(find.text(en.partiesTabCustomers));

    // A row opens that party's ledger; the statement opens from there.
    await tester.tapAndSettle(find.text('Ravi'));
    await tester.tapAndSettle(find.byTooltip(en.statementTitle));
    expect(find.text(en.statementTitle), findsOneWidget);
    expect(find.text('Ravi (${en.roleCustomer})'), findsOneWidget);
    expect(find.text(en.statementClosing), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);

    await tester.tapAndSettle(find.byTooltip(en.actionShareText));
    final text = env.share.shared.last;
    expect(text.isFile, isFalse);
    expect(text.content, contains('Test Kirana'));
    expect(text.content, contains('Ravi (${en.roleCustomer})'));
    expect(text.content, contains('${en.statementClosing}: '));
    expect(text.content, isNot(contains('ABC Traders')));
    // Nothing claims the statement was sent.
    expect(find.byType(SnackBar), findsNothing);

    // This month only: the credit of 1 Nov is inside, nothing is before.
    await tester.tapAndSettle(find.text(en.rangeThisMonth));
    expect(find.text('Rice'), findsOneWidget);

    env.share.fail = true;
    await tester.tapAndSettle(find.byTooltip(en.actionExportCsv));
    expect(find.text(en.shareFailed), findsOneWidget);
    expect(env.share.shared, hasLength(2));
  });

  testWidgets('Reports tab: a period summary with its date filter', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true, seed: seed);

    await tester.tapAndSettle(inNavBar(en.navReports));
    expect(find.text(en.reportsInfoNote), findsOneWidget);

    await tester.tapAndSettle(find.text(en.periodReportTitle));
    expect(find.text(en.periodMeasure), findsOneWidget);
    expect(find.textContaining(en.periodBothIncluded), findsOneWidget);
    // Today: the payment and the expense, by method and by category.
    expect(find.text(en.methodCash), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('₹1,000'), findsOneWidget);

    await tester.tapAndSettle(find.text(en.rangeYesterday));
    expect(find.text('Rent'), findsNothing);
    expect(find.text(en.methodCash), findsNothing);

    // Choosing dates shows the two date fields.
    expect(find.text(en.fromDateLabel), findsNothing);
    await tester.tapAndSettle(find.text(en.rangeCustom));
    expect(find.text(en.fromDateLabel), findsOneWidget);
    expect(find.text(en.toDateLabel), findsOneWidget);

    await tester.tapAndSettle(find.text(en.rangeThisMonth));
    expect(find.text(en.fromDateLabel), findsNothing);
    // The credit of 1 Nov is in this month.
    expect(find.text('₹500'), findsWidgets);
    expect(find.text(en.periodByDay), findsOneWidget);
  });

  testWidgets('Reports tab links open the cash book and closing history', (
    tester,
  ) async {
    await tester.pumpSmartKhata(env, tallScreen: true);
    await tester.tapAndSettle(inNavBar(en.navReports));
    await tester.tapAndSettle(find.text(en.reportsSupplierDues));
    expect(find.text(en.outstandingEmptySuppliers), findsOneWidget);
    await tester.pageBack();
    await tester.settle();

    await tester.tapAndSettle(find.text(en.moreCashBook));
    expect(find.text(en.cashBookTitle), findsOneWidget);
    await tester.pageBack();
    await tester.settle();

    await tester.tapAndSettle(find.text(en.moreClosingHistory));
    expect(find.text(en.closingHistoryTitle), findsOneWidget);
  });
}
