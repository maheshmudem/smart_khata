import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  final en = l10nFor(AppLocales.english);
  final te = l10nFor(AppLocales.telugu);

  Future<InMemorySettingsRepository> pumpSmartKhata(
    WidgetTester tester, {
    bool onboarded = false,
    Locale locale = AppLocales.english,
  }) async {
    final settings = InMemorySettingsRepository(onboardingComplete: onboarded);
    await tester.pumpWidget(
      SmartKhataApp(
        settings: settings,
        initialLocale: locale,
        onboardingComplete: onboarded,
      ),
    );
    await tester.pumpAndSettle();
    return settings;
  }

  testWidgets('first launch: choose Telugu, continue, land on the shell', (
    tester,
  ) async {
    final settings = await pumpSmartKhata(tester);

    // WF-001: both languages offered, each in its own script.
    expect(find.text(en.languageTitle), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('తెలుగు'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('తెలుగు'));
    await tester.pumpAndSettle();
    expect(find.text(te.languageTitle), findsOneWidget);
    expect(settings.localeCode, 'te');

    await tester.tap(find.text(te.actionContinue));
    await tester.pumpAndSettle();

    expect(settings.onboardingComplete, isTrue);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in [
      te.navHome,
      te.navParties,
      te.navQuickAdd,
      te.navReports,
      te.navMore,
    ]) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('stays in onboarding and explains when setup cannot be saved', (
    tester,
  ) async {
    final settings = await pumpSmartKhata(tester);
    settings.failWrites = true;

    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text(en.errorSaveFailed), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a returning owner goes straight to the shell', (tester) async {
    await pumpSmartKhata(tester, onboarded: true);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(en.languageTitle), findsNothing);
  });

  testWidgets('tabs switch and Quick Add opens a sheet, not a tab', (
    tester,
  ) async {
    await pumpSmartKhata(tester, onboarded: true);
    final bar = find.byType(NavigationBar);
    Finder inBar(String label) =>
        find.descendant(of: bar, matching: find.text(label));

    await tester.tap(inBar(en.navMore));
    await tester.pumpAndSettle();
    expect(find.text(en.settingsLanguage), findsOneWidget);
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 4);

    await tester.tap(inBar(en.navQuickAdd));
    await tester.pumpAndSettle();
    expect(find.text(en.quickAddTitle), findsOneWidget);
    for (final entry in [
      en.quickAddGiveCredit,
      en.quickAddReceivePayment,
      en.quickAddSupplierPurchase,
      en.quickAddPaySupplier,
      en.quickAddExpense,
      en.quickAddCashCount,
    ]) {
      expect(find.text(entry), findsOneWidget);
    }
    // Still on the More tab underneath.
    expect(tester.widget<NavigationBar>(bar).selectedIndex, 4);
  });

  testWidgets('language can be changed from More and is saved', (tester) async {
    final settings = await pumpSmartKhata(tester, onboarded: true);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(en.navMore),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.settingsLanguage));
    await tester.pumpAndSettle();
    await tester.tap(find.text('తెలుగు').last);
    await tester.pumpAndSettle();

    expect(settings.localeCode, 'te');
    expect(find.text(te.settingsLanguage), findsOneWidget);
    expect(find.text(te.navMore), findsWidgets);
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
