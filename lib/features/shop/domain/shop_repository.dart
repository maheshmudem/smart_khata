import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

abstract interface class ShopRepository {
  /// The shop, or `null` before setup.
  Future<Result<Shop?>> getShop();

  /// The shop, re-emitted whenever its profile changes.
  Stream<Result<Shop?>> watchShop();

  /// Creates the shop and its Cash money account in one transaction
  /// (SK-0202, SK-0203).
  ///
  /// V1 has exactly one shop: when one already exists (setup was interrupted
  /// and is being resumed) it is returned unchanged and nothing is written.
  Future<Result<Shop>> createShop({
    required ShopProfile profile,
    required String localeCode,
    required Money openingCash,
  });

  Future<Result<Shop>> updateProfile(String shopId, ShopProfile profile);
}
