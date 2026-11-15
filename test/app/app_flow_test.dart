import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_env.dart';

void main() {
  final en = l10nFor(AppLocales.english);
  final te = l10nFor(AppLocales.telugu);

  late TestEnv env;

  setUp(() {
    env = TestEnv();
    configureDependencies(
      database: env.db,
      logger: env.logger,
      clock: env.clock,
      idGenerator: env.ids,
    );
  });

  // getIt owns the database from here and closes it on reset.
  tearDown(getIt.reset);

  Future<void> pumpSmartKhata(
    WidgetTester tester, {
    bool onboarded = false,
  }) async {
    if (onboarded) {
      await tester.runAsync(() async {
        await env.setUpShop();
        await getIt<SettingsRepository>().markOnboardingComplete();
      });
    }
    await tester.pumpWidget(
      SmartKhataApp(
        settings: getIt<SettingsRepository>(),
        initialLocale: AppLocales.english,
        onboardingComplete: onboarded,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inNavBar(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  /// The text field whose label is [label] (required fields end in ` *`).
  Finder field(String label) => find.byWidgetPredicate(
    (w) =>
        w is TextField &&
        (w.decoration?.labelText == label ||
            w.decoration?.labelText == '$label *'),
  );

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    // Past the search debounce and the loading-indicator delay.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  group('first launch (journey 1)', () {
    testWidgets('language → shop setup → setup complete → shell', (
      tester,
    ) async {
      await pumpSmartKhata(tester);

      // WF-001
      expect(find.text(en.languageTitle), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tapAndSettle(tester, find.text('తెలుగు'));
      expect(find.text(te.languageTitle), findsOneWidget);
      await tapAndSettle(tester, find.text('English'));
      await tapAndSettle(tester, find.text(en.actionContinue));

      // WF-002: a blank name is refused and nothing is saved.
      expect(find.text(en.shopSetupTitle), findsOneWidget);
      expect(find.text(en.currencyInr), findsOneWidget);
      await tapAndSettle(tester, find.text(en.actionContinue));
      expect(find.text(en.validationRequired), findsOneWidget);
      expect(await tester.runAsync(() => env.count('shops')), 0);

      await tester.enterText(field(en.shopNameLabel), 'Sri Lakshmi Kirana');
      await tester.enterText(field(en.mobileNumberLabel), '98765 43210');
      await tapAndSettle(tester, find.text(en.actionContinue));

      // WF-004: honest about local storage and no cloud copy.
      expect(find.text(en.setupCompleteTitle), findsOneWidget);
      expect(find.text(en.setupCompleteStorage), findsOneWidget);
      expect(find.text(en.setupCompleteNoCloud), findsOneWidget);
      expect(await tester.runAsync(() => env.count('shops')), 1);
      expect(await tester.runAsync(() => env.count('money_accounts')), 1);

      await tapAndSettle(tester, find.text(en.actionOpenDashboard));

      expect(find.byType(NavigationBar), findsOneWidget);
      final onboarded = await tester.runAsync(
        () => getIt<SettingsRepository>().isOnboardingComplete(),
      );
      expect(onboarded!.valueOrNull, isTrue);
    });

    testWidgets('re-entering setup after the shop was saved resumes, without '
        'a second shop', (tester) async {
      await tester.runAsync(env.setUpShop);
      await pumpSmartKhata(tester);

      await tapAndSettle(tester, find.text(en.actionContinue));

      expect(find.text(en.setupCompleteTitle), findsOneWidget);
      expect(await tester.runAsync(() => env.count('shops')), 1);
    });
  });

  group('returning owner', () {
    testWidgets('goes straight to the shell', (tester) async {
      await pumpSmartKhata(tester, onboarded: true);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text(en.languageTitle), findsNothing);
    });

    testWidgets('Quick Add opens a sheet, not a tab', (tester) async {
      await pumpSmartKhata(tester, onboarded: true);
      await tapAndSettle(tester, inNavBar(en.navMore));
      await tapAndSettle(tester, inNavBar(en.navQuickAdd));

      expect(find.text(en.quickAddTitle), findsOneWidget);
      expect(find.text(en.quickAddGiveCredit), findsOneWidget);
      expect(find.text(en.quickAddCashCount), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        4,
      );
    });

    testWidgets('language can be changed from More and is saved', (
      tester,
    ) async {
      await pumpSmartKhata(tester, onboarded: true);
      await tapAndSettle(tester, inNavBar(en.navMore));
      await tapAndSettle(tester, find.text(en.settingsLanguage));
      await tapAndSettle(tester, find.text('తెలుగు').last);

      expect(find.text(te.settingsLanguage), findsOneWidget);
      final saved = await tester.runAsync(
        () => getIt<SettingsRepository>().readLocaleCode(),
      );
      expect(saved!.valueOrNull, 'te');
    });
  });

  group('parties (WF-020 to WF-022)', () {
    testWidgets('add a customer, record an opening balance, see it in the '
        'list, then archive', (tester) async {
      await pumpSmartKhata(tester, onboarded: true);
      await tapAndSettle(tester, inNavBar(en.navParties));

      // Empty state leads to the add form.
      expect(find.text(en.partiesEmptyCustomersTitle), findsOneWidget);
      await tapAndSettle(tester, find.text(en.actionAddCustomer));
      expect(find.text(en.partyFormAddTitle), findsOneWidget);

      // Name is required; the form keeps what was typed.
      await tester.enterText(field(en.mobileNumberLabel), '9876543210');
      await tapAndSettle(tester, find.text(en.actionSave));
      expect(find.text(en.validationRequired), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      await tester.enterText(field(en.partyNameLabel), 'Ravi Kumar');
      await tapAndSettle(tester, find.text(en.actionSave));

      // WF-022: the new party, nothing due yet.
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text(en.balanceSettled), findsOneWidget);
      expect(find.text(en.partyNoEntries), findsOneWidget);

      // Opening balance with a review before saving.
      await tapAndSettle(tester, find.text(en.actionAddOpeningBalance));
      expect(find.text(en.openingBalanceTitle), findsOneWidget);
      await tester.enterText(find.byType(MoneyAmountField), '300');
      await tester.pumpAndSettle();
      expect(
        find.text('${en.balanceCustomerOwes} ₹300'),
        findsOneWidget,
        reason: 'review shows the resulting balance in words',
      );
      expect(find.text(en.openingNoCashNote), findsOneWidget);
      await tapAndSettle(tester, find.text(en.actionSaveOpeningBalance));

      // Back on the party: balance and history updated by themselves.
      expect(find.text(en.openingSaved), findsOneWidget);
      expect(find.text(en.balanceCustomerOwes), findsOneWidget);
      expect(find.text('₹300'), findsWidgets);
      expect(find.text(en.txnOpeningBalance), findsOneWidget);
      expect(find.text(en.actionAddOpeningBalance), findsNothing);
      expect(await tester.runAsync(() => env.count('money_movements')), 0);

      // The list row shows the direction in words with the amount.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text(en.balanceCustomerOwes), findsOneWidget);
      expect(find.text('₹300'), findsOneWidget);

      // Archive from the party page.
      await tapAndSettle(tester, find.text('Ravi Kumar'));
      await tapAndSettle(tester, find.byTooltip(en.moreActionsTooltip));
      await tapAndSettle(tester, find.text(en.actionArchive));
      expect(find.text(en.archiveConfirmTitle('Ravi Kumar')), findsOneWidget);
      await tapAndSettle(
        tester,
        find.widgetWithText(FilledButton, en.actionArchive),
      );
      expect(find.text(en.partyArchivedBanner), findsOneWidget);
      // Balance and history stay.
      expect(find.text(en.txnOpeningBalance), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Ravi Kumar'), findsNothing);
      await tapAndSettle(tester, find.text(en.filterArchived));
      expect(find.text('Ravi Kumar'), findsOneWidget);
    });

    testWidgets('a duplicate phone warns and offers the existing party', (
      tester,
    ) async {
      await pumpSmartKhata(tester, onboarded: true);
      await tapAndSettle(tester, inNavBar(en.navParties));
      await tapAndSettle(tester, find.text(en.actionAddCustomer));
      await tester.enterText(field(en.partyNameLabel), 'Ravi');
      await tester.enterText(field(en.mobileNumberLabel), '9876543210');
      await tapAndSettle(tester, find.text(en.actionSave));
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.byTooltip(en.addPartyTooltip));
      await tester.enterText(field(en.partyNameLabel), 'Ravi wife');
      await tester.enterText(field(en.mobileNumberLabel), '+91 98765 43210');
      await tapAndSettle(tester, find.text(en.actionSave));

      expect(find.text(en.duplicateTitle), findsOneWidget);
      expect(find.text(en.duplicateBody('Ravi')), findsOneWidget);
      expect(await tester.runAsync(() => env.count('parties')), 1);

      await tapAndSettle(tester, find.text(en.actionCreateSeparate));
      expect(await tester.runAsync(() => env.count('parties')), 2);
      expect(find.text('Ravi wife'), findsOneWidget);
    });

    testWidgets('search, the supplier tab and the no-result state', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await env.setUpShop();
      });
      await pumpSmartKhata(tester, onboarded: true);
      await tapAndSettle(tester, inNavBar(en.navParties));
      await tapAndSettle(tester, find.text(en.partiesTabSuppliers));
      expect(find.text(en.partiesEmptySuppliersTitle), findsOneWidget);

      await tapAndSettle(tester, find.text(en.actionAddSupplier));
      await tester.enterText(field(en.partyNameLabel), 'ABC Distributors');
      await tapAndSettle(tester, find.text(en.actionSave));
      // A supplier's zero balance and labels, not a customer's.
      expect(find.text(en.totalPurchases), findsOneWidget);
      expect(find.text(en.totalCreditGiven), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('ABC Distributors'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'zzz');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text(en.partiesNoResultsTitle('zzz')), findsOneWidget);

      await tapAndSettle(tester, find.text(en.actionClearSearch));
      expect(find.text('ABC Distributors'), findsOneWidget);
    });
  });

  testWidgets('startup failure warns against uninstalling and can retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(StartupFailureApp(onRetry: () => retries++));
    await tester.pumpAndSettle();

    expect(find.text(en.errorStartupTitle), findsOneWidget);
    expect(find.text(en.errorStartupBody), findsOneWidget);
    await tester.tap(find.byType(AppSecondaryButton));
    expect(retries, 1);
  });
}
