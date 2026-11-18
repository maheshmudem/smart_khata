import 'package:drift/drift.dart' show Value;
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// [ShopRepository] over the `shops` and `money_accounts` tables.
final class DriftShopRepository implements ShopRepository {
  const DriftShopRepository({
    required this._database,
    required this._dao,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  /// Stored name of the default account. A fixed code-like value: the
  /// screen shows the translated "Cash" label for account type `cash`.
  static const String cashAccountName = 'Cash';

  final db.AppDatabase _database;
  final ShopDao _dao;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  @override
  Future<Result<Shop?>> getShop() => guard(
    () async => _toDomain(await _dao.currentShop()),
    logger: _logger,
    operation: 'shop.get',
  );

  @override
  Stream<Result<Shop?>> watchShop() => guardStream(
    _dao.watchCurrentShop().map(_toDomain),
    logger: _logger,
    operation: 'shop.watch',
  );

  @override
  Future<Result<Shop>> createShop({
    required ShopProfile profile,
    required String localeCode,
    required Money openingCash,
  }) => guard(
    () => _database.transaction(() async {
      // Single-shop invariant: resuming an interrupted setup returns the
      // shop that was already created and writes nothing.
      final existing = _toDomain(await _dao.currentShop());
      if (existing != null) return existing;

      final now = _clock.nowUtc();
      final shopId = _ids.newId();
      await _dao.insertShop(
        db.ShopsCompanion.insert(
          id: shopId,
          name: profile.name,
          ownerName: Value(profile.ownerName),
          phone: Value(profile.phone),
          address: Value(profile.address),
          locality: Value(profile.locality),
          localeCode: Value(localeCode),
          timeZone: ShopTimeZone.defaultName,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final cashId = _ids.newId();
      await _dao.insertMoneyAccount(
        db.MoneyAccountsCompanion.insert(
          id: cashId,
          shopId: shopId,
          name: cashAccountName,
          accountType: MoneyAccountType.cash,
          openingBalancePaise: Value(openingCash.paise),
          openingEffectiveAt: now,
          createdAt: now,
        ),
      );
      await _audit(shopId, 'shop', shopId, 'created', now);
      await _audit(shopId, 'money_account', cashId, 'created', now);
      return Shop(
        id: shopId,
        profile: profile,
        timeZone: ShopTimeZone.defaultName,
      );
    }),
    logger: _logger,
    operation: 'shop.create',
  );

  @override
  Future<Result<Shop>> updateProfile(String shopId, ShopProfile profile) =>
      guard(
        () => _database.transaction(() async {
          final now = _clock.nowUtc();
          final updated = await _dao.updateShop(
            shopId,
            db.ShopsCompanion(
              name: Value(profile.name),
              ownerName: Value(profile.ownerName),
              phone: Value(profile.phone),
              address: Value(profile.address),
              locality: Value(profile.locality),
              updatedAt: Value(now),
            ),
          );
          if (updated == 0) {
            throw const FailureException(NotFoundFailure('shop'));
          }
          await _audit(shopId, 'shop', shopId, 'profile_updated', now);
          return _toDomain(await _dao.currentShop())!;
        }),
        logger: _logger,
        operation: 'shop.updateProfile',
      );

  Future<void> _audit(
    String shopId,
    String entityType,
    String entityId,
    String action,
    DateTime now,
  ) => _dao.insertAudit(
    db.AuditLogsCompanion.insert(
      id: _ids.newId(),
      shopId: shopId,
      entityType: entityType,
      entityId: entityId,
      action: action,
      createdAt: now,
    ),
  );

  static Shop? _toDomain(db.Shop? row) => row == null
      ? null
      : Shop(
          id: row.id,
          timeZone: row.timeZone,
          profile: ShopProfile(
            name: row.name,
            ownerName: row.ownerName,
            phone: row.phone,
            address: row.address,
            locality: row.locality,
          ),
        );
}
