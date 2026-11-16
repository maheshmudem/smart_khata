import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'cash_dao.g.dart';

/// A money movement with the transaction that caused it.
class CashBookLineRow {
  const CashBookLineRow({
    required this.movementId,
    required this.transactionId,
    required this.transactionType,
    required this.direction,
    required this.amountPaise,
    required this.method,
    required this.effectiveAt,
    required this.partyName,
    required this.categoryName,
    required this.description,
    required this.isReversed,
  });

  final String movementId;
  final String transactionId;
  final TransactionType transactionType;
  final MovementDirection direction;
  final int amountPaise;
  final PaymentMethod method;
  final DateTime effectiveAt;
  final String? partyName;
  final String? categoryName;
  final String? description;
  final bool isReversed;
}

/// Opening balance and period totals of one account, in paise.
class CashSummaryRow {
  const CashSummaryRow({
    required this.openingPaise,
    required this.inflowPaise,
    required this.outflowPaise,
  });

  final int openingPaise;
  final int inflowPaise;
  final int outflowPaise;
}

const _types = CodedEnumConverter<TransactionType>(TransactionType.values);
const _methods = CodedEnumConverter<PaymentMethod>(PaymentMethod.values);
const _directions = CodedEnumConverter<MovementDirection>(
  MovementDirection.values,
);
const _instants = EpochMsConverter();

/// Smallest and largest instants, standing in for "no limit" so that the
/// SQL keeps one fixed shape.
const int _minInstant = -9007199254740991;
const int _maxInstant = 9007199254740991;

@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/money.drift',
    '../schema/operations.drift',
  },
)
class CashDao extends DatabaseAccessor<AppDatabase> with _$CashDaoMixin {
  CashDao(super.attachedDatabase);

  // ---- Cash book ---------------------------------------------------------

  /// Movements of an account whose transaction took effect in
  /// `[from, to)`, newest first. A movement belongs to the day its
  /// transaction is dated, not the day it was typed in.
  Stream<List<CashBookLineRow>> watchLines({
    required String shopId,
    required String accountId,
    required DateTime? from,
    required DateTime? to,
    required int limit,
  }) =>
      customSelect(
        '''
    SELECT v.id AS movement_id, t.id AS transaction_id,
           t.transaction_type AS transaction_type, v.direction AS direction,
           v.amount_paise AS amount_paise, v.payment_method AS method,
           t.effective_at AS effective_at, t.description AS description,
           p.display_name AS party_name,
           x.category_name_snapshot AS category_name,
           EXISTS (SELECT 1 FROM financial_transactions r
                   WHERE r.reversal_of_transaction_id = t.id) AS is_reversed
    FROM money_movements v
    JOIN financial_transactions t ON t.id = v.transaction_id
    LEFT JOIN party_accounts a ON a.id = t.party_account_id
    LEFT JOIN parties p ON p.id = a.party_id
    -- A reversal of an expense shows the expense's category too.
    LEFT JOIN expenses x
           ON x.transaction_id = COALESCE(t.reversal_of_transaction_id, t.id)
    WHERE v.shop_id = ? AND v.money_account_id = ?
      AND t.effective_at >= ? AND t.effective_at < ?
    ORDER BY t.effective_at DESC, t.recorded_at DESC, v.id DESC
    LIMIT ?
    ''',
        variables: [
          Variable.withString(shopId),
          Variable.withString(accountId),
          Variable.withInt(from?.millisecondsSinceEpoch ?? _minInstant),
          Variable.withInt(to?.millisecondsSinceEpoch ?? _maxInstant),
          Variable.withInt(limit),
        ],
        readsFrom: {
          moneyMovements,
          financialTransactions,
          partyAccounts,
          parties,
          expenses,
        },
      ).watch().map(
        (rows) => [
          for (final row in rows)
            CashBookLineRow(
              movementId: row.read<String>('movement_id'),
              transactionId: row.read<String>('transaction_id'),
              transactionType: _types.fromSql(
                row.read<String>('transaction_type'),
              ),
              direction: _directions.fromSql(row.read<String>('direction')),
              amountPaise: row.read<int>('amount_paise'),
              method: _methods.fromSql(row.read<String>('method')),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              partyName: row.readNullable<String>('party_name'),
              categoryName: row.readNullable<String>('category_name'),
              description: row.readNullable<String>('description'),
              isReversed: row.read<bool>('is_reversed'),
            ),
        ],
      );

