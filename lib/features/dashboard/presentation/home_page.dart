import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/money_text.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';
import 'package:smart_khata/features/dashboard/presentation/home_cubit.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';

/// WF-010: Home. What customers owe and what the shop owes suppliers are
/// separate figures and are never combined; there is no profit figure
/// (PRD 9.5).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<HomeCubit>().state;
    return Scaffold(
      body: switch (state) {
        Loading() => const SafeArea(child: LoadingView()),
        LoadFailed() => SafeArea(
          child: ErrorView(
            message: l10n.errorLoadFailed,
            onRetry: context.read<HomeCubit>().retry,
          ),
        ),
        Loaded(value: final summary) => _Dashboard(summary: summary),
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(summary: summary),
        // The action card overlaps the bottom of the header.
        Transform.translate(
          offset: const Offset(0, -AppSpacing.xxl),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _QuickActions(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (summary.hasNoParties) const _FirstRunCard(),
              if (!summary.hasNoParties) ...[
                Semantics(
                  header: true,
                  child: Text(
                    l10n.homeToday,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _TodayRow(summary: summary),
              ],
              const SizedBox(height: AppSpacing.lg),
              const _BackupWarning(),
              SectionHeader(title: l10n.homeRecentActivity),
              _RecentActivity(items: summary.recent),
            ],
          ),
        ),
      ],
    );
  }
}

/// The gradient top of Home: greeting, shop, date, and the two balances
/// side by side, each named in words.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final today = summary.today;
    final dateText = DateFormat.MMMEd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime.utc(today.year, today.month, today.day));
    final topInset = MediaQuery.paddingOf(context).top;

    String? advanceNote(Money advance) => advance.isZero
        ? null
        : l10n.homeAdvanceNote(MoneyFormatter.format(advance));

    final customers = summary.customers;
    final suppliers = summary.suppliers;
    final customersOwe = MoneyFormatter.format(customers.owed);
    final youOwe = MoneyFormatter.format(suppliers.owed);

    return GradientSurface(
      raised: false,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.xl + AppSpacing.xs),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topInset + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl + AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSizes.avatar,
                height: AppSizes.avatar,
                decoration: BoxDecoration(
                  color: AppGradients.onGradient.withValues(alpha: 0.18),
                  borderRadius: AppRadius.control,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppGradients.onGradient,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeWelcome,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppGradients.onGradientMuted,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        summary.shopName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppGradients.onGradient,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppGradients.onGradient.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: AppSpacing.lg,
                    color: AppGradients.onGradient,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      dateText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppGradients.onGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GlassTile(
                    icon: Icons.south_west_rounded,
                    label: l10n.homeCustomersOweYou,
                    value: customersOwe,
                    footnote: advanceNote(customers.advance),
                    semanticsLabel: l10n.amountSemantics(
                      l10n.homeCustomersOweYou,
                      customersOwe,
                    ),
                    onTap: () =>
                        context.go(AppRoutes.partiesFor(PartyRole.customer)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassTile(
                    icon: Icons.north_east_rounded,
                    label: l10n.homeYouOweSuppliers,
                    value: youOwe,
                    footnote: advanceNote(suppliers.advance),
                    semanticsLabel: l10n.amountSemantics(
                      l10n.homeYouOweSuppliers,
                      youOwe,
                    ),
                    onTap: () =>
                        context.go(AppRoutes.partiesFor(PartyRole.supplier)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CircleAction(
              icon: Icons.person_add_alt_1_rounded,
              label: l10n.actionAddCustomer,
              onTap: () =>
                  context.push(AppRoutes.partyNewFor(PartyRole.customer)),
            ),
          ),
          Expanded(
            child: CircleAction(
              icon: Icons.local_shipping_rounded,
              label: l10n.actionAddSupplier,
              onTap: () =>
                  context.push(AppRoutes.partyNewFor(PartyRole.supplier)),
            ),
          ),
          Expanded(
            child: CircleAction(
              icon: Icons.south_west_rounded,
              label: l10n.actionGiveCredit,
              onTap: () =>
                  context.push(AppRoutes.entry(EntryType.customerCredit)),
            ),
          ),
          Expanded(
            child: CircleAction(
              icon: Icons.payments_rounded,
              label: l10n.actionReceivePayment,
              onTap: () =>
                  context.push(AppRoutes.entry(EntryType.customerPayment)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's figures in one calm white card, split into three columns.
class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final divider = VerticalDivider(
      width: AppSpacing.lg,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _TodayFigure(
                icon: Icons.south_west_rounded,
                label: l10n.todayCredit,
                amount: summary.todayCredit,
              ),
            ),
            divider,
            Expanded(
              child: _TodayFigure(
                icon: Icons.payments_rounded,
                label: l10n.todayCollected,
                amount: summary.todayCollections,
              ),
            ),
            divider,
            Expanded(
              child: _TodayFigure(
                icon: Icons.receipt_long_rounded,
                label: l10n.todayExpenses,
                amount: summary.todayExpenses,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayFigure extends StatelessWidget {
  const _TodayFigure({
    required this.icon,
    required this.label,
    required this.amount,
  });

  final IconData icon;
  final String label;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final formatted = MoneyFormatter.format(amount);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: context.l10n.amountSemantics(label, formatted),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSm,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatted,
              style: AppTheme.amountStyle(theme.textTheme.titleMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstRunCard extends StatelessWidget {
  const _FirstRunCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              gradient: AppGradients.action,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_add_rounded,
              color: AppGradients.onGradient,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.homeEmptyTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.homeEmptyBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: l10n.actionAddCustomer,
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () =>
                context.push(AppRoutes.partyNewFor(PartyRole.customer)),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: l10n.actionAddSupplier,
            icon: Icons.local_shipping_rounded,
            onPressed: () =>
                context.push(AppRoutes.partyNewFor(PartyRole.supplier)),
          ),
        ],
      ),
    );
  }
}

/// A quiet reminder: a white card; only the small icon carries amber.
class _BackupWarning extends StatelessWidget {
  const _BackupWarning();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: AppRadius.control,
            ),
            child: Icon(
              Icons.shield_outlined,
              size: AppSizes.iconMd,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.backupWarningTitle,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.backupWarningBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (items.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.homeNoActivity,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final (index, item) in items.indexed) ...[
            if (index > 0)
              const Divider(
                indent: AppSpacing.lg + AppSizes.avatar + AppSpacing.md,
                endIndent: AppSpacing.lg,
              ),
            _ActivityRow(item: item, locale: locale),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item, required this.locale});

  final ActivityItem item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final kind = BalanceKind.of(item.role, item.signedAmount);
    // The shop's business day, not the phone's zone (ADR-021).
    final day = BusinessDate.fromInstant(
      item.effectiveAt,
      ShopTimeZone.resolve(ShopTimeZone.defaultName),
    );
    final date = DateFormat.MMMd(
      locale,
    ).format(DateTime.utc(day.year, day.month, day.day));
    final color = balanceColor(context, kind);
    return InkWell(
      onTap: () => context.push(AppRoutes.partyDetail(item.partyId)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            PartyAvatar(name: item.partyName),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.partyName, style: theme.textTheme.titleSmall),
                  Text(
                    '${l10n.transactionLabel(item.type)} · $date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    item.signedAmount.abs(),
                    style: theme.textTheme.titleSmall,
                    color: color,
                  ),
                  Text(
                    l10n.balanceLabel(kind),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
