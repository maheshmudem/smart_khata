import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';

/// WF-004: says plainly that records live on this phone and that no cloud
/// copy exists (FR-SET-005). Opening the dashboard finishes setup.
class SetupCompletePage extends StatefulWidget {
  const SetupCompletePage({super.key});

  @override
  State<SetupCompletePage> createState() => _SetupCompletePageState();
}

class _SetupCompletePageState extends State<SetupCompletePage> {
  bool _isSaving = false;
  bool _saveFailed = false;

  Future<void> _finish() async {
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });
    // On success the router's redirect leaves onboarding by itself.
    final saved = await context.read<OnboardingCubit>().complete();
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saveFailed = !saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget point(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: AppSizes.iconLg,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.setupCompleteTitle,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        point(
                          Icons.smartphone_outlined,
                          l10n.setupCompleteStorage,
                        ),
                        point(
                          Icons.cloud_off_outlined,
                          l10n.setupCompleteNoCloud,
                        ),
                        point(
                          Icons.save_alt_outlined,
                          l10n.setupCompleteBackup,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_saveFailed) ...[
                InlineError(message: l10n.errorSaveFailed),
                const SizedBox(height: AppSpacing.md),
              ],
              AppPrimaryButton(
                label: l10n.actionOpenDashboard,
                isLoading: _isSaving,
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
