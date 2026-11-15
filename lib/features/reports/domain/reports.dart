import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

// ---- Dashboard (WF-010, PRD 9.5) ------------------------------------------

/// The numbers on the Home screen. Each one has a fixed definition
/// (PRD 9.5); none of them is profit.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.customerOutstanding,
    required this.customersWithDues,
    required this.overdueCustomers,
    required this.customerAdvances,
    required this.supplierPayable,
    required this.suppliersWithDues,
    required this.overdueSuppliers,
    required this.supplierAdvances,
    required this.todayCredit,
    required this.todayCollections,
    required this.todayExpenses,
    required this.partyCount,
  });

  /// Sum of positive customer balances. Advances are not netted off.
  final Money customerOutstanding;
  final int customersWithDues;

  /// Customers with an unsettled entry whose due date has passed.
  final int overdueCustomers;

  /// Sum of customer advances, shown separately.
  final Money customerAdvances;

  /// Sum of positive supplier balances.
  final Money supplierPayable;
  final int suppliersWithDues;
  final int overdueSuppliers;
  final Money supplierAdvances;

  /// Customer credit dated today.
  final Money todayCredit;

  /// Customer payments dated today, by any method. Not revenue.
  final Money todayCollections;

  /// Expenses dated today.
  final Money todayExpenses;

  /// Customers and suppliers on record; zero means a brand-new shop.
  final int partyCount;

  @override
  List<Object?> get props => [
    customerOutstanding,
    customersWithDues,
    overdueCustomers,
    customerAdvances,
    supplierPayable,
    suppliersWithDues,
    overdueSuppliers,
    supplierAdvances,
    todayCredit,
    todayCollections,
    todayExpenses,
    partyCount,
  ];
}

/// One row of "Recent activity".
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.effectiveAt,
    required this.isReversed,
    this.partyName,
    this.categoryName,
    this.description,
  });

  final String transactionId;
  final TransactionType type;
  final Money amount;
  final DateTime effectiveAt;
  final String? partyName;
  final String? categoryName;
  final String? description;
  final bool isReversed;

  @override
  List<Object?> get props => [
    transactionId,
    type,
    amount,
    effectiveAt,
    partyName,
    categoryName,
    description,
    isReversed,
  ];
}

// ---- Outstanding and aging (WF-051) ---------------------------------------

/// How long an unsettled amount has been due. Ages count from the due
/// date, or from the entry date when there is none (schema doc 5.4).
enum AgingBucket {
  /// Not yet due, or up to 7 days.
  upTo7Days,
  days8To15,
  days16To30,
  over30Days;

  /// The bucket for an amount that started aging on [agingDate].
  static AgingBucket of(BusinessDate agingDate, BusinessDate today) {
    final days = today.differenceInDays(agingDate);
    if (days <= 7) return AgingBucket.upTo7Days;
    if (days <= 15) return AgingBucket.days8To15;
    if (days <= 30) return AgingBucket.days16To30;
    return AgingBucket.over30Days;
  }
}

/// Unsettled amounts split by age. The split is of what is still open on
/// each entry after payments were applied, never of the latest entry.
class AgingAmounts extends Equatable {
  const AgingAmounts({
    required this.upTo7Days,
    required this.days8To15,
    required this.days16To30,
    required this.over30Days,
  });

  static const AgingAmounts zero = AgingAmounts(
    upTo7Days: Money.zero,
    days8To15: Money.zero,
    days16To30: Money.zero,
    over30Days: Money.zero,
  );

  final Money upTo7Days;
  final Money days8To15;
  final Money days16To30;
  final Money over30Days;

  Money get total => upTo7Days + days8To15 + days16To30 + over30Days;

  Money amountIn(AgingBucket bucket) => switch (bucket) {
    AgingBucket.upTo7Days => upTo7Days,
    AgingBucket.days8To15 => days8To15,
    AgingBucket.days16To30 => days16To30,
    AgingBucket.over30Days => over30Days,
  };

  @override
  List<Object?> get props => [upTo7Days, days8To15, days16To30, over30Days];
}

/// One party's unsettled amounts.
class OutstandingRow extends Equatable {
  const OutstandingRow({
    required this.partyId,
    required this.accountId,
    required this.partyName,
    required this.aging,
    required this.oldestAgingDate,
    required this.openEntryCount,
  });

  final String partyId;
  final String accountId;
  final String partyName;
  final AgingAmounts aging;

  /// The date the oldest unsettled entry ages from.
  final DateTime oldestAgingDate;
  final int openEntryCount;

  Money get total => aging.total;

  @override
  List<Object?> get props => [
    partyId,
    accountId,
    partyName,
    aging,
    oldestAgingDate,
    openEntryCount,
  ];
}

/// A party holding an advance.
class AdvanceRow extends Equatable {
  const AdvanceRow({
    required this.partyId,
    required this.partyName,
    required this.amount,
  });

  final String partyId;
  final String partyName;

  /// The advance as a positive amount.
  final Money amount;

