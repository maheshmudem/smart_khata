import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/cash_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/money/domain/cash_book.dart';

final class DriftCashBookRepository implements CashBookRepository {
  const DriftCashBookRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final CashDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  @override
  Stream<CashBookSummary> watchSummary(String accountId, DateRange range) {
    final zone = ShopTimeZone.resolve(null);
    return Stream.fromFuture(_shop.requireShopId())
        .asyncExpand(
          (shopId) => _dao.watchSummary(
            shopId: shopId,
            accountId: accountId,
            from: range.startUtc(zone),
            to: range.endUtcExclusive(zone),
          ),
        )
        .map(
          (row) => CashBookSummary(
            openingBalance: Money.fromPaise(row.openingPaise),
            inflows: Money.fromPaise(row.inflowPaise),
            outflows: Money.fromPaise(row.outflowPaise),
          ),
        )
        .mapErrorsToFailures(logger: _logger, operation: 'cashBook.summary');
  }

  @override
  Stream<List<CashBookLine>> watchLines(
    String accountId,
    DateRange range, {
    required int limit,
  }) {
    final zone = ShopTimeZone.resolve(null);
    return Stream.fromFuture(_shop.requireShopId())
        .asyncExpand(
          (shopId) => _dao.watchLines(
            shopId: shopId,
            accountId: accountId,
            from: range.startUtc(zone),
            to: range.endUtcExclusive(zone),
            limit: limit,
          ),
        )
        .map(
          (rows) => [
            for (final row in rows)
              CashBookLine(
                movementId: row.movementId,
                transactionId: row.transactionId,
                transactionType: row.transactionType,
                direction: row.direction,
                amount: Money.fromPaise(row.amountPaise),
                method: row.method,
                effectiveAt: row.effectiveAt,
                partyName: row.partyName,
                categoryName: row.categoryName,
                description: row.description,
                isReversed: row.isReversed,
              ),
          ],
        )
        .mapErrorsToFailures(logger: _logger, operation: 'cashBook.lines');
  }

  @override
  Future<Result<String>> postAdjustment(AdjustmentPosting posting) => guard(
    () => _dao.transaction(() async {
      final existing = await _dao.findByOperationId(posting.operationId);
      if (existing != null) {
        // The same ID must be the same adjustment, not an edited one.
        if (existing.amountPaise != posting.amount.paise) {
          throw const FailureException(DuplicateOperationFailure());
        }
        return existing.id;
      }

      final shopId = await _shop.requireShopId();
      final account = await _dao.findMoneyAccount(
        shopId: shopId,
        id: posting.moneyAccountId,
      );
      if (account == null || !account.isActive) {
        throw const FailureException(NotFoundFailure('money_account'));
      }
      final isCash = account.accountType == MoneyAccountType.cash;

      final now = _clock.nowUtc();
      final transactionId = _ids.newId();
      await _dao.insertTransaction(
        db.FinancialTransactionsCompanion.insert(
          id: transactionId,
          shopId: shopId,
          transactionType: isCash
              ? TransactionType.cashAdjustment
              : TransactionType.bankAdjustment,
          amountPaise: posting.amount.paise,
          effectiveAt: posting.effectiveAt,
          recordedAt: now,
          businessDate: posting.businessDate.toIso(),
          description: Value(posting.reason),
          operationId: posting.operationId,
          createdAt: now,
        ),
      );
      await _dao.insertMovement(
        db.MoneyMovementsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          transactionId: transactionId,
          moneyAccountId: account.id,
          paymentMethod: isCash ? PaymentMethod.cash : PaymentMethod.other,
          direction: posting.direction,
          amountPaise: posting.amount.paise,
          createdAt: now,
        ),
      );
      // An adjustment is exactly the kind of entry that must be
      // explainable later: the reason goes to the audit trail.
      await _dao.insertAuditLog(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          entityType: 'financial_transaction',
          entityId: transactionId,
          action: 'money_adjustment_recorded',
          reason: Value(posting.reason),
          createdAt: now,
        ),
      );
      return transactionId;
    }),
    logger: _logger,
    operation: 'cashBook.postAdjustment',
  );

  @override
  Future<Result<void>> setAccountActive(
    String accountId, {
    required bool active,
  }) => guard(
    () => _dao.transaction(() async {
      final shopId = await _shop.requireShopId();
      final account = await _dao.findMoneyAccount(
        shopId: shopId,
        id: accountId,
      );
      if (account == null) {
        throw const FailureException(NotFoundFailure('money_account'));
      }
      if (!active && account.accountType == MoneyAccountType.cash) {
        throw const FailureException(
          RuleFailure(RuleViolation.cashAccountRequired),
        );
      }
      await _dao.setAccountActive(
        shopId: shopId,
        id: accountId,
        active: active,
      );
      await _dao.insertAuditLog(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          entityType: 'money_account',
          entityId: accountId,
          action: active ? 'reactivated' : 'deactivated',
          createdAt: _clock.nowUtc(),
        ),
      );
    }),
    logger: _logger,
    operation: 'cashBook.setAccountActive',
  );
}
