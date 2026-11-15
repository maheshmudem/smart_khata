import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/app_bloc_observer.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';

/// Starts the app: installs error handlers, wires dependencies, reads the
/// startup settings and shows the first screen.
Future<void> bootstrap() async {
  const logger = AppLogger();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installErrorHandlers(logger);
      Bloc.observer = const AppBlocObserver(logger);
      ShopTimeZone.ensureInitialized();
      configureDependencies(logger: logger, restartApp: restartApp);
      await _start();
    },
    (error, stackTrace) => logger.error(
      'uncaught zone error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

/// Starts the app again from nothing: every repository is rebuilt on the
/// database file that is now in place. Used after a restore.
Future<void> restartApp() async {
  await getIt.reset();
  configureDependencies(logger: const AppLogger(), restartApp: restartApp);
  await _start();
}

/// Reads what the first frame needs. The first read also opens the
/// database, so a database that cannot be opened is caught here and shown
/// as a startup failure rather than a blank screen.
Future<void> _start() async {
  final settings = getIt<SettingsRepository>();
  final localeResult = await settings.readLocaleCode();
  final onboardingResult = await settings.isOnboardingComplete();

  if (localeResult case Ok(value: final savedCode)) {
    if (onboardingResult case Ok(value: final onboardingComplete)) {
      runApp(
        SmartKhataApp(
          // A new key each start, so a restart rebuilds every screen.
          key: UniqueKey(),
          settings: settings,
          appLock: getIt<AppLockRepository>(),
          biometrics: getIt<BiometricAuth>(),
          reminders: getIt<ReminderRepository>(),
          clock: getIt<Clock>(),
          initialLocale: AppLocales.resolveInitial(
            savedCode: savedCode,
            deviceLocale: PlatformDispatcher.instance.locale,
          ),
          onboardingComplete: onboardingComplete,
        ),
      );
      return;
    }
  }
  runApp(StartupFailureApp(onRetry: () => unawaited(_start())));
}

void _installErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      'flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'uncaught platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };

  // In release a widget that fails to build shows a short translated note
  // instead of a grey box; debug keeps Flutter's detailed red screen.
  if (!kDebugMode) {
    ErrorWidget.builder = (details) => const _BrokenSection();
  }
}

class _BrokenSection extends StatelessWidget {
  const _BrokenSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        context.l10n.errorSectionUnavailable,
        textAlign: TextAlign.center,
      ),
    );
  }
}
