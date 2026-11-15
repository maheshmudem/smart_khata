import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

class ChargeFormState extends Equatable {
  const ChargeFormState({
    required this.role,
    required this.date,
    this.isLoadingParty = false,
    this.party,
    this.account,
    this.amount,
    this.dueDate,
    this.description = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.receipt,
  });

  /// Customer → credit given; supplier → purchase on credit.
  final PartyRole role;
  final bool isLoadingParty;
  final Party? party;
  final PartyAccountSummary? account;
  final Money? amount;
  final BusinessDate date;
  final BusinessDate? dueDate;
  final String description;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// Set once the posting has been committed.
  final PostingReceipt? receipt;

  bool get hasValidAmount => amount?.isPositive ?? false;

  /// The balance after saving, for the Review section.
  Money? get newBalance => switch ((account, amount)) {
    (final PartyAccountSummary a, final Money m) when m.isPositive =>
      a.balance + m,
    _ => null,
  };

  BalanceKind? get newBalanceKind => switch (newBalance) {
    final Money b => BalanceKind.of(role, b),
    null => null,
  };

  /// A warning, never a block (WF-030).
  bool get exceedsCreditLimit =>
      role == PartyRole.customer &&
      account != null &&
      RecordCharge.exceedsCreditLimit(
        currentBalance: account!.balance,
        amount: amount,
        creditLimit: party?.creditLimit,
      );

  ChargeFormState copyWith({
    bool? isLoadingParty,
    Party? party,
    PartyAccountSummary? account,
    Money? Function()? amount,
    BusinessDate? date,
    BusinessDate? Function()? dueDate,
    String? description,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    PostingReceipt? receipt,
  }) => ChargeFormState(
    role: role,
    isLoadingParty: isLoadingParty ?? this.isLoadingParty,
    party: party ?? this.party,
    account: account ?? this.account,
    amount: amount == null ? this.amount : amount(),
    date: date ?? this.date,
    dueDate: dueDate == null ? this.dueDate : dueDate(),
    description: description ?? this.description,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    receipt: receipt ?? this.receipt,
  );

  @override
  List<Object?> get props => [
    role,
    isLoadingParty,
    party,
    account,
    amount,
    date,
    dueDate,
    description,
    isDirty,
    errors,
    status,
    failure,
    receipt,
  ];
}

/// WF-030 (give customer credit) and WF-032 (supplier purchase on credit).
///
/// [operationId] is fixed for the life of the form, so a repeated tap or a
/// retry can never post twice.
class ChargeFormCubit extends Cubit<ChargeFormState> {
  ChargeFormCubit({
    required this._parties,
    required this._recordCharge,
    required PartyRole role,
    required this.operationId,
    required BusinessDate today,
    String? partyId,
  }) : super(ChargeFormState(role: role, date: today)) {
    if (partyId != null) unawaited(partySelected(partyId, markDirty: false));
  }

  final PartyRepository _parties;
  final RecordCharge _recordCharge;
  final String operationId;

  /// Loads the chosen party and its account for this form's role.
  Future<void> partySelected(String partyId, {bool markDirty = true}) async {
    emit(state.copyWith(isLoadingParty: true));
    final result = await _parties.getParty(partyId);
    if (isClosed) return;

    final detail = result.valueOrNull;
    final account = detail?.accountFor(state.role);
    if (detail == null || account == null) {
      emit(
        state.copyWith(
          isLoadingParty: false,
          failure: result.failureOrNull ?? const NotFoundFailure('party'),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        isLoadingParty: false,
        party: detail.party,
        account: account,
        isDirty: markDirty || state.isDirty,
        errors: {...state.errors}..remove(RecordChargeCommand.partyField),
      ),
    );
  }

  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount),
    clear: RecordChargeCommand.amountField,
  );

  void dateChanged(BusinessDate date) => _edit(
    state.copyWith(date: date),
    clear: RecordChargeCommand.dateField,
  );

  void dueDateChanged(BusinessDate? dueDate) => _edit(
    state.copyWith(dueDate: () => dueDate),
    clear: RecordChargeCommand.dueDateField,
  );

  void descriptionChanged(String description) => _edit(
    state.copyWith(description: description),
    clear: RecordChargeCommand.descriptionField,
  );

  void _edit(ChargeFormState next, {String? clear}) => emit(
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

    final result = await _recordCharge(
      RecordChargeCommand(
        operationId: operationId,
        role: state.role,
        partyId: state.party?.id,
        accountId: state.account?.accountId,
        amount: state.amount,
        date: state.date,
        dueDate: state.dueDate,
        description: state.description,
      ),
    );
    if (isClosed) return;

    emit(switch (result) {
      // Success only here, after the commit has returned.
      Ok(value: final receipt) => state.copyWith(
        status: SubmissionStatus.success,
        receipt: receipt,
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
