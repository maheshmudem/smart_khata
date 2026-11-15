import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';

/// WF-035: explain, require a reason, show the resulting balance, confirm.
class ReverseTransactionPage extends StatelessWidget {
  const ReverseTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ReverseTransactionCubit>();

    return BlocConsumer<ReverseTransactionCubit, ReverseTransactionState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) {
        final receipt = state.receipt!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                l10n.reversalSaved(
                  l10n.balanceText(receipt.balanceKind, receipt.balance),
                ),
              ),
            ),
          );
        context.pop();
      },
      builder: (context, state) {
        final detail = state.detail;
        if (state.loadStatus != LoadStatus.loaded || detail == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.reverseTitle)),
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

        final isBusy =
            state.status.isSubmitting ||
            state.status == SubmissionStatus.success;
        final after = detail.balanceAfterReversal;
        final afterKind = detail.balanceKind(after);
        final nowKind = detail.balanceKind(detail.accountBalance);

        return DiscardChangesGuard(
          isDirty: state.isDirty && !isBusy,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.reverseTitle)),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        Text(l10n.reverseExplain),
                        const SizedBox(height: AppSpacing.lg),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.reverseOriginal,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${l10n.transactionTypeLabel(detail.type)} '
                                  '${MoneyFormatter.format(detail.amount)}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  [
                                    ?detail.partyName,
                                    AppDateFormat.instant(
                                      context,
                                      detail.effectiveAt,
                                    ),
                                  ].join(' · '),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: l10n.reasonLabel,
                          isRequired: true,
                          autofocus: true,
                          helperText: l10n.reasonHint,
                          errorText: switch (state
                              .errors[ReverseTransactionCommand.reasonField]) {
                            final ValidationError e => l10n.validationMessage(
                              e,
                            ),
                            null => null,
                          },
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: ReverseTransactionCommand.maxReasonLength,
                          onChanged: cubit.reasonChanged,
                        ),
                        if (nowKind != null &&
                            afterKind != null &&
                            after != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          ReviewCard(
                            rows: [
                              (
                                l10n.reviewCurrentBalance,
                                l10n.balanceText(
                                  nowKind,
                                  detail.accountBalance!,
                                ),
                              ),
                              (
                                l10n.reverseBalanceAfter,
                                l10n.balanceText(afterKind, after),
                              ),
                            ],
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
                          label: l10n.actionReviewReversal,
                          isLoading: isBusy,
                          onPressed: () => _confirm(context),
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

  /// The reason is checked first; only a complete form reaches the final,
  /// explicit confirmation.
  Future<void> _confirm(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<ReverseTransactionCubit>();
    if (!cubit.validate()) return;

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.reverseConfirmTitle,
      message: l10n.reverseConfirmBody,
      confirmLabel: l10n.actionConfirmReverse,
      cancelLabel: l10n.actionCancel,
      isDestructive: true,
    );
    if (confirmed) await cubit.submit();
  }
}
