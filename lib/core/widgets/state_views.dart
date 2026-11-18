import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// Shown when a list or screen has nothing yet: says what belongs here and
/// offers one next step (UI spec 5).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CenteredMessage(
      icon: icon,
      iconColor: theme.colorScheme.primary,
      title: title,
      message: message,
      action: actionLabel == null
          ? null
          : AppPrimaryButton(label: actionLabel!, onPressed: onAction),
    );
  }
}

/// Shown when a screen's data could not be loaded. Always offers a retry.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    required this.onRetry,
    this.title,
    super.key,
  });

  final String? title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      title: title ?? message,
      message: title == null ? null : message,
      action: onRetry == null
          ? null
          : AppSecondaryButton(
              label: context.l10n.actionRetry,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
    );
  }
}

/// Progress for a local query. Local reads are quick, so the indicator is
/// held back briefly to avoid a flash on every screen open.
class LoadingView extends StatefulWidget {
  const LoadingView({
    this.delay = const Duration(milliseconds: 200),
    super.key,
  });

  final Duration delay;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () => setState(() => _visible = true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: AppDurations.fast,
        child: CircularProgressIndicator(
          semanticsLabel: context.l10n.loadingLabel,
        ),
      ),
    );
  }
}

/// A recoverable error shown inside a form, above the Save button. The form
/// keeps its values; the owner fixes the cause or taps Save again.
class InlineError extends StatelessWidget {
  const InlineError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: AppRadius.control,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: scheme.onErrorContainer,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Scrollable so large text and small screens never overflow.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Icon(icon, size: AppSizes.iconLg, color: iconColor),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
