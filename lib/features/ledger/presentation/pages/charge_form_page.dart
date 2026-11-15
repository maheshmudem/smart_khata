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
import 'package:smart_khata/features/money/presentation/widgets/payment_method_picker.dart';
import 'package:smart_khata/features/parties/presentation/widgets/party_selector_field.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// WF-030 Give customer credit, WF-032 Supplier purchase (with an optional
/// amount paid now), and the sales / purchase return forms.
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
            SnackBar(content: Text(_Copy.of(l10n, state).saved(balance))),
          );
        context.pop();
      },
      builder: (context, state) {
        final copy = _Copy.of(l10n, state);
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
            appBar: AppBar(title: Text(copy.title)),
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
                        if (state.offersDueDate) ...[
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
                        ],
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
                        if (state.offersPaidNow) ...[
                          const SizedBox(height: AppSpacing.lg),
                          MoneyAmountField(
                            label: l10n.paidNowLabel,
                            isRequired: false,
                            emphasized: false,
                            helperText: l10n.paidNowHelp,
                            errorText: error(RecordChargeCommand.paidNowField),
                            onChanged: cubit.paidNowAmountChanged,
                          ),
                          if (state.hasPaidNow) ...[
                            const SizedBox(height: AppSpacing.md),
                            PaymentMethodPicker(
                              method: state.paidNow.method,
                              accountId: state.paidNow.moneyAccountId,
                              accounts: state.moneyAccounts,
                              errorText: error(
                                RecordChargeCommand.paidNowAccountField,
                              ),
                              onMethodChanged: cubit.paidNowMethodChanged,
                              onAccountChanged: cubit.paidNowAccountChanged,
                              onAddAccount: cubit.addMoneyAccount,
                            ),
                          ],
                        ],
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
                                copy.reviewAmount,
                                state.hasValidAmount
                                    ? MoneyFormatter.format(state.amount!)
                                    : '—',
                              ),
                              if (state.hasPaidNow)
                                (
                                  l10n.reviewPaidNow,
                                  MoneyFormatter.format(state.paidNow.amount!),
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
                            // Says plainly that no money is recorded, unless
                            // part of the purchase is paid now.
                            note: state.hasPaidNow ? null : copy.noCashNote,
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
                          label: copy.save,
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

/// The wording of the form for each of its four uses.
class _Copy {
  const _Copy({
    required this.title,
    required this.reviewAmount,
    required this.save,
    required this.noCashNote,
    required this.saved,
  });

  factory _Copy.of(AppLocalizations l10n, ChargeFormState state) {
    final isCustomer = state.role == PartyRole.customer;
    if (state.isReturn) {
      return _Copy(
        title: isCustomer ? l10n.salesReturnTitle : l10n.purchaseReturnTitle,
        reviewAmount: l10n.reviewReturnAmount,
        save: l10n.actionSaveReturn,
        noCashNote: l10n.returnNoCashNote,
        saved: l10n.returnSaved,
      );
    }
    return isCustomer
        ? _Copy(
            title: l10n.giveCreditTitle,
            reviewAmount: l10n.reviewCreditAdded,
            save: l10n.actionSaveCredit,
            noCashNote: l10n.chargeNoCashNote,
            saved: l10n.creditSaved,
          )
        : _Copy(
            title: l10n.addPurchaseTitle,
            reviewAmount: l10n.reviewPurchaseTotal,
            save: l10n.actionSavePurchase,
            noCashNote: l10n.chargeNoCashNote,
            saved: l10n.purchaseSaved,
          );
  }

  final String title;
  final String reviewAmount;
  final String save;
  final String noCashNote;
  final String Function(String balance) saved;
}
