import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/language_options.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/onboarding_cubit.dart';

/// WF-001: first screen on first launch. Works with no network.
class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  bool _isSaving = false;
  bool _saveFailed = false;

  Future<void> _continue() async {
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });
    // Shop setup (WF-002 to WF-004) is inserted before this call in the
    // onboarding phase; until then choosing a language finishes setup.
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
                          Icons.menu_book_rounded,
                          size: AppSizes.iconLg,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.appTitle,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.languageTitle,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        BlocBuilder<LocaleCubit, Locale>(
                          builder: (context, locale) => LanguageOptions(
                            selected: locale,
                            onSelected: context.read<LocaleCubit>().setLocale,
                          ),
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
                label: l10n.actionContinue,
                isLoading: _isSaving,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
