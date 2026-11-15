import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

abstract interface class ShopRepository {
  /// The shop, or `null` before setup.
  Future<Result<Shop?>> getShop();

  /// Creates the shop and its default cash account in one transaction.
  ///
  /// If a shop already exists (setup was interrupted and re-entered) that
  /// shop is returned and nothing is written: there is never a second shop.
  Future<Result<Shop>> createShop(CreateShopCommand command);
}
