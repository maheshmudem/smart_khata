import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/cash_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/domain/text_normalizer.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/expenses/domain/expense.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

final class DriftExpenseRepository implements ExpenseRepository {
  const DriftExpenseRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final CashDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  // ---- Categories --------------------------------------------------------

  @override
  Stream<List<ExpenseCategory>> watchCategories({
    bool includeArchived = false,
  }) => Stream.fromFuture(_shop.requireShopId())
      .asyncExpand(
        (shopId) => _dao.watchCategories(
          shopId: shopId,
          includeArchived: includeArchived,
        ),
      )
      .map((rows) => rows.map(_toDomain).toList())
      .mapErrorsToFailures(logger: _logger, operation: 'expenses.categories');

  @override
  Future<Result<List<ExpenseCategory>>> getCategories() => guard(
    () async {
      final rows = await _dao.getCategories(
        shopId: await _shop.requireShopId(),
        includeArchived: false,
      );
      return rows.map(_toDomain).toList();
    },
    logger: _logger,
    operation: 'expenses.getCategories',
  );

  @override
  Future<Result<String>> createCategory(String name) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      await _requireFreeName(shopId, name);
      final now = _clock.nowUtc();
      final id = _ids.newId();
      await _dao.insertCategory(
        db.ExpenseCategoriesCompanion.insert(
          id: id,
          shopId: shopId,
          name: name,
          normalizedName: TextNormalizer.name(name),
          createdAt: now,
          updatedAt: now,
        ),
      );
      return id;
    }),
    logger: _logger,
    operation: 'expenses.createCategory',
  );

  @override
  Future<Result<void>> renameCategory(String categoryId, String name) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      await _requireFreeName(shopId, name, excludingId: categoryId);
      // Only the category is renamed. Expenses already saved keep the
      // name they were saved with (their snapshot).
      final changed = await _dao.updateCategory(
        shopId: shopId,
        id: categoryId,
        changes: db.ExpenseCategoriesCompanion(
          name: Value(name),
          normalizedName: Value(TextNormalizer.name(name)),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
      if (changed == 0) {
        throw const FailureException(NotFoundFailure('expense_category'));
      }
    }),
    logger: _logger,
    operation: 'expenses.renameCategory',
  );

  @override
  Future<Result<void>> setCategoryActive(
    String categoryId, {
    required bool active,
  }) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      final category = await _dao.findCategory(shopId: shopId, id: categoryId);
      if (category == null) {
        throw const FailureException(NotFoundFailure('expense_category'));
      }
      if (active) {
        // Restoring must not create two active categories of one name.
        await _requireFreeName(shopId, category.name, excludingId: categoryId);
      }
      await _dao.updateCategory(
        shopId: shopId,
        id: categoryId,
        changes: db.ExpenseCategoriesCompanion(
          isActive: Value(active),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
    }),
    logger: _logger,
    operation: 'expenses.setCategoryActive',
  );

  Future<void> _requireFreeName(
    String shopId,
    String name, {
    String? excludingId,
  }) async {
    final taken = await _dao.activeCategoryNameExists(
      shopId: shopId,
      normalizedName: TextNormalizer.name(name),
      excludingId: excludingId,
    );
    if (taken) {
      throw const FailureException(
        RuleFailure(RuleViolation.categoryNameTaken),
      );
    }
  }

  // ---- Posting -----------------------------------------------------------

  @override
  Future<Result<String>> postExpense(ExpensePosting posting) => guard(
    () => _dao.transaction(() async {
      final existing = await _dao.findByOperationId(posting.operationId);
      if (existing != null) return existing.id;

      final shopId = await _shop.requireShopId();
      final category = await _dao.findCategory(
        shopId: shopId,
        id: posting.categoryId,
      );
      if (category == null || !category.isActive) {
        throw const FailureException(NotFoundFailure('expense_category'));
      }
      final account = await _dao.findMoneyAccount(
        shopId: shopId,
        id: posting.moneyAccountId,
      );
      if (account == null || !account.isActive) {
        throw const FailureException(NotFoundFailure('money_account'));
      }
      if (!posting.method.fits(account.accountType)) {
        throw const FailureException(
          ValidationFailure({
            RecordExpenseCommand.accountField: ValidationError.accountMismatch,
          }),
        );
      }

      final now = _clock.nowUtc();
      final transactionId = _ids.newId();
      // Header, detail and outflow are written together: an expense with
      // no cash movement, or the reverse, can never exist (invariant 9).
      await _dao.insertTransaction(
        db.FinancialTransactionsCompanion.insert(
          id: transactionId,
          shopId: shopId,
          transactionType: TransactionType.expense,
          amountPaise: posting.amount.paise,
          effectiveAt: posting.effectiveAt,
          recordedAt: now,
          businessDate: posting.businessDate.toIso(),
          description: Value(posting.note),
          operationId: posting.operationId,
          createdAt: now,
        ),
      );
      await _dao.insertExpense(
        db.ExpensesCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          transactionId: transactionId,
          categoryId: Value(category.id),
          // The name as it is today, so the expense stays readable after
          // the category is renamed or archived.
          categoryNameSnapshot: category.name,
          payee: Value(posting.payee),
          note: Value(posting.note),
          createdAt: now,
        ),
      );
      await _dao.insertMovement(
        db.MoneyMovementsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          transactionId: transactionId,
          moneyAccountId: account.id,
          paymentMethod: posting.method,
          direction: MovementDirection.outflow,
          amountPaise: posting.amount.paise,
          createdAt: now,
        ),
      );
      return transactionId;
    }),
    logger: _logger,
    operation: 'expenses.post',
  );

  static ExpenseCategory _toDomain(db.ExpenseCategory row) => ExpenseCategory(
    id: row.id,
    name: row.name,
    isDefault: row.isDefault,
    isActive: row.isActive,
  );
}
