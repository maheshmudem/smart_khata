import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

class PartyFormState extends Equatable {
  const PartyFormState({
    this.loadStatus = LoadStatus.loading,
    this.partyId,
    this.displayName = '',
    this.primaryPhone = '',
    this.alternatePhone = '',
    this.address = '',
    this.locality = '',
    this.notes = '',
    this.roles = const {},
    this.lockedRoles = const {},
    this.creditLimit,
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.duplicates = const [],
    this.savedPartyId,
  });

  final LoadStatus loadStatus;

  /// `null` when adding a party.
  final String? partyId;
  final String displayName;
  final String primaryPhone;
  final String alternatePhone;
  final String address;
  final String locality;
  final String notes;
  final Set<PartyRole> roles;

  /// Roles the party already has; they cannot be switched off.
  final Set<PartyRole> lockedRoles;
  final Money? creditLimit;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// Existing parties with the same phone, waiting for the owner's choice.
  final List<Party> duplicates;
  final String? savedPartyId;

  bool get isEditing => partyId != null;

  PartyFormState copyWith({
    LoadStatus? loadStatus,
    String? partyId,
    String? displayName,
    String? primaryPhone,
    String? alternatePhone,
    String? address,
    String? locality,
    String? notes,
    Set<PartyRole>? roles,
    Set<PartyRole>? lockedRoles,
    Money? Function()? creditLimit,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    List<Party>? duplicates,
    String? savedPartyId,
  }) => PartyFormState(
    loadStatus: loadStatus ?? this.loadStatus,
    partyId: partyId ?? this.partyId,
    displayName: displayName ?? this.displayName,
    primaryPhone: primaryPhone ?? this.primaryPhone,
    alternatePhone: alternatePhone ?? this.alternatePhone,
    address: address ?? this.address,
    locality: locality ?? this.locality,
    notes: notes ?? this.notes,
    roles: roles ?? this.roles,
    lockedRoles: lockedRoles ?? this.lockedRoles,
    creditLimit: creditLimit == null ? this.creditLimit : creditLimit(),
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    duplicates: duplicates ?? const [],
    savedPartyId: savedPartyId ?? this.savedPartyId,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    partyId,
    displayName,
    primaryPhone,
    alternatePhone,
    address,
    locality,
    notes,
    roles,
    lockedRoles,
    creditLimit,
    isDirty,
    errors,
    status,
    failure,
    duplicates,
    savedPartyId,
  ];
}

/// WF-021: add or edit a party. Balances are never edited here; an
/// opening balance is its own dated ledger action.
class PartyFormCubit extends Cubit<PartyFormState> {
  PartyFormCubit({
    required this._repository,
    required this._saveParty,
    required this._findDuplicates,
    String? partyId,
    PartyRole initialRole = PartyRole.customer,
  }) : super(
         partyId == null
             ? PartyFormState(
                 loadStatus: LoadStatus.loaded,
                 roles: {initialRole},
               )
             : PartyFormState(partyId: partyId),
       ) {
    if (partyId != null) unawaited(_load(partyId));
  }

  final PartyRepository _repository;
  final SaveParty _saveParty;
  final FindDuplicateParties _findDuplicates;

  /// The phone the party had when the form opened; a duplicate warning is
  /// only raised when the number is new or changed.
  String? _originalPhone;

  Future<void> _load(String partyId) async {
    final result = await _repository.getParty(partyId);
    if (isClosed) return;
    switch (result) {
      case Ok(value: final detail?):
        final party = detail.party;
        _originalPhone = TextNormalizer.phone(party.primaryPhone);
        emit(
          state.copyWith(
            loadStatus: LoadStatus.loaded,
            displayName: party.displayName,
            primaryPhone: party.primaryPhone ?? '',
            alternatePhone: party.alternatePhone ?? '',
            address: party.address ?? '',
            locality: party.locality ?? '',
            notes: party.notes ?? '',
            roles: detail.roles,
            lockedRoles: detail.roles,
            creditLimit: () => party.creditLimit,
          ),
        );
      case Ok():
        emit(
          state.copyWith(
            loadStatus: LoadStatus.failure,
            failure: const NotFoundFailure('party'),
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(loadStatus: LoadStatus.failure, failure: failure));
    }
  }

  void nameChanged(String value) => _edit(
    state.copyWith(displayName: value),
    clear: SavePartyCommand.nameField,
  );

  void primaryPhoneChanged(String value) => _edit(
    state.copyWith(primaryPhone: value),
    clear: SavePartyCommand.primaryPhoneField,
  );

  void alternatePhoneChanged(String value) => _edit(
    state.copyWith(alternatePhone: value),
    clear: SavePartyCommand.alternatePhoneField,
  );

  void addressChanged(String value) => _edit(state.copyWith(address: value));

  void localityChanged(String value) => _edit(state.copyWith(locality: value));

  void notesChanged(String value) =>
      _edit(state.copyWith(notes: value), clear: SavePartyCommand.notesField);

  void creditLimitChanged(Money? value) =>
      _edit(state.copyWith(creditLimit: () => value));

  void roleToggled(PartyRole role, {required bool selected}) {
    if (state.lockedRoles.contains(role)) return;
    final roles = {...state.roles};
    if (selected) {
      roles.add(role);
    } else {
      roles.remove(role);
    }
    _edit(state.copyWith(roles: roles), clear: SavePartyCommand.rolesField);
  }

  void _edit(PartyFormState next, {String? clear}) => emit(
    next.copyWith(
      isDirty: true,
      status: SubmissionStatus.idle,
      errors: clear == null ? null : ({...next.errors}..remove(clear)),
    ),
  );

  /// Saves the party. When another party has the same phone the save
  /// pauses with [PartyFormState.duplicates] set; the owner then opens the
  /// existing party or calls this again with [allowDuplicatePhone].
  Future<void> submit({bool allowDuplicatePhone = false}) async {
    if (state.status.isSubmitting) return;

    final command = SavePartyCommand(
      partyId: state.partyId,
      displayName: state.displayName,
      primaryPhone: state.primaryPhone,
      alternatePhone: state.alternatePhone,
      address: state.address,
      locality: state.locality,
      notes: state.notes,
      roles: state.roles,
      creditLimit: state.creditLimit,
    );

    final errors = SaveParty.validate(command);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors, status: SubmissionStatus.idle));
      return;
    }

    emit(state.copyWith(status: SubmissionStatus.submitting));

    final phone = TextNormalizer.phone(state.primaryPhone);
    if (!allowDuplicatePhone && phone != null && phone != _originalPhone) {
      final found = await _findDuplicates(
        state.primaryPhone,
        excludingPartyId: state.partyId,
      );
      if (isClosed) return;
      // If the lookup itself fails, saving still goes ahead: the warning
      // is a convenience, not a rule.
      if (found case Ok(value: final parties) when parties.isNotEmpty) {
        emit(
          state.copyWith(status: SubmissionStatus.idle, duplicates: parties),
        );
        return;
      }
    }

    final result = await _saveParty(command);
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final id) => state.copyWith(
        status: SubmissionStatus.success,
        savedPartyId: id,
        isDirty: false,
      ),
      Err(failure: ValidationFailure(:final errors)) => state.copyWith(
        errors: errors,
        status: SubmissionStatus.idle,
      ),
      Err(:final failure) => state.copyWith(
        status: SubmissionStatus.failure,
        failure: failure,
      ),
    });
  }

  /// The owner dismissed the duplicate warning without choosing.
  void duplicatesDismissed() => emit(state.copyWith());
}
