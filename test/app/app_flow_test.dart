import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

void main() {
  final en = l10nFor(AppLocales.english);
  final te = l10nFor(AppLocales.telugu);

  late AppDatabase database;
  late Directory databaseDir;
  late int resets;

  setUp(() {
    database = createTestDatabase();
    databaseDir = Directory.systemTemp.createTempSync('sk_flow_');
    resets = 0;
    configureDependencies(
      database: database,
      clock: FakeClock(),
      databaseDirectory: () async => databaseDir,
    );
  });

  tearDown(() async {
    await getIt.reset(dispose: false);
    await database.close();
    if (databaseDir.existsSync()) databaseDir.deleteSync(recursive: true);
  });

  Future<InMemorySettingsRepository> pumpSmartKhata(
    WidgetTester tester, {
    bool onboarded = false,
    Locale locale = AppLocales.english,
  }) async {
    if (onboarded) {
      await getIt<ShopRepository>().createShop(
        profile: const ShopProfile(name: 'Test Kirana'),
        localeCode: 'en',
        openingCash: Money.zero,
      );
    }
    final settings = InMemorySettingsRepository(onboardingComplete: onboarded);
    await tester.pumpWidget(
      SmartKhataApp(
        settings: settings,
        initialLocale: locale,
        onboardingComplete: onboarded,
        onAppReset: () => resets++,
      ),
    );
    await tester.pumpAndSettle();
    return settings;
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label).first;

  Finder inBar(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('first launch: language, shop setup, done, then Home', (
    tester,
  ) async {
    final settings = await pumpSmartKhata(tester);

    // WF-001: both languages offered, each in its own script.
    expect(find.text(en.languageTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('తెలుగు'));
    await tester.pumpAndSettle();
    expect(find.text(te.languageTitle), findsOneWidget);
    expect(settings.localeCode, 'te');

    // WF-002: the shop name is required.
    await tester.tap(find.text(te.actionContinue));
    await tester.pumpAndSettle();
    expect(find.text(te.shopSetupTitle), findsOneWidget);
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text(te.validationRequired), findsOneWidget);

    await tester.enterText(field('${te.shopNameLabel} *'), 'Test Kirana');
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();

    // WF-004: setup complete, then the dashboard.
    expect(find.text(te.setupCompleteTitle), findsOneWidget);
    expect(settings.onboardingComplete, isFalse);
    await tester.tap(find.text(te.actionOpenDashboard));
    await tester.pumpAndSettle();

    expect(settings.onboardingComplete, isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Test Kirana'), findsOneWidget);
    expect(find.text(te.homeEmptyTitle), findsOneWidget);
    expect(
      await database.scalar('SELECT COUNT(*) FROM money_accounts'),
      1,
    );
  });

  testWidgets('stays on setup complete and explains when it cannot save', (
    tester,
  ) async {
    final settings = await pumpSmartKhata(tester);
    await tester.tap(find.text(en.actionContinue));
    await tester.pumpAndSettle();
    await tester.enterText(field('${en.shopNameLabel} *'), 'Test Kirana');
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();

    settings.failWrites = true;
    await tester.tap(find.text(en.actionOpenDashboard));
    await tester.pumpAndSettle();

    expect(find.text(en.errorSaveFailed), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a returning owner goes straight to Home', (tester) async {
    await pumpSmartKhata(tester, onboarded: true);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Test Kirana'), findsOneWidget);
    expect(find.text(en.languageTitle), findsNothing);
  });

  testWidgets('add a customer from Home and see them in Parties', (
    tester,
  ) async {
    await pumpSmartKhata(tester, onboarded: true);

    await tester.tap(find.text(en.actionAddCustomer).first);
    await tester.pumpAndSettle();
    expect(find.text(en.partyFormAddTitle), findsOneWidget);

    await tester.enterText(field('${en.partyNameLabel} *'), 'Ravi Kumar');
    await tester.enterText(field(en.phoneLabel), '98765 43210');
    await tester.tap(find.text(en.actionSave));
    await tester.pumpAndSettle();

    // The detail page opens on the new party, with nothing owed yet.
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text(en.balanceSettled), findsOneWidget);
    expect(find.text(en.openingBalanceAction), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(inBar(en.navParties));
    await tester.pumpAndSettle();
    expect(find.text('Ravi Kumar'), findsOneWidget);
  });

  testWidgets('Quick Add opens a sheet; entries not built yet say so', (
    tester,
  ) async {
    await pumpSmartKhata(tester, onboarded: true);
    final bar = find.byType(NavigationBar);

    await tester.tap(inBar(en.navMore));
    await tester.pumpAndSettle();
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 4);

    await tester.tap(inBar(en.navQuickAdd));
    await tester.pumpAndSettle();
    expect(find.text(en.quickAddTitle), findsOneWidget);
    expect(find.text(en.quickAddGiveCredit), findsOneWidget);

    // Expenses arrive with the cash book; the row says so.
    await tester.scrollUntilVisible(
      find.text(en.quickAddExpense),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(en.quickAddExpense));
    await tester.pumpAndSettle();
    expect(find.text(en.comingSoonMessage), findsOneWidget);
    // Still on the More tab underneath; nothing was posted.
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 4);
    expect(
      await database.scalar('SELECT COUNT(*) FROM financial_transactions'),
      0,
    );
  });

  testWidgets('give credit, then receive more: balance becomes an advance', (
    tester,
  ) async {
    await pumpSmartKhata(tester, onboarded: true);

    // Quick action on Home → pick or add the customer inline.
    await tester.tap(find.text(en.actionGiveCredit).first);
    await tester.pumpAndSettle();
    expect(find.text(en.entryChooseCustomer), findsOneWidget);
    await tester.tap(find.text(en.actionAddCustomer).first);
    await tester.pumpAndSettle();
    await tester.enterText(field('${en.partyNameLabel} *'), 'Ravi Kumar');
    await tester.tap(find.text(en.actionSave));
    await tester.pumpAndSettle();

    // Back on the credit form with the new customer chosen.
    expect(find.text('Ravi Kumar'), findsOneWidget);
    await tester.enterText(field('${en.amountLabel} *'), '600');
    await tester.pumpAndSettle();
    expect(find.text(en.reviewTitle), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, en.actionSave));
    await tester.pumpAndSettle();
    expect(
      await database.scalar(
        'SELECT SUM(amount_paise) FROM party_ledger_entries',
      ),
      60000,
    );

    // Receive ₹800: the extra ₹200 is explained, then kept as an advance.
    await tester.tap(find.text(en.actionReceivePayment).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ravi Kumar'));
    await tester.pumpAndSettle();
    await tester.enterText(field('${en.amountLabel} *'), '800');
    await tester.pumpAndSettle();
    expect(find.text(en.entryExcessAdvance('₹200')), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, en.actionSave));
    await tester.pumpAndSettle();

    expect(
      await database.scalar(
        'SELECT SUM(amount_paise) FROM party_ledger_entries',
      ),
      -20000,
    );
    expect(
      await database.scalar(
        "SELECT COUNT(*) FROM money_movements WHERE direction = 'inflow'",
      ),
      1,
    );
    // Home now shows the advance, labelled as an advance.
    expect(find.text(en.homeAdvanceNote('₹200')), findsOneWidget);
  });

  testWidgets('language can be changed from More and is saved', (tester) async {
    final settings = await pumpSmartKhata(tester, onboarded: true);

    await tester.tap(inBar(en.navMore));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.settingsLanguage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('తెలుగు').last);
    await tester.pumpAndSettle();

    expect(settings.localeCode, 'te');
    expect(find.text(te.settingsLanguage), findsOneWidget);
  });

  testWidgets('reset needs two confirmations, including the shop name', (
    tester,
  ) async {
    await pumpSmartKhata(tester, onboarded: true);
    await tester.tap(inBar(en.navMore));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text(en.resetTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(en.resetTitle));
    await tester.pumpAndSettle();
    expect(find.text(en.resetStep1Title), findsOneWidget);
    await tester.tap(find.text(en.actionContinue));
    await tester.pumpAndSettle();

    final erase = find.widgetWithText(FilledButton, en.actionEraseEverything);
    expect(tester.widget<FilledButton>(erase).onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'wrong name');
    await tester.pump();
    expect(tester.widget<FilledButton>(erase).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, ' test kirana ');
    await tester.pump();
    await tester.tap(erase);
    // The "Erasing records…" overlay spins until the app restarts, so pump
    // frames rather than waiting for it to settle.
    await tester.pump();
    expect(find.text(en.resetInProgress), findsOneWidget);
    // Closing the database is real I/O; let it finish outside fake time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(resets, 1);
  });

  testWidgets('startup failure warns against uninstalling and can retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(StartupFailureApp(onRetry: () => retries++));
    await tester.pumpAndSettle();

    expect(find.text(en.errorStartupTitle), findsOneWidget);
    expect(find.text(en.errorStartupBody), findsOneWidget);
    await tester.tap(find.text(en.actionRetry));
    expect(retries, 1);
  });
}
