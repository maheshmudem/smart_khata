import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_router.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The root widget. Owns the app-wide cubits and the router.
class SmartKhataApp extends StatefulWidget {
  const SmartKhataApp({
    required this.settings,
    required this.initialLocale,
    required this.onboardingComplete,
    required this.onAppReset,
    super.key,
  });

  /// Restarts the app after "Reset app data" has erased the database.
  final VoidCallback onAppReset;

  final SettingsRepository settings;
  final Locale initialLocale;
  final bool onboardingComplete;

  @override
  State<SmartKhataApp> createState() => _SmartKhataAppState();
}

class _SmartKhataAppState extends State<SmartKhataApp> {
  late final LocaleCubit _localeCubit = LocaleCubit(
    settings: widget.settings,
    initialLocale: widget.initialLocale,
  );
  late final OnboardingCubit _onboardingCubit = OnboardingCubit(
    settings: widget.settings,
    isComplete: widget.onboardingComplete,
  );
  late final GoRouter _router = createAppRouter(
    onboarding: _onboardingCubit,
    onAppReset: widget.onAppReset,
  );

  @override
  void dispose() {
    _router.dispose();
    // Cubit.close is async; nothing awaits the root widget's disposal.
    unawaited(_localeCubit.close());
    unawaited(_onboardingCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _onboardingCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}

/// Shown instead of the app when the database cannot be opened at launch.
/// It changes nothing on disk and warns against uninstalling, which would
/// delete records that have not been exported.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: ErrorView(
              title: context.l10n.errorStartupTitle,
              message: context.l10n.errorStartupBody,
              onRetry: onRetry,
            ),
          ),
        ),
      ),
    );
  }
}
