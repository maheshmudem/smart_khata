import 'package:flutter/material.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';

/// Number of first-run steps: language, shop, done (WF-001/002/004).
const int onboardingSteps = 3;

/// The branded gradient card at the top of each first-run step: the app
/// mark, "Step 2 of 3" with progress, a title and a short subtitle.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    required this.step,
    required this.title,
    this.subtitle,
    this.icon = Icons.menu_book_rounded,
    super.key,
  });

  final int step;
  final String title;
  final String? subtitle;

  /// The large symbol for this step.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: GradientSurface(
        // No glow: inside a scrolling list it would be clipped at the top.
        raised: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppGradients.onGradient.withValues(alpha: 0.18),
                    borderRadius: AppRadius.control,
                  ),
                  child: Icon(icon, color: AppGradients.onGradient),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppGradients.onGradient,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.onboardingStep(step, onboardingSteps),
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppGradients.onGradientMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: step / onboardingSteps,
                minHeight: AppSpacing.xs + AppSpacing.xxs,
                color: AppGradients.onGradient,
                backgroundColor: AppGradients.onGradient.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppGradients.onGradient,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppGradients.onGradientMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
