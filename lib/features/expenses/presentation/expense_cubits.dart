import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

// ---- Expense form (WF-042) ------------------------------------------------

class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    required this.date,
    this.categories = const [],
    this.moneyAccounts = const [],
    this.amount,
    this.categoryId,
    this.method = PaymentMethod.cash,
    this.moneyAccountId,
    this.payee = '',
    this.note = '',
    this.isDirty = false,
    this.errors = const {},
    this.status = SubmissionStatus.idle,
    this.failure,
  });

  final List<ExpenseCategory> categories;
  final List<MoneyAccount> moneyAccounts;
  final Money? amount;
  final String? categoryId;
  final BusinessDate date;
  final PaymentMethod method;
  final String? moneyAccountId;
  final String payee;
  final String note;
  final bool isDirty;
  final Map<String, ValidationError> errors;
  final SubmissionStatus status;
  final Failure? failure;

  /// The account the money will leave, for the Review section.
  MoneyAccount? get account {
    for (final a in moneyAccounts) {
      if (a.id == moneyAccountId) return a;
    }
    return null;
  }

  ExpenseFormState copyWith({
    List<ExpenseCategory>? categories,
    List<MoneyAccount>? moneyAccounts,
    Money? Function()? amount,
    String? Function()? categoryId,
    BusinessDate? date,
    PaymentMethod? method,
    String? Function()? moneyAccountId,
    String? payee,
    String? note,
    bool? isDirty,
    Map<String, ValidationError>? errors,
    SubmissionStatus? status,
    Failure? failure,
  }) => ExpenseFormState(
    categories: categories ?? this.categories,
    moneyAccounts: moneyAccounts ?? this.moneyAccounts,
    amount: amount == null ? this.amount : amount(),
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    date: date ?? this.date,
    method: method ?? this.method,
    moneyAccountId: moneyAccountId == null
        ? this.moneyAccountId
        : moneyAccountId(),
    payee: payee ?? this.payee,
    note: note ?? this.note,
    isDirty: isDirty ?? this.isDirty,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    categories,
    moneyAccounts,
    amount,
    categoryId,
    date,
    method,
    moneyAccountId,
    payee,
    note,
    isDirty,
    errors,
    status,
    failure,
  ];
}

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit({
    required this._expenses,
    required this._moneyAccounts,
    required this._createMoneyAccount,
    required this._recordExpense,
    required this.operationId,
    required BusinessDate today,
  }) : super(ExpenseFormState(date: today)) {
    // Categories stay live: one added on the categories page is offered
    // here as soon as the owner comes back.
    _categories = _expenses.watchCategories().listen(
      (categories) => emit(
        state.copyWith(
          categories: categories,
          // A category archived meanwhile is no longer a valid choice.
          categoryId: () => categories.any((c) => c.id == state.categoryId)
              ? state.categoryId
              : null,
        ),
      ),
      onError: (Object error) =>
          emit(state.copyWith(failure: FailureException.failureOf(error))),
    );
    unawaited(_loadMoneyAccounts());
  }

  final ExpenseRepository _expenses;
  final MoneyAccountRepository _moneyAccounts;
  final CreateMoneyAccount _createMoneyAccount;
  final RecordExpense _recordExpense;

  /// Fixed for the life of the form: a retry cannot post twice.
  final String operationId;

  late final StreamSubscription<List<ExpenseCategory>> _categories;

  Future<void> _loadMoneyAccounts() async {
    final accounts = (await _moneyAccounts.getAccounts()).valueOrNull;
    if (isClosed || accounts == null) return;
    emit(
      state.copyWith(
        moneyAccounts: accounts,
        moneyAccountId: () =>
            state.moneyAccountId ?? _firstFitting(state.method, accounts),
      ),
    );
  }

  static String? _firstFitting(
    PaymentMethod method,
    List<MoneyAccount> accounts,
  ) {
    for (final account in accounts) {
      if (method.fits(account.type)) return account.id;
    }
    return null;
  }

  void amountChanged(Money? amount) => _edit(
    state.copyWith(amount: () => amount),
    clear: RecordExpenseCommand.amountField,
  );

  void categoryChanged(String? categoryId) => _edit(
    state.copyWith(categoryId: () => categoryId),
    clear: RecordExpenseCommand.categoryField,
  );

  void dateChanged(BusinessDate date) => _edit(
    state.copyWith(date: date),
    clear: RecordExpenseCommand.dateField,
  );

  /// Changing the method moves the expense to an account that suits it.
  void methodChanged(PaymentMethod method) => _edit(
    state.copyWith(
      method: method,
      moneyAccountId: () => _firstFitting(method, state.moneyAccounts),
    ),
    clear: RecordExpenseCommand.accountField,
  );

  void accountChanged(String accountId) => _edit(
    state.copyWith(moneyAccountId: () => accountId),
    clear: RecordExpenseCommand.accountField,
  );

  void payeeChanged(String payee) => _edit(state.copyWith(payee: payee));

  void noteChanged(String note) =>
      _edit(state.copyWith(note: note), clear: RecordExpenseCommand.noteField);

  /// Creates a bank account and pays this expense from it.
  Future<void> addMoneyAccount(String name) async {
    final created = await _createMoneyAccount(name: name);
    if (isClosed) return;
    if (created case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
      return;
    }
    final accounts = (await _moneyAccounts.getAccounts()).valueOrNull;
    if (isClosed) return;
    emit(state.copyWith(moneyAccounts: accounts));
    accountChanged(created.valueOrNull!);
  }

  void _edit(ExpenseFormState next, {String? clear}) => emit(
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

    final result = await _recordExpense(
      RecordExpenseCommand(
        operationId: operationId,
        amount: state.amount,
        categoryId: state.categoryId,
        date: state.date,
        method: state.method,
        moneyAccountId: state.moneyAccountId,
        payee: state.payee,
        note: state.note,
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

  @override
  Future<void> close() async {
    await _categories.cancel();
    return super.close();
  }
}

// ---- Expense categories (WF-043) ------------------------------------------

class ExpenseCategoriesState extends Equatable {
  const ExpenseCategoriesState({
    this.status = LoadStatus.loading,
    this.categories = const [],
    this.failure,
  });

  final LoadStatus status;

  /// Active categories first, then archived ones.
  final List<ExpenseCategory> categories;
  final Failure? failure;

  @override
  List<Object?> get props => [status, categories, failure];
}

class ExpenseCategoriesCubit extends Cubit<ExpenseCategoriesState> {
  ExpenseCategoriesCubit({required this._expenses, required this._save})
    : super(const ExpenseCategoriesState()) {
    _subscribe();
  }

  final ExpenseRepository _expenses;
  final SaveExpenseCategory _save;

  StreamSubscription<List<ExpenseCategory>>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _expenses
        .watchCategories(includeArchived: true)
        .listen(
          (categories) => emit(
            ExpenseCategoriesState(
              status: LoadStatus.loaded,
              categories: categories,
            ),
          ),
          onError: (Object error) => emit(
            ExpenseCategoriesState(
              status: LoadStatus.failure,
              failure: FailureException.failureOf(error),
            ),
          ),
        );
  }

  void retry() {
    emit(const ExpenseCategoriesState());
    _subscribe();
  }

  /// Adds a category, or renames [categoryId]. Returns the failure to show
  /// in the dialog, or `null` when it was saved.
  Future<Failure?> save(String name, {String? categoryId}) async =>
      (await _save(name: name, categoryId: categoryId)).failureOrNull;

  Future<Failure?> setActive(String categoryId, {required bool active}) async =>
      (await _expenses.setCategoryActive(
        categoryId,
        active: active,
      )).failureOrNull;

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
