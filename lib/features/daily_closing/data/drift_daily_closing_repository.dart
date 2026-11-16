import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/cash_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/daily_closing/domain/daily_closing.dart';

final class DriftDailyClosingRepository implements DailyClosingRepository {
  const DriftDailyClosingRepository({
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

  Future<db.MoneyAccount> _cashAccount() async {
    final account = await _dao.findCashAccount(await _shop.requireShopId());
    if (account == null) {
      throw const FailureException(NotFoundFailure('cash_account'));
    }
    return account;
  }

  /// Opening cash plus every cash movement dated up to the end of [date].
  Future<Money> _expected(String accountId, BusinessDate date) async {
    final summary = await _dao.getSummary(
      shopId: await _shop.requireShopId(),
      accountId: accountId,
      from: null,
      to: date.endUtcExclusive(ShopTimeZone.resolve(null)),
    );
    return Money.fromPaise(
      summary.openingPaise + summary.inflowPaise - summary.outflowPaise,
    );
  }

  @override
  Future<Result<Money>> expectedCash(BusinessDate date) => guard(
    () async => _expected((await _cashAccount()).id, date),
    logger: _logger,
    operation: 'closing.expectedCash',
  );

  @override
  Future<Result<DailyClosing?>> currentClosing(BusinessDate date) => guard(
    () async {
      final row = await _dao.currentClosing(
        accountId: (await _cashAccount()).id,
        businessDate: date.toIso(),
      );
      return row == null ? null : _toDomain(row);
    },
    logger: _logger,
    operation: 'closing.current',
  );

  @override
  Future<Result<DailyClosing>> saveClosing({
    required String operationId,
    required BusinessDate date,
    required CashCount count,
    required String? note,
  }) => guard(
    () => _dao.transaction(() async {
      final account = await _cashAccount();
      // A retry of a save that already committed adds no second revision.
      final repeated = await _dao.closingOfOperation(
        shopId: account.shopId,
        operationId: operationId,
      );
      if (repeated != null) return _toDomain(repeated);

      // Read inside the transaction: the snapshot is of the books exactly
      // as they are when the closing is saved.
      final expected = await _expected(account.id, date);
      final counted = count.total;
      final previous = await _dao.currentClosing(
        accountId: account.id,
        businessDate: date.toIso(),
      );

      final id = _ids.newId();
      final now = _clock.nowUtc();
      // A closing is only ever inserted. Closing a day again adds the next
      // revision, pointing at the one it replaces (WF-045). Nothing is
      // written to the cash book: a count is an observation.
      await _dao.insertClosing(
        db.DailyClosingsCompanion.insert(
          id: id,
          shopId: account.shopId,
          moneyAccountId: account.id,
          businessDate: date.toIso(),
          expectedCashPaise: expected.paise,
          countedCashPaise: counted.paise,
          variancePaise: (counted - expected).paise,
          denominationCountsJson: _encode(count),
          note: Value(note),
          revisionNumber: (previous?.revisionNumber ?? 0) + 1,
          supersedesClosingId: Value(previous?.id),
          createdAt: now,
        ),
      );
      // The audit row also carries the operation ID, which is how a
      // repeated save is recognised.
      await _dao.insertAuditLog(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: account.shopId,
          entityType: CashDao.closingEntityType,
          entityId: id,
          action: CashDao.closingAction,
          metadataJson: Value(operationId),
          createdAt: now,
        ),
      );
      final saved = await _dao.currentClosing(
        accountId: account.id,
        businessDate: date.toIso(),
      );
      return _toDomain(saved!);
    }),
    logger: _logger,
    operation: 'closing.save',
  );

  @override
  Stream<List<DailyClosing>> watchHistory({required int limit}) =>
      Stream.fromFuture(_cashAccount())
          .asyncExpand(
            (account) =>
                _dao.watchCurrentClosings(accountId: account.id, limit: limit),
          )
          .map((rows) => rows.map(_toDomain).toList())
          .mapErrorsToFailures(logger: _logger, operation: 'closing.history');

  // ---- Mapping -----------------------------------------------------------

  /// `{"notes": {"500": 4, ...}, "otherPaise": 250}`. Only counts, never
  /// anything about customers.
  static String _encode(CashCount count) => jsonEncode({
    'notes': {
      for (final denomination in cashDenominations)
        if (count.quantityOf(denomination) > 0)
          '$denomination': count.quantityOf(denomination),
    },
    'otherPaise': count.otherAmount?.paise ?? 0,
  });

  static CashCount _decode(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final notes = (data['notes'] as Map<String, dynamic>?) ?? const {};
    final otherPaise = (data['otherPaise'] as int?) ?? 0;
    return CashCount(
      quantities: {
        for (final entry in notes.entries)
          int.parse(entry.key): entry.value as int,
      },
      otherAmount: otherPaise == 0 ? null : Money.fromPaise(otherPaise),
    );
  }

  static DailyClosing _toDomain(db.DailyClosing row) => DailyClosing(
    id: row.id,
    businessDate: BusinessDate.parse(row.businessDate),
    expectedCash: Money.fromPaise(row.expectedCashPaise),
    countedCash: Money.fromPaise(row.countedCashPaise),
    count: _decode(row.denominationCountsJson),
    revisionNumber: row.revisionNumber,
    closedAt: row.createdAt,
    note: row.note,
  );
}
