import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/money_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

final class DriftMoneyAccountRepository implements MoneyAccountRepository {
  const DriftMoneyAccountRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final MoneyDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  @override
  Stream<List<MoneyAccount>> watchAccounts() =>
      Stream.fromFuture(_shop.requireShopId())
          .asyncExpand(_dao.watchAccounts)
          .map((rows) => rows.map(_toDomain).toList())
          .mapErrorsToFailures(logger: _logger, operation: 'money.watch');

  @override
  Future<Result<List<MoneyAccount>>> getAccounts() => guard(
    () async {
      final rows = await _dao.getAccounts(await _shop.requireShopId());
      return rows.map(_toDomain).toList();
    },
    logger: _logger,
    operation: 'money.getAccounts',
  );

  @override
  Future<Result<String>> createAccount({
    required String name,
    required MoneyAccountType type,
  }) => guard(
    () async {
      final now = _clock.nowUtc();
      final id = _ids.newId();
      await _dao.insertAccount(
        db.MoneyAccountsCompanion.insert(
          id: id,
          shopId: await _shop.requireShopId(),
          name: name,
          accountType: type,
          openingEffectiveAt: now,
          createdAt: now,
        ),
      );
      return id;
    },
    logger: _logger,
    operation: 'money.createAccount',
  );

  static MoneyAccount _toDomain(MoneyAccountBalanceRow row) => MoneyAccount(
    id: row.id,
    name: row.name,
    type: row.type,
    balance: Money.fromPaise(row.balancePaise),
  );
}
