import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';

part 'shop_dao.g.dart';

/// The shop row, its money accounts and the audit trail.
@DriftAccessor(include: {'../schema/operations.drift'})
class ShopDao extends DatabaseAccessor<AppDatabase> with _$ShopDaoMixin {
  ShopDao(super.attachedDatabase);

  SimpleSelectStatement<Shops, Shop> _current() => select(shops)
    ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
    ..limit(1);

  /// V1 has one shop; the oldest row is it.
  Future<Shop?> currentShop() => _current().getSingleOrNull();

  Stream<Shop?> watchCurrentShop() => _current().watchSingleOrNull();

  Future<void> insertShop(ShopsCompanion row) => into(shops).insert(row);

  Future<int> updateShop(String id, ShopsCompanion row) =>
      (update(shops)..where((t) => t.id.equals(id))).write(row);

  Future<void> insertMoneyAccount(MoneyAccountsCompanion row) =>
      into(moneyAccounts).insert(row);

  /// Appends one audit record. Audit rows are append-only (ADR-020).
  Future<void> insertAudit(AuditLogsCompanion row) =>
      into(auditLogs).insert(row);
}
