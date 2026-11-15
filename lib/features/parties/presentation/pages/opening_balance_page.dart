import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/presentation/cubit/opening_balance_cubit.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// The opening-balance form (WF-021 note, FR-PAR-008): a dated ledger
/// event with a Review section, never a field on the party profile.
class OpeningBalancePage extends StatelessWidget {
  const OpeningBalancePage({required this.today, super.key});

  /// The shop's business date when the form opened; the latest date that
  /// can be chosen.
  final BusinessDate today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OpeningBalanceCubit>();

    return BlocConsumer<OpeningBalanceCubit, OpeningBalanceState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        // Shown only now, after the commit has returned.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.openingSaved)));
        context.pop();
      },
      builder: (context, state) {
        final account = state.account;
        if (state.loadStatus != LoadStatus.loaded || account == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.openingBalanceTitle)),
            body: state.loadStatus == LoadStatus.loading
                ? const LoadingView()
                : ErrorView(
                    message: l10n.failureMessage(
                      state.failure ?? const UnexpectedFailure(),
                      context: FailureContext.loading,
                    ),
                    onRetry: null,
                  ),
          );
        }

        String? error(String field) => switch (state.errors[field]) {
          final ValidationError e => l10n.validationMessage(e),
          null => null,
        };
        final (owedLabel, advanceLabel) = switch (account.role) {
          PartyRole.customer => (
            l10n.openingCustomerOwes,
            l10n.openingCustomerAdvance,
          ),
          PartyRole.supplier => (
            l10n.openingYouOweSupplier,
            l10n.openingSupplierAdvance,
          ),
        };
        final dateError = error(RecordOpeningBalanceCommand.dateField);
        final isBusy =
            state.status.isSubmitting ||
            state.status == SubmissionStatus.success;

        return DiscardChangesGuard(
          isDirty: state.isDirty && !isBusy,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.openingBalanceTitle)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        Text(
                          state.partyName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(l10n.roleLabel(account.role)),
                        const SizedBox(height: AppSpacing.lg),
                        MoneyAmountField(
                          label: l10n.amountLabel,
                          autofocus: true,
                          errorText: error(
                            RecordOpeningBalanceCommand.amountField,
                          ),
                          onChanged: cubit.amountChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.openingDirectionLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DirectionOption(
                          label: owedLabel,
                          isSelected:
                              state.direction == OpeningBalanceDirection.owed,
                          onTap: () => cubit.directionChanged(
                            OpeningBalanceDirection.owed,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DirectionOption(
                          label: advanceLabel,
                          isSelected:
                              state.direction ==
                              OpeningBalanceDirection.advance,
                          onTap: () => cubit.directionChanged(
                            OpeningBalanceDirection.advance,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        InkWell(
                          borderRadius: AppRadius.control,
                          onTap: () => _pickDate(context, state.date),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.asOfDateLabel,
                              errorText: dateError,
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                            ),
                            child: Text(
                              AppDateFormat.date(context, state.date),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.noteLabel,
                          errorText: error(
                            RecordOpeningBalanceCommand.noteField,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: RecordOpeningBalanceCommand.maxNoteLength,
                          onChanged: cubit.noteChanged,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _Review(state: state, l10n: l10n),
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
                          label: l10n.actionSaveOpeningBalance,
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

  Future<void> _pickDate(BuildContext context, BusinessDate current) async {
    final cubit = context.read<OpeningBalanceCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(current.year, current.month, current.day),
      firstDate: DateTime(2000),
      // A balance cannot be "as of" a day that has not happened.
      lastDate: DateTime(today.year, today.month, today.day),
    );
    if (picked != null) {
      cubit.dateChanged(BusinessDate(picked.year, picked.month, picked.day));
    }
  }
}

/// Current balance, the change, and the balance after saving, each with
/// its direction in words (wireframes 1.4).
class _Review extends StatelessWidget {
  const _Review({required this.state, required this.l10n});

  final OpeningBalanceState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = state.account!;
    final resulting = state.resultingBalance;
    final resultingKind = state.resultingKind;

    String describe(BalanceKind kind, Money balance) =>
        kind == BalanceKind.settled
        ? l10n.balanceLabel(kind)
        : '${l10n.balanceLabel(kind)} ${MoneyFormatter.format(balance.abs())}';

    Widget row(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: strong ? theme.textTheme.titleMedium : null,
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reviewTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            row(
              l10n.reviewCurrentBalance,
              describe(account.balanceKind, account.balance),
            ),
            row(
              l10n.reviewNewBalance,
              resulting == null || resultingKind == null
                  ? '—'
                  : describe(resultingKind, resulting),
              strong: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.openingNoCashNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DirectionOption extends StatelessWidget {
  const _DirectionOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      button: true,
      child: Material(
        color: isSelected ? scheme.primaryContainer : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.control,
          side: BorderSide(
            color: isSelected ? scheme.primary : scheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? scheme.primary : scheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(label)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
