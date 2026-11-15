import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'money_dao.g.dart';

/// A money account with its derived balance.
class MoneyAccountBalanceRow {
  const MoneyAccountBalanceRow({
    required this.id,
    required this.name,
    required this.type,
    required this.balancePaise,
  });

  final String id;
  final String name;
  final MoneyAccountType type;
  final int balancePaise;
}

const _accountTypes = CodedEnumConverter<MoneyAccountType>(
  MoneyAccountType.values,
);

@DriftAccessor(include: {'../schema/money.drift'})
class MoneyDao extends DatabaseAccessor<AppDatabase> with _$MoneyDaoMixin {
  MoneyDao(super.attachedDatabase);

  Stream<List<MoneyAccountBalanceRow>> watchAccounts(String shopId) =>
      _accounts(shopId).watch();

  Future<List<MoneyAccountBalanceRow>> getAccounts(String shopId) =>
      _accounts(shopId).get();

  /// Active accounts, cash first. Balance = opening + inflows - outflows
  /// (schema doc 3.8); it is computed here and never stored.
  Selectable<MoneyAccountBalanceRow> _accounts(String shopId) =>
      customSelect(
        '''
    SELECT m.id AS id, m.name AS name, m.account_type AS account_type,
           m.opening_balance_paise + COALESCE((
             SELECT SUM(CASE WHEN v.direction = 'inflow'
                             THEN v.amount_paise ELSE -v.amount_paise END)
             FROM money_movements v WHERE v.money_account_id = m.id
           ), 0) AS balance_paise
    FROM money_accounts m
    WHERE m.shop_id = ? AND m.is_active = 1
    ORDER BY CASE m.account_type WHEN 'cash' THEN 0 ELSE 1 END,
             m.created_at, m.id
    ''',
        variables: [Variable.withString(shopId)],
        readsFrom: {moneyAccounts, moneyMovements},
      ).map(
        (row) => MoneyAccountBalanceRow(
          id: row.read<String>('id'),
          name: row.read<String>('name'),
          type: _accountTypes.fromSql(row.read<String>('account_type')),
          balancePaise: row.read<int>('balance_paise'),
        ),
      );

  Future<void> insertAccount(MoneyAccountsCompanion account) =>
      into(moneyAccounts).insert(account);
}
