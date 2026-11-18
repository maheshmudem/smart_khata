import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

final class PartiesListState extends Equatable {
  const PartiesListState({
    required this.query,
    this.items = const Loading(),
    this.hasMore = false,
  });

  final PartyListQuery query;
  final LoadState<List<PartyListItem>> items;

  /// More rows exist beyond the current page.
  final bool hasMore;

  PartiesListState copyWith({
    PartyListQuery? query,
    LoadState<List<PartyListItem>>? items,
    bool? hasMore,
  }) => PartiesListState(
    query: query ?? this.query,
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  List<Object?> get props => [query, items, hasMore];
}

/// WF-020: the live, paginated parties list for one role.
class PartiesListCubit extends Cubit<PartiesListState> {
  PartiesListCubit(this._parties, {PartyRole role = PartyRole.customer})
    : super(PartiesListState(query: PartyListQuery(role: role))) {
    _subscribe();
  }

  static const int pageSize = 50;

  final PartyRepository _parties;
  StreamSubscription<Result<List<PartyListItem>>>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final query = state.query;
    // Ask for one extra row to learn whether a next page exists.
    _subscription = _parties
        .watchList(query.copyWith(limit: query.limit + 1))
        .listen((result) {
          switch (result) {
            case Ok(:final value):
              emit(
                state.copyWith(
                  items: Loaded(value.take(query.limit).toList()),
                  hasMore: value.length > query.limit,
                ),
              );
            case Err(:final failure):
              emit(state.copyWith(items: LoadFailed(failure)));
          }
        });
  }

  void _requery(PartyListQuery query, {bool showLoading = false}) {
    if (query == state.query) return;
    emit(
      state.copyWith(
        query: query,
        items: showLoading ? const Loading() : null,
      ),
    );
    _subscribe();
  }

  void selectRole(PartyRole role) => _requery(
    state.query.copyWith(role: role, limit: pageSize),
    showLoading: true,
  );

  void search(String text) =>
      _requery(state.query.copyWith(search: text, limit: pageSize));

  void filter(PartyListFilter filter) =>
      _requery(state.query.copyWith(filter: filter, limit: pageSize));

  void loadMore() =>
      _requery(state.query.copyWith(limit: state.query.limit + pageSize));

  void retry() {
    emit(state.copyWith(items: const Loading()));
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
