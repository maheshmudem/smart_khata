import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/shop_setup_cubit.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

/// WF-002: shop name is the only required field. Currency is fixed to INR.
class ShopSetupPage extends StatelessWidget {
  const ShopSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ShopSetupCubit>();

    return BlocConsumer<ShopSetupCubit, ShopSetupState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == SubmissionStatus.success,
      listener: (context, state) => context.go(AppRoutes.onboardingComplete),
      builder: (context, state) {
        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };

        return Scaffold(
          appBar: AppBar(title: Text(l10n.shopSetupTitle)),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      AppTextField(
                        label: l10n.shopNameLabel,
                        isRequired: true,
                        autofocus: true,
                        errorText: error(CreateShopCommand.nameField),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        maxLength: CreateShopCommand.maxNameLength,
                        onChanged: cubit.nameChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: l10n.ownerNameLabel,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        onChanged: cubit.ownerNameChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: l10n.mobileNumberLabel,
                        errorText: error(CreateShopCommand.phoneField),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
                        ],
                        maxLength: 15,
                        onChanged: cubit.phoneChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: l10n.addressLabel,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        maxLines: 2,
                        onChanged: cubit.addressChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: l10n.localityLabel,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onChanged: cubit.localityChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Shown, not editable: V1 supports rupees only.
                      AppTextField(
                        key: ValueKey(l10n.currencyInr),
                        label: l10n.currencyLabel,
                        initialValue: l10n.currencyInr,
                        enabled: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.failure case final Failure failure) ...[
                        InlineError(message: l10n.failureMessage(failure)),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppPrimaryButton(
                        label: l10n.actionContinue,
                        isLoading: state.status.isSubmitting,
                        onPressed: () => cubit.submit(
                          localeCode: Localizations.localeOf(
                            context,
                          ).languageCode,
                          cashAccountName: l10n.defaultCashAccountName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
