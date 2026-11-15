import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/money/presentation/widgets/payment_method_picker.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';
import 'package:smart_khata/features/reports/presentation/report_exports.dart';
import 'package:smart_khata/features/reports/presentation/report_widgets.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

extension _AgingLabelsX on AppLocalizations {
  String bucketName(AgingBucket bucket) => switch (bucket) {
    AgingBucket.upTo7Days => agingUpTo7,
    AgingBucket.days8To15 => aging8To15,
    AgingBucket.days16To30 => aging16To30,
    AgingBucket.over30Days => agingOver30,
  };
}

void _showShareFailed(BuildContext context) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(context.l10n.shareFailed)));

/// WF-050: the list of reports.
class ReportsHomePage extends StatelessWidget {
  const ReportsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: ListView(
        children: [
          for (final (icon, title, hint, route) in [
            (
              Icons.south_west,
              l10n.reportsCustomerDues,
              l10n.reportsCustomerDuesHint,
              AppRoutes.outstanding(PartyRole.customer),
            ),
            (
              Icons.north_east,
              l10n.reportsSupplierDues,
              l10n.reportsSupplierDuesHint,
              AppRoutes.outstanding(PartyRole.supplier),
            ),
            (
              Icons.date_range_outlined,
              l10n.periodReportTitle,
              l10n.reportsPeriodHint,
              AppRoutes.periodReport,
            ),
            (
              Icons.account_balance_wallet_outlined,
              l10n.moreCashBook,
              l10n.reportsCashBookHint,
              AppRoutes.cashBook,
            ),
            (
              Icons.history,
              l10n.moreClosingHistory,
              l10n.reportsClosingHint,
              AppRoutes.closingHistory,
            ),
          ])
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(hint),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(route)),
            ),
          const Divider(),
          ReportNote(l10n.reportsInfoNote),
        ],
      ),
    );
  }
}

/// WF-051: who still owes (or is owed), split by how long it has been due.
class OutstandingPage extends StatelessWidget {
  const OutstandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OutstandingCubit>();

    return BlocConsumer<OutstandingCubit, OutstandingState>(
      listenWhen: (before, after) => after.shareFailures > before.shareFailures,
      listener: (context, state) => _showShareFailed(context),
      builder: (context, state) {
        final report = state.report;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.outstandingTitle),
            actions: [
              IconButton(
                tooltip: l10n.actionExportCsv,
                icon: const Icon(Icons.table_view_outlined),
                onPressed: report == null || report.rows.isEmpty
                    ? null
                    : () => unawaited(
                        cubit.shareCsv(
                          fileName:
                              'dues-${report.role.code}-'
                              '${report.asOf.toIso()}.csv',
                          content: ReportExports.outstandingCsv(
                            l10n: l10n,
                            report: report,
                          ),
                          subject: l10n.outstandingTitle,
                        ),
                      ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: SegmentedButton<PartyRole>(
                  segments: [
                    ButtonSegment(
                      value: PartyRole.customer,
                      label: Text(l10n.partiesTabCustomers),
                    ),
                    ButtonSegment(
                      value: PartyRole.supplier,
                      label: Text(l10n.partiesTabSuppliers),
                    ),
                  ],
                  selected: {state.role},
                  showSelectedIcon: false,
                  onSelectionChanged: (roles) =>
                      cubit.roleSelected(roles.single),
                ),
              ),
              if (state.status == LoadStatus.failure)
                ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: cubit.retry,
                )
              else if (report == null)
                const SizedBox(height: 96, child: LoadingView())
              else
                ..._report(context, report, cubit),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _report(
    BuildContext context,
    OutstandingReport report,
    OutstandingCubit cubit,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isCustomer = report.role == PartyRole.customer;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return [
      ReportCard(
        title: l10n.asOfLabel(AppDateFormat.date(context, report.asOf)),
        children: [
          AmountRow(
            label: isCustomer
                ? l10n.dashCustomerOutstanding
                : l10n.dashSupplierPayable,
            amount: report.totals.total,
            strong: true,
          ),
          const Divider(),
          for (final bucket in AgingBucket.values)
            AmountRow(
              label: l10n.bucketName(bucket),
              amount: report.totals.amountIn(bucket),
            ),
        ],
      ),
      ReportNote(
        isCustomer
            ? l10n.outstandingMeasureCustomer
            : l10n.outstandingMeasureSupplier,
      ),
      if (report.rows.isEmpty)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            isCustomer
                ? l10n.outstandingEmptyCustomers
                : l10n.outstandingEmptySuppliers,
            textAlign: TextAlign.center,
          ),
        ),
      for (final row in report.rows) ...[
        InkWell(
          onTap: () async {
            await context.push(
              AppRoutes.partyLedger(row.partyId, row.accountId),
            );
            // A payment may have been recorded there.
            if (!cubit.isClosed) unawaited(cubit.load());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.partyName, style: theme.textTheme.titleSmall),
                AmountRow(
                  label: l10n.balanceLabel(
                    BalanceKind.of(report.role, row.total),
                  ),
                  amount: row.total,
                ),
                Text(
                  [
                    for (final bucket in AgingBucket.values)
                      if (row.aging.amountIn(bucket).isPositive)
                        [
                          l10n.bucketName(bucket),
                          MoneyFormatter.format(row.aging.amountIn(bucket)),
                        ].join(': '),
                  ].join(' · '),
                  style: muted,
                ),
                Text(
                  l10n.outstandingRowDetail(
                    row.openEntryCount,
                    AppDateFormat.instant(context, row.oldestAgingDate),
                  ),
                  style: muted,
                ),
              ],
            ),
          ),
        ),
        const Divider(),
      ],
      if (report.isTruncated)
        ReportNote(l10n.outstandingTruncated(report.rows.length)),
      if (report.advances.isNotEmpty) ...[
        // Advances are their own list and are never taken off the dues.
        ReportCard(
          title: isCustomer
              ? l10n.dashCustomerAdvances
              : l10n.dashSupplierAdvances,
          children: [
            for (final advance in report.advances)
              AmountRow(label: advance.partyName, amount: advance.amount),
            const Divider(),
            AmountRow(
              label: l10n.totalLabel,
              amount: report.totalAdvances,
              strong: true,
            ),
          ],
        ),
        ReportNote(l10n.advancesNotNettedNote),
      ],
    ];
  }
}

