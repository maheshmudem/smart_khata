import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// The languages V1 ships in (ADR-010).
abstract final class AppLocales {
  static const Locale english = Locale('en');
  static const Locale telugu = Locale('te');
  static const List<Locale> supported = [english, telugu];

  /// The language to start in: the saved choice, otherwise the device
  /// language when it is English or Telugu, otherwise English (WF-001).
  static Locale resolveInitial({
    required String? savedCode,
    required Locale deviceLocale,
  }) {
    for (final code in [savedCode, deviceLocale.languageCode]) {
      for (final locale in supported) {
        if (locale.languageCode == code) return locale;
      }
    }
    return english;
  }
}

/// Holds the app language and remembers the owner's choice.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({
    required this._settings,
    required Locale initialLocale,
  }) : super(initialLocale);

  final SettingsRepository _settings;

  /// Switches language at once and saves the choice. If saving fails the
  /// app still uses the new language for this session; the repository has
  /// already logged the failure.
  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supported.contains(locale) || locale == state) return;
    emit(locale);
    await _settings.saveLocaleCode(locale.languageCode);
  }
}
