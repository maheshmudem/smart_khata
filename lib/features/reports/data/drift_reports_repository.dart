import 'package:smart_khata/core/database/daos/reports_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/reports/domain/reports.dart';

final class DriftReportsRepository implements ReportsRepository {
  const DriftReportsRepository({
    required this._dao,
    required this._shop,
    required this._logger,
  });

  /// Days listed in a period report.
  static const int maxDays = 366;

  final ReportsDao _dao;
  final ShopContext _shop;
  final AppLogger _logger;

  @override
  Stream<DashboardSummary> watchDashboard(BusinessDate today) {
    final zone = ShopTimeZone.resolve(null);
    return Stream.fromFuture(_shop.requireShopId())
        .asyncExpand(
          (shopId) => _dao.watchDashboard(
            shopId: shopId,
            todayStart: today.startUtc(zone),
            businessDate: today.toIso(),
          ),
        )
        .map(
          (row) => DashboardSummary(
            customerOutstanding: Money.fromPaise(row.customerOutstandingPaise),
            customersWithDues: row.customersWithDues,
            overdueCustomers: row.overdueCustomers,
            customerAdvances: Money.fromPaise(row.customerAdvancesPaise),
            supplierPayable: Money.fromPaise(row.supplierPayablePaise),
            suppliersWithDues: row.suppliersWithDues,
            overdueSuppliers: row.overdueSuppliers,
            supplierAdvances: Money.fromPaise(row.supplierAdvancesPaise),
            todayCredit: Money.fromPaise(row.todayCreditPaise),
            todayCollections: Money.fromPaise(row.todayCollectionsPaise),
            todayExpenses: Money.fromPaise(row.todayExpensesPaise),
            partyCount: row.partyCount,
          ),
        )
        .mapErrorsToFailures(logger: _logger, operation: 'reports.dashboard');
  }

  @override
  Stream<List<ActivityItem>> watchRecentActivity({required int limit}) =>
      Stream.fromFuture(_shop.requireShopId())
          .asyncExpand(
            (shopId) => _dao.watchRecentActivity(shopId: shopId, limit: limit),
          )
          .map(
            (rows) => [
              for (final row in rows)
                ActivityItem(
                  transactionId: row.transactionId,
                  type: row.type,
                  amount: Money.fromPaise(row.amountPaise),
                  effectiveAt: row.effectiveAt,
                  partyName: row.partyName,
                  categoryName: row.categoryName,
                  description: row.description,
                  isReversed: row.isReversed,
                ),
            ],
          )
          .mapErrorsToFailures(logger: _logger, operation: 'reports.activity');

  @override
  Future<Result<OutstandingReport>> outstanding({
    required PartyRole role,
    required BusinessDate today,
    int limit = 200,
  }) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final zone = ShopTimeZone.resolve(null);
      final day7 = today.addDays(-7).startUtc(zone);
      final day15 = today.addDays(-15).startUtc(zone);
      final day30 = today.addDays(-30).startUtc(zone);