/// Totals of the entries dated in a period (FR-REP-004, FR-REP-005).
class PeriodReportPage extends StatelessWidget {
  const PeriodReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PeriodReportCubit>();

    return BlocBuilder<PeriodReportCubit, PeriodReportState>(
      builder: (context, state) {
        final report = state.report;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.periodReportTitle)),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              PeriodFilter(
                period: state.period,
                today: cubit.today,
                onChanged: cubit.periodSelected,
              ),
              if (state.status == LoadStatus.failure)
                ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: cubit.retry,
                )
              else if (report == null || state.status == LoadStatus.loading)
                const SizedBox(height: 96, child: LoadingView())
              else
                ..._report(context, report),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _report(BuildContext context, PeriodReport report) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return [
      ReportCard(
        title: l10n.partiesTabCustomers,
        children: [
          AmountRow(label: l10n.txnCustomerCredit, amount: report.creditGiven),
          AmountRow(
            label: l10n.txnCustomerPayment,
            amount: report.collections,
          ),
          for (final MapEntry(key: method, value: amount)
              in report.collectionsByMethod.entries)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
              child: AmountRow(label: l10n.methodName(method), amount: amount),
            ),
          if (report.salesReturns.isPositive)
            AmountRow(
              label: l10n.txnCustomerSalesReturn,
              amount: report.salesReturns,
            ),
        ],
      ),
      ReportCard(
        title: l10n.partiesTabSuppliers,
        children: [
          AmountRow(label: l10n.txnSupplierPurchase, amount: report.purchases),
          AmountRow(
            label: l10n.txnSupplierPayment,
            amount: report.supplierPayments,
          ),
          if (report.purchaseReturns.isPositive)
            AmountRow(
              label: l10n.txnSupplierPurchaseReturn,
              amount: report.purchaseReturns,
            ),
        ],
      ),
      ReportCard(
        title: l10n.periodExpensesByCategory,
        children: [
          for (final MapEntry(key: name, value: amount)
              in report.expensesByCategory.entries)
            AmountRow(label: name, amount: amount),
          if (report.expensesByCategory.isNotEmpty) const Divider(),
          AmountRow(
            label: l10n.totalLabel,
            amount: report.expenses,
            strong: true,
          ),
        ],
      ),
      ReportNote(l10n.periodMeasure),
      if (report.days.isNotEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: Text(l10n.periodByDay, style: theme.textTheme.titleSmall),
        ),
      for (final day in report.days)
        ReportCard(
          title: AppDateFormat.date(context, day.date),
          children: [
            AmountRow(label: l10n.txnCustomerCredit, amount: day.creditGiven),
            AmountRow(label: l10n.dashTodayCollected, amount: day.collections),
            AmountRow(label: l10n.dashTodayExpenses, amount: day.expenses),
          ],
        ),
      if (report.hasMoreDays)
        ReportNote(l10n.periodMoreDays(report.days.length)),
    ];
  }
}

