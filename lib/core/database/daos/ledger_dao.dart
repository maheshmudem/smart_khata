import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'ledger_dao.g.dart';

/// A ledger entry with an open (unpaid or unapplied) remainder, in paise.
class OpenEntryRow {
  const OpenEntryRow({
    required this.entryId,
    required this.openPaise,
    required this.effectiveAt,
    this.dueAt,
  });

  final String entryId;
  final int openPaise;
  final DateTime effectiveAt;
  final DateTime? dueAt;
}

/// One ledger line with the running balance after it, in paise.
class LedgerLineRow {
  const LedgerLineRow({
    required this.entryId,
    required this.type,
    required this.amountPaise,
    required this.runningPaise,
    required this.effectiveAt,
    this.description,
    this.dueAt,
    this.method,
  });

  final String entryId;
  final TransactionType type;
  final int amountPaise;
  final int runningPaise;
  final DateTime effectiveAt;
  final String? description;
  final DateTime? dueAt;
  final PaymentMethod? method;
}

/// Ledger postings: allocations, money movements and the ledger view.
///
/// Every balance here is derived from `party_ledger_entries` and every open
/// amount from `ledger_allocation_events`; nothing is stored as a total
/// (rule 3).
@DriftAccessor(include: {'../schema/operations.drift'})
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  static const _types = CodedEnumConverter<TransactionType>(
    TransactionType.values,
  );
  static const _methods = CodedEnumConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static const _instant = EpochMsConverter();

  /// Emits once now and again after any ledger change.
  Stream<void> changes() async* {
    yield null;
    yield* attachedDatabase
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            partyLedgerEntries,
            financialTransactions,
            ledgerAllocationEvents,
            moneyMovements,
          ]),
        )
        .map((_) {});
  }

  /// Charges (positive entries) on [accountId] that are not fully paid.
  Future<List<OpenEntryRow>> openCharges(String accountId) => _open(
    accountId,
    sign: '>',
    amount: 'e.amount_paise',
    link: 'target_entry_id',
  );

  /// Settlements (negative entries) on [accountId] with an unapplied part:
  /// the account's advances.
  Future<List<OpenEntryRow>> openSettlements(String accountId) => _open(
    accountId,
    sign: '<',
    amount: '-e.amount_paise',
    link: 'source_entry_id',
  );

  Future<List<OpenEntryRow>> _open(
    String accountId, {
    required String sign,
    required String amount,
    required String link,
  }) async {
    final rows = await customSelect(
      '''
SELECT * FROM (
  SELECT e.id AS entry_id, e.due_at AS due_at, t.effective_at AS effective_at,
         $amount - COALESCE((
           SELECT SUM(CASE WHEN a.event_type = 'allocate'
                           THEN a.amount_paise ELSE -a.amount_paise END)
           FROM ledger_allocation_events a WHERE a.$link = e.id), 0) AS open
  FROM party_ledger_entries e
  JOIN financial_transactions t ON t.id = e.transaction_id
  WHERE e.party_account_id = ?1 AND e.amount_paise $sign 0
)
WHERE open > 0
''',
      variables: [Variable.withString(accountId)],
      readsFrom: {
        partyLedgerEntries,
        financialTransactions,
        ledgerAllocationEvents,
      },
    ).get();
    return [
      for (final row in rows)
        OpenEntryRow(
          entryId: row.read<String>('entry_id'),
          openPaise: row.read<int>('open'),
          effectiveAt: _instant.fromSql(row.read<int>('effective_at')),
          dueAt: switch (row.readNullable<int>('due_at')) {
            final ms? => _instant.fromSql(ms),
            null => null,
          },
        ),
    ];
  }

  /// The account's balance: the sum of its signed entries.
  Future<int> balanceOf(String accountId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(amount_paise), 0) AS balance '
      'FROM party_ledger_entries WHERE party_account_id = ?1',
      variables: [Variable.withString(accountId)],
      readsFrom: {partyLedgerEntries},
    ).getSingle();
    return row.read<int>('balance');
  }

  /// The newest [limit] lines, newest first, each with the running balance
  /// computed over the whole account in ledger order (schema 5.5).
  Future<List<LedgerLineRow>> ledgerLines(String accountId, int limit) async {
    final rows = await customSelect(
      '''
SELECT * FROM (
  SELECT e.id AS entry_id, t.transaction_type AS type,
         e.amount_paise AS amount, t.effective_at AS effective_at,
         t.recorded_at AS recorded_at, t.description AS description,
         e.due_at AS due_at,
         (SELECT m.payment_method FROM money_movements m
          WHERE m.transaction_id = t.id ORDER BY m.id LIMIT 1) AS method,
         SUM(e.amount_paise) OVER (
           ORDER BY t.effective_at, t.recorded_at, e.id
           ROWS UNBOUNDED PRECEDING) AS running
  FROM party_ledger_entries e
  JOIN financial_transactions t ON t.id = e.transaction_id
  WHERE e.party_account_id = ?1
)
ORDER BY effective_at DESC, recorded_at DESC, entry_id DESC
LIMIT ?2
''',
      variables: [Variable.withString(accountId), Variable.withInt(limit)],
      readsFrom: {partyLedgerEntries, financialTransactions, moneyMovements},
    ).get();
    return [
      for (final row in rows)
        LedgerLineRow(
          entryId: row.read<String>('entry_id'),
          type: _types.fromSql(row.read<String>('type')),
          amountPaise: row.read<int>('amount'),
          runningPaise: row.read<int>('running'),
          effectiveAt: _instant.fromSql(row.read<int>('effective_at')),
          description: row.readNullable<String>('description'),
          dueAt: switch (row.readNullable<int>('due_at')) {
            final ms? => _instant.fromSql(ms),
            null => null,
          },
          method: switch (row.readNullable<String>('method')) {
            final code? => _methods.fromSql(code),
            null => null,
          },
        ),
    ];
  }

  /// The first active money account of one of [types] in [shopId].
  Future<String?> moneyAccountOf(
    String shopId,
    List<MoneyAccountType> types,
  ) async {
    final row =
        await (select(moneyAccounts)
              ..where(
                (t) =>
                    t.shopId.equals(shopId) &
                    t.isActive.equals(true) &
                    t.accountType.isIn([for (final type in types) type.code]),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.id;
  }

  Future<void> insertMoneyAccount(MoneyAccountsCompanion row) =>
      into(moneyAccounts).insert(row);

  Future<void> insertAllocation(LedgerAllocationEventsCompanion row) =>
      into(ledgerAllocationEvents).insert(row);

  Future<void> insertMovement(MoneyMovementsCompanion row) =>
      into(moneyMovements).insert(row);
}
