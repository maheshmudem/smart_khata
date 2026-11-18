import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:smart_khata/features/onboarding/presentation/widgets/onboarding_header.dart';

/// WF-004: setup complete. Says plainly where records live and that there
/// is no cloud copy (FR-SET-005). Finishing marks onboarding complete; the
/// router then opens Home.
class SetupCompletePage extends StatefulWidget {
  const SetupCompletePage({super.key});

  @override
  State<SetupCompletePage> createState() => _SetupCompletePageState();
}

class _SetupCompletePageState extends State<SetupCompletePage> {
  bool _saving = false;
  bool _failed = false;

  Future<void> _finish() async {
    setState(() {
      _saving = true;
      _failed = false;
    });
    final saved = await context.read<OnboardingCubit>().complete();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _failed = !saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    return PopScope(
      // The shop exists now; going back to the form would only confuse.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    OnboardingHeader(
                      step: 3,
                      icon: Icons.verified_rounded,
                      title: l10n.setupCompleteTitle,
                    ),
                    AppCard(
                      child: Column(
                        children: [
                          _Point(
                            icon: Icons.phone_android,
                            color: theme.colorScheme.primary,
                            text: l10n.setupCompleteStorage,
                          ),
                          _Point(
                            icon: Icons.wifi_off_rounded,
                            color: theme.colorScheme.primary,
                            text: l10n.setupCompleteOffline,
                          ),
                          _Point(
                            icon: Icons.warning_amber_rounded,
                            color: semantic.warning,
                            text: l10n.setupCompleteBackup,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              FormActionBar(
                children: [
                  if (_failed) ...[
                    InlineError(message: l10n.errorSaveFailed),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppPrimaryButton(
                    label: l10n.actionOpenDashboard,
                    icon: Icons.arrow_forward,
                    isLoading: _saving,
                    onPressed: _finish,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
