import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

class PartyDetailState extends Equatable {
  const PartyDetailState({
    this.status = LoadStatus.loading,
    this.detail,
    this.selectedRole,
    this.entries = const [],
    this.failure,
    this.actionFailure,
  });

  final LoadStatus status;
  final PartyDetail? detail;

  /// Which role's ledger is shown. A dual-role party switches between two
  /// separate balances; they are never combined.
  final PartyRole? selectedRole;
  final List<LedgerEntrySummary> entries;
  final Failure? failure;

  /// An archive/reactivate attempt that failed; shown once.
  final Failure? actionFailure;

  PartyAccountSummary? get account => switch ((detail, selectedRole)) {
    (final PartyDetail d, final PartyRole role) => d.accountFor(role),
    _ => null,
  };

  PartyDetailState copyWith({
    LoadStatus? status,
    PartyDetail? detail,
    PartyRole? selectedRole,
    List<LedgerEntrySummary>? entries,
    Failure? failure,
    Failure? actionFailure,
  }) => PartyDetailState(
    status: status ?? this.status,
    detail: detail ?? this.detail,
    selectedRole: selectedRole ?? this.selectedRole,
    entries: entries ?? this.entries,
    failure: failure,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    detail,
    selectedRole,
    entries,
    failure,
    actionFailure,
  ];
}

/// WF-022: one party, one role at a time, kept live.
class PartyDetailCubit extends Cubit<PartyDetailState> {
  PartyDetailCubit({
    required this._repository,
    required this.partyId,
    PartyRole? initialRole,
  }) : _preferredRole = initialRole,
       super(const PartyDetailState()) {
    _watchParty();
  }

  final PartyRepository _repository;
  final String partyId;
  final PartyRole? _preferredRole;

  StreamSubscription<PartyDetail?>? _partySubscription;
  StreamSubscription<List<LedgerEntrySummary>>? _entriesSubscription;
  String? _watchedAccountId;

  void _watchParty() {
    unawaited(_partySubscription?.cancel());
    _partySubscription = _repository
        .watchParty(partyId)
        .listen(_onDetail, onError: _onError);
  }

  void _onDetail(PartyDetail? detail) {
    if (detail == null || detail.accounts.isEmpty) {
      emit(
        const PartyDetailState(
          status: LoadStatus.failure,
          failure: NotFoundFailure('party'),
        ),
      );
      return;
    }
    final current = state.selectedRole ?? _preferredRole;
    final role = current != null && detail.roles.contains(current)
        ? current
        : detail.accounts.first.role;
    emit(
      state.copyWith(
        status: LoadStatus.loaded,
        detail: detail,
        selectedRole: role,
      ),
    );
    _watchEntries(detail.accountFor(role)!.accountId);
  }

  void _onError(Object error) => emit(
    state.copyWith(
      status: LoadStatus.failure,
      failure: FailureException.failureOf(error),
    ),
  );

  void _watchEntries(String accountId) {
    if (accountId == _watchedAccountId) return;
    _watchedAccountId = accountId;
    unawaited(_entriesSubscription?.cancel());
    _entriesSubscription = _repository
        .watchRecentEntries(accountId)
        .listen(
          (entries) => emit(state.copyWith(entries: entries)),
          onError: _onError,
        );
  }

  void roleSelected(PartyRole role) {
    final account = state.detail?.accountFor(role);
    if (account == null || role == state.selectedRole) return;
    emit(state.copyWith(selectedRole: role, entries: const []));
    _watchEntries(account.accountId);
  }

  void retry() {
    emit(const PartyDetailState());
    _watchedAccountId = null;
    _watchParty();
  }

  /// Archives or reactivates. Returns whether it was saved; the live
  /// stream then updates the screen.
  Future<bool> setArchived({required bool archived}) async {
    final result = await _repository.setArchived(partyId, archived: archived);
    if (isClosed) return false;
    if (result case Err(:final failure)) {
      emit(state.copyWith(actionFailure: failure));
      return false;
    }
    return true;
  }

  @override
  Future<void> close() async {
    await _partySubscription?.cancel();
    await _entriesSubscription?.cancel();
    return super.close();
  }
}
