import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

sealed class OpeningBalanceEvent extends Equatable {
  const OpeningBalanceEvent();

  @override
  List<Object?> get props => const [];
}

final class OpeningAmountChanged extends OpeningBalanceEvent {
  const OpeningAmountChanged(this.amount);

  final Money? amount;

  @override
  List<Object?> get props => [amount];
}

final class OpeningDirectionChanged extends OpeningBalanceEvent {
  const OpeningDirectionChanged(this.direction);

  final OpeningDirection direction;

  @override
  List<Object?> get props => [direction];
}

final class OpeningBalanceSubmitted extends OpeningBalanceEvent {
  const OpeningBalanceSubmitted();
}

final class OpeningBalanceState extends Equatable {
  const OpeningBalanceState({
    this.amount,
    this.direction = OpeningDirection.owed,
    this.amountError,
    this.status = SubmitStatus.idle,
    this.failure,
  });

  final Money? amount;
  final OpeningDirection direction;
  final ValidationError? amountError;
  final SubmitStatus status;
  final Failure? failure;

  /// The signed ledger effect the review shows before saving.
  Money get signedChange {
    final value = amount ?? Money.zero;
    return direction == OpeningDirection.owed ? value : -value;
  }

  bool get isDirty => amount != null;

  OpeningBalanceState copyWith({
    Money? amount,
    bool clearAmount = false,
    OpeningDirection? direction,
    ValidationError? amountError,
    bool clearAmountError = false,
    SubmitStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) => OpeningBalanceState(
    amount: clearAmount ? null : amount ?? this.amount,
    direction: direction ?? this.direction,
    amountError: clearAmountError ? null : amountError ?? this.amountError,
    status: status ?? this.status,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [amount, direction, amountError, status, failure];
}

/// Posts a party account's opening balance (SK-0306). [operationId] is
/// created when the sheet opens, so a retry or double tap posts once.
class OpeningBalanceBloc
    extends Bloc<OpeningBalanceEvent, OpeningBalanceState> {
  OpeningBalanceBloc({
    required this._post,
    required this.accountId,
    required this.operationId,
  }) : super(const OpeningBalanceState()) {
    on<OpeningAmountChanged>(
      (event, emit) => emit(
        state.copyWith(
          amount: event.amount,
          clearAmount: event.amount == null,
          clearAmountError: true,
          clearFailure: true,
          status: SubmitStatus.idle,
        ),
      ),
    );
    on<OpeningDirectionChanged>(
      (event, emit) => emit(state.copyWith(direction: event.direction)),
    );
    on<OpeningBalanceSubmitted>(_onSubmitted, transformer: droppable());
  }

  final PostOpeningBalance _post;
  final String accountId;
  final String operationId;

  Future<void> _onSubmitted(
    OpeningBalanceSubmitted event,
    Emitter<OpeningBalanceState> emit,
  ) async {
    emit(state.copyWith(status: SubmitStatus.submitting, clearFailure: true));
    final result = await _post(
      PostOpeningBalanceCommand(
        accountId: accountId,
        amount: state.amount,
        direction: state.direction,
        operationId: operationId,
      ),
    );
    switch (result) {
      // The same operation already committed: the first write stands.
      case Ok() || Err(failure: DuplicateOperationFailure()):
        emit(state.copyWith(status: SubmitStatus.success));
      case Err(failure: ValidationFailure(:final errors)):
        emit(
          state.copyWith(
            status: SubmitStatus.failure,
            amountError: errors[PartyFields.amount],
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(status: SubmitStatus.failure, failure: failure));
    }
  }
}
