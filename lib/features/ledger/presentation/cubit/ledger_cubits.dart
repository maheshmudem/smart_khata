import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';

// ---- Party ledger (WF-023) ------------------------------------------------

class LedgerState extends Equatable {
  const LedgerState({
    this.status = LoadStatus.loading,
    this.partyName = '',
    this.role,
    this.lines = const [],
    this.limit = LedgerCubit.pageSize,
    this.failure,
  });

  final LoadStatus status;
  final String partyName;
  final PartyRole? role;
  final List<LedgerLine> lines;
  final int limit;
  final Failure? failure;

  /// A full page came back, so older lines may exist.
  bool get hasMore => lines.length >= limit;

  /// The newest line carries the current balance.
  Money get balance => lines.isEmpty ? Money.zero : lines.first.runningBalance;

  BalanceKind? get balanceKind => switch (role) {
    final PartyRole r => BalanceKind.of(r, balance),
    null => null,
  };

  LedgerState copyWith({
    LoadStatus? status,
    String? partyName,
    PartyRole? role,
    List<LedgerLine>? lines,
    int? limit,
    Failure? failure,
  }) => LedgerState(
    status: status ?? this.status,
    partyName: partyName ?? this.partyName,
    role: role ?? this.role,
    lines: lines ?? this.lines,
    limit: limit ?? this.limit,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, partyName, role, lines, limit, failure];
}

/// One account's history with a running balance, kept live and paged.
class LedgerCubit extends Cubit<LedgerState> {
  LedgerCubit({
    required this._ledger,
    required this._parties,
    required this.partyId,
    required this.accountId,
  }) : super(const LedgerState()) {
    unawaited(_load());
  }

  static const int pageSize = 50;

  final LedgerRepository _ledger;
  final PartyRepository _parties;
  final String partyId;
  final String accountId;

  StreamSubscription<List<LedgerLine>>? _subscription;

  Future<void> _load() async {
    final result = await _parties.getParty(partyId);
    if (isClosed) return;

    final detail = result.valueOrNull;
    PartyRole? role;
    for (final account in detail?.accounts ?? <PartyAccountSummary>[]) {
      if (account.accountId == accountId) role = account.role;
    }
    if (detail == null || role == null) {
      emit(
        state.copyWith(
          status: LoadStatus.failure,
          failure:
              result.failureOrNull ?? const NotFoundFailure('party_account'),
        ),
      );
      return;
    }
    emit(state.copyWith(partyName: detail.party.displayName, role: role));
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _ledger
        .watchLedger(accountId, limit: state.limit)
        .listen(
          (lines) =>
              emit(state.copyWith(status: LoadStatus.loaded, lines: lines)),
          onError: (Object error) => emit(
            state.copyWith(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  /// Shows older lines. Nothing is ever silently left out: the button
  /// stays while more may exist.
  void loadMore() {
    if (!state.hasMore) return;
    emit(state.copyWith(limit: state.limit + pageSize));
    _subscribe();
  }

  void retry() {
    emit(const LedgerState());
    unawaited(_load());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- Transaction details (WF-034) -----------------------------------------

class TransactionDetailState extends Equatable {
  const TransactionDetailState({
    this.status = LoadStatus.loading,
    this.detail,
    this.failure,
  });

  final LoadStatus status;
  final TransactionDetail? detail;
  final Failure? failure;

  @override
  List<Object?> get props => [status, detail, failure];
}

/// A transaction, kept live so that a reversal made from here shows at
/// once.
class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  TransactionDetailCubit({required this._ledger, required this.transactionId})
    : super(const TransactionDetailState()) {
    _subscribe();
  }

  final LedgerRepository _ledger;
  final String transactionId;

  StreamSubscription<TransactionDetail?>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _ledger
        .watchTransaction(transactionId)
        .listen(
          (detail) => emit(
            detail == null
                ? const TransactionDetailState(
                    status: LoadStatus.failure,
                    failure: NotFoundFailure('transaction'),
                  )
                : TransactionDetailState(
                    status: LoadStatus.loaded,
                    detail: detail,
                  ),
          ),
          onError: (Object error) => emit(
            TransactionDetailState(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  void retry() {
    emit(const TransactionDetailState());
    _subscribe();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

// ---- Reverse a transaction (WF-035) ---------------------------------------

class ReverseTransactionState extends Equatable {
  const ReverseTransactionState({
    this.loadStatus = LoadStatus.loading,
    this.detail,
    this.reason = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.receipt,
  });

  final LoadStatus loadStatus;
  final TransactionDetail? detail;
  final String reason;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;
  final PostingReceipt? receipt;

  ReverseTransactionState copyWith({
    LoadStatus? loadStatus,
    TransactionDetail? detail,
    String? reason,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    PostingReceipt? receipt,
  }) => ReverseTransactionState(
    loadStatus: loadStatus ?? this.loadStatus,
    detail: detail ?? this.detail,
    reason: reason ?? this.reason,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    receipt: receipt ?? this.receipt,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    detail,
    reason,
    isDirty,
    errors,
    status,
    failure,
    receipt,
  ];
}

class ReverseTransactionCubit extends Cubit<ReverseTransactionState> {
  ReverseTransactionCubit({
    required this._ledger,
    required this._reverse,
    required this.transactionId,
    required this.operationId,
  }) : super(const ReverseTransactionState()) {
    unawaited(_load());
  }

  final LedgerRepository _ledger;
  final ReverseTransaction _reverse;
  final String transactionId;
  final String operationId;

  Future<void> _load() async {
    final result = await _ledger.getTransaction(transactionId);
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final detail?) => state.copyWith(
        loadStatus: LoadStatus.loaded,
        detail: detail,
      ),
      Ok() => state.copyWith(
        loadStatus: LoadStatus.failure,
        failure: const NotFoundFailure('transaction'),
      ),
      Err(:final failure) => state.copyWith(
        loadStatus: LoadStatus.failure,
        failure: failure,
      ),
    });
  }

  void reasonChanged(String reason) => emit(
    state.copyWith(
      reason: reason,
      isDirty: true,
      status: SubmissionStatus.idle,
      errors: const {},
    ),
  );

  /// Checks the reason without posting, so the page can ask for the final
  /// confirmation only when the form is complete.
  bool validate() {
    final errors = ReverseTransaction.validate(
      ReverseTransactionCommand(
        operationId: operationId,
        transactionId: transactionId,
        reason: state.reason,
      ),
    );
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors, status: SubmissionStatus.idle));
    }
    return errors.isEmpty;
  }

  Future<void> submit() async {
    if (state.status.isSubmitting || state.status == SubmissionStatus.success) {
      return;
    }
    emit(state.copyWith(status: SubmissionStatus.submitting));

    final result = await _reverse(
      ReverseTransactionCommand(
        operationId: operationId,
        transactionId: transactionId,
        reason: state.reason,
      ),
    );
    if (isClosed) return;

    emit(switch (result) {
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