  Stream<CashSummaryRow> watchSummary({
    required String shopId,
    required String accountId,
    required DateTime? from,
    required DateTime? to,
  }) => _summary(shopId, accountId, from, to).watchSingle();

  Future<CashSummaryRow> getSummary({
    required String shopId,
    required String accountId,
    required DateTime? from,
    required DateTime? to,
  }) => _summary(shopId, accountId, from, to).getSingle();

  /// Balance before `from` (the account's opening balance plus everything
  /// earlier), and the inflows and outflows in `[from, to)`.
  Selectable<CashSummaryRow> _summary(
    String shopId,
    String accountId,
    DateTime? from,
    DateTime? to,
  ) {
    final fromMs = from?.millisecondsSinceEpoch ?? _minInstant;
    final toMs = to?.millisecondsSinceEpoch ?? _maxInstant;
    return customSelect(
      '''
      SELECT m.opening_balance_paise + COALESCE(SUM(
               CASE WHEN t.effective_at < ?1 THEN
                 CASE WHEN v.direction = 'inflow'
                      THEN v.amount_paise ELSE -v.amount_paise END
               END), 0) AS opening_paise,
             COALESCE(SUM(CASE WHEN t.effective_at >= ?1 AND t.effective_at < ?2
                                AND v.direction = 'inflow'
                               THEN v.amount_paise END), 0) AS inflow_paise,
             COALESCE(SUM(CASE WHEN t.effective_at >= ?1 AND t.effective_at < ?2
                                AND v.direction = 'outflow'
                               THEN v.amount_paise END), 0) AS outflow_paise
      FROM money_accounts m
      LEFT JOIN money_movements v ON v.money_account_id = m.id
      LEFT JOIN financial_transactions t ON t.id = v.transaction_id
      WHERE m.id = ?3 AND m.shop_id = ?4
      GROUP BY m.id
      ''',
      variables: [
        Variable.withInt(fromMs),
        Variable.withInt(toMs),
        Variable.withString(accountId),
        Variable.withString(shopId),
      ],
      readsFrom: {moneyAccounts, moneyMovements, financialTransactions},
    ).map(
      (row) => CashSummaryRow(
        openingPaise: row.read<int>('opening_paise'),
        inflowPaise: row.read<int>('inflow_paise'),
        outflowPaise: row.read<int>('outflow_paise'),
      ),
    );
  }

