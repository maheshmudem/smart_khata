import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'reports_dao.g.dart';

class DashboardRow {
  const DashboardRow({
    required this.customerOutstandingPaise,
    required this.customersWithDues,
    required this.overdueCustomers,
    required this.customerAdvancesPaise,
    required this.supplierPayablePaise,
    required this.suppliersWithDues,
    required this.overdueSuppliers,
    required this.supplierAdvancesPaise,
    required this.todayCreditPaise,
    required this.todayCollectionsPaise,
    required this.todayExpensesPaise,
    required this.partyCount,
  });

  final int customerOutstandingPaise;
  final int customersWithDues;
  final int overdueCustomers;
  final int customerAdvancesPaise;
  final int supplierPayablePaise;
  final int suppliersWithDues;
  final int overdueSuppliers;
  final int supplierAdvancesPaise;
  final int todayCreditPaise;
  final int todayCollectionsPaise;
  final int todayExpensesPaise;
  final int partyCount;
}

class ActivityRow {
  const ActivityRow({
    required this.transactionId,
    required this.type,
    required this.amountPaise,
    required this.effectiveAt,
    required this.partyName,
    required this.categoryName,
    required this.description,
    required this.isReversed,
  });

  final String transactionId;
  final TransactionType type;
  final int amountPaise;
  final DateTime effectiveAt;
  final String? partyName;
  final String? categoryName;
  final String? description;
  final bool isReversed;
}

/// Unsettled paise by age. Buckets follow `AgingBucket`.
class AgingRow {
  const AgingRow({
    required this.upTo7Paise,
    required this.days8To15Paise,
    required this.days16To30Paise,
    required this.over30Paise,
  });

  final int upTo7Paise;
  final int days8To15Paise;
  final int days16To30Paise;
  final int over30Paise;
}

class OutstandingPartyRow {
  const OutstandingPartyRow({
    required this.partyId,
    required this.accountId,
    required this.partyName,
    required this.aging,
    required this.oldestAgingAt,
    required this.openEntryCount,
  });

  final String partyId;
  final String accountId;
  final String partyName;
  final AgingRow aging;
  final DateTime oldestAgingAt;
  final int openEntryCount;
}

class AdvancePartyRow {
  const AdvancePartyRow({
    required this.partyId,
    required this.partyName,
    required this.advancePaise,
  });

  final String partyId;
  final String partyName;
  final int advancePaise;
}

class DayTotalsRow {
  const DayTotalsRow({
    required this.businessDate,
    required this.creditPaise,
    required this.collectionsPaise,
    required this.expensesPaise,
  });

  final String businessDate;
  final int creditPaise;
  final int collectionsPaise;
  final int expensesPaise;
}

class StatementAccountRow {
  const StatementAccountRow({
    required this.partyName,
    required this.role,
    required this.openingPaise,
    required this.closingPaise,
  });

  final String partyName;
  final PartyRole role;
  final int openingPaise;
  final int closingPaise;
}

class StatementLineRow {
  const StatementLineRow({
    required this.transactionId,
    required this.type,
    required this.amountPaise,
    required this.effectiveAt,
    required this.description,
    required this.isReversed,
  });

  final String transactionId;
  final TransactionType type;
  final int amountPaise;
  final DateTime effectiveAt;
  final String? description;
  final bool isReversed;
}

const _roles = CodedEnumConverter<PartyRole>(PartyRole.values);
const _types = CodedEnumConverter<TransactionType>(TransactionType.values);
const _methods = CodedEnumConverter<PaymentMethod>(PaymentMethod.values);
const _instants = EpochMsConverter();

/// Stand-ins for "no limit", so each query keeps one fixed shape.
const int _minInstant = -9007199254740991;
const int _maxInstant = 9007199254740991;
const String _minDate = '0000-00-00';
const String _maxDate = '9999-99-99';

