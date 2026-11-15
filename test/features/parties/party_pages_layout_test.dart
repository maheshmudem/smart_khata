import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/backup/domain/backup.dart';
import 'package:smart_khata/features/backup/presentation/backup_cubits.dart';
import 'package:smart_khata/features/backup/presentation/backup_pages.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';
import 'package:smart_khata/features/daily_closing/presentation/closing_cubits.dart';
import 'package:smart_khata/features/daily_closing/presentation/closing_pages.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/expenses/presentation/expense_cubits.dart';
import 'package:smart_khata/features/expenses/presentation/expense_pages.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/charge_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/payment_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/pages/charge_form_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/ledger_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/payment_form_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/reverse_transaction_page.dart';
import 'package:smart_khata/features/ledger/presentation/pages/transaction_detail_page.dart';
import 'package:smart_khata/features/ledger/presentation/widgets/allocation_editor.dart';
import 'package:smart_khata/features/money/presentation/money_cubits.dart';
import 'package:smart_khata/features/money/presentation/money_pages.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/shop_setup_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/setup_complete_page.dart';
import 'package:smart_khata/features/onboarding/presentation/pages/shop_setup_page.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/presentation/cubit/opening_balance_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_form_cubit.dart';
import 'package:smart_khata/features/parties/presentation/pages/opening_balance_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/parties_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_detail_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_form_page.dart';
import 'package:smart_khata/features/parties/presentation/pages/party_picker_page.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/reminders/presentation/reminders_cubit.dart';
import 'package:smart_khata/features/reminders/presentation/reminders_page.dart';
import 'package:smart_khata/features/reports/presentation/dashboard_page.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';
import 'package:smart_khata/features/reports/presentation/reports_pages.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/security/presentation/app_lock_cubit.dart';
import 'package:smart_khata/features/security/presentation/lock_screen.dart';
import 'package:smart_khata/features/security/presentation/security_settings_page.dart';
import 'package:smart_khata/features/settings/presentation/pages/help_page.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_env.dart';

