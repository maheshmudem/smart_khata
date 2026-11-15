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
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/payment_form_cubit.dart';
import 'package:smart_khata/features/ledger/presentation/widgets/allocation_editor.dart';
import 'package:smart_khata/features/money/presentation/widgets/payment_method_picker.dart';
import 'package:smart_khata/features/parties/presentation/widgets/party_selector_field.dart';

/// WF-031 Receive customer payment / WF-033 Pay supplier.
class PaymentFormPage extends StatelessWidget {
  const PaymentFormPage({required this.today, super.key});

  /// The shop's business date when the form opened; the latest entry date.
  final BusinessDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PaymentFormCubit>();

    return BlocConsumer<PaymentFormCubit, PaymentFormState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        // Shown only now, after the commit: the new balance in words.
        final receipt = state.receipt!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n.paymentSaved(
                  l10n.balanceText(receipt.balanceKind, receipt.balance),
                ),
              ),
            ),
          );
        context.pop();
      },
      builder: (context, state) {
        final isCustomer = state.role == PartyRole.customer;
        final account = state.account;
        final theme = Theme.of(context);
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
                isCustomer ? l10n.receivePaymentTitle : l10n.paySupplierTitle,
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        PartySelectorField(
                          label: isCustomer
                              ? l10n.customerLabel
                              : l10n.supplierLabel,
                          hint: isCustomer
                              ? l10n.chooseCustomer
                              : l10n.chooseSupplier,
                          partyName: state.party?.displayName,
                          isLoading: state.isLoadingParty,
                          errorText: error(RecordPaymentCommand.partyField),
                          onTap: () => _pickParty(context, state.role),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        MoneyAmountField(
                          label: isCustomer
                              ? l10n.amountReceivedLabel
                              : l10n.amountPaidLabel,
                          autofocus: state.party != null,
                          errorText: error(RecordPaymentCommand.amountField),
                          onChanged: cubit.amountChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DateField(
                          label: l10n.dateLabel,
                          value: state.date,
                          firstDate: BusinessDate(2000, 1, 1),
                          lastDate: today,
                          errorText: error(RecordPaymentCommand.dateField),
                          onChanged: cubit.dateChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.paymentMethodLabel,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final (index, split) in state.splits.indexed)
                          _SplitRow(
                            index: index,
                            split: split,
                            state: state,
                            // The split error is shown once, under the last
                            // part.
                            errorText: index == state.splits.length - 1
                                ? error(RecordPaymentCommand.splitsField)
                                : null,
                          ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            icon: const Icon(Icons.add, size: AppSizes.iconSm),
                            label: Text(l10n.actionAddAnotherMethod),
                            onPressed: cubit.addSplit,
                          ),
                        ),
                        if (state.openCharges.isNotEmpty &&
                            state.hasValidAmount) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _AllocationSummary(state: state),
                        ],
                        if (error(RecordPaymentCommand.allocationsField)
                            case final String message)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: InlineError(message: message),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.noteLabel,
                          errorText: error(RecordPaymentCommand.noteField),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: RecordPaymentCommand.maxNoteLength,
                          onChanged: cubit.noteChanged,
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
                                    ? l10n.amountReceivedLabel
                                    : l10n.amountPaidLabel,
                                state.hasValidAmount
                                    ? MoneyFormatter.format(state.amount!)
                                    : '—',
                              ),
                              if (state.hasValidAmount)
                                (
                                  l10n.reviewAppliedToDues,
                                  MoneyFormatter.format(state.allocatedTotal),
                                ),
                              if (state.advance.isPositive)
                                (
                                  l10n.reviewAdvanceCreated,
                                  MoneyFormatter.format(state.advance),
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
                            // An excess is called an advance before saving,
                            // never left for the owner to work out.
                            note: state.advance.isPositive
                                ? l10n.advanceNote
                                : null,
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
                          label: l10n.actionSavePayment,
                          isLoading: isBusy,
                          onPressed: cubit.submit,
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
    final cubit = context.read<PaymentFormCubit>();
    final partyId = await context.push<String>(AppRoutes.partyPick(role: role));
    if (partyId != null) await cubit.partySelected(partyId);
  }
}

/// One way the payment was made (wireframes 5, `PaymentSplitEditor`).
class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.index,
    required this.split,
    required this.state,
    required this.errorText,
  });

  final int index;
  final PaymentSplit split;
  final PaymentFormState state;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PaymentFormCubit>();

    final picker = PaymentMethodPicker(
      method: split.method,
      accountId: split.moneyAccountId,
      accounts: state.moneyAccounts,
      errorText: errorText,
      onMethodChanged: (method) => cubit.splitMethodChanged(index, method),
      onAccountChanged: (id) => cubit.splitAccountChanged(index, id),
      onAddAccount: (name) => cubit.addMoneyAccount(index, name),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isSplit)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: picker),
                IconButton(
                  tooltip: l10n.removeMethodTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () => cubit.removeSplit(index),
                ),
              ],
            )
          else
            picker,
          if (state.isSplit) ...[
            const SizedBox(height: AppSpacing.sm),
            MoneyAmountField(
              // The field keeps its own text; a new key resets it when the
              // parts are re-indexed after a removal.
              key: ValueKey('split-$index-${state.splits.length}'),
              label: l10n.splitAmountLabel,
              emphasized: false,
              initialValue: split.amount,
              onChanged: (amount) => cubit.splitAmountChanged(index, amount),
            ),
          ],
          if (split.method != PaymentMethod.cash) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              key: ValueKey('ref-$index-${state.splits.length}'),
              label: l10n.referenceLabel,
              initialValue: split.reference,
              maxLength: 40,
              onChanged: (text) => cubit.splitReferenceChanged(index, text),
            ),
          ],
        ],
      ),
    );
  }
}

/// Says how the payment will be applied and lets the owner change it.
class _AllocationSummary extends StatelessWidget {
  const _AllocationSummary({required this.state});

  final PaymentFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<PaymentFormCubit>();
    final isManual = state.manualAllocations != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allocationTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    isManual
                        ? l10n.allocationManual
                        : l10n.allocationOldestFirst,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final choice = await showAllocationEditor(
                  context,
                  charges: state.openCharges,
                  current: state.allocations,
                  amount: state.amount!,
                );
                switch (choice) {
                  case UseManual(:final lines):
                    cubit.allocationsChanged(lines);
                  case UseOldestFirst():
                    cubit.allocationsChanged(null);
                  case null:
                    break;
                }
              },
              child: Text(l10n.actionChangeAllocation),
            ),
          ],
        ),
      ),
    );
  }
}