  Future<MoneyAccount?> findMoneyAccount({
    required String shopId,
    required String id,
  }) => (select(
    moneyAccounts,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).getSingleOrNull();

  /// The shop's cash drawer.
  Future<MoneyAccount?> findCashAccount(String shopId) =>
      (select(moneyAccounts)
            ..where(
              (t) =>
                  t.shopId.equals(shopId) &
                  t.accountType.equalsValue(MoneyAccountType.cash),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> setAccountActive({
    required String shopId,
    required String id,
    required bool active,
  }) =>
      (update(moneyAccounts)
            ..where((t) => t.id.equals(id) & t.shopId.equals(shopId)))
          .write(MoneyAccountsCompanion(isActive: Value(active)));

  Future<FinancialTransaction?> findByOperationId(String operationId) =>
      (select(
        financialTransactions,
      )..where((t) => t.operationId.equals(operationId))).getSingleOrNull();

  // ---- Expense categories ------------------------------------------------

  Stream<List<ExpenseCategory>> watchCategories({
    required String shopId,
    required bool includeArchived,
  }) => _categories(shopId, includeArchived: includeArchived).watch();

  Future<List<ExpenseCategory>> getCategories({
    required String shopId,
    required bool includeArchived,
  }) => _categories(shopId, includeArchived: includeArchived).get();

  Selectable<ExpenseCategory> _categories(
    String shopId, {
    required bool includeArchived,
  }) {
    final query = select(expenseCategories)
      ..where((t) => t.shopId.equals(shopId))
      // Active first, then by name.
      ..orderBy([
        (t) => OrderingTerm.desc(t.isActive),
        (t) => OrderingTerm.asc(t.normalizedName),
      ]);
    if (!includeArchived) query.where((t) => t.isActive.equals(true));
    return query;
  }

  Future<ExpenseCategory?> findCategory({
    required String shopId,
    required String id,
  }) => (select(
    expenseCategories,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).getSingleOrNull();

  /// An active category with this normalised name, other than
  /// [excludingId].
  Future<bool> activeCategoryNameExists({
    required String shopId,
    required String normalizedName,
    String? excludingId,
  }) async {
    final query = select(expenseCategories)
      ..where(
        (t) =>
            t.shopId.equals(shopId) &
            t.normalizedName.equals(normalizedName) &
            t.isActive.equals(true),
      )
      ..limit(1);
    if (excludingId != null) query.where((t) => t.id.equals(excludingId).not());
    return await query.getSingleOrNull() != null;
  }

  Future<void> insertCategory(ExpenseCategoriesCompanion category) =>
      into(expenseCategories).insert(category);

  Future<int> updateCategory({
    required String shopId,
    required String id,
    required ExpenseCategoriesCompanion changes,
  }) => (update(
    expenseCategories,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).write(changes);

  // ---- Inserts for money-only postings (inside a transaction) -------------

  Future<void> insertTransaction(FinancialTransactionsCompanion header) =>
      into(financialTransactions).insert(header);

  Future<void> insertMovement(MoneyMovementsCompanion movement) =>
      into(moneyMovements).insert(movement);

  Future<void> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  Future<void> insertAuditLog(AuditLogsCompanion log) =>
      into(auditLogs).insert(log);

  // ---- Daily closings ----------------------------------------------------

  /// The latest revision of the closing of [businessDate], if any.
  Future<DailyClosing?> currentClosing({
    required String accountId,
    required String businessDate,
  }) =>
      (select(dailyClosings)
            ..where(
              (t) =>
                  t.moneyAccountId.equals(accountId) &
                  t.businessDate.equals(businessDate),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.revisionNumber)])
            ..limit(1))
          .getSingleOrNull();

  /// The current closing of each business date, newest date first.
  Stream<List<DailyClosing>> watchCurrentClosings({
    required String accountId,
    required int limit,
  }) =>
      (select(dailyClosings)
            ..where(
              (t) =>
                  t.moneyAccountId.equals(accountId) &
                  // Not superseded: no closing points back at this one.
                  notExistsQuery(
                    selectOnly(alias(dailyClosings, 'newer'))
                      ..addColumns([alias(dailyClosings, 'newer').id])
                      ..where(
                        alias(
                          dailyClosings,
                          'newer',
                        ).supersedesClosingId.equalsExp(t.id),
                      ),
                  ),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.businessDate)])
            ..limit(limit))
          .watch();

  Future<void> insertClosing(DailyClosingsCompanion closing) =>
      into(dailyClosings).insert(closing);

  /// The closing saved by [operationId], if that operation already ran.
  /// A closing row has no operation column, so the ID is kept in the
  /// audit row written with it.
  Future<DailyClosing?> closingOfOperation({
    required String shopId,
    required String operationId,
  }) async {
    final log =
        await (select(auditLogs)
              ..where(
                (t) =>
                    t.shopId.equals(shopId) &
                    t.entityType.equals(closingEntityType) &
                    t.action.equals(closingAction) &
                    t.metadataJson.equals(operationId),
              )
              ..limit(1))
            .getSingleOrNull();
    if (log == null) return null;
    return (select(dailyClosings)..where(
          (t) => t.id.equals(log.entityId) & t.shopId.equals(shopId),
        ))
        .getSingleOrNull();
  }

  static const String closingEntityType = 'daily_closing';
  static const String closingAction = 'day_closed';
}