/// Every screen built so far is pumped in English and Telugu at twice the normal
/// text size on a 320dp-wide phone. A layout overflow or a build error is
/// reported as a test exception, so "no exception" is the assertion
/// (PRD 10.4, SK-1204).
void main() {
  late TestEnv env;
  late String partyId;
  late String customerAccountId;
  late String paymentId;

  // A long name with a phone and both roles: the widest realistic content.
  const longName = 'శ్రీ వెంకటేశ్వర జనరల్ స్టోర్స్ అండ్ కిరాణా మర్చంట్స్';

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      await env.setUpShop();
      partyId = await env.addParty(
        SavePartyCommand(
          displayName: longName,
          primaryPhone: '+91 98765 43210',
          roles: const {PartyRole.customer, PartyRole.supplier},
          creditLimit: Money.fromPaise(12500000),
          notes: 'నెలవారీ ఖాతా',
        ),
      );
      customerAccountId = await env.accountId(partyId, 'customer');
      await env.postEntry(
        id: 'e1',
        accountId: customerAccountId,
        signed: Money.fromPaise(9999999999),
      );
      // An overdue credit with a due date, shared and with a reminder
      // set: every line of the reminders row.
      await env.recordCharge(
        RecordChargeCommand(
          operationId: 'op-due-seed',
          role: PartyRole.customer,
          partyId: partyId,
          accountId: customerAccountId,
          amount: Money.fromPaise(9999999900),
          date: BusinessDate(2026, 11, 1),
          dueDate: BusinessDate(2026, 11, 5),
        ),
      );
      await env.reminders.recordShareOpened(
        partyId: partyId,
        role: PartyRole.customer,
      );
      await env.reminders.schedule(
        partyId: partyId,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 20),
        texts: const ReminderTexts(
          title: 'Smart Khata',
          body: 'Reminder',
          channelName: 'Reminders',
        ),
      );
      await env.addParty(
        const SavePartyCommand(
          displayName: 'Ravi',
          roles: {PartyRole.customer},
        ),
      );
      // A second entry with a long description, then reversed, so the
      // ledger shows a due date, a "Reversed" tag and a reversal line.
      await env.postEntry(
        id: 'e2',
        accountId: customerAccountId,
        signed: Money.fromPaise(125000),
      );
      await env.reverseTransaction(
        const ReverseTransactionCommand(
          operationId: 'op-rev-seed',
          transactionId: 'txn-e2',
          reason: 'తప్పు మొత్తం నమోదు చేశాను, సరిచేయడానికి రద్దు',
        ),
      );
      // A bank account with a long name, and a split payment with a
      // reference, for the payment form and the payment's page.
      final bank = (await env.createMoneyAccount(
        name: 'స్టేట్ బ్యాంక్ ఆఫ్ ఇండియా కరెంట్ ఖాతా',
      )).valueOrNull!;
      final cash = (await env.money.getAccounts()).valueOrNull!.first.id;
      paymentId = (await env.recordPayment(
        RecordPaymentCommand(
          operationId: 'op-pay-seed',
          role: PartyRole.customer,
          partyId: partyId,
          accountId: customerAccountId,
          amount: Money.fromPaise(250000),
          date: BusinessDate(2026, 11, 15),
          splits: [
            PaymentSplit(
              method: PaymentMethod.cash,
              moneyAccountId: cash,
              amount: Money.fromPaise(100000),
            ),
            PaymentSplit(
              method: PaymentMethod.upi,
              moneyAccountId: bank,
              amount: Money.fromPaise(150000),
              reference: 'UTR1234567890123456',
            ),
          ],
        ),
      )).valueOrNull!.transactionId;
      // An expense with a long category name and payee, an archived
      // category, and a revised closing with a note and a difference.
      await env.saveExpenseCategory(
        name: 'దుకాణం నిర్వహణ మరియు మరమ్మతుల ఖర్చులు',
      );
      final categories = (await env.expenses.getCategories()).valueOrNull!;
      await env.recordExpense(
        RecordExpenseCommand(
          operationId: 'op-expense-seed',
          amount: Money.fromPaise(9999999900),
          categoryId: categories.first.id,
          date: BusinessDate(2026, 11, 15),
          method: PaymentMethod.cash,
          moneyAccountId: cash,
          payee: 'శ్రీ వెంకటేశ్వర ఎలక్ట్రికల్ సర్వీసెస్',
        ),
      );
      await env.expenses.setCategoryActive(categories.last.id, active: false);
      for (final quantity in [3, 99999]) {
        await env.closeDay(
          CloseDayCommand(
            businessDate: BusinessDate(2026, 11, 15),
            count: CashCount(quantities: {500: quantity}),
            note: 'సాయంత్రం లెక్క, ఒక నోటు తక్కువగా ఉంది',
          ),
        );
      }
    });
  }

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  final pages = <String, Widget Function()>{
    'shop setup': () => BlocProvider(
      create: (_) =>
          ShopSetupCubit(createShop: env.createShop, shops: env.shops),
      child: const ShopSetupPage(),
    ),
    'setup complete': () => BlocProvider(
      create: (_) => OnboardingCubit(
        settings: InMemorySettingsRepository(),
        isComplete: false,
      ),
      child: const SetupCompletePage(),
    ),
    'parties list': () => BlocProvider(
      create: (_) => PartiesListCubit(repository: env.parties),
      child: const PartiesPage(),
    ),
    'add party': () => BlocProvider(
      create: (_) => PartyFormCubit(
        repository: env.parties,
        saveParty: env.saveParty,
        findDuplicates: env.findDuplicates,
      ),
      child: const PartyFormPage(),
    ),
    'edit party': () => BlocProvider(
      create: (_) => PartyFormCubit(
        repository: env.parties,
        saveParty: env.saveParty,
        findDuplicates: env.findDuplicates,
        partyId: partyId,
      ),
      child: const PartyFormPage(),
    ),
    'party detail': () => BlocProvider(
      create: (_) =>
          PartyDetailCubit(repository: env.parties, partyId: partyId),
      child: const PartyDetailPage(),
    ),
    'opening balance': () => BlocProvider(
      create: (_) => OpeningBalanceCubit(
        repository: env.parties,
        recordOpeningBalance: env.recordOpeningBalance,
        partyId: partyId,
        accountId: customerAccountId,
        operationId: 'op-layout',
        today: BusinessDate(2026, 11, 15),
      ),
      child: OpeningBalancePage(today: BusinessDate(2026, 11, 15)),
    ),
    'give credit': () => BlocProvider(
      create: (_) => ChargeFormCubit(
        parties: env.parties,
        moneyAccounts: env.money,
        createMoneyAccount: env.createMoneyAccount,
        recordCharge: env.recordCharge,
        recordReturn: env.recordReturn,
        role: PartyRole.customer,
        operationId: 'op-charge-layout',
        today: BusinessDate(2026, 11, 15),
        partyId: partyId,
      )..amountChanged(Money.fromPaise(9999999900)),
      child: ChargeFormPage(today: BusinessDate(2026, 11, 15)),
    ),
    'supplier purchase with paid now': () => BlocProvider(
      create: (_) =>
          ChargeFormCubit(
              parties: env.parties,
              moneyAccounts: env.money,
              createMoneyAccount: env.createMoneyAccount,
              recordCharge: env.recordCharge,
              recordReturn: env.recordReturn,
              role: PartyRole.supplier,
              operationId: 'op-purchase-layout',
              today: BusinessDate(2026, 11, 15),
              partyId: partyId,
            )
            ..amountChanged(Money.fromPaise(9999999900))
            ..paidNowAmountChanged(Money.fromPaise(125000))
            ..paidNowMethodChanged(PaymentMethod.upi),
      child: ChargeFormPage(today: BusinessDate(2026, 11, 15)),
    ),
    'sales return': () => BlocProvider(
      create: (_) => ChargeFormCubit(
        parties: env.parties,
        moneyAccounts: env.money,
        createMoneyAccount: env.createMoneyAccount,
        recordCharge: env.recordCharge,
        recordReturn: env.recordReturn,
        role: PartyRole.customer,
        kind: EntryFormKind.returned,
        operationId: 'op-return-layout',
        today: BusinessDate(2026, 11, 15),
        partyId: partyId,
      )..amountChanged(Money.fromPaise(125000)),
      child: ChargeFormPage(today: BusinessDate(2026, 11, 15)),
    ),
    // A split UPI payment larger than the dues: every optional part of the
    // form is showing at once.
    'receive payment': () => BlocProvider(
      create: (_) =>
          PaymentFormCubit(
              parties: env.parties,
              ledger: env.ledger,
              moneyAccounts: env.money,
              createMoneyAccount: env.createMoneyAccount,
              recordPayment: env.recordPayment,
              role: PartyRole.customer,
              operationId: 'op-payment-layout',
              today: BusinessDate(2026, 11, 15),
              partyId: partyId,
            )
            ..amountChanged(Money.fromPaise(9999999900))
            ..addSplit()
            ..splitAmountChanged(0, Money.fromPaise(9999999900)),
      child: PaymentFormPage(today: BusinessDate(2026, 11, 15)),
    ),
    'payment details': () => BlocProvider(
      create: (_) => TransactionDetailCubit(
        ledger: env.ledger,
        transactionId: paymentId,
      ),
      child: const TransactionDetailPage(),
    ),
    'expense form': () => BlocProvider(
      create: (_) =>
          ExpenseFormCubit(
              expenses: env.expenses,
              moneyAccounts: env.money,
              createMoneyAccount: env.createMoneyAccount,
              recordExpense: env.recordExpense,
              operationId: 'op-expense-layout',
              today: BusinessDate(2026, 11, 15),
            )
            ..amountChanged(Money.fromPaise(9999999900))
            ..methodChanged(PaymentMethod.upi),
      child: ExpenseFormPage(today: BusinessDate(2026, 11, 15)),
    ),
    'expense categories': () => BlocProvider(
      create: (_) => ExpenseCategoriesCubit(
        expenses: env.expenses,
        save: env.saveExpenseCategory,
      ),
      child: const ExpenseCategoriesPage(),
    ),
    'cash book': () => BlocProvider(
      create: (_) => CashBookCubit(
        accounts: env.money,
        cashBook: env.cashBook,
        today: BusinessDate(2026, 11, 15),
      ),
      child: const CashBookPage(),
    ),
    'money accounts': () => BlocProvider(
      create: (_) => MoneyAccountsCubit(
        accounts: env.money,
        cashBook: env.cashBook,
        create: env.createMoneyAccount,
      ),
      child: const MoneyAccountsPage(),
    ),
    'add or remove money': () => BlocProvider(
      create: (_) => AdjustmentFormCubit(
        accounts: env.money,
        record: env.recordAdjustment,
        operationId: 'op-adjust-layout',
        direction: MovementDirection.outflow,
        amount: Money.fromPaise(9999999900),
      ),
      child: const AdjustmentFormPage(),
    ),
    'count cash': () => BlocProvider(
      create: (_) => DailyCloseCubit(
        closings: env.closings,
        closeDay: env.closeDay,
        date: BusinessDate(2026, 11, 15),
      )..quantityChanged(500, 99999),
      child: const DailyClosePage(),
    ),
    'closing history': () => BlocProvider(
      create: (_) => ClosingHistoryCubit(closings: env.closings),
      child: const ClosingHistoryPage(),
    ),
    'party picker': () => BlocProvider(
      create: (_) => PartiesListCubit(repository: env.parties),
      child: const PartyPickerPage(role: PartyRole.customer),
    ),
    'ledger': () => BlocProvider(
      create: (_) => LedgerCubit(
        ledger: env.ledger,
        parties: env.parties,
        partyId: partyId,
        accountId: customerAccountId,
      ),
      child: const LedgerPage(),
    ),
    'entry details': () => BlocProvider(
      create: (_) => TransactionDetailCubit(
        ledger: env.ledger,
        transactionId: 'txn-e1',
      ),
      child: const TransactionDetailPage(),
    ),
    'reversed entry details': () => BlocProvider(
      create: (_) => TransactionDetailCubit(
        ledger: env.ledger,
        transactionId: 'txn-e2',
      ),
      child: const TransactionDetailPage(),
    ),
    'dashboard': () => BlocProvider(
      create: (_) => DashboardCubit(
        reports: env.reports,
        shops: env.shops,
        today: () => BusinessDate(2026, 11, 15),
      ),
      child: const DashboardPage(),
    ),
    'reports home': () => const ReportsHomePage(),
    'dues and aging': () => BlocProvider(
      create: (_) => OutstandingCubit(
        reports: env.reports,
        shareService: env.share,
        shareLogger: env.logger,
        today: BusinessDate(2026, 11, 15),
        role: PartyRole.customer,
      ),
      child: const OutstandingPage(),
    ),
    'period summary with chosen dates': () => BlocProvider(
      create: (_) =>
          PeriodReportCubit(
            reports: env.reports,
            today: BusinessDate(2026, 11, 15),
          )..periodSelected(
            PeriodSelection.custom(
              DateRange(
                start: BusinessDate(2026, 10, 1),
                end: BusinessDate(2026, 11, 15),
              ),
            ),
          ),
      child: const PeriodReportPage(),
    ),
    'statement': () => BlocProvider(
      create: (_) => StatementCubit(
        reports: env.reports,
        shops: env.shops,
        shareService: env.share,
        shareLogger: env.logger,
        accountId: customerAccountId,
        today: BusinessDate(2026, 11, 15),
      ),
      child: const StatementPage(),
    ),
    'lock screen after a wrong PIN': () => BlocProvider(
      create: (_) =>
          AppLockCubit(
            repository: env.appLock,
            biometrics: env.biometrics..available = true,
            clock: env.clock,
          )..emit(
            const AppLockState(
              phase: LockPhase.locked,
              config: AppLockConfig(
                enabled: true,
                biometricsEnabled: true,
                timeout: AutoLockTimeout.immediately,
              ),
              biometricsAvailable: true,
              attemptsLeft: 1,
            ),
          ),
      child: const LockScreen(),
    ),
    'app lock settings, lock on': () => BlocProvider(
      create: (_) =>
          AppLockCubit(
            repository: env.appLock,
            biometrics: env.biometrics,
            clock: env.clock,
          )..emit(
            const AppLockState(
              phase: LockPhase.unlocked,
              config: AppLockConfig(
                enabled: true,
                biometricsEnabled: false,
                timeout: AutoLockTimeout.fiveMinutes,
              ),
            ),
          ),
      child: const SecuritySettingsPage(),
    ),
    'backup home': () => BlocProvider(
      create: (_) => BackupStatusCubit(repository: env.fakeBackup),
      child: const BackupHomePage(),
    ),
    'create backup with errors': () => BlocProvider(
      create: (_) =>
          CreateBackupCubit(
            export: ExportBackup(env.fakeBackup, env.backupFiles),
          )..emit(
            const CreateBackupState(
              status: SubmissionStatus.failure,
              errors: {
                ExportBackup.passphraseField:
                    ValidationError.passphraseTooShort,
                ExportBackup.confirmationField: ValidationError.doesNotMatch,
              },
              failure: BackupFailure(BackupError.notSaved),
            ),
          ),
      child: const CreateBackupPage(),
    ),
    'restore preview': () => BlocProvider(
      create: (_) =>
          RestoreCubit(repository: env.fakeBackup, files: env.backupFiles)
            ..emit(
              RestoreState(
                step: RestoreStep.preview,
                staged: StagedRestore(
                  manifest: FakeBackupRepository.manifest,
                  stagedPath: 'staged.sqlite',
                ),
                failure: const BackupFailure(BackupError.notInstalled),
              ),
            ),
      child: const RestoreBackupPage(),
    ),
    'reminders': () => BlocProvider(
      create: (_) => RemindersCubit(
        reminders: env.reminders,
        shops: env.shops,
        share: env.share,
        clock: env.clock,
        today: BusinessDate(2026, 11, 15),
      ),
      child: const RemindersPage(),
    ),
    'help and about': () => const HelpPage(),
    'reverse entry': () => BlocProvider(
      create: (_) => ReverseTransactionCubit(
        ledger: env.ledger,
        reverse: env.reverseTransaction,
        transactionId: 'txn-e1',
        operationId: 'op-reverse-layout',
      ),
      child: const ReverseTransactionPage(),
    ),
  };

  for (final locale in AppLocales.supported) {
    for (final MapEntry(key: name, value: build) in pages.entries) {
      testWidgets('$name: ${locale.languageCode}, 2x text, 320dp wide', (
        tester,
      ) async {
        await seed(tester);
        await tester.pumpApp(
          build(),
          locale: locale,
          textScale: 2,
          narrow: true,
          settle: false,
        );
        // Past the loading delay, then let the data arrive and settle.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    }
  }

  // Accessibility (SK-1203, UI spec 7): every screen, in both themes, must
  // have touch targets of at least 48dp, a label on everything that can
  // be tapped, and readable text contrast.
  for (final brightness in Brightness.values) {
    for (final MapEntry(key: name, value: build) in pages.entries) {
      testWidgets('$name: accessible in ${brightness.name} theme', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await seed(tester);
        await tester.pumpApp(build(), brightness: brightness, settle: false);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }
  }

  testWidgets('allocation editor in Telugu at 2x text does not overflow', (
    tester,
  ) async {
    await seed(tester);
    final charges = (await tester.runAsync(
      () => env.ledger.getOpenCharges(customerAccountId),
    ))!.valueOrNull!;
    expect(charges, isNotEmpty);
    final te = l10nFor(AppLocales.telugu);

    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showAllocationEditor(
            context,
            charges: charges,
            current: const [],
            amount: Money.fromPaise(50000),
          ),
          child: const Text('open'),
        ),
      ),
      locale: AppLocales.telugu,
      textScale: 2,
      narrow: true,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(te.allocationEditorTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validation errors in Telugu at 2x text do not overflow', (
    tester,
  ) async {
    await seed(tester);
    await tester.pumpApp(
      pages['add party']!(),
      locale: AppLocales.telugu,
      textScale: 2,
      narrow: true,
    );
    final te = l10nFor(AppLocales.telugu);

    await tester.ensureVisible(find.text(te.actionSave));
    await tester.tap(find.text(te.actionSave));
    await tester.pumpAndSettle();

    expect(find.text(te.validationRequired), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
