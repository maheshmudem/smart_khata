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
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';
import 'package:smart_khata/features/reports/presentation/report_widgets.dart';

/// WF-010: what is owed to the shop, what the shop owes, and today.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The app may have been left open overnight.
    if (state == AppLifecycleState.resumed) {
      context.read<DashboardCubit>().refreshDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final summary = state.summary;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.shopName.isEmpty ? l10n.appTitle : state.shopName,
            ),
            actions: [
              IconButton(
                tooltip: l10n.dashInfoTitle,
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfo(context),
              ),
            ],
          ),
          body: switch (state.status) {
            LoadStatus.failure => ErrorView(
              message: l10n.failureMessage(
                state.failure ?? const UnexpectedFailure(),
                context: FailureContext.loading,
              ),
              onRetry: context.read<DashboardCubit>().retry,
            ),
            _ when summary == null => const LoadingView(),
            _ => _DashboardBody(state: state, summary: summary),
          },
        );
      },
    );
  }

  Future<void> _showInfo(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dashInfoTitle),
        content: SingleChildScrollView(
          child: Text(
            [
              l10n.dashInfoCustomers,
              l10n.dashInfoSuppliers,
              l10n.dashInfoToday,
              l10n.dashInfoCurrency,
            ].join('\n\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.actionClose),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.state, required this.summary});

  final DashboardState state;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppDateFormat.date(context, state.today), style: muted),
              const SizedBox(height: AppSpacing.xs),
              // The date of the last backup saved outside the app, or a
              // plain warning that there is none (WF-010, FR-BKP-009).
              InkWell(
                onTap: () => unawaited(context.push(AppRoutes.backup)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        state.lastBackupAt == null
                            ? Icons.warning_amber_outlined
                            : Icons.verified_outlined,
                        size: AppSizes.iconSm,
                        color: state.lastBackupAt == null
                            ? semantic.warning
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          switch (state.lastBackupAt) {
                            null => l10n.dashNoBackup,
                            final at => l10n.backupLastOn(
                              AppDateFormat.instant(context, at),
                            ),
                          },
                          style: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isFirstRun)
          ReportCard(
            children: [
              Text(l10n.dashFirstRunTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.dashFirstRunBody),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: l10n.actionAddCustomer,
                onPressed: () => unawaited(
                  context.push(AppRoutes.partyNew(role: PartyRole.customer)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSecondaryButton(
                label: l10n.actionAddSupplier,
                onPressed: () => unawaited(
                  context.push(AppRoutes.partyNew(role: PartyRole.supplier)),
                ),
              ),
            ],
          ),
        _BalanceCard(
          title: l10n.dashCustomerOutstanding,
          amount: summary.customerOutstanding,
          color: semantic.receivable,
          detail: [
            l10n.dashCustomersCount(summary.customersWithDues),
            if (summary.overdueCustomers > 0)
              l10n.dashOverdueCount(summary.overdueCustomers),
          ].join(' · '),
          advanceLabel: l10n.dashCustomerAdvances,
          advances: summary.customerAdvances,
          onTap: () => unawaited(
            context.push(AppRoutes.outstanding(PartyRole.customer)),
          ),
        ),
        _BalanceCard(
          title: l10n.dashSupplierPayable,
          amount: summary.supplierPayable,
          color: semantic.payable,
          detail: [
            l10n.dashSuppliersCount(summary.suppliersWithDues),
            if (summary.overdueSuppliers > 0)
              l10n.dashOverdueCount(summary.overdueSuppliers),
          ].join(' · '),
          advanceLabel: l10n.dashSupplierAdvances,
          advances: summary.supplierAdvances,
          onTap: () => unawaited(
            context.push(AppRoutes.outstanding(PartyRole.supplier)),
          ),
        ),
        ReportCard(
          title: l10n.rangeToday,
          children: [
            AmountRow(
              label: l10n.txnCustomerCredit,
              amount: summary.todayCredit,
            ),
            AmountRow(
              label: l10n.dashTodayCollected,
              amount: summary.todayCollections,
            ),
            AmountRow(
              label: l10n.dashTodayExpenses,
              amount: summary.todayExpenses,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(l10n.dashQuickActions, style: theme.textTheme.titleSmall),
        ),
        Padding(
          padding: AppSpacing.page,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (icon, label, route) in [
                (
                  Icons.person_add_alt,
                  l10n.actionAddCustomer,
                  AppRoutes.partyNew(role: PartyRole.customer),
                ),
                (
                  Icons.south_west,
                  l10n.actionGiveCredit,
                  AppRoutes.charge(role: PartyRole.customer),
                ),
                (
                  Icons.payments_outlined,
                  l10n.actionReceivePayment,
                  AppRoutes.payment(role: PartyRole.customer),
                ),
                (
                  Icons.local_shipping_outlined,
                  l10n.actionAddSupplier,
                  AppRoutes.partyNew(role: PartyRole.supplier),
                ),
                (
                  Icons.receipt_long_outlined,
                  l10n.dashQuickExpense,
                  AppRoutes.expense,
                ),
                (
                  Icons.calculate_outlined,
                  l10n.dashQuickCashCount,
                  AppRoutes.dailyClose,
                ),
              ])
                ActionChip(
                  avatar: Icon(icon, size: AppSizes.iconSm),
                  label: Text(label),
                  onPressed: () => unawaited(context.push(route)),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.dashRecentActivity,
            style: theme.textTheme.titleSmall,
          ),
        ),
        if (state.activity.isEmpty)
          Padding(
            padding: AppSpacing.page,
            child: Text(l10n.partyNoEntries, style: muted),
          )
        else
          for (final item in state.activity) ...[
            ActivityTile(item: item),
            const Divider(),
          ],
      ],
    );
  }
}

/// One headline balance with its count line and, when there is one, the
/// matching advances as a separate figure (never netted).
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.detail,
    required this.advanceLabel,
    required this.advances,
    required this.onTap,
  });

  final String title;
  final Money amount;
  final Color color;
  final String detail;
  final String advanceLabel;
  final Money advances;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(color: color),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: MoneyText(
                  amount,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (advances.isPositive) ...[
                const Divider(),
                AmountRow(label: advanceLabel, amount: advances),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One recent entry: who or what, the kind of entry in words, the date
/// and the amount. Opens the entry.
class ActivityTile extends StatelessWidget {
  const ActivityTile({required this.item, super.key});

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final source = item.partyName ?? item.categoryName ?? item.description;

    return InkWell(
      onTap: () =>
          unawaited(context.push(AppRoutes.transaction(item.transactionId))),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.transactionTypeLabel(item.type),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      MoneyFormatter.format(item.amount),
                      style: AppTheme.amountStyle(theme.textTheme.titleMedium)
                          ?.copyWith(
                            decoration: item.isReversed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            if (source != null) Text(source, style: muted),
            Text(
              [
                AppDateFormat.instant(context, item.effectiveAt),
                if (item.isReversed) l10n.ledgerReversedTag,
              ].join(' · '),
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}