      final totals = await _dao.agingTotals(
        shopId: shopId,
        role: role,
        day7Start: day7,
        day15Start: day15,
        day30Start: day30,
      );
      // One extra row tells whether the list was cut short.
      final rows = await _dao.outstandingParties(
        shopId: shopId,
        role: role,
        day7Start: day7,
        day15Start: day15,
        day30Start: day30,
        limit: limit + 1,
      );
      final advances = await _dao.advanceParties(
        shopId: shopId,
        role: role,
        limit: limit,
      );
      return OutstandingReport(
        role: role,
        asOf: today,
        totals: _aging(totals),
        rows: [
          for (final row in rows.take(limit))
            OutstandingRow(
              partyId: row.partyId,
              accountId: row.accountId,
              partyName: row.partyName,
              aging: _aging(row.aging),
              oldestAgingDate: row.oldestAgingAt,
              openEntryCount: row.openEntryCount,
            ),
        ],
        advances: [
          for (final row in advances)
            AdvanceRow(
              partyId: row.partyId,
              partyName: row.partyName,
              amount: Money.fromPaise(row.advancePaise),
            ),
        ],
        isTruncated: rows.length > limit,
      );
    },
    logger: _logger,
    operation: 'reports.outstanding',
  );

  static AgingAmounts _aging(AgingRow row) => AgingAmounts(
    upTo7Days: Money.fromPaise(row.upTo7Paise),
    days8To15: Money.fromPaise(row.days8To15Paise),
    days16To30: Money.fromPaise(row.days16To30Paise),
    over30Days: Money.fromPaise(row.over30Paise),
  );

  @override
  Future<Result<PeriodReport>> period(DateRange range) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final from = range.start?.toIso();
      final to = range.end?.toIso();

      final byType = await _dao.totalsByType(
        shopId: shopId,
        fromDate: from,
        toDate: to,
      );
      final byMethod = await _dao.collectionsByMethod(
        shopId: shopId,
        fromDate: from,
        toDate: to,
      );
      final byCategory = await _dao.expensesByCategory(
        shopId: shopId,
        fromDate: from,
        toDate: to,
      );
      final days = await _dao.dayTotals(
        shopId: shopId,
        fromDate: from,
        toDate: to,
        limit: maxDays + 1,
      );
      Money of(TransactionType type) => Money.fromPaise(byType[type] ?? 0);

      return PeriodReport(
        range: range,
        creditGiven: of(TransactionType.customerCredit),
        collections: of(TransactionType.customerPayment),
        collectionsByMethod: {
          // In the fixed order of the enum, so the screen does not jump.
          for (final method in PaymentMethod.values)
            if (byMethod[method] != null)
              method: Money.fromPaise(byMethod[method]!),
        },
        salesReturns: of(TransactionType.customerSalesReturn),
        purchases: of(TransactionType.supplierPurchase),
        supplierPayments: of(TransactionType.supplierPayment),
        purchaseReturns: of(TransactionType.supplierPurchaseReturn),
        expenses: of(TransactionType.expense),
        expensesByCategory: {
          for (final (name, paise) in byCategory) name: Money.fromPaise(paise),
        },
        days: [
          for (final row in days.take(maxDays))
            DayTotals(
              date: BusinessDate.parse(row.businessDate),
              creditGiven: Money.fromPaise(row.creditPaise),
              collections: Money.fromPaise(row.collectionsPaise),
              expenses: Money.fromPaise(row.expensesPaise),
            ),
        ],
        hasMoreDays: days.length > maxDays,
      );
    },
    logger: _logger,
    operation: 'reports.period',
  );

  @override
  Future<Result<PartyStatement?>> statement({
    required String accountId,
    required DateRange range,
    int limit = 500,
  }) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final zone = ShopTimeZone.resolve(null);
      final from = range.startUtc(zone);
      final to = range.endUtcExclusive(zone);

      final account = await _dao.statementAccount(
        shopId: shopId,
        accountId: accountId,
        from: from,
        to: to,
      );
      if (account == null) return null;

      final newestFirst = await _dao.statementLines(
        shopId: shopId,
        accountId: accountId,
        from: from,
        to: to,
        limit: limit + 1,
      );
      final shown = newestFirst.take(limit).toList().reversed.toList();

      // The balance just before the first line shown. When the list was
      // cut short this is later than the opening balance, so it is worked
      // back from the closing balance.
      var running = account.closingPaise;
      for (final row in shown) {
        running -= row.amountPaise;
      }
      final lines = <StatementLine>[];
      for (final row in shown) {
        running += row.amountPaise;
        lines.add(
          StatementLine(
            transactionId: row.transactionId,
            type: row.type,
            amount: Money.fromPaise(row.amountPaise),
            balanceAfter: Money.fromPaise(running),
            effectiveAt: row.effectiveAt,
            description: row.description,
            isReversed: row.isReversed,
          ),
        );
      }
      return PartyStatement(
        partyName: account.partyName,
        role: account.role,
        range: range,
        openingBalance: Money.fromPaise(account.openingPaise),
        lines: lines,
        closingBalance: Money.fromPaise(account.closingPaise),
        isTruncated: newestFirst.length > limit,
      );
    },
    logger: _logger,
    operation: 'reports.statement',
  );
}
