import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

// ---- Cash book (WF-040) ---------------------------------------------------

class CashBookState extends Equatable {
  const CashBookState({
    this.status = LoadStatus.loading,
    this.accounts = const [],
    this.selectedAccountId,
    this.preset = DateRangePreset.today,
    this.summary,
    this.lines = const [],
    this.limit = CashBookCubit.pageSize,
    this.failure,
  });

  final LoadStatus status;
  final List<MoneyAccount> accounts;
  final String? selectedAccountId;
  final DateRangePreset preset;
  final CashBookSummary? summary;
  final List<CashBookLine> lines;
  final int limit;
  final Failure? failure;

  MoneyAccount? get selectedAccount {
    for (final account in accounts) {
      if (account.id == selectedAccountId) return account;
    }
    return null;
  }

  bool get hasMore => lines.length >= limit;

  CashBookState copyWith({
    LoadStatus? status,
    List<MoneyAccount>? accounts,
    String? selectedAccountId,
    DateRangePreset? preset,
    CashBookSummary? Function()? summary,
    List<CashBookLine>? lines,
    int? limit,
    Failure? failure,
  }) => CashBookState(
    status: status ?? this.status,
    accounts: accounts ?? this.accounts,
    selectedAccountId: selectedAccountId ?? this.selectedAccountId,
    preset: preset ?? this.preset,
    summary: summary == null ? this.summary : summary(),
    lines: lines ?? this.lines,
    limit: limit ?? this.limit,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    accounts,
    selectedAccountId,
    preset,
    summary,
    lines,
    limit,
    failure,
  ];
}

/// One money account's movements and totals for a period, kept live.
class CashBookCubit extends Cubit<CashBookState> {
  CashBookCubit({
    required this._accounts,
    required this._cashBook,
    required this.today,
  }) : super(const CashBookState()) {
    _accountsSubscription = _accounts.watchAccounts().listen(
      _onAccounts,
      onError: _onError,
    );
  }

  static const int pageSize = 50;

  /// The periods the cash book offers.
  static const List<DateRangePreset> presets = [
    DateRangePreset.today,
    DateRangePreset.last7Days,
    DateRangePreset.thisMonth,
    DateRangePreset.allTime,
  ];

  final MoneyAccountRepository _accounts;
  final CashBookRepository _cashBook;

  /// The shop's business date when the page opened; presets count from it.
  final BusinessDate today;

  late final StreamSubscription<List<MoneyAccount>> _accountsSubscription;
  StreamSubscription<CashBookSummary>? _summarySubscription;
  StreamSubscription<List<CashBookLine>>? _linesSubscription;

  void _onAccounts(List<MoneyAccount> accounts) {
    final stillThere = accounts.any((a) => a.id == state.selectedAccountId);
    final selected = stillThere
        ? state.selectedAccountId
        : (accounts.isEmpty ? null : accounts.first.id);
    final changed = selected != state.selectedAccountId;
    emit(state.copyWith(accounts: accounts, selectedAccountId: selected));
    if (changed) _watchBook();
  }

  void _onError(Object error) => emit(
    state.copyWith(
      status: LoadStatus.failure,
      failure: FailureException.failureOf(error),
    ),
  );

  void accountSelected(String accountId) {
    if (accountId == state.selectedAccountId) return;
    emit(
      state.copyWith(
        selectedAccountId: accountId,
        status: LoadStatus.loading,
        limit: pageSize,
      ),
    );
    _watchBook();
  }

  void presetSelected(DateRangePreset preset) {
    if (preset == state.preset) return;
    emit(
      state.copyWith(
        preset: preset,
        status: LoadStatus.loading,
        limit: pageSize,
      ),
    );
    _watchBook();
  }

  void loadMore() {
    if (!state.hasMore) return;
    emit(state.copyWith(limit: state.limit + pageSize));
    _watchBook();
  }

  void _watchBook() {
    final accountId = state.selectedAccountId;
    unawaited(_summarySubscription?.cancel());
    unawaited(_linesSubscription?.cancel());
    if (accountId == null) return;

    final range = DateRange.preset(state.preset, today);
    _summarySubscription = _cashBook
        .watchSummary(accountId, range)
        .listen(
          (summary) => emit(state.copyWith(summary: () => summary)),
          onError: _onError,
        );
    _linesSubscription = _cashBook
        .watchLines(accountId, range, limit: state.limit)
        .listen(
          (lines) =>
              emit(state.copyWith(status: LoadStatus.loaded, lines: lines)),
          onError: _onError,
        );
  }

  @override
  Future<void> close() async {
    await _accountsSubscription.cancel();
    await _summarySubscription?.cancel();
    await _linesSubscription?.cancel();
    return super.close();
  }
}

// ---- Money accounts (WF-041) ----------------------------------------------

class MoneyAccountsState extends Equatable {
  const MoneyAccountsState({
    this.status = LoadStatus.loading,
    this.accounts = const [],
    this.failure,
  });

  final LoadStatus status;
  final List<MoneyAccount> accounts;
  final Failure? failure;

