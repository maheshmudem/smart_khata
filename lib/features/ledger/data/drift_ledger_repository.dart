import 'package:drift/drift.dart' show Value;
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/ledger_dao.dart';
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/database/daos/shop_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';

/// [LedgerRepository] that posts credit, purchases and payments following
/// the atomic write contracts of schema 9.
final class DriftLedgerRepository implements LedgerRepository {
  const DriftLedgerRepository({
    required this._database,
    required this._ledger,
    required this._parties,
    required this._shops,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  /// Stored name of the account UPI and bank transfers land in (ADR-023).
  static const String bankAccountName = 'Bank & UPI';

  final db.AppDatabase _database;
  final LedgerDao _ledger;
  final PartiesDao _parties;
  final ShopDao _shops;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  @override
  Stream<Result<List<LedgerLine>>> watchLedger(String accountId, int limit) =>
      guardStream(
        _ledger.changes().asyncMap((_) async {
          final rows = await _ledger.ledgerLines(accountId, limit);
          return [
            for (final row in rows)
              LedgerLine(
                entryId: row.entryId,
                type: row.type,
                signedAmount: Money.fromPaise(row.amountPaise),
                runningBalance: Money.fromPaise(row.runningPaise),
                effectiveAt: row.effectiveAt,
                description: row.description,
                dueAt: row.dueAt,
                method: row.method,
              ),
          ];
        }),
        logger: _logger,
        operation: 'ledger.watch',
      );

  @override
  Future<Result<PostedEntry>> post(EntryPosting posting) => guard(
    () => _database.transaction(() async {
      // 1. Idempotency: a retry or double tap posts once (FR-PAY-006).
      if (await _parties.operationExists(posting.operationId)) {
        throw const FailureException(DuplicateOperationFailure());
      }

      // 2. The account must be in this shop, have the entry's role and
      //    belong to an active party.
      final shop = await _shops.currentShop();
      if (shop == null) throw const FailureException(NotFoundFailure('shop'));
      final context = await _parties.accountContext(
        posting.accountId,
        shop.id,
      );
      if (context == null || context.role != posting.type.role) {
        throw const FailureException(NotFoundFailure('party_account'));
      }
      if (context.partyStatus == PartyStatus.archived) {
        throw const FailureException(
          BusinessRuleFailure(BusinessRule.partyArchived),
        );
      }

      final now = _clock.nowUtc();
      final businessDate = BusinessDate.fromInstant(
        now,
        ShopTimeZone.resolve(shop.timeZone),
      );

      // 3. Header: the amount is always positive; direction is carried by
      //    the signed entry and the movement.
      final transactionId = _ids.newId();
      await _parties.insertTransaction(
        db.FinancialTransactionsCompanion.insert(
          id: transactionId,
          shopId: shop.id,
          partyAccountId: Value(posting.accountId),
          transactionType: posting.type.transactionType,
          amountPaise: posting.amount.paise,
          effectiveAt: now,
          recordedAt: now,
          businessDate: businessDate.toIso(),
          description: Value(posting.description),
          operationId: posting.operationId,
          createdAt: now,
        ),
      );

      // 4. The signed ledger entry.
      final entryId = _ids.newId();
      await _parties.insertLedgerEntry(
        db.PartyLedgerEntriesCompanion.insert(
          id: entryId,
          shopId: shop.id,
          partyAccountId: posting.accountId,
          transactionId: transactionId,
          entryKind: posting.type.entryKind,
          amountPaise: posting.signedAmount.paise,
          dueAt: Value(posting.dueAt),
          createdAt: now,
        ),
      );

      // 5. Allocations, oldest first. A payment settles open charges; a
      //    new charge uses up any advance the account holds. Whatever is
      //    left over stays on the ledger as an advance or a due.
      await _allocate(shop.id, posting, entryId, now);

      // 6. Money moves only for a payment (schema 4).
      final direction = posting.type.movement;
      final method = posting.method;
      if (direction != null && method != null) {
        await _ledger.insertMovement(
          db.MoneyMovementsCompanion.insert(
            id: _ids.newId(),
            shopId: shop.id,
            transactionId: transactionId,
            moneyAccountId: await _moneyAccountFor(shop.id, method, now),
            paymentMethod: method,
            direction: direction,
            amountPaise: posting.amount.paise,
            createdAt: now,
          ),
        );
      }

      // 7. Audit, then commit.
      await _parties.insertAudit(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: shop.id,
          entityType: 'financial_transaction',
          entityId: transactionId,
          action: '${posting.type.transactionType.code}_posted',
          createdAt: now,
        ),
      );
      return PostedEntry(
        balanceAfter: Money.fromPaise(
          await _ledger.balanceOf(posting.accountId),
        ),
      );
    }),
    logger: _logger,
    operation: 'ledger.post',
  );

  Future<void> _allocate(
    String shopId,
    EntryPosting posting,
    String entryId,
    DateTime now,
  ) async {
    final isCharge = posting.type.isCharge;
    final openRows = isCharge
        ? await _ledger.openSettlements(posting.accountId)
        : await _ledger.openCharges(posting.accountId);
    final shares = allocateOldestFirst(posting.amount, [
      for (final row in openRows)
        if (row.entryId != entryId)
          OpenItem(
            entryId: row.entryId,
            open: Money.fromPaise(row.openPaise),
            effectiveAt: row.effectiveAt,
            dueAt: row.dueAt,
          ),
    ]);
    for (final share in shares) {
      // Source is always the settlement (negative), target the charge
      // (positive); the allocation trigger checks both and the caps.
      await _ledger.insertAllocation(
        db.LedgerAllocationEventsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          partyAccountId: posting.accountId,
          sourceEntryId: isCharge ? share.entryId : entryId,
          targetEntryId: isCharge ? entryId : share.entryId,
          eventType: AllocationEventType.allocate,
          amountPaise: share.amount.paise,
          createdAt: now,
        ),
      );
    }
  }

  /// Cash goes to the Cash account; UPI and bank transfers to the bank
  /// account, created on first use (ADR-023).
  Future<String> _moneyAccountFor(
    String shopId,
    PaymentMethod method,
    DateTime now,
  ) async {
    final isCash = method == PaymentMethod.cash;
    final existing = await _ledger.moneyAccountOf(
      shopId,
      isCash
          ? const [MoneyAccountType.cash]
          : const [MoneyAccountType.bank, MoneyAccountType.upiSettlement],
    );
    if (existing != null) return existing;

    final id = _ids.newId();
    await _ledger.insertMoneyAccount(
      db.MoneyAccountsCompanion.insert(
        id: id,
        shopId: shopId,
        name: isCash ? 'Cash' : bankAccountName,
        accountType: isCash ? MoneyAccountType.cash : MoneyAccountType.bank,
        openingEffectiveAt: now,
        createdAt: now,
      ),
    );
    await _parties.insertAudit(
      db.AuditLogsCompanion.insert(
        id: _ids.newId(),
        shopId: shopId,
        entityType: 'money_account',
        entityId: id,
        action: 'created',
        createdAt: now,
      ),
    );
    return id;
  }
}
