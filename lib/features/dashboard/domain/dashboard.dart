import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// Totals for one side of the business. Owed and advance are kept apart
/// (PRD 9.5); customer and supplier totals are never combined.
final class RoleTotals extends Equatable {
  const RoleTotals({
    required this.owed,
    required this.advance,
    required this.accountsWithDues,
    required this.accounts,
  });

  static const RoleTotals empty = RoleTotals(
    owed: Money.zero,
    advance: Money.zero,
    accountsWithDues: 0,
    accounts: 0,
  );

  /// Sum of positive balances.
  final Money owed;

  /// Sum of advance magnitudes (negative balances).
  final Money advance;
  final int accountsWithDues;
  final int accounts;

  @override
  List<Object?> get props => [owed, advance, accountsWithDues, accounts];
}

/// One recent ledger line for the activity list.
final class ActivityItem extends Equatable {
  const ActivityItem({
    required this.partyId,
    required this.partyName,
    required this.role,
    required this.type,
    required this.signedAmount,
    required this.effectiveAt,
  });

  final String partyId;
  final String partyName;
  final PartyRole role;
  final TransactionType type;
  final Money signedAmount;
  final DateTime effectiveAt;

  @override
  List<Object?> get props => [
    partyId,
    partyName,
    role,
    type,
    signedAmount,
    effectiveAt,
  ];
}

/// Everything the Home dashboard shows (WF-010, FR-REP-001).
final class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.shopName,
    required this.today,
    required this.customers,
    required this.suppliers,
    required this.todayCredit,
    required this.todayCollections,
    required this.todayExpenses,
    required this.recent,
  });

  final String shopName;

  /// The shop's business date, in the shop time zone.
  final BusinessDate today;
  final RoleTotals customers;
  final RoleTotals suppliers;
  final Money todayCredit;
  final Money todayCollections;
  final Money todayExpenses;
  final List<ActivityItem> recent;

  bool get hasNoParties => customers.accounts == 0 && suppliers.accounts == 0;

  @override
  List<Object?> get props => [
    shopName,
    today,
    customers,
    suppliers,
    todayCredit,
    todayCollections,
    todayExpenses,
    recent,
  ];
}

// One stream method on purpose: the dashboard is one live query.
// ignore: one_member_abstracts
abstract interface class DashboardRepository {
  /// Re-emits whenever parties, ledgers or money change.
  Stream<Result<DashboardSummary>> watchSummary();
}