  @override
  List<Object?> get props => [partyId, partyName, amount];
}

/// The outstanding and aging report for one role. Advances are a separate
/// section and are never netted against dues (WF-051).
class OutstandingReport extends Equatable {
  const OutstandingReport({
    required this.role,
    required this.asOf,
    required this.totals,
    required this.rows,
    required this.advances,
    required this.isTruncated,
  });

  final PartyRole role;
  final BusinessDate asOf;

  /// Over every party, not only the rows shown.
  final AgingAmounts totals;

  /// Largest dues first.
  final List<OutstandingRow> rows;
  final List<AdvanceRow> advances;

  /// More parties have dues than [rows] holds.
  final bool isTruncated;

  Money get totalAdvances => Money.sum(advances.map((a) => a.amount));

  @override
  List<Object?> get props => [role, asOf, totals, rows, advances, isTruncated];
}

// ---- Period report (FR-REP-004..006) --------------------------------------

/// Totals of one business day inside a period.
class DayTotals extends Equatable {
  const DayTotals({
    required this.date,
    required this.creditGiven,
    required this.collections,
    required this.expenses,
  });

  final BusinessDate date;
  final Money creditGiven;
  final Money collections;
  final Money expenses;

  @override
  List<Object?> get props => [date, creditGiven, collections, expenses];
}

/// Totals of entries dated inside a period. Reversed entries are left
/// out. These are totals of entries and money movements, not balances and
/// not profit (FR-REP-008).
class PeriodReport extends Equatable {
  const PeriodReport({
    required this.range,
    required this.creditGiven,
    required this.collections,
    required this.collectionsByMethod,
    required this.salesReturns,
    required this.purchases,
    required this.supplierPayments,
    required this.purchaseReturns,
    required this.expenses,
    required this.expensesByCategory,
    required this.days,
    required this.hasMoreDays,
  });

  final DateRange range;
  final Money creditGiven;
  final Money collections;
  final Map<PaymentMethod, Money> collectionsByMethod;
  final Money salesReturns;
  final Money purchases;
  final Money supplierPayments;
  final Money purchaseReturns;
  final Money expenses;

  /// Category name (as saved on each expense) → total, largest first.
  final Map<String, Money> expensesByCategory;

  /// Newest day first; only days with entries.
  final List<DayTotals> days;

  /// The period has more days with entries than [days] holds. The totals
  /// above still cover the whole period.
  final bool hasMoreDays;

  @override
  List<Object?> get props => [
    range,
    creditGiven,
    collections,
    collectionsByMethod,
    salesReturns,
    purchases,
    supplierPayments,
    purchaseReturns,
    expenses,
    expensesByCategory,
    days,
    hasMoreDays,
  ];
}

// ---- Party statement (WF-052, FR-LED-009) ---------------------------------

class StatementLine extends Equatable {
  const StatementLine({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.effectiveAt,
    required this.isReversed,
    this.description,
  });

  final String transactionId;
  final TransactionType type;

  /// Signed effect on the balance.
  final Money amount;
  final Money balanceAfter;
  final DateTime effectiveAt;
  final String? description;
  final bool isReversed;

  @override
  List<Object?> get props => [
    transactionId,
    type,
    amount,
    balanceAfter,
    effectiveAt,
    description,
    isReversed,
  ];
}

/// A statement of one party account for a period: the balance before it,
/// every entry in order (reversals included), and the balance after it.
/// It contains nothing about any other party.
class PartyStatement extends Equatable {
  const PartyStatement({
    required this.partyName,
    required this.role,
    required this.range,
    required this.openingBalance,
    required this.lines,
    required this.closingBalance,
    required this.isTruncated,
  });

  final String partyName;
  final PartyRole role;
  final DateRange range;

  /// The account balance just before the period.
  final Money openingBalance;

  /// Oldest first.
  final List<StatementLine> lines;

  /// The account balance at the end of the period.
  final Money closingBalance;

  /// The period has more entries than [lines] holds; the closing balance
  /// is still that of the whole period.
  final bool isTruncated;

  @override
  List<Object?> get props => [
    partyName,
    role,
    range,
    openingBalance,
    lines,
    closingBalance,
    isTruncated,
  ];
}

// ---- Repository -----------------------------------------------------------

/// Read-only reporting. Every figure is computed from the ledger and money
/// movements by a bounded query; nothing here is stored.
abstract interface class ReportsRepository {
  Stream<DashboardSummary> watchDashboard(BusinessDate today);

  /// Latest entries of any kind, newest first.
  Stream<List<ActivityItem>> watchRecentActivity({required int limit});

  Future<Result<OutstandingReport>> outstanding({
    required PartyRole role,
    required BusinessDate today,
    int limit = 200,
  });

  Future<Result<PeriodReport>> period(DateRange range);

  /// `null` if the account does not exist.
  Future<Result<PartyStatement?>> statement({
    required String accountId,
    required DateRange range,
    int limit = 500,
  });
}
