import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/ledger_dao.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';

final class DriftLedgerRepository implements LedgerRepository {
  const DriftLedgerRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  });

  final LedgerDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;

  // ---- Reads -------------------------------------------------------------

  @override
  Stream<List<LedgerLine>> watchLedger(
    String accountId, {
    required int limit,
  }) => Stream.fromFuture(_shop.requireShopId())
      .asyncExpand(
        (shopId) => _dao.watchLedger(
          shopId: shopId,
          accountId: accountId,
          limit: limit,
        ),
      )
      .map(
        (rows) => [
          for (final row in rows)
            LedgerLine(
              entryId: row.entryId,
              transactionId: row.transactionId,
              kind: row.kind,
              transactionType: row.transactionType,
              amount: Money.fromPaise(row.amountPaise),
              runningBalance: Money.fromPaise(row.runningBalancePaise),
              effectiveAt: row.effectiveAt,
              dueAt: row.dueAt,
              description: row.description,
              isReversed: row.isReversed,
            ),
        ],
      )
      .mapErrorsToFailures(logger: _logger, operation: 'ledger.watch');

  @override
  Stream<TransactionDetail?> watchTransaction(String transactionId) =>
      Stream.fromFuture(_shop.requireShopId())
          .asyncExpand(
            (shopId) => _dao.watchTransactionDetail(
              shopId: shopId,
              transactionId: transactionId,
            ),
          )
          .map((row) => row == null ? null : _toDetail(row))
          .mapErrorsToFailures(
            logger: _logger,
            operation: 'ledger.watchTransaction',
          );

  @override
  Future<Result<TransactionDetail?>> getTransaction(String transactionId) =>
      guard(
        () async {
          final row = await _dao.getTransactionDetail(
            shopId: await _shop.requireShopId(),
            transactionId: transactionId,
          );
          return row == null ? null : _toDetail(row);
        },
        logger: _logger,
        operation: 'ledger.getTransaction',
      );

  // ---- Writes ------------------------------------------------------------

  @override
  Future<Result<PostingReceipt>> postCharge(ChargePosting posting) => guard(
    () => _dao.transaction(() async {
      // A retry of an operation that already committed posts nothing and
      // reports the first posting (FR-PAY-006).
      final existing = await _dao.findByOperationId(posting.operationId);
      if (existing != null) {
        return _receipt(existing.id, posting.role, posting.accountId);
      }

      final shopId = await _shop.requireShopId();
      final account = await _dao.findAccount(
        shopId: shopId,
        accountId: posting.accountId,
      );
      if (account == null ||
          account.partyId != posting.partyId ||
          account.role != posting.role) {
        throw const FailureException(NotFoundFailure('party_account'));
      }
      final party = await _dao.findParty(shopId: shopId, id: posting.partyId);
      if (party == null) {
        throw const FailureException(NotFoundFailure('party'));
      }
      if (party.status == PartyStatus.archived) {
        throw const FailureException(RuleFailure(RuleViolation.partyArchived));
      }

      final now = _clock.nowUtc();
      final transactionId = _ids.newId();
      await _dao.insertTransaction(
        db.FinancialTransactionsCompanion.insert(
          id: transactionId,
          shopId: shopId,
          partyAccountId: Value(posting.accountId),
          transactionType: posting.transactionType,
          amountPaise: posting.amount.paise,
          effectiveAt: posting.effectiveAt,
          recordedAt: now,
          businessDate: posting.businessDate.toIso(),
          description: Value(posting.description),
          operationId: posting.operationId,
          createdAt: now,
        ),
      );
      // The only effect: the party owes more. Credit given is not cash
      // received and a purchase is not cash paid, so no money movement.
      await _dao.insertLedgerEntry(
        db.PartyLedgerEntriesCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          partyAccountId: posting.accountId,
          transactionId: transactionId,
          entryKind: LedgerEntryKind.charge,
          amountPaise: posting.amount.paise,
          dueAt: Value(posting.dueAt),
          createdAt: now,
        ),
      );
      return _receipt(transactionId, posting.role, posting.accountId);
    }),
    logger: _logger,
    operation: 'ledger.postCharge',
  );

  @override
  Future<Result<PostingReceipt>> reverseTransaction(ReversalPosting posting) =>
      guard(
        () => _dao.transaction(() async {
          final shopId = await _shop.requireShopId();
          final source = await _dao.findTransaction(
            shopId: shopId,
            id: posting.transactionId,
          );
          if (source == null) {
            throw const FailureException(NotFoundFailure('transaction'));
          }
          final entries = await _dao.entriesOf(source.id);

          Future<PostingReceipt> receiptFor(String reversalId) async {
            final accountId = source.partyAccountId;
            final account = accountId == null
                ? null
                : await _dao.findAccount(shopId: shopId, accountId: accountId);
            return PostingReceipt(
              transactionId: reversalId,
              role: account?.role ?? PartyRole.customer,
              balance: accountId == null
                  ? Money.zero
                  : Money.fromPaise(await _dao.accountBalance(accountId)),
            );
          }

          // The same reversal submitted again: already done.
          final repeated = await _dao.findByOperationId(posting.operationId);
          if (repeated != null) return receiptFor(repeated.id);

          if (source.transactionType == TransactionType.transactionReversal) {
            throw const FailureException(
              RuleFailure(RuleViolation.cannotReverseReversal),
            );
          }
          if (await _dao.findReversalOf(source.id) != null) {
            throw const FailureException(
              RuleFailure(RuleViolation.transactionAlreadyReversed),
            );
          }

          final now = _clock.nowUtc();

          // 1. Free whatever is allocated to or from these entries, so a
          //    payment that settled a reversed charge becomes an advance
          //    again instead of pointing at a cancelled entry.
          for (final entry in entries) {
            for (final allocation in await _dao.activeAllocationsFor(
              entry.id,
            )) {
              await _dao.insertAllocationEvent(
                db.LedgerAllocationEventsCompanion.insert(
                  id: _ids.newId(),
                  shopId: shopId,
                  partyAccountId: allocation.partyAccountId,
                  sourceEntryId: allocation.sourceEntryId,
                  targetEntryId: allocation.targetEntryId,
                  eventType: AllocationEventType.release,
                  amountPaise: allocation.remainingPaise,
                  reversesEventId: Value(allocation.eventId),
                  createdAt: now,
                ),
              );
            }
          }

          // 2. The reversal header, linked to its source. The unique link
          //    is what makes a second reversal impossible.
          final reversalId = _ids.newId();
          await _dao.insertTransaction(
            db.FinancialTransactionsCompanion.insert(
              id: reversalId,
              shopId: shopId,
              partyAccountId: Value(source.partyAccountId),
              transactionType: TransactionType.transactionReversal,
              amountPaise: source.amountPaise,
              effectiveAt: posting.effectiveAt,
              recordedAt: now,
              businessDate: posting.businessDate.toIso(),
              description: Value(posting.reason),
              operationId: posting.operationId,
              relatedTransactionId: Value(source.id),
              reversalOfTransactionId: Value(source.id),
              createdAt: now,
            ),
          );

          // 3. The exact opposite of every party-ledger effect …
          for (final entry in entries) {
            await _dao.insertLedgerEntry(
              db.PartyLedgerEntriesCompanion.insert(
                id: _ids.newId(),
                shopId: shopId,
                partyAccountId: entry.partyAccountId,
                transactionId: reversalId,
                entryKind: LedgerEntryKind.reversal,
                amountPaise: -entry.amountPaise,
                createdAt: now,
              ),
            );
          }

          // 4. … and of every money movement, on the same account.
          for (final movement in await _dao.movementsOf(source.id)) {
            await _dao.insertMovement(
              db.MoneyMovementsCompanion.insert(
                id: _ids.newId(),
                shopId: shopId,
                transactionId: reversalId,
                moneyAccountId: movement.moneyAccountId,
                paymentMethod: movement.paymentMethod,
                direction: switch (movement.direction) {
                  MovementDirection.inflow => MovementDirection.outflow,
                  MovementDirection.outflow => MovementDirection.inflow,
                },
                amountPaise: movement.amountPaise,
                referenceNumber: Value(movement.referenceNumber),
                createdAt: now,
              ),
            );
          }

          // 5. Why it was reversed.
          await _dao.insertAuditLog(
            db.AuditLogsCompanion.insert(
              id: _ids.newId(),
              shopId: shopId,
              entityType: 'financial_transaction',
              entityId: source.id,
              action: 'transaction_reversed',
              reason: Value(posting.reason),
              createdAt: now,
            ),
          );

          return receiptFor(reversalId);
        }),
        logger: _logger,
        operation: 'ledger.reverse',
      );

  // ---- Helpers -----------------------------------------------------------

  Future<PostingReceipt> _receipt(
    String transactionId,
    PartyRole role,
    String accountId,
  ) async => PostingReceipt(
    transactionId: transactionId,
    role: role,
    balance: Money.fromPaise(await _dao.accountBalance(accountId)),
  );

  static Money? _money(int? paise) =>
      paise == null ? null : Money.fromPaise(paise);

  static TransactionDetail _toDetail(TransactionDetailRow row) =>
      TransactionDetail(
        id: row.id,
        type: row.transactionType,
        amount: Money.fromPaise(row.amountPaise),
        effectiveAt: row.effectiveAt,
        recordedAt: row.recordedAt,
        description: row.description,
        referenceNumber: row.referenceNumber,
        partyId: row.partyId,
        partyName: row.partyName,
        accountId: row.accountId,
        role: row.role,
        ledgerEffect: _money(row.entryAmountPaise),
        dueAt: row.dueAt,
        accountBalance: _money(row.accountBalancePaise),
        reversalOfTransactionId: row.reversalOfTransactionId,
        reversedByTransactionId: row.reversedByTransactionId,
        reversalReason: row.reversalReason,
      );
}
