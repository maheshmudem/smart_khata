import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/entry_type.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

/// The party account an entry is for, with its balance before the entry.
final class EntryParty extends Equatable {
  const EntryParty({
    required this.partyId,
    required this.accountId,
    required this.name,
    required this.balance,
    this.phone,
  });

  final String partyId;
  final String accountId;
  final String name;
  final Money balance;
  final String? phone;

  @override
  List<Object?> get props => [partyId, accountId, name, balance, phone];
}

sealed class EntryFormEvent extends Equatable {
  const EntryFormEvent();

  @override
  List<Object?> get props => const [];
}

final class EntryFormStarted extends EntryFormEvent {
  const EntryFormStarted();
}

final class EntrySearchChanged extends EntryFormEvent {
  const EntrySearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class EntryPartyPicked extends EntryFormEvent {
  const EntryPartyPicked(this.item);

  final PartyListItem item;

  @override
  List<Object?> get props => [item];
}

/// A party was just created from inside this form.
final class EntryPartyCreated extends EntryFormEvent {
  const EntryPartyCreated(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

final class EntryPartyCleared extends EntryFormEvent {
  const EntryPartyCleared();
}

final class EntryAmountChanged extends EntryFormEvent {
  const EntryAmountChanged(this.amount);

  final Money? amount;

  @override
  List<Object?> get props => [amount];
}

final class EntryMethodChanged extends EntryFormEvent {
  const EntryMethodChanged(this.method);

  final PaymentMethod method;

  @override
  List<Object?> get props => [method];
}

final class EntryDueDateChanged extends EntryFormEvent {
  const EntryDueDateChanged(this.dueAt);

  final DateTime? dueAt;

  @override
  List<Object?> get props => [dueAt];
}

final class EntryNoteChanged extends EntryFormEvent {
  const EntryNoteChanged(this.note);

  final String note;

  @override
  List<Object?> get props => [note];
}

final class EntryFormSubmitted extends EntryFormEvent {
  const EntryFormSubmitted();
}

final class EntryFormState extends Equatable {
  const EntryFormState({
    required this.type,
    this.isLoading = false,
    this.party,
    this.search = '',
    this.candidates = const Loading(),
    this.amount,
    this.method = PaymentMethod.cash,
    this.dueAt,
    this.note = '',
    this.errors = const {},
    this.status = SubmitStatus.idle,
    this.failure,
    this.balanceAfter,
  });

  final EntryType type;

  /// Loading the party the form was opened for.
  final bool isLoading;
  final EntryParty? party;
  final String search;

  /// Parties of the entry's role matching [search].
  final LoadState<List<PartyListItem>> candidates;
  final Money? amount;
  final PaymentMethod method;
  final DateTime? dueAt;
  final String note;
  final Map<String, ValidationError> errors;
  final SubmitStatus status;
  final Failure? failure;

  /// The committed balance, set on success.
  final Money? balanceAfter;

  /// The signed effect of this entry, for the review.
  Money get change {
    final value = amount ?? Money.zero;
    return type.isCharge ? value : -value;
  }

  /// The balance the owner will see after saving.
  Money? get preview => party == null ? null : party!.balance + change;

  /// The part of a payment beyond what is due, which becomes an advance.
  Money get excess {
    final after = preview;
    if (type.isCharge || after == null || !after.isNegative) {
      return Money.zero;
    }
    final before = party!.balance;
    // Only the part this payment pushes below zero is new advance.
    return before.isNegative ? -change : -after;
  }

  bool get isDirty => amount != null || note.trim().isNotEmpty || dueAt != null;

  EntryFormState copyWith({
    bool? isLoading,
    EntryParty? party,
    bool clearParty = false,
    String? search,
    LoadState<List<PartyListItem>>? candidates,
    Money? amount,
    bool clearAmount = false,
    PaymentMethod? method,
    DateTime? dueAt,
    bool clearDueAt = false,
    String? note,
    Map<String, ValidationError>? errors,
    SubmitStatus? status,
    Failure? failure,
    bool clearFailure = false,
    Money? balanceAfter,
  }) => EntryFormState(
    type: type,
    isLoading: isLoading ?? this.isLoading,
    party: clearParty ? null : party ?? this.party,
    search: search ?? this.search,
    candidates: candidates ?? this.candidates,
    amount: clearAmount ? null : amount ?? this.amount,
    method: method ?? this.method,
    dueAt: clearDueAt ? null : dueAt ?? this.dueAt,
    note: note ?? this.note,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: clearFailure ? null : failure ?? this.failure,
    balanceAfter: balanceAfter ?? this.balanceAfter,
  );

  @override
  List<Object?> get props => [
    type,
    isLoading,
    party,
    search,
    candidates,
    amount,
    method,
    dueAt,
    note,
    errors,
    status,
    failure,
    balanceAfter,
  ];
}

/// WF-030 to WF-033: one form for credit, payment, purchase and supplier
/// payment. [operationId] is created when the form opens, so a retry or
/// double tap posts once (FR-PAY-006).
class EntryFormBloc extends Bloc<EntryFormEvent, EntryFormState> {
  EntryFormBloc({
    required EntryType type,
    required this._parties,
    required this._postEntry,
    required this._clock,
    required this.operationId,
    this.partyId,
  }) : super(EntryFormState(type: type, isLoading: partyId != null)) {
    on<EntryFormStarted>(_onStarted);
    on<EntrySearchChanged>(_onSearch);
    on<_CandidatesLoaded>(
      (event, emit) =>
          emit(state.copyWith(candidates: LoadState.from(event.result))),
    );
    on<EntryPartyPicked>(_onPicked);
    on<EntryPartyCreated>(_onCreated);
    on<EntryPartyCleared>(
      (event, emit) => emit(state.copyWith(clearParty: true)),
    );
    on<EntryAmountChanged>(
      (event, emit) => emit(
        state.copyWith(
          amount: event.amount,
          clearAmount: event.amount == null,
          errors: const {},
          status: SubmitStatus.idle,
          clearFailure: true,
        ),
      ),
    );
    on<EntryMethodChanged>(
      (event, emit) => emit(state.copyWith(method: event.method)),
    );
    on<EntryDueDateChanged>(
      (event, emit) => emit(
        state.copyWith(dueAt: event.dueAt, clearDueAt: event.dueAt == null),
      ),
    );
    on<EntryNoteChanged>(
      (event, emit) => emit(state.copyWith(note: event.note)),
    );
    on<EntryFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  static const int candidateLimit = 30;

  final PartyRepository _parties;
  final PostEntry _postEntry;
  final Clock _clock;

  /// The current instant, for the due-date picker.
  DateTime get nowUtc => _clock.nowUtc();
  final String operationId;

  /// The party the form was opened for, if any.
  final String? partyId;
  StreamSubscription<Result<List<PartyListItem>>>? _search;

  Future<void> _onStarted(
    EntryFormStarted event,
    Emitter<EntryFormState> emit,
  ) async {
    final id = partyId;
    if (id != null) {
      await _selectParty(id, emit);
      emit(state.copyWith(isLoading: false));
    }
    _watchCandidates();
  }

  void _onSearch(EntrySearchChanged event, Emitter<EntryFormState> emit) {
    emit(state.copyWith(search: event.text));
    _watchCandidates();
  }

  void _watchCandidates() {
    unawaited(_search?.cancel());
    _search = _parties
        .watchList(
          PartyListQuery(
            role: state.type.role,
            search: state.search,
            limit: candidateLimit,
          ),
        )
        .listen((result) => add(_CandidatesLoaded(result)));
  }

  void _onPicked(EntryPartyPicked event, Emitter<EntryFormState> emit) {
    final item = event.item;
    emit(
      state.copyWith(
        party: EntryParty(
          partyId: item.partyId,
          accountId: item.accountId,
          name: item.name,
          phone: item.phone,
          balance: item.balance,
        ),
        errors: const {},
      ),
    );
  }

  Future<void> _onCreated(
    EntryPartyCreated event,
    Emitter<EntryFormState> emit,
  ) => _selectParty(event.partyId, emit);

  Future<void> _selectParty(String id, Emitter<EntryFormState> emit) async {
    final result = await _parties.watchDetails(id).first;
    final details = result.valueOrNull;
    final account = details?.account(state.type.role);
    if (details == null || account == null) return;
    emit(
      state.copyWith(
        party: EntryParty(
          partyId: details.id,
          accountId: account.accountId,
          name: details.name,
          phone: details.phone,
          balance: account.balance,
        ),
      ),
    );
  }

  Future<void> _onSubmitted(
    EntryFormSubmitted event,
    Emitter<EntryFormState> emit,
  ) async {
    emit(state.copyWith(status: SubmitStatus.submitting, clearFailure: true));
    final result = await _postEntry(
      PostEntryCommand(
        type: state.type,
        accountId: state.party?.accountId,
        amount: state.amount,
        operationId: operationId,
        method: state.method,
        dueAt: state.dueAt,
        description: state.note,
      ),
    );
    switch (result) {
      case Ok(value: PostedEntry(:final balanceAfter)):
        emit(
          state.copyWith(
            status: SubmitStatus.success,
            balanceAfter: balanceAfter,
          ),
        );
      // The same operation already committed: the first write stands.
      case Err(failure: DuplicateOperationFailure()):
        emit(
          state.copyWith(
            status: SubmitStatus.success,
            balanceAfter: state.preview,
          ),
        );
      case Err(failure: ValidationFailure(:final errors)):
        emit(state.copyWith(status: SubmitStatus.failure, errors: errors));
      case Err(:final failure):
        emit(state.copyWith(status: SubmitStatus.failure, failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _search?.cancel();
    return super.close();
  }
}

/// Internal: a new page of candidates from the live query.
final class _CandidatesLoaded extends EntryFormEvent {
  const _CandidatesLoaded(this.result);

  final Result<List<PartyListItem>> result;

  @override
  List<Object?> get props => [result];
}
