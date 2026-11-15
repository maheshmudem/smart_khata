import 'package:smart_khata/core/errors/result.dart';

/// Non-secret app preferences. Secrets (PIN, keys) never go through here.
abstract interface class SettingsRepository {
  /// The saved language code (`en` / `te`), or `null` if never chosen.
  Future<Result<String?>> readLocaleCode();

  Future<Result<void>> saveLocaleCode(String localeCode);

  /// Whether first-run setup has been finished on this device.
  Future<Result<bool>> isOnboardingComplete();

  Future<Result<void>> markOnboardingComplete();
}