/// A live transaction: not reversed. (A reversal itself has its own type
/// and is never matched by the type filters below.)
const String _notReversed = '''
  NOT EXISTS (SELECT 1 FROM financial_transactions r
              WHERE r.reversal_of_transaction_id = t.id)''';

/// Charges that are not fully settled, with what is still open on each and
/// the instant it ages from (due date, else entry date). The same rule as
/// `LedgerDao.openCharges`, over every account of the shop (`?1`).
const String _openCharges = '''
  SELECT e.party_account_id AS account_id, e.due_at AS due_at,
         COALESCE(e.due_at, t.effective_at) AS aging_at,
         e.amount_paise - COALESCE((
           SELECT SUM(CASE WHEN x.event_type = 'allocate'
                           THEN x.amount_paise ELSE -x.amount_paise END)
           FROM ledger_allocation_events x
           WHERE x.target_entry_id = e.id
         ), 0) AS open_paise
  FROM party_ledger_entries e
  JOIN financial_transactions t ON t.id = e.transaction_id
  WHERE e.shop_id = ?1
    AND e.amount_paise > 0 AND e.entry_kind IN ('charge', 'opening')
    AND $_notReversed''';

/// Read-only queries behind the dashboard and reports. Every figure is
/// computed from ledger entries, allocation events and money movements;
/// nothing is stored.
@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/money.drift',
    '../schema/operations.drift',
  },
)
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.attachedDatabase);

  // ---- Dashboard ---------------------------------------------------------

  /// [todayStart] is the first instant of today in the shop's zone; a
  /// charge is overdue when its due date is before it.
  Stream<DashboardRow> watchDashboard({
    required String shopId,
    required DateTime todayStart,
    required String businessDate,
  }) =>
      customSelect(
        '''
    WITH balances AS (
      SELECT a.id AS account_id, a.role AS role,
             COALESCE(SUM(e.amount_paise), 0) AS balance_paise
      FROM party_accounts a
      LEFT JOIN party_ledger_entries e ON e.party_account_id = a.id
      WHERE a.shop_id = ?1
      GROUP BY a.id
    ),
    overdue AS (
      SELECT DISTINCT a.id AS account_id, a.role AS role
      FROM ($_openCharges) o
      JOIN party_accounts a ON a.id = o.account_id
      WHERE o.open_paise > 0 AND o.due_at IS NOT NULL AND o.due_at < ?2
    ),
    today AS (
      SELECT t.transaction_type AS type, SUM(t.amount_paise) AS paise
      FROM financial_transactions t
      WHERE t.shop_id = ?1 AND t.business_date = ?3 AND $_notReversed
      GROUP BY t.transaction_type
    )
    SELECT
      (SELECT COALESCE(SUM(balance_paise), 0) FROM balances
        WHERE role = 'customer' AND balance_paise > 0) AS customer_outstanding,
      (SELECT COUNT(*) FROM balances
        WHERE role = 'customer' AND balance_paise > 0) AS customers_with_dues,
      (SELECT COUNT(*) FROM overdue WHERE role = 'customer')
        AS overdue_customers,
      (SELECT COALESCE(SUM(-balance_paise), 0) FROM balances
        WHERE role = 'customer' AND balance_paise < 0) AS customer_advances,
      (SELECT COALESCE(SUM(balance_paise), 0) FROM balances
        WHERE role = 'supplier' AND balance_paise > 0) AS supplier_payable,
      (SELECT COUNT(*) FROM balances
        WHERE role = 'supplier' AND balance_paise > 0) AS suppliers_with_dues,
      (SELECT COUNT(*) FROM overdue WHERE role = 'supplier')
        AS overdue_suppliers,
      (SELECT COALESCE(SUM(-balance_paise), 0) FROM balances
        WHERE role = 'supplier' AND balance_paise < 0) AS supplier_advances,
      (SELECT COALESCE(SUM(paise), 0) FROM today
        WHERE type = 'customer_credit') AS today_credit,
      (SELECT COALESCE(SUM(paise), 0) FROM today
        WHERE type = 'customer_payment') AS today_collections,
      (SELECT COALESCE(SUM(paise), 0) FROM today
        WHERE type = 'expense') AS today_expenses,
      (SELECT COUNT(*) FROM parties WHERE shop_id = ?1) AS party_count
    ''',
        variables: [
          Variable.withString(shopId),
          Variable.withInt(todayStart.millisecondsSinceEpoch),
          Variable.withString(businessDate),
        ],
        readsFrom: {
          parties,
          partyAccounts,
          partyLedgerEntries,
          ledgerAllocationEvents,
          financialTransactions,
        },
      ).watchSingle().map(
        (row) => DashboardRow(
          customerOutstandingPaise: row.read<int>('customer_outstanding'),
          customersWithDues: row.read<int>('customers_with_dues'),
          overdueCustomers: row.read<int>('overdue_customers'),
          customerAdvancesPaise: row.read<int>('customer_advances'),
          supplierPayablePaise: row.read<int>('supplier_payable'),
          suppliersWithDues: row.read<int>('suppliers_with_dues'),
          overdueSuppliers: row.read<int>('overdue_suppliers'),
          supplierAdvancesPaise: row.read<int>('supplier_advances'),
          todayCreditPaise: row.read<int>('today_credit'),
          todayCollectionsPaise: row.read<int>('today_collections'),
          todayExpensesPaise: row.read<int>('today_expenses'),
          partyCount: row.read<int>('party_count'),
        ),
      );

  /// The newest transactions of any kind.
  Stream<List<ActivityRow>> watchRecentActivity({
    required String shopId,
    required int limit,
  }) =>
      customSelect(
        '''
    SELECT t.id AS transaction_id, t.transaction_type AS transaction_type,
           t.amount_paise AS amount_paise, t.effective_at AS effective_at,
           t.description AS description, p.display_name AS party_name,
           x.category_name_snapshot AS category_name,
           EXISTS (SELECT 1 FROM financial_transactions r
                   WHERE r.reversal_of_transaction_id = t.id) AS is_reversed
    FROM financial_transactions t
    LEFT JOIN party_accounts a ON a.id = t.party_account_id
    LEFT JOIN parties p ON p.id = a.party_id
    LEFT JOIN expenses x
           ON x.transaction_id = COALESCE(t.reversal_of_transaction_id, t.id)
    WHERE t.shop_id = ?
    ORDER BY t.effective_at DESC, t.recorded_at DESC, t.id DESC
    LIMIT ?
    ''',
        variables: [Variable.withString(shopId), Variable.withInt(limit)],
        readsFrom: {financialTransactions, partyAccounts, parties, expenses},
      ).watch().map(
        (rows) => [
          for (final row in rows)
            ActivityRow(
              transactionId: row.read<String>('transaction_id'),
              type: _types.fromSql(row.read<String>('transaction_type')),
              amountPaise: row.read<int>('amount_paise'),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              partyName: row.readNullable<String>('party_name'),
              categoryName: row.readNullable<String>('category_name'),
              description: row.readNullable<String>('description'),
              isReversed: row.read<bool>('is_reversed'),
            ),
        ],
      );

  // ---- Outstanding and aging ---------------------------------------------

  /// Bucket sums. `?3..?5` are the first instants of the days 7, 15 and 30
  /// days before today: an amount aging from on or after `?3` is at most
  /// 7 days old, and so on.
  static const String _agingColumns = '''
      COALESCE(SUM(CASE WHEN o.aging_at >= ?3 THEN o.open_paise END), 0)
        AS up_to_7,
      COALESCE(SUM(CASE WHEN o.aging_at < ?3 AND o.aging_at >= ?4
                        THEN o.open_paise END), 0) AS days_8_15,
      COALESCE(SUM(CASE WHEN o.aging_at < ?4 AND o.aging_at >= ?5
                        THEN o.open_paise END), 0) AS days_16_30,
      COALESCE(SUM(CASE WHEN o.aging_at < ?5 THEN o.open_paise END), 0)
        AS over_30''';

  List<Variable<Object>> _agingVariables(
    String shopId,
    PartyRole role,
    DateTime day7Start,
    DateTime day15Start,
    DateTime day30Start,
  ) => [
    Variable.withString(shopId),
    Variable.withString(role.code),
    Variable.withInt(day7Start.millisecondsSinceEpoch),
    Variable.withInt(day15Start.millisecondsSinceEpoch),
    Variable.withInt(day30Start.millisecondsSinceEpoch),
  ];

  static AgingRow _aging(QueryRow row) => AgingRow(
    upTo7Paise: row.read<int>('up_to_7'),
    days8To15Paise: row.read<int>('days_8_15'),
    days16To30Paise: row.read<int>('days_16_30'),
    over30Paise: row.read<int>('over_30'),
  );

  /// Aging of everything unsettled for one role, over every party.
  Future<AgingRow> agingTotals({
    required String shopId,
    required PartyRole role,
    required DateTime day7Start,
    required DateTime day15Start,
    required DateTime day30Start,
  }) => customSelect(
    '''
    SELECT $_agingColumns
    FROM ($_openCharges) o
    JOIN party_accounts a ON a.id = o.account_id
    WHERE a.role = ?2 AND o.open_paise > 0
    ''',
    variables: _agingVariables(shopId, role, day7Start, day15Start, day30Start),
  ).map(_aging).getSingle();

  /// Parties with unsettled amounts for one role, largest total first.
  Future<List<OutstandingPartyRow>> outstandingParties({
    required String shopId,
    required PartyRole role,
    required DateTime day7Start,
    required DateTime day15Start,
    required DateTime day30Start,
    required int limit,
  }) =>
      customSelect(
            '''
    SELECT p.id AS party_id, a.id AS account_id, p.display_name AS party_name,
           MIN(o.aging_at) AS oldest_aging_at, COUNT(*) AS open_count,
           $_agingColumns
    FROM ($_openCharges) o
    JOIN party_accounts a ON a.id = o.account_id
    JOIN parties p ON p.id = a.party_id
    WHERE a.role = ?2 AND o.open_paise > 0
    GROUP BY a.id
    ORDER BY SUM(o.open_paise) DESC, p.normalized_name ASC, a.id ASC
    LIMIT ?6
    ''',
            variables: [
              ..._agingVariables(
                shopId,
                role,
                day7Start,
                day15Start,
                day30Start,
              ),
              Variable.withInt(limit),
            ],
          )
          .map(
            (row) => OutstandingPartyRow(
              partyId: row.read<String>('party_id'),
              accountId: row.read<String>('account_id'),
              partyName: row.read<String>('party_name'),
              aging: _aging(row),
              oldestAgingAt: _instants.fromSql(
                row.read<int>('oldest_aging_at'),
              ),
              openEntryCount: row.read<int>('open_count'),
            ),
          )
          .get();

  /// Parties whose account for [role] holds an advance, largest first.
  Future<List<AdvancePartyRow>> advanceParties({
    required String shopId,
    required PartyRole role,
    required int limit,
  }) =>
      customSelect(
            '''
    SELECT p.id AS party_id, p.display_name AS party_name,
           -SUM(e.amount_paise) AS advance_paise
    FROM party_accounts a
    JOIN parties p ON p.id = a.party_id
    JOIN party_ledger_entries e ON e.party_account_id = a.id
    WHERE a.shop_id = ? AND a.role = ?
    GROUP BY a.id
    HAVING SUM(e.amount_paise) < 0
    ORDER BY advance_paise DESC, p.normalized_name ASC, a.id ASC
    LIMIT ?
    ''',
            variables: [
              Variable.withString(shopId),
              Variable.withString(role.code),
              Variable.withInt(limit),
            ],
          )
          .map(
            (row) => AdvancePartyRow(
              partyId: row.read<String>('party_id'),
              partyName: row.read<String>('party_name'),
              advancePaise: row.read<int>('advance_paise'),
            ),
          )
          .get();

  // ---- Period report -----------------------------------------------------

  /// Total of live transactions per type, dated in `[fromDate, toDate]`
  /// (ISO business dates, both included).
  Future<Map<TransactionType, int>> totalsByType({
    required String shopId,
    required String? fromDate,
    required String? toDate,
  }) async {
    final rows = await customSelect(
      '''
      SELECT t.transaction_type AS type, SUM(t.amount_paise) AS paise
      FROM financial_transactions t
      WHERE t.shop_id = ? AND t.business_date >= ? AND t.business_date <= ?
        AND t.transaction_type <> 'transaction_reversal' AND $_notReversed
      GROUP BY t.transaction_type
      ''',
      variables: _periodVariables(shopId, fromDate, toDate),
    ).get();
    return {
      for (final row in rows)
        _types.fromSql(row.read<String>('type')): row.read<int>('paise'),
    };
  }

  /// Money received from customers in the period, per payment method.
  Future<Map<PaymentMethod, int>> collectionsByMethod({
    required String shopId,
    required String? fromDate,
    required String? toDate,
  }) async {
    final rows = await customSelect(
      '''
      SELECT v.payment_method AS method, SUM(v.amount_paise) AS paise
      FROM money_movements v
      JOIN financial_transactions t ON t.id = v.transaction_id
      WHERE t.shop_id = ? AND t.business_date >= ? AND t.business_date <= ?
        AND t.transaction_type = 'customer_payment'
        AND v.direction = 'inflow' AND $_notReversed
      GROUP BY v.payment_method
      ''',
      variables: _periodVariables(shopId, fromDate, toDate),
    ).get();
    return {
      for (final row in rows)
        _methods.fromSql(row.read<String>('method')): row.read<int>('paise'),
    };
  }

  /// Expenses in the period per saved category name, largest first.
  Future<List<(String, int)>> expensesByCategory({
    required String shopId,
    required String? fromDate,
    required String? toDate,
  }) => customSelect(
    '''
    SELECT x.category_name_snapshot AS category, SUM(t.amount_paise) AS paise
    FROM expenses x
    JOIN financial_transactions t ON t.id = x.transaction_id
    WHERE t.shop_id = ? AND t.business_date >= ? AND t.business_date <= ?
      AND $_notReversed
    GROUP BY x.category_name_snapshot
    ORDER BY paise DESC, category ASC
    ''',
    variables: _periodVariables(shopId, fromDate, toDate),
  ).map((row) => (row.read<String>('category'), row.read<int>('paise'))).get();

  /// Per-day totals in the period, newest day first.
  Future<List<DayTotalsRow>> dayTotals({
    required String shopId,
    required String? fromDate,
    required String? toDate,
    required int limit,
  }) =>
      customSelect(
            '''
    SELECT t.business_date AS business_date,
           COALESCE(SUM(CASE WHEN t.transaction_type = 'customer_credit'
                             THEN t.amount_paise END), 0) AS credit,
           COALESCE(SUM(CASE WHEN t.transaction_type = 'customer_payment'
                             THEN t.amount_paise END), 0) AS collections,
           COALESCE(SUM(CASE WHEN t.transaction_type = 'expense'
                             THEN t.amount_paise END), 0) AS expenses
    FROM financial_transactions t
    WHERE t.shop_id = ? AND t.business_date >= ? AND t.business_date <= ?
      AND t.transaction_type IN
          ('customer_credit', 'customer_payment', 'expense')
      AND $_notReversed
    GROUP BY t.business_date
    ORDER BY t.business_date DESC
    LIMIT ?
    ''',
            variables: [
              ..._periodVariables(shopId, fromDate, toDate),
              Variable.withInt(limit),
            ],
          )
          .map(
            (row) => DayTotalsRow(
              businessDate: row.read<String>('business_date'),
              creditPaise: row.read<int>('credit'),
              collectionsPaise: row.read<int>('collections'),
              expensesPaise: row.read<int>('expenses'),
            ),
          )
          .get();

  List<Variable<Object>> _periodVariables(
    String shopId,
    String? fromDate,
    String? toDate,
  ) => [
    Variable.withString(shopId),
    Variable.withString(fromDate ?? _minDate),
    Variable.withString(toDate ?? _maxDate),
  ];

  // ---- Statement ---------------------------------------------------------

  /// The party of an account with the account balance before [from] and
  /// before [to]. The balance counts every entry, reversals included.
  Future<StatementAccountRow?> statementAccount({
    required String shopId,
    required String accountId,
    required DateTime? from,
    required DateTime? to,
  }) =>
      customSelect(
            '''
    SELECT p.display_name AS party_name, a.role AS role,
           COALESCE(SUM(CASE WHEN t.effective_at < ?3
                             THEN e.amount_paise END), 0) AS opening_paise,
           COALESCE(SUM(CASE WHEN t.effective_at < ?4
                             THEN e.amount_paise END), 0) AS closing_paise
    FROM party_accounts a
    JOIN parties p ON p.id = a.party_id
    LEFT JOIN party_ledger_entries e ON e.party_account_id = a.id
    LEFT JOIN financial_transactions t ON t.id = e.transaction_id
    WHERE a.shop_id = ?1 AND a.id = ?2
    GROUP BY a.id
    ''',
            variables: [
              Variable.withString(shopId),
              Variable.withString(accountId),
              Variable.withInt(from?.millisecondsSinceEpoch ?? _minInstant),
              Variable.withInt(to?.millisecondsSinceEpoch ?? _maxInstant),
            ],
          )
          .map(
            (row) => StatementAccountRow(
              partyName: row.read<String>('party_name'),
              role: _roles.fromSql(row.read<String>('role')),
              openingPaise: row.read<int>('opening_paise'),
              closingPaise: row.read<int>('closing_paise'),
            ),
          )
          .getSingleOrNull();

  /// Entries of an account in `[from, to)`, newest first.
  Future<List<StatementLineRow>> statementLines({
    required String shopId,
    required String accountId,
    required DateTime? from,
    required DateTime? to,
    required int limit,
  }) =>
      customSelect(
            '''
    SELECT t.id AS transaction_id, t.transaction_type AS transaction_type,
           e.amount_paise AS amount_paise, t.effective_at AS effective_at,
           t.description AS description,
           EXISTS (SELECT 1 FROM financial_transactions r
                   WHERE r.reversal_of_transaction_id = t.id) AS is_reversed
    FROM party_ledger_entries e
    JOIN financial_transactions t ON t.id = e.transaction_id
    WHERE e.shop_id = ? AND e.party_account_id = ?
      AND t.effective_at >= ? AND t.effective_at < ?
    ORDER BY t.effective_at DESC, t.recorded_at DESC, e.id DESC
    LIMIT ?
    ''',
            variables: [
              Variable.withString(shopId),
              Variable.withString(accountId),
              Variable.withInt(from?.millisecondsSinceEpoch ?? _minInstant),
              Variable.withInt(to?.millisecondsSinceEpoch ?? _maxInstant),
              Variable.withInt(limit),
            ],
          )
          .map(
            (row) => StatementLineRow(
              transactionId: row.read<String>('transaction_id'),
              type: _types.fromSql(row.read<String>('transaction_type')),
              amountPaise: row.read<int>('amount_paise'),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              description: row.readNullable<String>('description'),
              isReversed: row.read<bool>('is_reversed'),
            ),
          )
          .get();
}
