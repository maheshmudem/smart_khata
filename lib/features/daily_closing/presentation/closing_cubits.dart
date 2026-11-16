import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';

// ---- Count cash and close the day (WF-044, WF-045) ------------------------

class DailyCloseState extends Equatable {
  const DailyCloseState({
    required this.date,
    this.loadStatus = LoadStatus.loading,
    this.expectedCash,
    this.existing,
    this.count = const CashCount(),
    this.note = '',
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
    this.saved,
  });

  final BusinessDate date;
  final LoadStatus loadStatus;

  /// What the cash book says should be in the drawer.
  final Money? expectedCash;

  /// The closing already saved for this date, if the day was closed.
  final DailyClosing? existing;
  final CashCount count;
  final String note;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// The closing that was just saved.
  final DailyClosing? saved;

  Money get countedCash => count.total;

  /// Counted minus expected: positive is extra, negative is short.
  Money? get difference => switch (expectedCash) {
    final Money expected => countedCash - expected,
    null => null,
  };

  bool get isDirty => !count.isEmpty || note.isNotEmpty;

  DailyCloseState copyWith({
    LoadStatus? loadStatus,
    Money? expectedCash,
    DailyClosing? existing,
    CashCount? count,
    String? note,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
    DailyClosing? saved,
  }) => DailyCloseState(
    date: date,
    loadStatus: loadStatus ?? this.loadStatus,
    expectedCash: expectedCash ?? this.expectedCash,
    existing: existing ?? this.existing,
    count: count ?? this.count,
    note: note ?? this.note,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
    saved: saved ?? this.saved,
  );

  @override
  List<Object?> get props => [
    date,
    loadStatus,
    expectedCash,
    existing,
    count,
    note,
    errors,
    status,
    failure,
    saved,
  ];
}

/// Counting changes nothing in the books. Saving stores a snapshot; it
/// still changes nothing in the cash book (ADR-014).
class DailyCloseCubit extends Cubit<DailyCloseState> {
  DailyCloseCubit({
    required this._closings,
    required this._closeDay,
    required this._newOperationId,
    required BusinessDate date,
  }) : _operationId = _newOperationId(),
       super(DailyCloseState(date: date)) {
    unawaited(_load());
  }

  final DailyClosingRepository _closings;
  final CloseDay _closeDay;
  final String Function() _newOperationId;

  /// The ID of the save in progress. It is the same for every tap and
  /// retry of one save, and a new one after that save has gone through.
  String _operationId;

  Future<void> _load() async {
    final expected = await _closings.expectedCash(state.date);
    final existing = await _closings.currentClosing(state.date);
    if (isClosed) return;
    if (expected case Err(:final failure)) {
      emit(state.copyWith(loadStatus: LoadStatus.failure, failure: failure));
      return;
    }
    emit(
      state.copyWith(
        loadStatus: LoadStatus.loaded,
        expectedCash: expected.valueOrNull,
        existing: existing.valueOrNull,
      ),
    );
  }

  void retry() {
    emit(DailyCloseState(date: state.date));
    unawaited(_load());
  }

  void quantityChanged(int denomination, int quantity) => emit(
    state.copyWith(
      count: state.count.withQuantity(denomination, quantity),
      status: SubmissionStatus.idle,
    ),
  );

  void increment(int denomination) =>
      quantityChanged(denomination, state.count.quantityOf(denomination) + 1);

  void decrement(int denomination) =>
      quantityChanged(denomination, state.count.quantityOf(denomination) - 1);

  void otherAmountChanged(Money? amount) => emit(
    state.copyWith(
      count: state.count.withOtherAmount(amount),
      status: SubmissionStatus.idle,
    ),
  );

  void noteChanged(String note) =>
      emit(state.copyWith(note: note, errors: const {}));

  /// Clears every quantity (the page asks first if anything was entered).
  void reset() => emit(
    state.copyWith(count: const CashCount(), status: SubmissionStatus.idle),
  );

  Future<void> submit() async {
    if (state.status.isSubmitting || state.status == SubmissionStatus.success) {
      return;
    }
    emit(state.copyWith(status: SubmissionStatus.submitting));

    final result = await _closeDay(
      CloseDayCommand(
        operationId: _operationId,
        businessDate: state.date,
        count: state.count,
        note: state.note,
      ),
    );
    if (isClosed) return;
    // Saved: a later re-count is a new save and gets its own ID.
    if (result.isOk) _operationId = _newOperationId();

    emit(switch (result) {
      Ok(value: final closing) => state.copyWith(
        status: SubmissionStatus.success,
        saved: closing,
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

// ---- Closing history (WF-046) ---------------------------------------------

class ClosingHistoryState extends Equatable {
  const ClosingHistoryState({
    this.status = LoadStatus.loading,
    this.closings = const [],
    this.limit = ClosingHistoryCubit.pageSize,
    this.failure,
  });

  final LoadStatus status;
  final List<DailyClosing> closings;
  final int limit;
  final Failure? failure;

  bool get hasMore => closings.length >= limit;

  @override
  List<Object?> get props => [status, closings, limit, failure];
}

class ClosingHistoryCubit extends Cubit<ClosingHistoryState> {
  ClosingHistoryCubit({required this._closings})
    : super(const ClosingHistoryState()) {
    _subscribe(pageSize);
  }

  static const int pageSize = 60;

  final DailyClosingRepository _closings;
  StreamSubscription<List<DailyClosing>>? _subscription;

  void _subscribe(int limit) {
    unawaited(_subscription?.cancel());
    _subscription = _closings
        .watchHistory(limit: limit)
        .listen(
          (closings) => emit(
            ClosingHistoryState(
              status: LoadStatus.loaded,
              closings: closings,
              limit: limit,
            ),
          ),
          onError: (Object error) => emit(
            ClosingHistoryState(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  void loadMore() {
    if (state.hasMore) _subscribe(state.limit + pageSize);
  }

  void retry() {
    emit(const ClosingHistoryState());
    _subscribe(pageSize);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
