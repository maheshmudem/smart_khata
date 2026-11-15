import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/charge_form_cubit.dart';

/// WF-030 Give customer credit / WF-032 Supplier purchase on credit.
class ChargeFormPage extends StatelessWidget {
  const ChargeFormPage({required this.today, super.key});

  /// The shop's business date when the form opened; the latest entry date.
  final BusinessDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ChargeFormCubit>();

    return BlocConsumer<ChargeFormCubit, ChargeFormState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        // Shown only now, after the commit: the new balance in words.
        final receipt = state.receipt!;
        final balance = l10n.balanceText(receipt.balanceKind, receipt.balance);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                state.role == PartyRole.customer
                    ? l10n.creditSaved(balance)
                    : l10n.purchaseSaved(balance),
              ),
            ),
          );
        context.pop();
      },
      builder: (context, state) {
        final isCustomer = state.role == PartyRole.customer;
        final account = state.account;
        final party = state.party;
        final isBusy =
            state.status.isSubmitting ||
            state.status == SubmissionStatus.success;

        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };

        return DiscardChangesGuard(
          isDirty: state.isDirty && !isBusy,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                isCustomer ? l10n.giveCreditTitle : l10n.addPurchaseTitle,
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        _PartyField(
                          label: isCustomer
                              ? l10n.customerLabel
                              : l10n.supplierLabel,
                          hint: isCustomer
                              ? l10n.chooseCustomer
                              : l10n.chooseSupplier,
                          partyName: party?.displayName,
                          isLoading: state.isLoadingParty,
                          errorText: error(RecordChargeCommand.partyField),
                          onTap: () => _pickParty(context, state.role),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MoneyAmountField(
                          label: l10n.amountLabel,
                          autofocus: party != null,
                          errorText: error(RecordChargeCommand.amountField),
                          onChanged: cubit.amountChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DateField(
                          label: l10n.dateLabel,
                          value: state.date,
                          firstDate: BusinessDate(2000, 1, 1),
                          lastDate: today,
                          errorText: error(RecordChargeCommand.dateField),
                          onChanged: cubit.dateChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DateField(
                          label: l10n.dueDateLabel,
                          value: state.dueDate,
                          emptyText: l10n.dueDateNone,
                          // A due date cannot be before the entry date.
                          firstDate: state.date,
                          lastDate: state.date.addDays(3650),
                          errorText: error(RecordChargeCommand.dueDateField),
                          onChanged: cubit.dueDateChanged,
                          onCleared: () => cubit.dueDateChanged(null),
                          clearTooltip: l10n.clearDueDateTooltip,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.descriptionLabel,
                          errorText: error(
                            RecordChargeCommand.descriptionField,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: RecordChargeCommand.maxDescriptionLength,
                          onChanged: cubit.descriptionChanged,
                        ),
                        if (account != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ReviewCard(
                            rows: [
                              (
                                l10n.reviewCurrentBalance,
                                l10n.balanceText(
                                  account.balanceKind,
                                  account.balance,
                                ),
                              ),
                              (
                                isCustomer
                                    ? l10n.reviewCreditAdded
                                    : l10n.reviewPurchaseAdded,
                                state.hasValidAmount
                                    ? MoneyFormatter.format(state.amount!)
                                    : '—',
                              ),
                              (
                                l10n.reviewNewBalance,
                                switch ((
                                  state.newBalanceKind,
                                  state.newBalance,
                                )) {
                                  (final kind?, final balance?) =>
                                    l10n.balanceText(kind, balance),
                                  _ => '—',
                                },
                              ),
                            ],
                            warning: state.exceedsCreditLimit
                                ? l10n.creditLimitWarning(
                                    MoneyFormatter.format(party!.creditLimit!),
                                  )
                                : null,
                            note: l10n.chargeNoCashNote,
                          ),
                        ],
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
                          label: isCustomer
                              ? l10n.actionSaveCredit
                              : l10n.actionSavePurchase,
                          isLoading: isBusy,
                          onPressed: () => _save(context, state),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickParty(BuildContext context, PartyRole role) async {
    final cubit = context.read<ChargeFormCubit>();
    final partyId = await context.push<String>(AppRoutes.partyPick(role: role));
    if (partyId != null) await cubit.partySelected(partyId);
  }

  /// Over the credit limit the owner is warned and must confirm; it never
  /// silently blocks and never silently saves (WF-030).
  Future<void> _save(BuildContext context, ChargeFormState state) async {
    final l10n = context.l10n;
    final cubit = context.read<ChargeFormCubit>();
    if (state.exceedsCreditLimit) {
      final goAhead = await showConfirmDialog(
        context,
        title: l10n.creditLimitConfirmTitle,
        message: l10n.creditLimitWarning(
          MoneyFormatter.format(state.party!.creditLimit!),
        ),
        confirmLabel: l10n.actionSaveAnyway,
        cancelLabel: l10n.actionGoBack,
      );
      if (!goAhead) return;
    }
    await cubit.submit();
  }
}

class _PartyField extends StatelessWidget {
  const _PartyField({
    required this.label,
    required this.hint,
    required this.partyName,
    required this.isLoading,
    required this.errorText,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String? partyName;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: AppRadius.control,
      onTap: isLoading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$label *',
          errorText: errorText,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          partyName ?? hint,
          style: partyName == null
              ? theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )
              : theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
