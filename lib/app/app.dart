import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_messenger.dart';
import 'package:smart_khata/app/router/app_router.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/security/secret_store.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/reminders/presentation/reminders_page.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/security/presentation/app_lock_cubit.dart';
import 'package:smart_khata/features/security/presentation/lock_screen.dart';
import 'package:smart_khata/features/settings/domain/settings_repository.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// Why the app has just started again.
enum StartupNotice {
  /// The records were replaced from a backup.
  restored,

  /// A restore could not be put in place; the earlier records are shown.
  restoreFailed,
}

/// The root widget. Owns the app-wide cubits and the router.
class SmartKhataApp extends StatefulWidget {
  const SmartKhataApp({
    required this.settings,
    required this.appLock,
    required this.biometrics,
    required this.reminders,
    required this.clock,
    required this.initialLocale,
    required this.onboardingComplete,
    this.startupNotice,
    super.key,
  });

  final SettingsRepository settings;
  final AppLockRepository appLock;
  final BiometricAuth biometrics;
  final ReminderRepository reminders;
  final Clock clock;
  final Locale initialLocale;
  final bool onboardingComplete;

  /// Something to tell the owner once, right after this start.
  final StartupNotice? startupNotice;

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
  late final GoRouter _router = createAppRouter(onboarding: _onboardingCubit);
  late final AppLockCubit _lockCubit = AppLockCubit(
    repository: widget.appLock,
    biometrics: widget.biometrics,
    clock: widget.clock,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_lockCubit.start());
    if (widget.onboardingComplete) unawaited(_resyncReminders());
    final notice = widget.startupNotice;
    if (notice != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show(notice));
    }
  }

  /// A restore replaces the whole app, so its result is shown by the app
  /// that comes up afterwards.
  void _show(StartupNotice notice) {
    final l10n = lookupAppLocalizations(_localeCubit.state);
    AppMessenger.key.currentState?.showSnackBar(
      SnackBar(
        content: Text(switch (notice) {
          StartupNotice.restored => l10n.restoreDone,
          StartupNotice.restoreFailed => l10n.backupErrorNotInstalled,
        }),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  /// After a restore on a new phone the saved reminders exist but the
  /// phone's alarms do not; set them again. Best effort.
  Future<void> _resyncReminders() => widget.reminders.resync(
    lookupAppLocalizations(widget.initialLocale).reminderTexts,
  );

  @override
  void dispose() {
    _router.dispose();
    // Cubit.close is async; nothing awaits the root widget's disposal.
    unawaited(_localeCubit.close());
    unawaited(_onboardingCubit.close());
    unawaited(_lockCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _onboardingCubit),
        BlocProvider.value(value: _lockCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: AppMessenger.key,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: locale,
          supportedLocales: AppLocales.supported,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router,
          // The lock sits above every screen, dialogs included.
          builder: (context, child) =>
              AppLockGate(child: child ?? const SizedBox.shrink()),
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
