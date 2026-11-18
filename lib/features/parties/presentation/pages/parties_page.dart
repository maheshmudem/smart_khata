import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/app_buttons.dart';
import 'package:smart_khata/core/widgets/app_cards.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/presentation/bloc/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/widgets/party_tile.dart';

/// WF-020: Customers and Suppliers, searchable and filtered. A dual-role
/// party appears on both tabs, each with its own balance.
class PartiesPage extends StatelessWidget {
  const PartiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<PartiesListCubit>().state;
    final role = state.query.role;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navParties)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.partyNewFor(role)),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(
          role == PartyRole.customer
              ? l10n.actionAddCustomer
              : l10n.actionAddSupplier,
        ),
      ),
      // One scrolling list so the header never squeezes the rows out on a
      // small phone with large text.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxxl + AppSpacing.xxl,
        ),
        children: [
          const _Header(),
          const SizedBox(height: AppSpacing.md),
          ..._body(context, state),
        ],
      ),
    );
  }

  List<Widget> _body(BuildContext context, PartiesListState state) {
    final l10n = context.l10n;
    final cubit = context.read<PartiesListCubit>();
    final query = state.query;
    switch (state.items) {
      case Loading():
        return const [SizedBox(height: 200, child: LoadingView())];
      case LoadFailed():
        return [
          SizedBox(
            height: 320,
            child: ErrorView(
              message: l10n.errorLoadFailed,
              onRetry: cubit.retry,
            ),
          ),
        ];
      case Loaded(value: final items) when items.isEmpty:
        final searching = query.search.trim().isNotEmpty;
        final filtering = query.filter != PartyListFilter.all;
        return [
          if (searching)
            EmptyState(
              icon: Icons.search_off,
              title: l10n.partiesNoMatch(query.search.trim()),
            )
          else if (filtering)
            EmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: l10n.partiesNoFilterMatch,
            )
          else
            EmptyState(
              icon: Icons.group_add_outlined,
              title: query.role == PartyRole.customer
                  ? l10n.partiesEmptyCustomers
                  : l10n.partiesEmptySuppliers,
              message: l10n.partiesEmptyBody,
            ),
        ];
      case Loaded(value: final items):
        return [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: PartyTile(
                item: item,
                onTap: () => context.push(AppRoutes.partyDetail(item.partyId)),
              ),
            ),
          if (state.hasMore)
            AppSecondaryButton(
              label: l10n.actionLoadMore,
              onPressed: cubit.loadMore,
            ),
        ];
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PartiesListCubit>();
    final query = context.select<PartiesListCubit, PartyListQuery>(
      (cubit) => cubit.state.query,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<PartyRole>(
          segments: [
            ButtonSegment(
              value: PartyRole.customer,
              label: Text(l10n.roleCustomers),
              icon: const Icon(Icons.people_alt_outlined),
            ),
            ButtonSegment(
              value: PartyRole.supplier,
              label: Text(l10n.roleSuppliers),
              icon: const Icon(Icons.local_shipping_outlined),
            ),
          ],
          selected: {query.role},
          showSelectedIcon: false,
          onSelectionChanged: (s) => cubit.selectRole(s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        PartySearchField(
          hintText: l10n.partiesSearchHint,
          onChanged: cubit.search,
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (filter, label) in [
                (PartyListFilter.all, l10n.filterAll),
                (PartyListFilter.hasDues, l10n.filterHasDues),
                (PartyListFilter.advance, l10n.filterAdvance),
                (PartyListFilter.archived, l10n.filterArchived),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: query.filter == filter,
                    showCheckmark: false,
                    onSelected: (_) => cubit.filter(filter),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
