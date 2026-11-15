import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';

/// One option of an either/or choice, shown as a full-width tappable row
/// with a radio mark. Used where the options need a sentence each, such as
/// "Customer owes you" / "You hold the customer's advance".
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      button: true,
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.control,
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? scheme.primary : scheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(label)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
