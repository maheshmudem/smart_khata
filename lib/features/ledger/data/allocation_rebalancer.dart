import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/ledger_dao.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/allocation.dart';

/// Keeps one rule true for every party account after every posting: it
/// never holds an unpaid charge and an unapplied settlement at the same
/// time (ADR-023).
///
/// So an advance is taken up by the next charge, and a payment released by
/// a reversal moves to the next due. Only allocation events are written;
/// the balance is not affected. Call it inside the posting's transaction.
final class AllocationRebalancer {
  const AllocationRebalancer({required this._dao, required this._ids});

  final LedgerDao _dao;
  final IdGenerator _ids;

  Future<List<OpenCharge>> openCharges({
    required String shopId,
    required String accountId,
  }) async => [
    for (final row in await _dao.openCharges(
      shopId: shopId,
      accountId: accountId,
    ))
      OpenCharge(
        entryId: row.entryId,
        transactionId: row.transactionId,
        transactionType: row.transactionType,
        amount: Money.fromPaise(row.amountPaise),
        openAmount: Money.fromPaise(row.openPaise),
        effectiveAt: row.effectiveAt,
        dueAt: row.dueAt,
        description: row.description,
      ),
  ];

  Future<void> allocate({
    required String shopId,
    required String accountId,
    required String sourceEntryId,
    required String targetEntryId,
    required Money amount,
    required DateTime now,
  }) => _dao.insertAllocationEvent(
    db.LedgerAllocationEventsCompanion.insert(
      id: _ids.newId(),
      shopId: shopId,
      partyAccountId: accountId,
      sourceEntryId: sourceEntryId,
      targetEntryId: targetEntryId,
      eventType: AllocationEventType.allocate,
      amountPaise: amount.paise,
      createdAt: now,
    ),
  );

  /// Applies every unallocated settlement of the account to its open
  /// charges, oldest charge first.
  Future<void> rebalance({
    required String shopId,
    required String accountId,
    required DateTime now,
  }) async {
    final settlements = [
      for (final (entryId, paise) in await _dao.unallocatedSettlements(
        shopId: shopId,
        accountId: accountId,
      ))
        UnallocatedSettlement(
          entryId: entryId,
          unallocatedAmount: Money.fromPaise(paise),
        ),
    ];
    if (settlements.isEmpty) return;

    final charges = await openCharges(shopId: shopId, accountId: accountId);
    for (final line in AllocationPolicy.settle(settlements, charges)) {
      await allocate(
        shopId: shopId,
        accountId: accountId,
        sourceEntryId: line.sourceEntryId,
        targetEntryId: line.targetEntryId,
        amount: line.amount,
        now: now,
      );
    }
  }
}
