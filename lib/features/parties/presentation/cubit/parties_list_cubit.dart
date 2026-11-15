import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

class PartiesListState extends Equatable {
  const PartiesListState({
    required this.query,
    this.status = LoadStatus.loading,
    this.items = const [],
    this.failure,
  });

  final PartyListQuery query;
  final LoadStatus status;
  final List<PartyListItem> items;
  final Failure? failure;

  /// The query returned a full page, so there may be more rows.
  bool get hasMore => items.length >= query.limit;

  bool get isSearching => query.searchText.trim().isNotEmpty;

  /// Nothing narrows the list: an empty result means no parties exist.
  bool get isUnfiltered => !isSearching && query.filter == PartyListFilter.all;

  PartiesListState copyWith({
    PartyListQuery? query,
    LoadStatus? status,
    List<PartyListItem>? items,
    Failure? failure,
  }) => PartiesListState(
    query: query ?? this.query,
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
  );

  @override
  List<Object?> get props => [query, status, items, failure];
}

/// WF-020: a live, bounded list of customers or suppliers.
class PartiesListCubit extends Cubit<PartiesListState> {
  PartiesListCubit({
    required this._repository,
    PartyRole initialRole = PartyRole.customer,
    this.searchDebounce = const Duration(milliseconds: 250),
  }) : super(PartiesListState(query: PartyListQuery(role: initialRole))) {
    _subscribe();
  }

  final PartyRepository _repository;
  final Duration searchDebounce;

  StreamSubscription<List<PartyListItem>>? _subscription;
  Timer? _debounce;

  void roleChanged(PartyRole role) {
    if (role == state.query.role) return;
    // Each tab starts from its own first page; search text is kept.
    _apply(
      state.query.copyWith(
        role: role,
        filter: PartyListFilter.all,
        limit: PartyListQuery.pageSize,
      ),
    );
  }

  void filterChanged(PartyListFilter filter) => _apply(
    state.query.copyWith(filter: filter, limit: PartyListQuery.pageSize),
  );

  void sortChanged(PartyListSort sort) =>
      _apply(state.query.copyWith(sort: sort, limit: PartyListQuery.pageSize));

  /// Search waits briefly so a query is not run for every keystroke.
  void searchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      searchDebounce,
      () => _apply(
        state.query.copyWith(searchText: text, limit: PartyListQuery.pageSize),
      ),
    );
  }

  void clearSearch() {
    _debounce?.cancel();
    _apply(
      state.query.copyWith(searchText: '', limit: PartyListQuery.pageSize),
    );
  }

  void loadMore() {
    if (!state.hasMore) return;
    _apply(
      state.query.copyWith(limit: state.query.limit + PartyListQuery.pageSize),
      keepItems: true,
    );
  }

  void retry() => _apply(state.query);

  void _apply(PartyListQuery query, {bool keepItems = false}) {
    if (isClosed) return;
    emit(
      state.copyWith(
        query: query,
        // Loading more keeps the rows on screen instead of flashing.
        status: keepItems ? state.status : LoadStatus.loading,
      ),
    );
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchParties(state.query)
        .listen(
          (items) => emit(
            state.copyWith(status: LoadStatus.loaded, items: items),
          ),
          onError: (Object error) => emit(
            state.copyWith(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
