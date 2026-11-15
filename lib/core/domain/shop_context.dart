/// The shop this install belongs to. V1 has exactly one (ADR-001), but
/// every business row carries its `shop_id` and every query filters by it.
// One method on purpose: an injection seam.
// ignore: one_member_abstracts
abstract interface class ShopContext {
  /// The shop's ID. Fails with a not-found failure before shop setup.
  Future<String> requireShopId();
}
