import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/features/security/domain/app_lock.dart';
import 'package:smart_khata/features/security/presentation/app_lock_cubit.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension _LockLabelsX on AppLocalizations {
  String timeoutName(AutoLockTimeout timeout) => switch (timeout) {
    AutoLockTimeout.immediately => timeoutImmediately,
    AutoLockTimeout.oneMinute => timeoutOneMinute,
    AutoLockTimeout.fiveMinutes => timeoutFiveMinutes,
  };
}

/// WF-082: turn the app lock on or off, change the PIN, choose
/// fingerprint or face unlock and how soon the app locks.
class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<AppLockCubit>();

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        final config = state.config;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.securityTitle)),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(l10n.securityExplain),
              ),
              ListTile(
                leading: Icon(
                  config.enabled ? Icons.lock_outline : Icons.lock_open,
                ),
                title: Text(
                  config.enabled ? l10n.securityOn : l10n.securityOff,
                ),
              ),
              if (!config.enabled)
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(l10n.actionSetPin),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pinDialog(context, _PinMode.set),
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(l10n.actionChangePin),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pinDialog(context, _PinMode.change),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: Text(l10n.biometricsSwitch),
                  subtitle: state.biometricsAvailable
                      ? null
                      : Text(l10n.biometricsUnavailable),
                  value: config.biometricsEnabled && state.biometricsAvailable,
                  onChanged: state.biometricsAvailable
                      ? (value) =>
                            unawaited(cubit.setBiometrics(enabled: value))
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    l10n.autoLockLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                RadioGroup<AutoLockTimeout>(
                  groupValue: config.timeout,
                  onChanged: (value) {
                    if (value != null) unawaited(cubit.setTimeout(value));
                  },
                  child: Column(
                    children: [
                      for (final timeout in AutoLockTimeout.values)
                        RadioListTile<AutoLockTimeout>(
                          value: timeout,
                          title: Text(l10n.timeoutName(timeout)),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.no_encryption_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(l10n.actionTurnOffLock),
                  onTap: () => _pinDialog(context, _PinMode.turnOff),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  l10n.lockForgotNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pinDialog(BuildContext context, _PinMode mode) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final done = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AppLockCubit>(),
        child: _PinDialog(mode: mode),
      ),
    );
    if (done != true) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mode == _PinMode.turnOff ? l10n.lockTurnedOff : l10n.pinSaved,
          ),
        ),
      );
  }
}

enum _PinMode { set, change, turnOff }

/// Asks for the PINs a change needs. It stays open and says what is
/// wrong until the change has been saved.
class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.mode});

  final _PinMode mode;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  String _current = '';
  String _new = '';
  String _confirm = '';
  String? _currentError;
  String? _newError;
  String? _confirmError;
  bool _saving = false;

  bool get _needsCurrent => widget.mode != _PinMode.set;
  bool get _needsNew => widget.mode != _PinMode.turnOff;

  Future<void> _save() async {
    final l10n = context.l10n;
    final cubit = context.read<AppLockCubit>();
    final navigator = Navigator.of(context);

    final newError = _needsNew ? PinPolicy.validate(_new) : null;
    setState(() {
      _currentError = _needsCurrent && _current.isEmpty
          ? l10n.validationRequired
          : null;
      _newError = newError == null ? null : l10n.validationMessage(newError);
      _confirmError = _needsNew && newError == null && _confirm != _new
          ? l10n.validationMessage(ValidationError.doesNotMatch)
          : null;
    });
    if (_currentError != null || _newError != null || _confirmError != null) {
      return;
    }

    setState(() => _saving = true);
    final change = await switch (widget.mode) {
      _PinMode.set => cubit.enable(_new),
      _PinMode.change => cubit.changePin(currentPin: _current, newPin: _new),
      _PinMode.turnOff => cubit.disable(currentPin: _current),
    };
    if (!mounted) return;
    if (change == LockChange.done) {
      navigator.pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _currentError = switch (change) {
        LockChange.wrongPin => l10n.errorWrongPin,
        LockChange.lockedOut => l10n.errorPinPaused,
        _ => l10n.errorSaveFailed,
      };
    });
  }

  Widget _field(
    String label,
    String? error,
    ValueChanged<String> onChanged, {
    bool autofocus = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppTextField(
      label: label,
      obscureText: true,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      maxLength: PinPolicy.maxLength,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      errorText: error,
      onChanged: onChanged,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(switch (widget.mode) {
        _PinMode.set => l10n.actionSetPin,
        _PinMode.change => l10n.actionChangePin,
        _PinMode.turnOff => l10n.actionTurnOffLock,
      }),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_needsCurrent)
              _field(
                l10n.currentPinLabel,
                _currentError,
                (value) => _current = value,
                autofocus: true,
              ),
            if (_needsNew) ...[
              _field(
                l10n.newPinLabel,
                _newError,
                (value) => _new = value,
                autofocus: !_needsCurrent,
              ),
              _field(
                l10n.confirmPinLabel,
                _confirmError,
                (value) => _confirm = value,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _saving ? null : () => unawaited(_save()),
          child: Text(switch (widget.mode) {
            _PinMode.turnOff => l10n.actionTurnOffLock,
            _ => l10n.actionSave,
          }),
        ),
      ],
    );
  }
}
