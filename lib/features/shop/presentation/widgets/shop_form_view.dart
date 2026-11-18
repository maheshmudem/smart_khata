import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';
import 'package:smart_khata/features/shop/presentation/bloc/shop_form_bloc.dart';

/// The shop details form (WF-002), used in setup and in Shop profile.
///
/// [header] sits above the fields; [showOpeningCash] adds the drawer-cash
/// field, which only makes sense when the shop is first created.
class ShopFormView extends StatelessWidget {
  const ShopFormView({
    required this.submitLabel,
    required this.onSaved,
    this.header,
    this.showOpeningCash = false,
    super.key,
  });

  final String submitLabel;
  final VoidCallback onSaved;
  final Widget? header;
  final bool showOpeningCash;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopFormBloc, ShopFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == SubmitStatus.success) onSaved();
      },
      builder: (context, state) {
        if (state.isLoading) return const LoadingView();
        return DiscardChangesGuard(
          isDirty: state.isDirty && state.status != SubmitStatus.success,
          child: _Fields(
            state: state,
            header: header,
            submitLabel: submitLabel,
            showOpeningCash: showOpeningCash && !state.hasExistingShop,
          ),
        );
      },
    );
  }
}

class _Fields extends StatelessWidget {
  const _Fields({
    required this.state,
    required this.header,
    required this.submitLabel,
    required this.showOpeningCash,
  });

  final ShopFormState state;
  final Widget? header;
  final String submitLabel;
  final bool showOpeningCash;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<ShopFormBloc>();
    final input = state.input;
    final errors = state.errors;
    String? errorFor(String field) {
      final error = errors[field];
      return error == null ? null : l10n.validationMessage(error);
    }

    void change(ShopProfileInput next) => bloc.add(ShopFormChanged(next));
    final failure = state.failure;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            children: [
              ?header,
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      label: l10n.shopNameLabel,
                      initialValue: input.name,
                      isRequired: true,
                      autofocus: input.name.isEmpty,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 80,
                      errorText: errorFor(ShopFields.name),
                      onChanged: (v) => change(input.copyWith(name: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // INR is fixed in V1: shown as a fact, not a field.
                    InfoRow(
                      icon: Icons.currency_rupee_rounded,
                      label: l10n.currencyLabel,
                      value: l10n.currencyValue,
                    ),
                    if (showOpeningCash) ...[
                      const SizedBox(height: AppSpacing.md),
                      MoneyAmountField(
                        label: l10n.openingCashLabel,
                        helperText: l10n.openingCashHelper,
                        isRequired: false,
                        initialValue: state.openingCash,
                        onChanged: (m) => bloc.add(ShopOpeningCashChanged(m)),
                      ),
                    ],
                  ],
                ),
              ),
              SectionHeader(title: l10n.shopContactSection),
              AppCard(
                child: Column(
                  children: [
                    AppTextField(
                      label: l10n.ownerNameLabel,
                      initialValue: input.ownerName,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 80,
                      onChanged: (v) => change(input.copyWith(ownerName: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.phoneLabel,
                      initialValue: input.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 16,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                      ],
                      errorText: errorFor(ShopFields.phone),
                      onChanged: (v) => change(input.copyWith(phone: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.addressLabel,
                      initialValue: input.address,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      maxLength: 200,
                      onChanged: (v) => change(input.copyWith(address: v)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: l10n.localityLabel,
                      initialValue: input.locality,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 80,
                      onChanged: (v) => change(input.copyWith(locality: v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        FormActionBar(
          children: [
            if (failure != null) ...[
              InlineError(message: l10n.failureMessage(failure)),
              const SizedBox(height: AppSpacing.md),
            ],
            AppPrimaryButton(
              label: submitLabel,
              isLoading: state.status == SubmitStatus.submitting,
              onPressed: () => bloc.add(const ShopFormSubmitted()),
            ),
          ],
        ),
      ],
    );
  }
}