  @override
  List<Object?> get props => [status, accounts, failure];
}

class MoneyAccountsCubit extends Cubit<MoneyAccountsState> {
  MoneyAccountsCubit({
    required this._accounts,
    required this._cashBook,
    required this._create,
  }) : super(const MoneyAccountsState()) {
    _subscription = _accounts.watchAccounts().listen(
      (accounts) => emit(
        MoneyAccountsState(status: LoadStatus.loaded, accounts: accounts),
      ),
      onError: (Object error) => emit(
        MoneyAccountsState(
          status: LoadStatus.failure,
          failure: FailureException.failureOf(error),
        ),
      ),
    );
  }

  final MoneyAccountRepository _accounts;
  final CashBookRepository _cashBook;
  final CreateMoneyAccount _create;

  late final StreamSubscription<List<MoneyAccount>> _subscription;

  /// Adds an account. Returns the failure to show, or `null` when saved.
  Future<Failure?> add({
    required String name,
    required MoneyAccountType type,
    Money? openingBalance,
  }) async => (await _create(
    name: name,
    type: type,
    openingBalance: openingBalance,
  )).failureOrNull;

  /// Stops offering an account for new entries. Its history stays.
  Future<Failure?> deactivate(String accountId) async =>
      (await _cashBook.setAccountActive(
        accountId,
        active: false,
      )).failureOrNull;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

// ---- Add or remove money --------------------------------------------------

class AdjustmentFormState extends Equatable {
  const AdjustmentFormState({
    this.accounts = const [],
    this.moneyAccountId,
    this.direction = MovementDirection.inflow,
    this.amount,
    this.reason = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final List<MoneyAccount> accounts;
  final String? moneyAccountId;
  final MovementDirection direction;
  final Money? amount;
  final String reason;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  MoneyAccount? get account {
    for (final a in accounts) {
      if (a.id == moneyAccountId) return a;
    }
    return null;
  }

  /// The account balance after saving, for the Review section.
  Money? get newBalance => switch ((account, amount)) {
    (final MoneyAccount a, final Money m) when m.isPositive =>
      direction == MovementDirection.inflow ? a.balance + m : a.balance - m,
    _ => null,
  };

  AdjustmentFormState copyWith({
    List<MoneyAccount>? accounts,
    String? Function()? moneyAccountId,
    MovementDirection? direction,
    Money? Function()? amount,
    String? reason,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
  }) => AdjustmentFormState(
    accounts: accounts ?? this.accounts,
    moneyAccountId: moneyAccountId == null
        ? this.moneyAccountId
        : moneyAccountId(),
    direction: direction ?? this.direction,
    amount: amount == null ? this.amount : amount(),
    reason: reason ?? this.reason,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    accounts,
    moneyAccountId,
    direction,
    amount,
    reason,
    isDirty,
    errors,
    status,
    failure,
  ];
}

/// Money added to or taken out of an account with a reason. It can open
/// pre-filled, for example with a counted difference from a daily closing;
/// even then nothing is posted until the owner gives a reason and saves.
class AdjustmentFormCubit extends Cubit<AdjustmentFormState> {
  AdjustmentFormCubit({
    required this._accounts,
    required this._record,
    required this.operationId,
    String? moneyAccountId,
    MovementDirection direction = MovementDirection.inflow,
    Money? amount,
  }) : super(
         AdjustmentFormState(
           moneyAccountId: moneyAccountId,
           direction: direction,
           amount: amount,
         ),
       ) {
    unawaited(_load());
  }

  final MoneyAccountRepository _accounts;
  final RecordAdjustment _record;
  final String operationId;

  Future<void> _load() async {
    final accounts = (await _accounts.getAccounts()).valueOrNull;
    if (isClosed || accounts == null) return;
    final known = accounts.any((a) => a.id == state.moneyAccountId);
    emit(
      state.copyWith(
        accounts: accounts,
        // Default to the cash drawer, the usual place for an adjustment.
        moneyAccountId: () => known
            ? state.moneyAccountId
            : (accounts.isEmpty ? null : accounts.first.id),
      ),
    );
  }

  void accountChanged(String accountId) => _edit(
    state.copyWith(moneyAccountId: () => accountId),
    clear: RecordAdjustmentCommand.accountField,
  );

  void directionChanged(MovementDirection direction) =>
      _edit(state.copyWith(direction: direction));

  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount),
    clear: RecordAdjustmentCommand.amountField,
  );

  void reasonChanged(String reason) => _edit(
    state.copyWith(reason: reason),
    clear: RecordAdjustmentCommand.reasonField,
  );

  void _edit(AdjustmentFormState next, {String? clear}) => emit(
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

    final result = await _record(
      RecordAdjustmentCommand(
        operationId: operationId,
        moneyAccountId: state.moneyAccountId,
        direction: state.direction,
        amount: state.amount,
        reason: state.reason,
      ),
    );
    if (isClosed) return;

    emit(switch (result) {
      Ok() => state.copyWith(status: SubmissionStatus.success, isDirty: false),
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
