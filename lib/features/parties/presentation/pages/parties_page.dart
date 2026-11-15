import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/core/theme/app_colors.dart';
import 'package:smart_khata/core/theme/app_theme.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/formatters.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/presentation/cubit/parties_list_cubit.dart';
import 'package:smart_khata/l10n/generated/app_localizations.dart';

/// WF-020: customers and suppliers with their role-specific balances.
class PartiesPage extends StatefulWidget {
  const PartiesPage({super.key});

  @override
  State<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends State<PartiesPage> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _addParty(PartyRole role) =>
      unawaited(context.push(AppRoutes.partyNew(role: role)));

  void _clearSearch() {
    _search.clear();
    context.read<PartiesListCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PartiesListCubit>();

    return BlocBuilder<PartiesListCubit, PartiesListState>(
      builder: (context, state) {
        final query = state.query;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.navParties),
            actions: [
              PopupMenuButton<PartyListSort>(
                tooltip: l10n.sortLabel,
                icon: const Icon(Icons.sort),
                initialValue: query.sort,
                onSelected: cubit.sortChanged,
                itemBuilder: (context) => [
                  for (final sort in PartyListSort.values)
                    PopupMenuItem(
                      value: sort,
                      child: Text(_sortLabel(l10n, sort)),
                    ),
                ],
              ),
              IconButton(
                tooltip: l10n.addPartyTooltip,
                icon: const Icon(Icons.person_add_alt_1),
                onPressed: () => _addParty(query.role),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<PartyRole>(
                        showSelectedIcon: false,
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
                        selected: {query.role},
                        onSelectionChanged: (roles) =>
                            cubit.roleChanged(roles.first),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _search,
                      onChanged: cubit.searchChanged,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.partiesSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.actionClearSearch,
                                icon: const Icon(Icons.close),
                                onPressed: _clearSearch,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppSizes.minTouchTarget,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.page,
                  children: [
                    for (final filter in PartyListFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(_filterLabel(l10n, filter)),
                          selected: query.filter == filter,
                          onSelected: (_) => cubit.filterChanged(filter),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: switch (state.status) {
                  LoadStatus.loading => const LoadingView(),
                  LoadStatus.failure => ErrorView(
                    message: l10n.failureMessage(
                      state.failure ?? const UnexpectedFailure(),
                      context: FailureContext.loading,
                    ),
                    onRetry: cubit.retry,
                  ),
                  LoadStatus.loaded when state.items.isEmpty => _empty(
                    l10n,
                    state,
                  ),
                  LoadStatus.loaded => _PartyList(
                    state: state,
                    onLoadMore: cubit.loadMore,
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(AppLocalizations l10n, PartiesListState state) {
    final role = state.query.role;
    if (state.isSearching) {
      return EmptyState(
        icon: Icons.search_off,
        title: l10n.partiesNoResultsTitle(state.query.searchText.trim()),
        actionLabel: l10n.actionClearSearch,
        onAction: _clearSearch,
      );
    }
    if (!state.isUnfiltered) {
      return EmptyState(title: l10n.partiesNothingInFilter);
    }
    return switch (role) {
      PartyRole.customer => EmptyState(
        icon: Icons.people_outline,
        title: l10n.partiesEmptyCustomersTitle,
        message: l10n.partiesEmptyCustomersBody,
        actionLabel: l10n.actionAddCustomer,
        onAction: () => _addParty(role),
      ),
      PartyRole.supplier => EmptyState(
        icon: Icons.local_shipping_outlined,
        title: l10n.partiesEmptySuppliersTitle,
        message: l10n.partiesEmptySuppliersBody,
        actionLabel: l10n.actionAddSupplier,
        onAction: () => _addParty(role),
      ),
    };
  }

  static String _filterLabel(AppLocalizations l10n, PartyListFilter filter) =>
      switch (filter) {
        PartyListFilter.all => l10n.filterAll,
        PartyListFilter.outstanding => l10n.filterOutstanding,
        PartyListFilter.advance => l10n.filterAdvance,
        PartyListFilter.archived => l10n.filterArchived,
      };

  static String _sortLabel(AppLocalizations l10n, PartyListSort sort) =>
      switch (sort) {
        PartyListSort.name => l10n.sortName,
        PartyListSort.highestBalance => l10n.sortHighestBalance,
        PartyListSort.recentActivity => l10n.sortRecentActivity,
      };
}

class _PartyList extends StatelessWidget {
  const _PartyList({required this.state, required this.onLoadMore});

  final PartiesListState state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    return ListView.separated(
      itemCount: items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextButton(
              onPressed: onLoadMore,
              child: Text(context.l10n.actionLoadMore),
            ),
          );
        }
        return _PartyTile(item: items[index]);
      },
    );
  }
}

/// A list row: name and phone on the left; the balance with its direction
/// in words on the right (never colour or sign alone).
class _PartyTile extends StatelessWidget {
  const _PartyTile({required this.item});

  final PartyListItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final kind = item.balanceKind;
    final color = switch (kind) {
      BalanceKind.customerOwes => semantic.receivable,
      BalanceKind.youOweSupplier => semantic.payable,
      BalanceKind.customerAdvance ||
      BalanceKind.supplierAdvance => semantic.advance,
      BalanceKind.settled => semantic.neutral,
    };
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final lastEntry = switch (item.lastActivityAt) {
      final DateTime at => l10n.partyLastEntry(
        AppDateFormat.instant(context, at),
      ),
      null => l10n.partyNoEntries,
    };

    return InkWell(
      onTap: () => unawaited(
        context.push(AppRoutes.partyDetail(item.partyId, role: item.role)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayName, style: theme.textTheme.titleMedium),
                  if (item.primaryPhone case final String phone)
                    Text(phone, style: muted),
                  Text(
                    item.isArchived ? l10n.partyArchivedLabel : lastEntry,
                    style: muted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Bounded to half the row: the label wraps and a very large
            // amount shrinks, so the row never overflows.
            Flexible(
              child: Semantics(
                label: l10n.amountSemantics(
                  l10n.balanceLabel(kind),
                  MoneyFormatter.format(item.balance.abs()),
                ),
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.balanceLabel(kind),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    if (kind != BalanceKind.settled)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          MoneyFormatter.format(item.balance.abs()),
                          style: AppTheme.amountStyle(
                            theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
