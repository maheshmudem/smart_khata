import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'shop_dao.g.dart';

@DriftAccessor(include: {'../schema/parties.drift', '../schema/money.drift'})
class ShopDao extends DatabaseAccessor<AppDatabase> with _$ShopDaoMixin {
  ShopDao(super.attachedDatabase);

  /// The one shop, or `null` before setup. Ordered so the result is stable
  /// even if a second row ever existed.
  Future<Shop?> findShop() =>
      (select(shops)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Inserts the shop and its default cash account. Call inside a
  /// transaction.
  Future<void> insertShopWithCashAccount({
    required ShopsCompanion shop,
    required String cashAccountId,
    required String cashAccountName,
    required DateTime now,
    List<ExpenseCategoriesCompanion> expenseCategories = const [],
  }) async {
    await into(shops).insert(shop);
    await into(moneyAccounts).insert(
      MoneyAccountsCompanion.insert(
        id: cashAccountId,
        shopId: shop.id.value,
        name: cashAccountName,
        accountType: MoneyAccountType.cash,
        openingEffectiveAt: now,
        createdAt: now,
      ),
    );
    for (final category in expenseCategories) {
      await into(this.expenseCategories).insert(category);
    }
  }
}
