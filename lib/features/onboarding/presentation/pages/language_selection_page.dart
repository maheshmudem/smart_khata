import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/language_options.dart';
import 'package:smart_khata/features/onboarding/presentation/widgets/onboarding_header.dart';

/// WF-001: first screen on first launch. Works with no network. The choice
/// is saved as soon as it is tapped.
class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  OnboardingHeader(
                    step: 1,
                    icon: Icons.translate_rounded,
                    title: l10n.languageTitle,
                    subtitle: l10n.languageSubtitle,
                  ),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) => LanguageOptions(
                      selected: locale,
                      onSelected: context.read<LocaleCubit>().setLocale,
                    ),
                  ),
                ],
              ),
            ),
            FormActionBar(
              children: [
                AppPrimaryButton(
                  label: l10n.actionContinue,
                  icon: Icons.arrow_forward,
                  onPressed: () => context.push(AppRoutes.onboardingShop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
