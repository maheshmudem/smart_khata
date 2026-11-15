import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The translated strings for [locale], for use in expectations.
AppLocalizations l10nFor(Locale locale) => lookupAppLocalizations(locale);

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app's theme and localization setup.
  ///
  /// [textScale] 2.0 is the "large text" setting the accessibility checks
  /// use; [narrow] shrinks the screen to a small 320dp-wide phone. Pass
  /// [settle] `false` for widgets that animate forever, such as a spinner.
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = AppLocales.english,
    Brightness brightness = Brightness.light,
    double textScale = 1,
    bool narrow = false,
    bool settle = true,
  }) async {
    if (narrow) {
      view.physicalSize = const Size(320, 640);
      view.devicePixelRatio = 1;
      addTearDown(view.reset);
    }
    await pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.light ? AppTheme.light : AppTheme.dark,
        locale: locale,
        supportedLocales: AppLocales.supported,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(body: widget),
      ),
    );
    if (settle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }
}
