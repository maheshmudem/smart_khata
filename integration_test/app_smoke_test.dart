import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';
import 'package:smart_khata/main.dart' as app;

/// A smoke test for a real phone or emulator: the app starts on the real
/// database and plugins, a shop can be set up, and Home appears.
///
/// It needs a fresh install, because it walks through first-run setup:
///
/// ```sh
/// adb uninstall com.maheshmudem.smartkhata
/// flutter test integration_test/app_smoke_test.dart
/// ```
///
/// NOT YET RUN: no device was available when this was written. Treat a
/// first failure as a fault in this test as much as in the app.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final en = lookupAppLocalizations(const Locale('en'));

  testWidgets('first launch: language, shop setup, Home, More', (
    tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // WF-001. The phone may be set to Telugu; choose English so the
    // rest of the test can find its labels.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.actionContinue));
    await tester.pumpAndSettle();

    // WF-002.
    expect(find.text(en.shopSetupTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Smoke Test Kirana');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(en.actionContinue));
    await tester.tap(find.text(en.actionContinue));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // WF-004.
    expect(find.text(en.setupCompleteTitle), findsOneWidget);
    await tester.tap(find.text(en.actionOpenDashboard));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // WF-010: the shop name, the backup warning and first-run guidance.
    expect(find.text('Smoke Test Kirana'), findsOneWidget);
    expect(find.text(en.dashNoBackup), findsOneWidget);
    expect(find.text(en.dashFirstRunTitle), findsOneWidget);

    // The More tab lists what Phase 6 added.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(en.navMore),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(en.backupTitle), findsOneWidget);
    expect(find.text(en.securityTitle), findsOneWidget);
    expect(find.text(en.remindersTitle), findsOneWidget);
  });
}
