import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_text_fields.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';
import 'package:smart_khata/features/daily_closing/presentation/closing_cubits.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension ClosingLabelsX on AppLocalizations {
  /// A counted difference in words: "Extra ₹100", "Short ₹500" or
  /// "No difference". Never a bare signed number.
  String differenceText(Money difference) {
    if (difference.isZero) return differenceNone;
    final amount = MoneyFormatter.format(difference.abs());
    return difference.isPositive
        ? differenceExtra(amount)
        : differenceShort(amount);
  }
}

/// WF-044 and WF-045: count the drawer, compare with the cash book, save
/// the closing.
class DailyClosePage extends StatelessWidget {
  const DailyClosePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<DailyCloseCubit>();

    return BlocConsumer<DailyCloseCubit, DailyCloseState>(
      listenWhen: (previous, current) =>
          current.status == SubmissionStatus.success &&
          previous.status != SubmissionStatus.success,
      listener: (context, state) => _onSaved(context, state.saved!),
      builder: (context, state) {
        final isSaved = state.status == SubmissionStatus.success;
        final theme = Theme.of(context);

        return DiscardChangesGuard(
          isDirty: state.isDirty && !state.status.isSubmitting && !isSaved,
          child: Scaffold(
            appBar: AppBar(
              title: Text(l10n.cashCountTitle),
              actions: [
                IconButton(
                  tooltip: l10n.closingHistoryTitle,
                  icon: const Icon(Icons.history),
                  onPressed: () =>
                      unawaited(context.push(AppRoutes.closingHistory)),
                ),
              ],
            ),
            body: switch (state.loadStatus) {
              LoadStatus.loading => const LoadingView(),
              LoadStatus.failure => ErrorView(
                message: l10n.failureMessage(
                  state.failure ?? const UnexpectedFailure(),
                  context: FailureContext.loading,
                ),
                onRetry: cubit.retry,
              ),
              LoadStatus.loaded => SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        children: [
                          Text(
                            '${l10n.closingDateLabel}: '
                            '${AppDateFormat.date(context, state.date)}',
                            style: theme.textTheme.titleMedium,
                          ),
                          if (state.existing != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.closingAlreadyClosed,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          for (final denomination in cashDenominations)
                            _DenominationRow(
                              denomination: denomination,
                              count: state.count,
                            ),
                          const SizedBox(height: AppSpacing.md),
                          MoneyAmountField(
                            label: l10n.otherCashLabel,
                            isRequired: false,
                            emphasized: false,
                            initialValue: state.count.otherAmount,
                            onChanged: cubit.otherAmountChanged,
                          ),
                          if (!state.count.isEmpty)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: () => _reset(context),
                                child: Text(l10n.actionResetCount),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),
                          _TotalsCard(state: state),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            label: l10n.noteLabel,
                            errorText: switch (state.errors[CloseDayCommand
                                .noteField]) {
                              final ValidationError e => l10n.validationMessage(
                                e,
                              ),
                              null => null,
                            },
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: CloseDayCommand.maxNoteLength,
                            onChanged: cubit.noteChanged,
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
                            label: l10n.actionSaveClosing,
                            isLoading: state.status.isSubmitting,
                            // Once saved the page is only waiting to be
                            // left; it cannot be saved a second time.
                            onPressed: isSaved ? null : cubit.submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            },
          ),
        );
      },
    );
  }

