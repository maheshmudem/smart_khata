import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// A kind of shop expense (WF-043).
class ExpenseCategory extends Equatable {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.isActive,
  });

  final String id;
  final String name;

  /// One of the categories created with the shop.
  final bool isDefault;

  /// An archived category is not offered for new expenses; old expenses
  /// keep the name they were saved with.
  final bool isActive;

  @override
  List<Object?> get props => [id, name, isDefault, isActive];
}

/// The expense form (WF-042).
class RecordExpenseCommand extends Equatable {
  const RecordExpenseCommand({
    required this.operationId,
    required this.amount,
    required this.date,
    required this.method,
    this.categoryId,
    this.moneyAccountId,
    this.payee,
    this.note,
  });

  final String operationId;
  final Money? amount;
  final String? categoryId;
  final BusinessDate date;

  /// How it was paid, and the account the money left.
  final PaymentMethod method;
  final String? moneyAccountId;
  final String? payee;
  final String? note;

  static const String amountField = 'amount';
  static const String categoryField = 'category';
  static const String dateField = 'date';
  static const String accountField = 'account';
  static const String noteField = 'note';
  static const int maxTextLength = 200;

  @override
  List<Object?> get props => [
    operationId,
    amount,
    categoryId,
    date,
    method,
    moneyAccountId,
    payee,
    note,
  ];
}

/// A validated expense ready to post.
class ExpensePosting {
  const ExpensePosting({
    required this.operationId,
    required this.amount,
    required this.categoryId,
    required this.method,
    required this.moneyAccountId,
    required this.effectiveAt,
    required this.businessDate,
    this.payee,
    this.note,
  });

  final String operationId;
  final Money amount;
  final String categoryId;
  final PaymentMethod method;
  final String moneyAccountId;
  final DateTime effectiveAt;
  final BusinessDate businessDate;
  final String? payee;
  final String? note;
}

abstract interface class ExpenseRepository {
  /// Categories by name; archived ones only with [includeArchived].
  Stream<List<ExpenseCategory>> watchCategories({bool includeArchived});

  Future<Result<List<ExpenseCategory>>> getCategories();

  /// Adds a category. Returns its ID.
  Future<Result<String>> createCategory(String name);

  Future<Result<void>> renameCategory(String categoryId, String name);

  /// Archives or restores a category. Past expenses are untouched.
  Future<Result<void>> setCategoryActive(
    String categoryId, {
    required bool active,
  });

  /// Posts an expense: the transaction header, the expense detail with a
  /// snapshot of the category name, and the money-account outflow, in one
  /// database transaction (invariant 9). Returns the transaction ID.
  /// Repeating an operation ID posts nothing.
  Future<Result<String>> postExpense(ExpensePosting posting);
}

/// Records a shop expense (FR-CASH-004, SK-0602).
///
/// Money leaves a cash or bank account. Nothing here calculates profit:
/// an expense is a cash movement with a category (FR-CASH-009).
class RecordExpense {
  const RecordExpense(this._repository, this._clock);

  final ExpenseRepository _repository;
  final Clock _clock;

  Future<Result<String>> call(RecordExpenseCommand command) async {
    final now = _clock.nowUtc();
    final zone = ShopTimeZone.resolve(null);
    final today = BusinessDate.fromInstant(now, zone);

    final errors = validate(command, today: today);
    if (errors.isNotEmpty) return Err(ValidationFailure(errors));

    return _repository.postExpense(
      ExpensePosting(
        operationId: command.operationId,
        amount: command.amount!,
        categoryId: command.categoryId!,
        method: command.method,
        moneyAccountId: command.moneyAccountId!,
        effectiveAt: command.date == today ? now : command.date.startUtc(zone),
        businessDate: command.date,
        payee: TextNormalizer.cleanOrNull(command.payee),
        note: TextNormalizer.cleanOrNull(command.note),
      ),
    );
  }

  static Map<String, ValidationError> validate(
    RecordExpenseCommand command, {
    required BusinessDate today,
  }) {
    final errors = <String, ValidationError>{};
    final amount = command.amount;
    if (amount == null || !amount.isPositive) {
      errors[RecordExpenseCommand.amountField] =
          ValidationError.amountMustBePositive;
    }
    if (command.categoryId == null) {
      errors[RecordExpenseCommand.categoryField] =
          ValidationError.categoryRequired;
    }
    if (command.moneyAccountId == null) {
      errors[RecordExpenseCommand.accountField] =
          ValidationError.accountRequired;
    }
    if (command.date.compareTo(today) > 0) {
      errors[RecordExpenseCommand.dateField] = ValidationError.dateInFuture;
    }
    if ((command.note ?? '').length > RecordExpenseCommand.maxTextLength ||
        (command.payee ?? '').length > RecordExpenseCommand.maxTextLength) {
      errors[RecordExpenseCommand.noteField] = ValidationError.tooLong;
    }
    return errors;
  }
}

/// Adds or renames an expense category (SK-0601).
class SaveExpenseCategory {
  const SaveExpenseCategory(this._repository);

  final ExpenseRepository _repository;

  static const String nameField = 'name';
  static const int maxNameLength = 40;

  /// Creates a category, or renames [categoryId] when given.
  Future<Result<void>> call({required String name, String? categoryId}) async {
    final cleaned = TextNormalizer.clean(name);
    if (cleaned.isEmpty) {
      return const Err(
        ValidationFailure({nameField: ValidationError.required}),
      );
    }
    if (cleaned.length > maxNameLength) {
      return const Err(ValidationFailure({nameField: ValidationError.tooLong}));
    }
    if (categoryId != null) {
      return _repository.renameCategory(categoryId, cleaned);
    }
    return (await _repository.createCategory(cleaned)).map((_) {});
  }
}
