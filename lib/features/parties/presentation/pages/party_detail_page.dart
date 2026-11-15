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
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/dialogs.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/ledger/presentation/widgets/ledger_line_tile.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_detail_cubit.dart';

enum _MenuAction { edit, returned, archive, reactivate }

/// WF-022: a party's balance and history for one role at a time.
class PartyDetailPage extends StatelessWidget {
  const PartyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PartyDetailCubit>();

    return BlocConsumer<PartyDetailCubit, PartyDetailState>(
      listenWhen: (previous, current) =>
          current.actionFailure != null &&
          current.actionFailure != previous.actionFailure,
      listener: (context, state) => _snack(
        context,
        l10n.failureMessage(state.actionFailure!),
      ),
      builder: (context, state) {
        final detail = state.detail;
        final account = state.account;

        if (state.status != LoadStatus.loaded ||
            detail == null ||
            account == null) {
          return Scaffold(
            appBar: AppBar(),
            body: state.status == LoadStatus.failure
                ? ErrorView(
                    message: l10n.failureMessage(
                      state.failure ?? const UnexpectedFailure(),
                      context: FailureContext.loading,
                    ),
                    onRetry: state.failure is NotFoundFailure
                        ? null
                        : cubit.retry,
                  )
                : const LoadingView(),
          );
        }

        final party = detail.party;
        return Scaffold(
          appBar: AppBar(
            title: Text(party.displayName),
            actions: [
              PopupMenuButton<_MenuAction>(
                tooltip: l10n.moreActionsTooltip,
                onSelected: (action) =>
                    _onMenu(context, action, party, account.role),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _MenuAction.edit,
                    child: Text(l10n.actionEdit),
                  ),
                  if (!party.isArchived)
                    PopupMenuItem(
                      value: _MenuAction.returned,
                      child: Text(
                        account.role == PartyRole.customer
                            ? l10n.salesReturnTitle
                            : l10n.purchaseReturnTitle,
                      ),
                    ),
                  if (party.isArchived)
                    PopupMenuItem(
                      value: _MenuAction.reactivate,
                      child: Text(l10n.actionReactivate),
                    )
                  else
                    PopupMenuItem(
                      value: _MenuAction.archive,
                      child: Text(l10n.actionArchive),
                    ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (party.primaryPhone case final String phone)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    phone,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              if (party.isArchived) ...[
                _Banner(text: l10n.partyArchivedBanner),
                const SizedBox(height: AppSpacing.md),
              ],
              if (detail.accounts.length > 1) ...[
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<PartyRole>(
                    showSelectedIcon: false,
                    segments: [
                      for (final a in detail.accounts)
                        ButtonSegment(
                          value: a.role,
                          label: Text(l10n.roleLabel(a.role)),
                        ),
                    ],
                    selected: {account.role},
                    onSelectionChanged: (roles) =>
                        cubit.roleSelected(roles.first),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              _BalanceCard(party: party, account: account),
              const SizedBox(height: AppSpacing.md),
              _TotalsCard(account: account),
              if (!party.isArchived) ...[
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: account.role == PartyRole.customer
                      ? l10n.actionGiveCredit
                      : l10n.actionAddPurchase,
                  icon: Icons.add,
                  onPressed: () => unawaited(
                    context.push(
                      AppRoutes.charge(role: account.role, partyId: party.id),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: account.role == PartyRole.customer
                      ? l10n.actionReceivePayment
                      : l10n.actionPaySupplier,
                  icon: Icons.payments_outlined,
                  onPressed: () => unawaited(
                    context.push(
                      AppRoutes.payment(role: account.role, partyId: party.id),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                label: l10n.actionViewLedger,
                icon: Icons.receipt_long_outlined,
                onPressed: () => unawaited(
                  context.push(
                    AppRoutes.partyLedger(party.id, account.accountId),
                  ),
                ),
              ),
              if (!account.hasOpeningBalance && !party.isArchived) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.openingBalanceHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppSecondaryButton(
                  label: l10n.actionAddOpeningBalance,
                  icon: Icons.add,
                  onPressed: () => unawaited(
                    context.push(
                      AppRoutes.partyOpeningBalance(
                        party.id,
                        account.accountId,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.recentEntriesTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    l10n.partyNoEntries,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final entry in state.entries) ...[
                  LedgerLineTile(
                    transactionType: entry.transactionType,
                    amount: entry.amount,
                    effectiveAt: entry.effectiveAt,
                    description: entry.description,
                    isReversed: entry.isReversed,
                    horizontalPadding: 0,
                    onTap: () => unawaited(
                      context.push(AppRoutes.transaction(entry.transactionId)),
                    ),
                  ),
                  const Divider(),
                ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    _MenuAction action,
    Party party,
    PartyRole role,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<PartyDetailCubit>();
    switch (action) {
      case _MenuAction.edit:
        unawaited(context.push(AppRoutes.partyEdit(party.id)));
      case _MenuAction.returned:
        unawaited(
          context.push(AppRoutes.returned(role: role, partyId: party.id)),
        );
      case _MenuAction.archive:
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.archiveConfirmTitle(party.displayName),
          message: l10n.archiveConfirmBody,
          confirmLabel: l10n.actionArchive,
          cancelLabel: l10n.actionCancel,
        );
        if (!confirmed) return;
        final saved = await cubit.setArchived(archived: true);
        if (saved && context.mounted) _snack(context, l10n.partyArchivedSnack);
      case _MenuAction.reactivate:
        final saved = await cubit.setArchived(archived: false);
        if (saved && context.mounted) {
          _snack(context, l10n.partyReactivatedSnack);
        }
    }
  }

  static void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.party, required this.account});

  final Party party;
  final PartyAccountSummary account;

  @override
  Widget build(BuildContext context) {
    final limit = party.creditLimit;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceSummary(
              kind: account.balanceKind,
              amount: account.balance,
              amountStyle: Theme.of(context).textTheme.headlineMedium,
            ),
            if (account.role == PartyRole.customer && limit != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.partyCreditLimit(MoneyFormatter.format(limit)),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.account});

  final PartyAccountSummary account;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (chargesLabel, settlementsLabel) = switch (account.role) {
      PartyRole.customer => (l10n.totalCreditGiven, l10n.totalPaymentsReceived),
      PartyRole.supplier => (l10n.totalPurchases, l10n.totalPaymentsMade),
    };

    Widget row(String label, Money amount) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.md),
          MoneyText(amount),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            row(chargesLabel, account.totalCharges),
            row(settlementsLabel, account.totalSettlements),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text});

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
          Icon(Icons.archive_outlined, color: context.semanticColors.warning),
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
