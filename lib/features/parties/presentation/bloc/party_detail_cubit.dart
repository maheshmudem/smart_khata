import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

final class PartyDetailState extends Equatable {
  const PartyDetailState({
    this.details = const Loading(),
    this.role,
    this.isUpdating = false,
    this.actionFailure,
  });

  /// `Loaded(null)` means the party does not exist.
  final LoadState<PartyDetails?> details;

  /// The role being shown; for a dual-role party the owner switches it.
  final PartyRole? role;
  final bool isUpdating;

  /// Why the last archive/reactivate failed; shown once.
  final Failure? actionFailure;

  PartyDetailState copyWith({
    LoadState<PartyDetails?>? details,
    PartyRole? role,
    bool? isUpdating,
    Failure? actionFailure,
    bool clearActionFailure = false,
  }) => PartyDetailState(
    details: details ?? this.details,
    role: role ?? this.role,
    isUpdating: isUpdating ?? this.isUpdating,
    actionFailure: clearActionFailure
        ? null
        : actionFailure ?? this.actionFailure,
  );

  @override
  List<Object?> get props => [details, role, isUpdating, actionFailure];
}

/// WF-022: one party, live, with separate customer and supplier balances.
class PartyDetailCubit extends Cubit<PartyDetailState> {
  PartyDetailCubit(this._parties, this.partyId, {PartyRole? role})
    : super(PartyDetailState(role: role)) {
    _subscribe();
  }

  final PartyRepository _parties;
  final String partyId;
  StreamSubscription<Result<PartyDetails?>>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _parties.watchDetails(partyId).listen((result) {
      switch (result) {
        case Ok(:final value):
          // Keep the chosen role if the party still has it.
          final roles = value?.roles ?? const <PartyRole>{};
          final role = roles.contains(state.role)
              ? state.role
              : value?.accounts.firstOrNull?.role;
          emit(state.copyWith(details: Loaded(value), role: role));
        case Err(:final failure):
          emit(state.copyWith(details: LoadFailed(failure)));
      }
    });
  }

  void selectRole(PartyRole role) => emit(state.copyWith(role: role));

  void retry() {
    emit(state.copyWith(details: const Loading()));
    _subscribe();
  }

  /// Archives or reactivates. The list and this page update from the live
  /// query once the change has committed.
  Future<void> setArchived({required bool archived}) async {
    if (state.isUpdating) return;
    emit(state.copyWith(isUpdating: true, clearActionFailure: true));
    final result = await _parties.setArchived(partyId, archived: archived);
    emit(
      state.copyWith(isUpdating: false, actionFailure: result.failureOrNull),
    );
  }

  void clearActionFailure() => emit(state.copyWith(clearActionFailure: true));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