  /// Clearing a count that has quantities asks first (UI spec 4.13).
  Future<void> _reset(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<DailyCloseCubit>();
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.resetCountTitle,
      confirmLabel: l10n.actionResetCount,
      cancelLabel: l10n.actionCancel,
      isDestructive: true,
    );
    if (confirmed) cubit.reset();
  }

  /// After the closing is saved: say so. If there is a difference, offer
  /// (never perform) an adjustment, which is a separate entry with its own
  /// reason (FR-CASH-008).
  Future<void> _onSaved(BuildContext context, DailyClosing closing) async {
    final l10n = context.l10n;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    var recordAdjustment = false;
    if (!closing.variance.isZero) {
      recordAdjustment = await showConfirmDialog(
        context,
        title: l10n.differenceText(closing.variance),
        message: l10n.closingNoAdjustNote,
        confirmLabel: l10n.actionRecordAdjustment,
        cancelLabel: l10n.actionClose,
      );
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.closingSaved)));

    if (recordAdjustment) {
      // Extra cash is added to the book; a shortage is taken out.
      unawaited(
        router.pushReplacement(
          AppRoutes.adjustment(
            direction: closing.variance.isPositive
                ? MovementDirection.inflow
                : MovementDirection.outflow,
            amount: closing.variance.abs(),
          ),
        ),
      );
    } else {
      router.pop();
    }
  }
}

/// One note or coin: its value, a quantity with − and + buttons, and the
/// subtotal.
class _DenominationRow extends StatelessWidget {
  const _DenominationRow({required this.denomination, required this.count});

  final int denomination;
  final CashCount count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<DailyCloseCubit>();
    final quantity = count.quantityOf(denomination);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹$denomination',
                  style: AppTheme.amountStyle(theme.textTheme.titleMedium),
                ),
                Text(
                  MoneyFormatter.format(count.subtotalOf(denomination)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.decreaseTooltip,
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: quantity == 0
                ? null
                : () => cubit.decrement(denomination),
          ),
          Semantics(
            label: l10n.denominationQuantity('$denomination'),
            child: SizedBox(
              width: AppSizes.minTouchTarget,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppTheme.amountStyle(theme.textTheme.titleMedium),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.increaseTooltip,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => cubit.increment(denomination),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state});

  final DailyCloseState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
            row(l10n.countedTotal, MoneyFormatter.format(state.countedCash)),
            row(
              l10n.expectedCashLabel,
              MoneyFormatter.format(state.expectedCash ?? Money.zero),
            ),
            const Divider(),
            row(
              l10n.differenceLabel,
              l10n.differenceText(state.difference ?? Money.zero),
              strong: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            // Said before saving: a count does not touch the book.
            Text(l10n.closingNoAdjustNote, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// WF-046: the current closing of each day.
class ClosingHistoryPage extends StatelessWidget {
  const ClosingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ClosingHistoryCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.closingHistoryTitle)),
      body: BlocBuilder<ClosingHistoryCubit, ClosingHistoryState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.loading => const LoadingView(),
          LoadStatus.failure => ErrorView(
            message: l10n.failureMessage(
              state.failure ?? const UnexpectedFailure(),
              context: FailureContext.loading,
            ),
            onRetry: cubit.retry,
          ),
          LoadStatus.loaded when state.closings.isEmpty => EmptyState(
            icon: Icons.calculate_outlined,
            title: l10n.closingHistoryEmpty,
          ),
          LoadStatus.loaded => ListView.separated(
            itemCount: state.closings.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              if (index == state.closings.length) {
                return TextButton(
                  onPressed: cubit.loadMore,
                  child: Text(l10n.actionLoadMore),
                );
              }
              return _ClosingTile(closing: state.closings[index]);
            },
          ),
        },
      ),
    );
  }
}

class _ClosingTile extends StatelessWidget {
  const _ClosingTile({required this.closing});

  final DailyClosing closing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppDateFormat.date(context, closing.businessDate),
            style: theme.textTheme.titleSmall,
          ),
          Text(
            l10n.differenceText(closing.variance),
            style: theme.textTheme.titleMedium,
          ),
          Text(
            '${l10n.countedTotal}: '
            '${MoneyFormatter.format(closing.countedCash)}',
            style: muted,
          ),
          Text(
            '${l10n.expectedCashLabel}: '
            '${MoneyFormatter.format(closing.expectedCash)}',
            style: muted,
          ),
          if (closing.isRevised)
            Text(l10n.closingRevision(closing.revisionNumber), style: muted),
          if (closing.note case final String note) Text(note, style: muted),
        ],
      ),
    );
  }
}
