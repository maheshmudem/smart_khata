import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_khata/app/router/app_routes.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/theme/app_tokens.dart';
import 'package:smart_khata/core/widgets/form_fields.dart';
import 'package:smart_khata/core/widgets/l10n_extensions.dart';
import 'package:smart_khata/core/widgets/state_views.dart';
import 'package:smart_khata/features/parties/presentation/cubit/parties_list_cubit.dart';

/// Chooses the customer or supplier for an entry form, with search and
/// create-inline (wireframes 5, `PartySearchField`). Pops with the chosen
/// party's ID.
class PartyPickerPage extends StatelessWidget {
  const PartyPickerPage({required this.role, super.key});

  final PartyRole role;

  /// Adds a party without leaving the entry flow: the new party is chosen
  /// straight away.
  Future<void> _addNew(BuildContext context) async {
    final partyId = await context.push<String>(
      AppRoutes.partyNew(role: role, returnOnSave: true),
    );
    if (partyId != null && context.mounted) context.pop(partyId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<PartiesListCubit>();
    final isCustomer = role == PartyRole.customer;
    final addLabel = isCustomer
        ? l10n.actionAddNewCustomer
        : l10n.actionAddNewSupplier;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCustomer ? l10n.chooseCustomer : l10n.chooseSupplier),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              autofocus: true,
              onChanged: cubit.searchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.pickPartySearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: Text(addLabel),
            onTap: () => _addNew(context),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<PartiesListCubit, PartiesListState>(
              builder: (context, state) => switch (state.status) {
                LoadStatus.loading => const LoadingView(),
                LoadStatus.failure => ErrorView(
                  message: l10n.failureMessage(
                    state.failure ?? const UnexpectedFailure(),
                    context: FailureContext.loading,
                  ),
                  onRetry: cubit.retry,
                ),
                LoadStatus.loaded when state.items.isEmpty => EmptyState(
                  icon: state.isSearching
                      ? Icons.search_off
                      : Icons.people_outline,
                  title: state.isSearching
                      ? l10n.partiesNoResultsTitle(
                          state.query.searchText.trim(),
                        )
                      : (isCustomer
                            ? l10n.partiesEmptyCustomersTitle
                            : l10n.partiesEmptySuppliersTitle),
                  actionLabel: addLabel,
                  onAction: () => _addNew(context),
                ),
                LoadStatus.loaded => ListView.separated(
                  itemCount: state.items.length + (state.hasMore ? 1 : 0),
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return TextButton(
                        onPressed: cubit.loadMore,
                        child: Text(l10n.actionLoadMore),
                      );
                    }
                    final item = state.items[index];
                    return ListTile(
                      title: Text(item.displayName),
                      subtitle: Text(
                        [
                          ?item.primaryPhone,
                          l10n.balanceText(item.balanceKind, item.balance),
                        ].join(' · '),
                      ),
                      onTap: () => context.pop(item.partyId),
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
