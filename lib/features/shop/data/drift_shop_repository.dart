import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// [ShopRepository] on SQLite. Also the [ShopContext] other repositories
/// use to scope their queries.
final class DriftShopRepository implements ShopRepository, ShopContext {
  DriftShopRepository({
    required this._dao,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final ShopDao _dao;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  /// The shop ID never changes once the shop exists, so it is read once.
  String? _cachedShopId;

  @override
  Future<String> requireShopId() async {
    final cached = _cachedShopId;
    if (cached != null) return cached;
    final shop = await _dao.findShop();
    if (shop == null) throw const FailureException(NotFoundFailure('shop'));
    return _cachedShopId = shop.id;
  }

  @override
  Future<Result<Shop?>> getShop() => guard(
    () async => switch (await _dao.findShop()) {
      final row? => _toDomain(row),
      null => null,
    },
    logger: _logger,
    operation: 'shop.get',
  );

  @override
  Future<Result<Shop>> createShop(CreateShopCommand command) => guard(
    () => _dao.transaction(() async {
      // Re-entering setup must never create a second shop (WF-002).
      final existing = await _dao.findShop();
      if (existing != null) return _toDomain(existing);

      final now = _clock.nowUtc();
      final shopId = _ids.newId();
      await _dao.insertShopWithCashAccount(
        shop: db.ShopsCompanion.insert(
          id: shopId,
          name: command.name,
          ownerName: Value(command.ownerName),
          phone: Value(command.phone),
          address: Value(command.address),
          locality: Value(command.locality),
          localeCode: Value(command.localeCode),
          timeZone: ShopTimeZone.defaultName,
          createdAt: now,
          updatedAt: now,
        ),
        cashAccountId: _ids.newId(),
        cashAccountName: command.cashAccountName,
        now: now,
      );
      _cachedShopId = shopId;
      return _toDomain((await _dao.findShop())!);
    }),
    logger: _logger,
    operation: 'shop.create',
  );

  static Shop _toDomain(db.Shop row) => Shop(
    id: row.id,
    name: row.name,
    ownerName: row.ownerName,
    phone: row.phone,
    address: row.address,
    locality: row.locality,
    timeZone: row.timeZone,
  );
}