/// WF-052: one party's statement for a period, previewed before it is
/// shared as text or exported as CSV.
class StatementPage extends StatelessWidget {
  const StatementPage({super.key});

  static BusinessDate _day(DateTime instantUtc) =>
      BusinessDate.fromInstant(instantUtc, ShopTimeZone.resolve(null));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<StatementCubit>();

    return BlocConsumer<StatementCubit, StatementState>(
      listenWhen: (before, after) => after.shareFailures > before.shareFailures,
      listener: (context, state) => _showShareFailed(context),
      builder: (context, state) {
        final statement = state.statement;
        final ready = statement != null && state.status == LoadStatus.loaded;
        final periodText = l10n.periodText(
          context,
          state.period.range,
          cubit.today,
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.statementTitle),
            actions: [
              IconButton(
                tooltip: l10n.actionShareText,
                icon: const Icon(Icons.share_outlined),
                onPressed: !ready
                    ? null
                    : () => unawaited(
                        cubit.shareText(
                          ReportExports.statementText(
                            l10n: l10n,
                            statement: statement,
                            shopName: state.shopName,
                            periodText: periodText,
                            formatDate: (date) =>
                                AppDateFormat.date(context, date),
                          ),
                          subject: l10n.statementTitle,
                        ),
                      ),
              ),
              IconButton(
                tooltip: l10n.actionExportCsv,
                icon: const Icon(Icons.table_view_outlined),
                onPressed: !ready
                    ? null
                    : () => unawaited(
                        cubit.shareCsv(
                          fileName: 'statement-${cubit.today.toIso()}.csv',
                          content: ReportExports.statementCsv(
                            l10n: l10n,
                            statement: statement,
                          ),
                          subject: l10n.statementTitle,
                        ),
                      ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              PeriodFilter(
                period: state.period,
                today: cubit.today,
                presets: const [
                  DateRangePreset.allTime,
                  DateRangePreset.thisMonth,
                  DateRangePreset.lastMonth,
                ],
                onChanged: cubit.periodSelected,
              ),
              if (state.status == LoadStatus.failure)
                ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: state.failure is NotFoundFailure
                      ? null
                      : cubit.retry,
                )
              else if (!ready)
                const SizedBox(height: 96, child: LoadingView())
              else
                ..._statement(context, state, statement),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _statement(
    BuildContext context,
    StatementState state,
    PartyStatement statement,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final role = statement.role;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    Widget balanceRow(String label, StatementLine? line, {bool strong = true}) {
      final amount = line?.balanceAfter ?? statement.openingBalance;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: muted),
            Text(
              l10n.balanceText(BalanceKind.of(role, amount), amount),
              style: strong ? theme.textTheme.titleMedium : null,
            ),
          ],
        ),
      );
    }

    final closing = statement.closingBalance;
    return [
      ReportCard(
        children: [
          if (state.shopName.isNotEmpty) Text(state.shopName, style: muted),
          Text(
            '${statement.partyName} (${l10n.roleLabel(role)})',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          balanceRow(l10n.statementOpening, null),
        ],
      ),
      if (statement.isTruncated)
        ReportNote(l10n.statementTruncated(statement.lines.length)),
      if (statement.lines.isEmpty)
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(l10n.periodNoEntries, textAlign: TextAlign.center),
        ),
      for (final line in statement.lines) ...[
        Padding(
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
                      l10n.transactionTypeLabel(line.type),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        MoneyFormatter.format(line.amount.abs()),
                        style: AppTheme.amountStyle(theme.textTheme.titleMedium)
                            ?.copyWith(
                              decoration: line.isReversed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              if (line.description != null)
                Text(line.description!, style: muted),
              Text(
                [
                  AppDateFormat.date(context, _day(line.effectiveAt)),
                  if (line.isReversed) l10n.ledgerReversedTag,
                ].join(' · '),
                style: muted,
              ),
              Text(
                l10n.ledgerBalanceAfter(
                  l10n.balanceText(
                    BalanceKind.of(role, line.balanceAfter),
                    line.balanceAfter,
                  ),
                ),
                style: muted,
              ),
            ],
          ),
        ),
        const Divider(),
      ],
      ReportCard(
        children: [
          Text(l10n.statementClosing, style: muted),
          Text(
            l10n.balanceText(BalanceKind.of(role, closing), closing),
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
      ReportNote(l10n.statementCurrencyNote),
    ];
  }
}
