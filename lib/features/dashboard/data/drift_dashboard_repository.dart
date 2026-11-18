import 'package:smart_khata/core/database/daos/dashboard_dao.dart';
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';

/// [DashboardRepository] built from derived ledger and transaction totals.
final class DriftDashboardRepository implements DashboardRepository {
  const DriftDashboardRepository({
    required this._dashboard,
    required this._shops,
    required this._clock,
    required this._logger,
  });

  static const int recentLimit = 6;

  final DashboardDao _dashboard;
  final ShopDao _shops;
  final Clock _clock;
  final AppLogger _logger;

  @override
  Stream<Result<DashboardSummary>> watchSummary() => guardStream(
    _dashboard.changes().asyncMap((_) => _load()),
    logger: _logger,
    operation: 'dashboard.watch',
  );

  Future<DashboardSummary> _load() async {
    final shop = await _shops.currentShop();
    if (shop == null) throw const FailureException(NotFoundFailure('shop'));

    // "Today" is the shop's business date, not the UTC date (PRD 9.5).
    final today = BusinessDate.fromInstant(
      _clock.nowUtc(),
      ShopTimeZone.resolve(shop.timeZone),
    );
    final totals = await _dashboard.roleTotals(shop.id);
    final day = await _dashboard.dayTotals(shop.id, today.toIso());
    final recent = await _dashboard.recentActivity(shop.id, recentLimit);

    RoleTotals totalsFor(PartyRole role) {
      for (final row in totals) {
        if (row.role == role) {
          return RoleTotals(
            owed: Money.fromPaise(row.owedPaise),
            advance: Money.fromPaise(row.advancePaise),
            accountsWithDues: row.accountsWithDues,
            accounts: row.accounts,
          );
        }
      }
      return RoleTotals.empty;
    }

    Money dayTotal(TransactionType type) => Money.fromPaise(day[type] ?? 0);

    return DashboardSummary(
      shopName: shop.name,
      today: today,
      customers: totalsFor(PartyRole.customer),
      suppliers: totalsFor(PartyRole.supplier),
      todayCredit: dayTotal(TransactionType.customerCredit),
      todayCollections: dayTotal(TransactionType.customerPayment),
      todayExpenses: dayTotal(TransactionType.expense),
      recent: [
        for (final row in recent)
          ActivityItem(
            partyId: row.partyId,
            partyName: row.partyName,
            role: row.role,
            type: row.type,
            signedAmount: Money.fromPaise(row.signedPaise),
            effectiveAt: row.effectiveAt,
          ),
      ],
    );
  }
}
