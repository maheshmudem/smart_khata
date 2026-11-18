import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/app/app.dart';
import 'package:smart_khata/app/app_bloc_observer.dart';
import 'package:smart_khata/app/di/injection.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

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
      configureDependencies(logger: logger);
      await _start(logger);
    },
    (error, stackTrace) => logger.error(
      'uncaught zone error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

/// Starts the app again from a fresh database after "Reset app data"
/// (ADR-022).
///
/// The reset has already closed and deleted the database, so dependencies
/// are dropped without disposing them, then registered again; the new
/// database creates an empty schema on first use and the owner lands
/// on language selection like a new install.
Future<void> _restartAfterReset(AppLogger logger) async {
  await getIt.reset(dispose: false);
  configureDependencies(logger: logger);
  await _start(logger);
}

/// Reads what the first frame needs. The first read also opens the
/// database, so a database that cannot be opened is caught here and shown
/// as a startup failure rather than a blank screen.
Future<void> _start(AppLogger logger) async {
  final settings = getIt<SettingsRepository>();
  final localeResult = await settings.readLocaleCode();
  final onboardingResult = await settings.isOnboardingComplete();
  final shopResult = await getIt<ShopRepository>().getShop();

  if (localeResult case Ok(value: final savedCode)) {
    if (onboardingResult case Ok(value: final flag)) {
      // Setup counts as finished only when a shop exists. An install that
      // finished the language-only onboarding of the foundation build has
      // the flag but no shop, and is sent through shop setup.
      final onboardingComplete = flag && shopResult.valueOrNull != null;
      runApp(
        SmartKhataApp(
          settings: settings,
          initialLocale: AppLocales.resolveInitial(
            savedCode: savedCode,
            deviceLocale: PlatformDispatcher.instance.locale,
          ),
          onboardingComplete: onboardingComplete,
          onAppReset: () => unawaited(_restartAfterReset(logger)),
        ),
      );
      return;
    }
  }
  runApp(StartupFailureApp(onRetry: () => unawaited(_start(logger))));
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
