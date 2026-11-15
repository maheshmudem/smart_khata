import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

class OpeningBalanceState extends Equatable {
  const OpeningBalanceState({
    required this.date,
    this.loadStatus = LoadStatus.loading,
    this.partyName = '',
    this.account,
    this.amount,
    this.direction = OpeningBalanceDirection.owed,
    this.note = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final LoadStatus loadStatus;
  final String partyName;
  final PartyAccountSummary? account;
  final Money? amount;
  final OpeningBalanceDirection direction;
  final BusinessDate date;
  final String note;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// The signed effect of what is entered, or `null` until it is valid.
  Money? get signedAmount => switch (amount) {
    final Money a when a.isPositive =>
      direction == OpeningBalanceDirection.owed ? a : -a,
    _ => null,
  };

  /// The balance after saving, for the Review section.
  Money? get resultingBalance => switch ((account, signedAmount)) {
    (final PartyAccountSummary a, final Money signed) => a.balance + signed,
    _ => null,
  };

  BalanceKind? get resultingKind => switch ((account, resultingBalance)) {
    (final PartyAccountSummary a, final Money b) => BalanceKind.of(a.role, b),
    _ => null,
  };

  OpeningBalanceState copyWith({
    LoadStatus? loadStatus,
    String? partyName,
    PartyAccountSummary? account,
    Money? Function()? amount,
    OpeningBalanceDirection? direction,
    BusinessDate? date,
    String? note,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
  }) => OpeningBalanceState(
    loadStatus: loadStatus ?? this.loadStatus,
    partyName: partyName ?? this.partyName,
    account: account ?? this.account,
    amount: amount == null ? this.amount : amount(),
    direction: direction ?? this.direction,
    date: date ?? this.date,
    note: note ?? this.note,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    partyName,
    account,
    amount,
    direction,
    date,
    note,
    isDirty,
    errors,
    status,
    failure,
  ];
}

/// The opening-balance form (SK-0306).
///
/// [operationId] is fixed for the life of the form, so a repeated tap or a
/// retry after a failure can never post the balance twice (FR-PAY-006).
class OpeningBalanceCubit extends Cubit<OpeningBalanceState> {
  OpeningBalanceCubit({
    required this._repository,
    required this._recordOpeningBalance,
    required this.partyId,
    required this.accountId,
    required this.operationId,
    required BusinessDate today,
  }) : super(OpeningBalanceState(date: today)) {
    unawaited(_load());
  }

  final PartyRepository _repository;
  final RecordOpeningBalance _recordOpeningBalance;
  final String partyId;
  final String accountId;
  final String operationId;

  Future<void> _load() async {
    final result = await _repository.getParty(partyId);
    if (isClosed) return;

    PartyDetail? detail;
    PartyAccountSummary? account;
    if (result case Ok(value: final PartyDetail found)) {
      detail = found;
      for (final candidate in found.accounts) {
        if (candidate.accountId == accountId) account = candidate;
      }
    }
    if (detail == null || account == null) {
      emit(
        state.copyWith(
          loadStatus: LoadStatus.failure,
          failure:
              result.failureOrNull ?? const NotFoundFailure('party_account'),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        loadStatus: LoadStatus.loaded,
        partyName: detail.party.displayName,
        account: account,
      ),
    );
  }

  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount),
    clear: RecordOpeningBalanceCommand.amountField,
  );

  void directionChanged(OpeningBalanceDirection direction) =>
      _edit(state.copyWith(direction: direction));

  void dateChanged(BusinessDate date) => _edit(
    state.copyWith(date: date),
    clear: RecordOpeningBalanceCommand.dateField,
  );

  void noteChanged(String note) => _edit(
    state.copyWith(note: note),
    clear: RecordOpeningBalanceCommand.noteField,
  );

  void _edit(OpeningBalanceState next, {String? clear}) => emit(
    next.copyWith(
      isDirty: true,
      status: SubmissionStatus.idle,
      errors: clear == null ? null : ({...next.errors}..remove(clear)),
    ),
  );

  Future<void> submit() async {
    if (state.status.isSubmitting || state.status == SubmissionStatus.success) {
      return;
    }
    emit(state.copyWith(status: SubmissionStatus.submitting));

    final result = await _recordOpeningBalance(
      RecordOpeningBalanceCommand(
        operationId: operationId,
        partyId: partyId,
        accountId: accountId,
        amount: state.amount,
        direction: state.direction,
        date: state.date,
        note: state.note,
      ),
    );
    if (isClosed) return;

    emit(switch (result) {
      // The same operation was already committed: that is a saved entry.
      Ok() || Err(failure: DuplicateOperationFailure()) => state.copyWith(
        status: SubmissionStatus.success,
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
}
