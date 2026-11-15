import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/presentation/cubit/ledger_cubits.dart';
import 'package:smart_khata/features/money/presentation/widgets/payment_method_picker.dart';

/// WF-034: everything about one posted entry. It offers reversal, never
/// edit or delete.
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TransactionDetailCubit>();

    return BlocBuilder<TransactionDetailCubit, TransactionDetailState>(
      builder: (context, state) {
        final detail = state.detail;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.transactionTitle)),
          body: switch ((state.status, detail)) {
            (LoadStatus.loaded, final TransactionDetail d) => _Body(detail: d),
            (LoadStatus.failure, _) => ErrorView(
              message: l10n.failureMessage(
                state.failure ?? const UnexpectedFailure(),
                context: FailureContext.loading,
              ),
              onRetry: state.failure is NotFoundFailure ? null : cubit.retry,
            ),
            _ => const LoadingView(),
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail});

  final TransactionDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final effect = detail.ledgerEffect;
    final balanceKind = detail.balanceKind(detail.accountBalance);
    final linkedId =
        detail.reversedByTransactionId ?? detail.reversalOfTransactionId;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (detail.isReversed || detail.isReversal) ...[
                  _Notice(
                    text: detail.isReversed
                        ? l10n.transactionReversedBanner
                        : l10n.transactionIsReversalBanner,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  l10n.transactionTypeLabel(detail.type),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  MoneyFormatter.format(detail.amount, alwaysShowPaise: true),
                  style: AppTheme.amountStyle(theme.textTheme.headlineMedium)
                      ?.copyWith(
                        decoration: detail.isReversed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(),
                if (detail.partyName case final String name)
                  row(
                    switch (detail.role) {
                      final role? => l10n.roleLabel(role),
                      null => l10n.partyNameLabel,
                    },
                    name,
                  ),
                row(
                  l10n.transactionEffectiveDate,
                  AppDateFormat.instant(context, detail.effectiveAt),
                ),
                row(
                  l10n.transactionRecordedDate,
                  AppDateFormat.instant(context, detail.recordedAt),
                ),
                if (detail.dueAt case final DateTime due)
                  row(l10n.dueDateLabel, AppDateFormat.instant(context, due)),
                if (detail.description case final String text)
                  row(
                    detail.isReversal
                        ? l10n.transactionReason
                        : l10n.descriptionLabel,
                    text,
                  ),
                if (detail.isReversed)
                  if (detail.reversalReason case final String reason)
                    row(l10n.transactionReason, reason),
                if (effect != null)
                  row(
                    l10n.transactionEffect,
                    effect.isPositive
                        ? l10n.entryIncrease(
                            MoneyFormatter.format(effect.abs()),
                          )
                        : l10n.entryDecrease(
                            MoneyFormatter.format(effect.abs()),
                          ),
                  ),
                if (balanceKind != null)
                  row(
                    l10n.transactionCurrentBalance,
                    l10n.balanceText(balanceKind, detail.accountBalance!),
                  ),
                if (detail.openAmount case final Money open
                    when detail.accountBalance != null)
                  row(l10n.transactionStillDue, MoneyFormatter.format(open)),
                if (detail.movements.isNotEmpty) ...[
                  const Divider(),
                  for (final movement in detail.movements)
                    row(
                      l10n.movementLine(
                        l10n.methodName(movement.method),
                        movement.accountName,
                      ),
                      [
                        MoneyFormatter.format(movement.amount),
                        ?movement.reference,
                      ].join(' · '),
                    ),
                ],
                if (detail.allocations.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      l10n.transactionSettled,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  for (final allocation in detail.allocations)
                    row(
                      '${l10n.transactionTypeLabel(allocation.transactionType)}'
                      ' · ${AppDateFormat.instant(context, allocation.effectiveAt)}',
                      MoneyFormatter.format(allocation.amount),
                    ),
                ],
                // An excess is named as an advance, never left implied.
                if (detail.unallocatedAmount case final Money advance
                    when advance.isPositive && !detail.isReversed)
                  row(
                    l10n.transactionAdvance,
                    MoneyFormatter.format(advance),
                  ),
                const Divider(),
                if (detail.referenceNumber case final String number)
                  row(
                    detail.type == TransactionType.customerPayment
                        ? l10n.transactionReceiptNo
                        : l10n.transactionVoucherNo,
                    number,
                  ),
                row(l10n.transactionReference, detail.id),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy, size: AppSizes.iconSm),
                    label: Text(l10n.actionCopyReference),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(ClipboardData(text: detail.id));
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text(l10n.referenceCopied)),
                        );
                    },
                  ),
                ),
                if (linkedId != null)
                  AppSecondaryButton(
                    label: detail.isReversed
                        ? l10n.actionViewReversal
                        : l10n.actionViewOriginal,
                    onPressed: () => unawaited(
                      context.push(AppRoutes.transaction(linkedId)),
                    ),
                  ),
              ],
            ),
          ),
          if (detail.canBeReversed)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppSecondaryButton(
                label: l10n.actionReverse,
                icon: Icons.undo,
                onPressed: () => unawaited(
                  context.push(AppRoutes.transactionReverse(detail.id)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: AppRadius.control,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.undo, color: context.semanticColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
