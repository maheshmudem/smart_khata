import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';

/// The one primary action of a screen.
///
/// While [isLoading] the button shows progress and ignores taps, which is
/// the first line of defence against a double submit (the BLoC's droppable
/// transformer and the operation ID are the others).
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
      ),
    );
  }
}

/// A secondary action: outlined, never competing with the primary one.
class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          const SizedBox.square(
            dimension: AppSizes.iconSm,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: AppSizes.iconSm),
          const SizedBox(width: AppSpacing.sm),
        ],
        // Long Telugu labels wrap instead of clipping.
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }
}
