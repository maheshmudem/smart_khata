import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/security/presentation/app_lock_cubit.dart';

/// Covers the whole app while it is locked (FR-SET-006).
///
/// The app underneath is kept alive but taken off screen, out of reach of
/// taps and of the screen reader, so unlocking returns the owner to where
/// they were.
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<AppLockCubit>();
    switch (state) {
      case AppLifecycleState.resumed:
        cubit.resumed();
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        cubit.paused();
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLockCubit, AppLockState>(
      buildWhen: (before, after) => before.phase != after.phase,
      builder: (context, state) {
        final covered = state.phase != LockPhase.unlocked;
        return Stack(
          children: [
            Offstage(
              offstage: covered,
              child: ExcludeFocus(excluding: covered, child: widget.child),
            ),
            if (state.phase == LockPhase.locked) const _LockOverlay(),
            if (state.phase == LockPhase.starting)
              ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: const SizedBox.expand(),
              ),
          ],
        );
      },
    );
  }
}

/// The lock screen in an overlay of its own. The gate sits above the
/// app's navigator, so without this the PIN field would have nowhere to
/// put its cursor and selection handles.
class _LockOverlay extends StatefulWidget {
  const _LockOverlay();

  @override
  State<_LockOverlay> createState() => _LockOverlayState();
}

class _LockOverlayState extends State<_LockOverlay> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (_) => const LockScreen(),
  );

  @override
  void dispose() {
    _entry
      ..remove()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: [_entry]);
}

/// PIN entry, with the fingerprint or face prompt when the owner turned
/// it on.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pin = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Offer the quick way first, once the screen is up.
    WidgetsBinding.instance.addPostFrameCallback((_) => _biometrics());
  }

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  void _biometrics() {
    if (!mounted) return;
    final cubit = context.read<AppLockCubit>();
    if (!cubit.state.canUseBiometrics) return;
    unawaited(cubit.unlockWithBiometrics(context.l10n.biometricReason));
  }

  Future<void> _submit() async {
    final pin = _pin.text;
    if (PinPolicy.validate(pin) != null) return;
    _pin.clear();
    await context.read<AppLockCubit>().unlockWithPin(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: BlocBuilder<AppLockCubit, AppLockState>(
          builder: (context, state) {
            final until = state.lockedUntil;
            final message = until != null
                ? l10n.lockPaused(AppDateFormat.timeOfDay(context, until))
                : state.attemptsLeft != null
                ? l10n.lockWrongPin(state.attemptsLeft!)
                : null;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Icon(
                  Icons.lock_outline,
                  size: AppSizes.iconLg,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.lockTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  label: l10n.pinLabel,
                  controller: _pin,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: PinPolicy.maxLength,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  errorText: message,
                  onSubmitted: (_) => unawaited(_submit()),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: l10n.actionUnlock,
                  isLoading: state.isChecking,
                  onPressed: () => unawaited(_submit()),
                ),
                if (state.canUseBiometrics) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    label: l10n.actionUseBiometrics,
                    icon: Icons.fingerprint,
                    onPressed: _biometrics,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.lockForgotNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
