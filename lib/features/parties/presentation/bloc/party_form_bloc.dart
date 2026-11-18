import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money_formatter.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

sealed class PartyFormEvent extends Equatable {
  const PartyFormEvent();

  @override
  List<Object?> get props => const [];
}

final class PartyFormStarted extends PartyFormEvent {
  const PartyFormStarted();
}

final class PartyFormChanged extends PartyFormEvent {
  const PartyFormChanged(this.input);

  final PartyInput input;

  @override
  List<Object?> get props => [input];
}

final class PartyFormSubmitted extends PartyFormEvent {
  const PartyFormSubmitted({this.allowDuplicatePhone = false});

  /// The owner saw the duplicate-phone warning and chose to save anyway.
  final bool allowDuplicatePhone;

  @override
  List<Object?> get props => [allowDuplicatePhone];
}

/// The owner closed the duplicate-phone warning without saving.
final class PartyDuplicateDismissed extends PartyFormEvent {
  const PartyDuplicateDismissed();
}

final class PartyFormState extends Equatable {
  const PartyFormState({
    this.isLoading = false,
    this.input = const PartyInput(),
    this.lockedRoles = const {},
    this.errors = const {},
    this.status = SubmitStatus.idle,
    this.failure,
    this.duplicates = const [],
    this.savedPartyId,
    this.isDirty = false,
  });

  final bool isLoading;
  final PartyInput input;

  /// Roles that already have an account and cannot be unticked.
  final Set<PartyRole> lockedRoles;
  final Map<String, ValidationError> errors;
  final SubmitStatus status;
  final Failure? failure;

  /// Other parties with the same phone, waiting for the owner's decision.
  final List<PhoneMatch> duplicates;
  final String? savedPartyId;
  final bool isDirty;

  PartyFormState copyWith({
    bool? isLoading,
    PartyInput? input,
    Set<PartyRole>? lockedRoles,
    Map<String, ValidationError>? errors,
    SubmitStatus? status,
    Failure? failure,
    bool clearFailure = false,
    List<PhoneMatch>? duplicates,
    String? savedPartyId,
    bool? isDirty,
  }) => PartyFormState(
    isLoading: isLoading ?? this.isLoading,
    input: input ?? this.input,
    lockedRoles: lockedRoles ?? this.lockedRoles,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: clearFailure ? null : failure ?? this.failure,
    duplicates: duplicates ?? this.duplicates,
    savedPartyId: savedPartyId ?? this.savedPartyId,
    isDirty: isDirty ?? this.isDirty,
  );

  @override
  List<Object?> get props => [
    isLoading,
    input,
    lockedRoles,
    errors,
    status,
    failure,
    duplicates,
    savedPartyId,
    isDirty,
  ];
}

/// WF-021: add or edit a party.
class PartyFormBloc extends Bloc<PartyFormEvent, PartyFormState> {
  PartyFormBloc({
    required this._parties,
    required this._saveParty,
    this.partyId,
    PartyRole? initialRole,
  }) : super(
         PartyFormState(
           isLoading: partyId != null,
           input: PartyInput(roles: {initialRole ?? PartyRole.customer}),
         ),
       ) {
    on<PartyFormStarted>(_onStarted);
    on<PartyFormChanged>(_onChanged);
    on<PartyDuplicateDismissed>(
      (event, emit) => emit(state.copyWith(duplicates: const [])),
    );
    // A second tap while saving is ignored.
    on<PartyFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  final PartyRepository _parties;
  final SaveParty _saveParty;

  /// `null` when adding.
  final String? partyId;

  bool get isEditing => partyId != null;

  Future<void> _onStarted(
    PartyFormStarted event,
    Emitter<PartyFormState> emit,
  ) async {
    final id = partyId;
    if (id == null) return;
    final result = await _parties.watchDetails(id).first;
    switch (result) {
      case Ok(value: final details?):
        final limit = details.creditLimit;
        emit(
          state.copyWith(
            isLoading: false,
            lockedRoles: details.roles,
            input: PartyInput(
              name: details.name,
              roles: details.roles,
              phone: details.phone ?? '',
              alternatePhone: details.alternatePhone ?? '',
              address: details.address ?? '',
              locality: details.locality ?? '',
              notes: details.notes ?? '',
              creditLimitText: limit == null
                  ? ''
                  : MoneyFormatter.toInputText(limit),
            ),
          ),
        );
      case Ok():
        emit(
          state.copyWith(
            isLoading: false,
            failure: const NotFoundFailure('party'),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _onChanged(PartyFormChanged event, Emitter<PartyFormState> emit) {
    // A role with an account can never be unticked.
    final roles = {...event.input.roles, ...state.lockedRoles};
    emit(
      state.copyWith(
        input: event.input.copyWith(roles: roles),
        isDirty: true,
        errors: const {},
        status: SubmitStatus.idle,
        clearFailure: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    PartyFormSubmitted event,
    Emitter<PartyFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SubmitStatus.submitting,
        duplicates: const [],
        clearFailure: true,
      ),
    );
    final result = await _saveParty(
      SavePartyCommand(
        input: state.input,
        partyId: partyId,
        allowDuplicatePhone: event.allowDuplicatePhone,
      ),
    );
    switch (result) {
      case Ok(value: PartySaved(:final partyId)):
        emit(
          state.copyWith(
            status: SubmitStatus.success,
            savedPartyId: partyId,
            isDirty: false,
          ),
        );
      case Ok(value: DuplicatePhoneFound(:final matches)):
        emit(state.copyWith(status: SubmitStatus.idle, duplicates: matches));
      case Err(failure: ValidationFailure(:final errors)):
        emit(state.copyWith(status: SubmitStatus.failure, errors: errors));
      case Err(:final failure):
        emit(state.copyWith(status: SubmitStatus.failure, failure: failure));
    }
  }
}
