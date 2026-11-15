import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

import 'test_env.dart';

/// A label in the bottom navigation bar.
Finder inNavBar(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// The text field whose label is [label] (required fields end in ` *`).
Finder field(String label) => find.byWidgetPredicate(
  (w) =>
      w is TextField &&
      (w.decoration?.labelText == label ||
          w.decoration?.labelText == '$label *'),
);

/// Drives the whole app in a widget test, against the real repositories on
/// an in-memory database.
extension AppDriver on WidgetTester {
  /// Call from `setUp`. Pair with `tearDown(getIt.reset)`, which also
  /// closes the database.
  static TestEnv configure() {
    // A tap that lands on something else (for example a snackbar over a
    // button) fails the test instead of printing a warning.
    WidgetController.hitTestWarningShouldBeFatal = true;
    final env = TestEnv();
    configureDependencies(
      database: env.db,
      logger: env.logger,
      clock: env.clock,
      idGenerator: env.ids,
      shareService: env.share,
    );
    return env;
  }

  /// Starts the app. With [onboarded] the shop already exists and setup is
  /// finished. [tallScreen] gives a very tall window so that a long form is
  /// built in full; use it when a test addresses fields by position.
  ///
  /// [seed] runs after shop setup and before the app starts. Seed there,
  /// not later: Home keeps live queries open, and a database write made
  /// from `runAsync` while they are listening never finishes.
  Future<void> pumpSmartKhata(
    TestEnv env, {
    bool onboarded = true,
    bool tallScreen = false,
    Future<void> Function()? seed,
  }) async {
    if (tallScreen) {
      view.physicalSize = const Size(800, 4000);
      view.devicePixelRatio = 1;
      addTearDown(view.reset);
    }
    if (onboarded) {
      await runAsync(() async {
        await env.setUpShop();
        await getIt<SettingsRepository>().markOnboardingComplete();
        await seed?.call();
      });
    }
    await pumpWidget(
      SmartKhataApp(
        settings: getIt<SettingsRepository>(),
        initialLocale: AppLocales.english,
        onboardingComplete: onboarded,
      ),
    );
    await pumpAndSettle();
  }

  /// Past the search debounce and the loading-indicator delay, then until
  /// nothing is animating.
  Future<void> settle() async {
    await pump(const Duration(milliseconds: 400));
    await pumpAndSettle();
  }

  /// Scrolls the top page's list until [finder] is built and on screen.
  /// Lists build lazily, so content below the fold does not exist until
  /// it is scrolled to.
  Future<void> reveal(Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await scrollUntilVisible(
        finder,
        120,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await ensureVisible(finder.first);
    await pumpAndSettle();
  }

  /// Scrolls the top page's list back to its start.
  Future<void> scrollToTop() async {
    await drag(find.byType(ListView).last, const Offset(0, 2000));
    await pumpAndSettle();
  }

  /// Waits out a snackbar that is covering the bottom of the screen.
  Future<void> waitForSnackBarToGo() async {
    await pump(const Duration(seconds: 5));
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(Finder finder) async {
    await reveal(finder);
    await tap(finder.first);
    await settle();
  }

  /// Types into the field labelled [label].
  Future<void> type(String label, String text) async {
    await reveal(field(label));
    await enterText(field(label), text);
    await pumpAndSettle();
  }
}
