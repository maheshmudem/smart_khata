import 'package:smart_khata/core/database/daos/settings_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// [SettingsRepository] stored in the `app_settings` table.
final class DriftSettingsRepository implements SettingsRepository {
  const DriftSettingsRepository({
    required this._dao,
    required this._clock,
    required this._logger,
  });

  static const String localeKey = 'locale_code';
  static const String onboardingCompleteKey = 'onboarding_complete';

  final SettingsDao _dao;
  final Clock _clock;
  final AppLogger _logger;

  @override
  Future<Result<String?>> readLocaleCode() => guard(
    () => _dao.read(localeKey),
    logger: _logger,
    operation: 'settings.readLocale',
  );

  @override
  Future<Result<void>> saveLocaleCode(String localeCode) => guard(
    () => _dao.write(localeKey, localeCode, now: _clock.nowUtc()),
    logger: _logger,
    operation: 'settings.saveLocale',
  );

  @override
  Future<Result<bool>> isOnboardingComplete() => guard(
    () async => await _dao.read(onboardingCompleteKey) == 'true',
    logger: _logger,
    operation: 'settings.readOnboarding',
  );

  @override
  Future<Result<void>> markOnboardingComplete() => guard(
    () => _dao.write(onboardingCompleteKey, 'true', now: _clock.nowUtc()),
    logger: _logger,
    operation: 'settings.saveOnboarding',
  );
}
