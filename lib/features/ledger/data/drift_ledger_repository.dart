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
import 'package:smart_khata/features/ledger/data/allocation_rebalancer.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';

/// Every posting to a party ledger goes through this class, so the rules
/// are in one place: one database transaction per operation, idempotent by
/// operation ID, inserts only, and allocations rebalanced afterwards.
final class DriftLedgerRepository implements LedgerRepository {
  DriftLedgerRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
  }) : _allocations = AllocationRebalancer(dao: _dao, ids: _ids);

  final LedgerDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;
  final AllocationRebalancer _allocations;

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
          .asyncMap((row) async => row == null ? null : _toDetail(row))
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

  @override
  Future<Result<List<OpenCharge>>> getOpenCharges(String accountId) => guard(
    () async => _allocations.openCharges(
      shopId: await _shop.requireShopId(),
      accountId: accountId,
    ),
    logger: _logger,
    operation: 'ledger.getOpenCharges',
  );

  // ---- Charges -----------------------------------------------------------

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
      await _requirePostableAccount(
        shopId: shopId,
        partyId: posting.partyId,
        accountId: posting.accountId,
        role: posting.role,
      );
      final paidNow = posting.paidNow;
      if (paidNow != null) {
        await _requireMoneyAccounts(shopId, [paidNow]);
      }

      final now = _clock.nowUtc();
      final transactionId = _ids.newId();
      final chargeEntryId = _ids.newId();
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
      // The party owes more. Credit given is not cash received and a
      // purchase is not cash paid, so the charge itself moves no money.
      await _dao.insertLedgerEntry(
        db.PartyLedgerEntriesCompanion.insert(
          id: chargeEntryId,
          shopId: shopId,
          partyAccountId: posting.accountId,
          transactionId: transactionId,
          entryKind: LedgerEntryKind.charge,
          amountPaise: posting.amount.paise,
          dueAt: Value(posting.dueAt),
          createdAt: now,
        ),
      );

      // Part of a purchase paid at once is its own linked payment, with its
      // own ledger entry and money movement, so that payment reports stay
      // right (WF-032). It is applied to this purchase first.
      if (paidNow != null) {
        final paymentEntryId = await _insertPayment(
          shopId: shopId,
          accountId: posting.accountId,
          role: posting.role,
          amount: paidNow.amount,
          effectiveAt: posting.effectiveAt,
          businessDate: posting.businessDate.toIso(),
          operationId: '${posting.operationId}:paid-now',
          relatedTransactionId: transactionId,
          movements: [paidNow],
          now: now,
        );
        await _allocations.allocate(
          shopId: shopId,
          accountId: posting.accountId,
          sourceEntryId: paymentEntryId,
          targetEntryId: chargeEntryId,
          amount: paidNow.amount,
          now: now,
        );
      }

      // An advance the party already holds is taken up by the new charge.
      await _allocations.rebalance(
        shopId: shopId,
        accountId: posting.accountId,
        now: now,
      );
      return _receipt(transactionId, posting.role, posting.accountId);
    }),
    logger: _logger,
    operation: 'ledger.postCharge',
  );

  // ---- Payments ----------------------------------------------------------

  @override
  Future<Result<PostingReceipt>> postPayment(PaymentPosting posting) => guard(
    () => _dao.transaction(() async {
      final existing = await _dao.findByOperationId(posting.operationId);
      if (existing != null) {
        return _receipt(existing.id, posting.role, posting.accountId);
      }

      final shopId = await _shop.requireShopId();
      await _requirePostableAccount(
        shopId: shopId,
        partyId: posting.partyId,
        accountId: posting.accountId,
        role: posting.role,
      );
      await _requireMoneyAccounts(shopId, posting.movements);
      if (Money.sum(posting.movements.map((m) => m.amount)) != posting.amount) {
        throw const FailureException(
          ValidationFailure({
            RecordPaymentCommand.splitsField:
                ValidationError.splitMustEqualTotal,
          }),
        );
      }

      // The owner's own allocation is checked against the dues as they are
      // now, inside the transaction, not as the form last saw them.
      final manual = posting.allocations;
      if (manual != null) {
        final charges = await _allocations.openCharges(
          shopId: shopId,
          accountId: posting.accountId,
        );
        if (!AllocationPolicy.isValidManual(manual, charges, posting.amount)) {
          throw const FailureException(
            ValidationFailure({
              RecordPaymentCommand.allocationsField:
                  ValidationError.allocationInvalid,
            }),
          );
        }
      }

      final now = _clock.nowUtc();
      final transactionId = _ids.newId();
      final entryId = await _insertPayment(
        shopId: shopId,
        accountId: posting.accountId,
        role: posting.role,
        amount: posting.amount,
        effectiveAt: posting.effectiveAt,
        businessDate: posting.businessDate.toIso(),
        operationId: posting.operationId,
        description: posting.note,
        movements: posting.movements,
        now: now,
        transactionId: transactionId,
      );

      for (final line in manual ?? const <AllocationLine>[]) {
        await _allocations.allocate(
          shopId: shopId,
          accountId: posting.accountId,
          sourceEntryId: entryId,
          targetEntryId: line.targetEntryId,
          amount: line.amount,
          now: now,
        );
      }
      // Oldest dues first for whatever is not yet applied. What is left
      // after every due is settled stays unallocated: the advance.
      await _allocations.rebalance(
        shopId: shopId,
        accountId: posting.accountId,
        now: now,
      );

      await _dao.insertAuditLog(
        db.AuditLogsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          entityType: 'financial_transaction',
          entityId: transactionId,
          action: 'payment_recorded',
          createdAt: now,
        ),
      );
      return _receipt(transactionId, posting.role, posting.accountId);
    }),
    logger: _logger,
    operation: 'ledger.postPayment',
  );

  @override
  Future<Result<PostingReceipt>> postReturn(ReturnPosting posting) => guard(
    () => _dao.transaction(() async {
      final existing = await _dao.findByOperationId(posting.operationId);
      if (existing != null) {
        return _receipt(existing.id, posting.role, posting.accountId);
      }

      final shopId = await _shop.requireShopId();
      await _requirePostableAccount(
        shopId: shopId,
        partyId: posting.partyId,
        accountId: posting.accountId,
        role: posting.role,
      );

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
      // Goods came back: less is owed. No money moved, so no movement; a
      // cash refund would be a separate entry.
      await _dao.insertLedgerEntry(
        db.PartyLedgerEntriesCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          partyAccountId: posting.accountId,
          transactionId: transactionId,
          entryKind: LedgerEntryKind.returned,
          amountPaise: -posting.amount.paise,
          createdAt: now,
        ),
      );
      await _allocations.rebalance(
        shopId: shopId,
        accountId: posting.accountId,
        now: now,
      );
      return _receipt(transactionId, posting.role, posting.accountId);
    }),
    logger: _logger,
    operation: 'ledger.postReturn',
  );

  // ---- Reversal ----------------------------------------------------------

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

          // 1. Free whatever is allocated to or from these entries.
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

          // 5. Released settlements move to the next open dues.
          for (final accountId in {for (final e in entries) e.partyAccountId}) {
            await _allocations.rebalance(
              shopId: shopId,
              accountId: accountId,
              now: now,
            );
          }

          // 6. Why it was reversed.
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

  /// The account must belong to the party, have the posting's role, and
  /// the party must not be archived.
  Future<void> _requirePostableAccount({
    required String shopId,
    required String partyId,
    required String accountId,
    required PartyRole role,
  }) async {
    final account = await _dao.findAccount(
      shopId: shopId,
      accountId: accountId,
    );
    if (account == null || account.partyId != partyId || account.role != role) {
      throw const FailureException(NotFoundFailure('party_account'));
    }
    final party = await _dao.findParty(shopId: shopId, id: partyId);
    if (party == null) throw const FailureException(NotFoundFailure('party'));
    if (party.status == PartyStatus.archived) {
      throw const FailureException(RuleFailure(RuleViolation.partyArchived));
    }
  }

  /// Every money account must be an active account of this shop, and the
  /// method must suit it: cash to the cash drawer, UPI to a bank account.
  Future<void> _requireMoneyAccounts(
    String shopId,
    List<MovementPosting> movements,
  ) async {
    for (final movement in movements) {
      final account = await _dao.findMoneyAccount(
        shopId: shopId,
        id: movement.moneyAccountId,
      );
      if (account == null || !account.isActive) {
        throw const FailureException(NotFoundFailure('money_account'));
      }
      if (!movement.method.fits(account.accountType)) {
        throw const FailureException(
          ValidationFailure({
            RecordPaymentCommand.splitsField: ValidationError.accountMismatch,
          }),
        );
      }
    }
  }

  /// Inserts a payment: header (with the next receipt or voucher number),
  /// one negative ledger entry and its money movements. Returns the ledger
  /// entry ID.
  ///
  /// The ledger effect and the money movement are written here, together,
  /// inside the caller's transaction: there is never one without the other
  /// (invariants 7 and 8).
  Future<String> _insertPayment({
    required String shopId,
    required String accountId,
    required PartyRole role,
    required Money amount,
    required DateTime effectiveAt,
    required String businessDate,
    required String operationId,
    required List<MovementPosting> movements,
    required DateTime now,
    String? transactionId,
    String? relatedTransactionId,
    String? description,
  }) async {
    final isCustomer = role == PartyRole.customer;
    final type = isCustomer
        ? TransactionType.customerPayment
        : TransactionType.supplierPayment;
    final number = await _dao.countOfType(shopId: shopId, type: type) + 1;
    final id = transactionId ?? _ids.newId();
    final entryId = _ids.newId();

    await _dao.insertTransaction(
      db.FinancialTransactionsCompanion.insert(
        id: id,
        shopId: shopId,
        partyAccountId: Value(accountId),
        transactionType: type,
        amountPaise: amount.paise,
        effectiveAt: effectiveAt,
        recordedAt: now,
        businessDate: businessDate,
        description: Value(description),
        // Receipt number for money received, voucher number for money paid.
        referenceNumber: Value(
          '${isCustomer ? 'RCP' : 'PAY'}-${number.toString().padLeft(4, '0')}',
        ),
        operationId: operationId,
        relatedTransactionId: Value(relatedTransactionId),
        createdAt: now,
      ),
    );
    await _dao.insertLedgerEntry(
      db.PartyLedgerEntriesCompanion.insert(
        id: entryId,
        shopId: shopId,
        partyAccountId: accountId,
        transactionId: id,
        entryKind: LedgerEntryKind.payment,
        amountPaise: -amount.paise,
        createdAt: now,
      ),
    );
    for (final movement in movements) {
      await _dao.insertMovement(
        db.MoneyMovementsCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          transactionId: id,
          moneyAccountId: movement.moneyAccountId,
          paymentMethod: movement.method,
          // A customer pays in; the shop pays a supplier out.
          direction: isCustomer
              ? MovementDirection.inflow
              : MovementDirection.outflow,
          amountPaise: movement.amount.paise,
          referenceNumber: Value(movement.reference),
          createdAt: now,
        ),
      );
    }
    return entryId;
  }

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

  Future<TransactionDetail> _toDetail(TransactionDetailRow row) async {
    final entryId = row.entryId;
    final entryAmount = row.entryAmountPaise;
    final isCharge =
        entryAmount != null &&
        entryAmount > 0 &&
        row.reversalOfTransactionId == null;

    return TransactionDetail(
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
      ledgerEffect: _money(entryAmount),
      dueAt: row.dueAt,
      accountBalance: _money(row.accountBalancePaise),
      reversalOfTransactionId: row.reversalOfTransactionId,
      reversedByTransactionId: row.reversedByTransactionId,
      reversalReason: row.reversalReason,
      relatedTransactionId: row.relatedTransactionId,
      openAmount: isCharge && row.reversedByTransactionId == null
          ? Money.fromPaise(entryAmount - row.allocatedToEntryPaise)
          : null,
      movements: [
        for (final m in await _dao.movementLines(row.id))
          MovementLine(
            accountName: m.accountName,
            method: m.method,
            direction: m.direction,
            amount: Money.fromPaise(m.amountPaise),
            reference: m.reference,
          ),
      ],
      allocations: entryId == null
          ? const []
          : [
              for (final a in await _dao.allocationTargetsOf(entryId))
                AllocationView(
                  transactionId: a.transactionId,
                  transactionType: a.transactionType,
                  effectiveAt: a.effectiveAt,
                  amount: Money.fromPaise(a.amountPaise),
                ),
            ],
    );
  }
}
