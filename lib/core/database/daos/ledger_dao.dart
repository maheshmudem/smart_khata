import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'ledger_dao.g.dart';

/// A ledger line with the account balance after it.
class LedgerLineRow {
  const LedgerLineRow({
    required this.entryId,
    required this.transactionId,
    required this.kind,
    required this.transactionType,
    required this.amountPaise,
    required this.runningBalancePaise,
    required this.effectiveAt,
    required this.recordedAt,
    required this.dueAt,
    required this.description,
    required this.isReversed,
  });

  final String entryId;
  final String transactionId;
  final LedgerEntryKind kind;
  final TransactionType transactionType;
  final int amountPaise;
  final int runningBalancePaise;
  final DateTime effectiveAt;
  final DateTime recordedAt;
  final DateTime? dueAt;
  final String? description;
  final bool isReversed;
}

/// A transaction header with its party, ledger effect and reversal links.
class TransactionDetailRow {
  const TransactionDetailRow({
    required this.id,
    required this.transactionType,
    required this.amountPaise,
    required this.effectiveAt,
    required this.recordedAt,
    required this.businessDate,
    required this.description,
    required this.referenceNumber,
    required this.reversalOfTransactionId,
    required this.reversedByTransactionId,
    required this.reversalReason,
    required this.accountId,
    required this.role,
    required this.partyId,
    required this.partyName,
    required this.entryAmountPaise,
    required this.dueAt,
    required this.accountBalancePaise,
    required this.entryId,
    required this.relatedTransactionId,
    required this.allocatedToEntryPaise,
    required this.categoryName,
    required this.payee,
  });

  final String id;
  final TransactionType transactionType;
  final int amountPaise;
  final DateTime effectiveAt;
  final DateTime recordedAt;
  final String businessDate;
  final String? description;
  final String? referenceNumber;
  final String? reversalOfTransactionId;
  final String? reversedByTransactionId;
  final String? reversalReason;
  final String? accountId;
  final PartyRole? role;
  final String? partyId;
  final String? partyName;
  final int? entryAmountPaise;
  final DateTime? dueAt;
  final int? accountBalancePaise;
  final String? entryId;
  final String? relatedTransactionId;

  /// Net amount allocated to this transaction's entry as a target.
  final int allocatedToEntryPaise;

  /// For an expense: the category as it was named when saved, and who was
  /// paid.
  final String? categoryName;
  final String? payee;
}

/// A positive entry with what is still unsettled.
class OpenChargeRow {
  const OpenChargeRow({
    required this.entryId,
    required this.transactionId,
    required this.transactionType,
    required this.amountPaise,
    required this.openPaise,
    required this.effectiveAt,
    required this.dueAt,
    required this.description,
  });

  final String entryId;
  final String transactionId;
  final TransactionType transactionType;
  final int amountPaise;
  final int openPaise;
  final DateTime effectiveAt;
  final DateTime? dueAt;
  final String? description;
}

/// A money movement with its account's name.
class MovementLineRow {
  const MovementLineRow({
    required this.accountName,
    required this.method,
    required this.direction,
    required this.amountPaise,
    required this.reference,
  });

  final String accountName;
  final PaymentMethod method;
  final MovementDirection direction;
  final int amountPaise;
  final String? reference;
}

/// The net amount a settlement has applied to one charge.
class AllocationTargetRow {
  const AllocationTargetRow({
    required this.transactionId,
    required this.transactionType,
    required this.effectiveAt,
    required this.amountPaise,
  });

  final String transactionId;
  final TransactionType transactionType;
  final DateTime effectiveAt;
  final int amountPaise;
}

/// An allocation that is still (partly) in force.
class ActiveAllocationRow {
  const ActiveAllocationRow({
    required this.eventId,
    required this.partyAccountId,
    required this.sourceEntryId,
    required this.targetEntryId,
    required this.remainingPaise,
  });

  final String eventId;
  final String partyAccountId;
  final String sourceEntryId;
  final String targetEntryId;
  final int remainingPaise;
}

const _roles = CodedEnumConverter<PartyRole>(PartyRole.values);
const _kinds = CodedEnumConverter<LedgerEntryKind>(LedgerEntryKind.values);
const _types = CodedEnumConverter<TransactionType>(TransactionType.values);
const _methods = CodedEnumConverter<PaymentMethod>(PaymentMethod.values);
const _directions = CodedEnumConverter<MovementDirection>(
  MovementDirection.values,
);
const _instants = EpochMsConverter();

DateTime? _instantOrNull(int? ms) => ms == null ? null : _instants.fromSql(ms);

@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/money.drift',
    '../schema/operations.drift',
  },
)
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.attachedDatabase);

  // ---- Reads -------------------------------------------------------------

  /// One account's history, newest first, each line with the balance after
  /// it.
  ///
  /// The running balance is computed over the whole account in the stable
  /// order `effective_at, recorded_at, id` (schema doc 5.5), so a
  /// backdated entry changes the balances after it. Only [limit] rows are
  /// returned.
  Stream<List<LedgerLineRow>> watchLedger({
    required String shopId,
    required String accountId,
    required int limit,
  }) =>
      customSelect(
        '''
    SELECT * FROM (
      SELECT e.id AS entry_id, t.id AS transaction_id, e.entry_kind AS kind,
             t.transaction_type AS transaction_type,
             e.amount_paise AS amount_paise,
             SUM(e.amount_paise) OVER (
               ORDER BY t.effective_at, t.recorded_at, e.id
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
             ) AS running_balance_paise,
             t.effective_at AS effective_at, t.recorded_at AS recorded_at,
             e.due_at AS due_at, t.description AS description,
             EXISTS (SELECT 1 FROM financial_transactions r
                     WHERE r.reversal_of_transaction_id = t.id) AS is_reversed
      FROM party_ledger_entries e
      JOIN financial_transactions t ON t.id = e.transaction_id
      WHERE e.shop_id = ? AND e.party_account_id = ?
    )
    ORDER BY effective_at DESC, recorded_at DESC, entry_id DESC
    LIMIT ?
    ''',
        variables: [
          Variable.withString(shopId),
          Variable.withString(accountId),
          Variable.withInt(limit),
        ],
        readsFrom: {partyLedgerEntries, financialTransactions},
      ).watch().map(
        (rows) => [
          for (final row in rows)
            LedgerLineRow(
              entryId: row.read<String>('entry_id'),
              transactionId: row.read<String>('transaction_id'),
              kind: _kinds.fromSql(row.read<String>('kind')),
              transactionType: _types.fromSql(
                row.read<String>('transaction_type'),
              ),
              amountPaise: row.read<int>('amount_paise'),
              runningBalancePaise: row.read<int>('running_balance_paise'),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              recordedAt: _instants.fromSql(row.read<int>('recorded_at')),
              dueAt: _instantOrNull(row.readNullable<int>('due_at')),
              description: row.readNullable<String>('description'),
              isReversed: row.read<bool>('is_reversed'),
            ),
        ],
      );

  Stream<TransactionDetailRow?> watchTransactionDetail({
    required String shopId,
    required String transactionId,
  }) => _transactionDetail(shopId, transactionId).watchSingleOrNull();

  Future<TransactionDetailRow?> getTransactionDetail({
    required String shopId,
    required String transactionId,
  }) => _transactionDetail(shopId, transactionId).getSingleOrNull();

  Selectable<TransactionDetailRow> _transactionDetail(
    String shopId,
    String transactionId,
  ) =>
      customSelect(
        '''
    SELECT t.id AS id, t.transaction_type AS transaction_type,
           t.amount_paise AS amount_paise, t.effective_at AS effective_at,
           t.recorded_at AS recorded_at, t.business_date AS business_date,
           t.description AS description, t.reference_number AS reference_number,
           t.reversal_of_transaction_id AS reversal_of_id,
           (SELECT r.id FROM financial_transactions r
            WHERE r.reversal_of_transaction_id = t.id) AS reversed_by_id,
           (SELECT l.reason FROM audit_logs l
            WHERE l."action" = 'transaction_reversed'
              AND l.entity_id = COALESCE(t.reversal_of_transaction_id, t.id)
            LIMIT 1) AS reversal_reason,
           a.id AS account_id, a.role AS role,
           p.id AS party_id, p.display_name AS party_name,
           e.id AS entry_id, t.related_transaction_id AS related_id,
           x.category_name_snapshot AS category_name, x.payee AS payee,
           COALESCE((SELECT SUM(CASE WHEN al.event_type = 'allocate'
                                     THEN al.amount_paise
                                     ELSE -al.amount_paise END)
                     FROM ledger_allocation_events al
                     WHERE al.target_entry_id = e.id), 0) AS allocated_to_entry,
           e.amount_paise AS entry_amount_paise, e.due_at AS due_at,
           (SELECT SUM(x.amount_paise) FROM party_ledger_entries x
            WHERE x.party_account_id = t.party_account_id) AS account_balance_paise
    FROM financial_transactions t
    LEFT JOIN party_accounts a ON a.id = t.party_account_id
    LEFT JOIN parties p ON p.id = a.party_id
    LEFT JOIN party_ledger_entries e
           ON e.transaction_id = t.id AND e.party_account_id = t.party_account_id
    LEFT JOIN expenses x
           ON x.transaction_id = COALESCE(t.reversal_of_transaction_id, t.id)
    WHERE t.shop_id = ? AND t.id = ?
    ''',
        variables: [
          Variable.withString(shopId),
          Variable.withString(transactionId),
        ],
        readsFrom: {
          financialTransactions,
          partyLedgerEntries,
          partyAccounts,
          parties,
          auditLogs,
          // So an entry page refreshes when it is settled or reversed.
          ledgerAllocationEvents,
          moneyMovements,
          expenses,
        },
      ).map(
        (row) => TransactionDetailRow(
          id: row.read<String>('id'),
          transactionType: _types.fromSql(row.read<String>('transaction_type')),
          amountPaise: row.read<int>('amount_paise'),
          effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
          recordedAt: _instants.fromSql(row.read<int>('recorded_at')),
          businessDate: row.read<String>('business_date'),
          description: row.readNullable<String>('description'),
          referenceNumber: row.readNullable<String>('reference_number'),
          reversalOfTransactionId: row.readNullable<String>('reversal_of_id'),
          reversedByTransactionId: row.readNullable<String>('reversed_by_id'),
          reversalReason: row.readNullable<String>('reversal_reason'),
          accountId: row.readNullable<String>('account_id'),
          role: switch (row.readNullable<String>('role')) {
            final code? => _roles.fromSql(code),
            null => null,
          },
          partyId: row.readNullable<String>('party_id'),
          partyName: row.readNullable<String>('party_name'),
          entryAmountPaise: row.readNullable<int>('entry_amount_paise'),
          dueAt: _instantOrNull(row.readNullable<int>('due_at')),
          accountBalancePaise: row.readNullable<int>('account_balance_paise'),
          entryId: row.readNullable<String>('entry_id'),
          relatedTransactionId: row.readNullable<String>('related_id'),
          allocatedToEntryPaise: row.read<int>('allocated_to_entry'),
          categoryName: row.readNullable<String>('category_name'),
          payee: row.readNullable<String>('payee'),
        ),
      );

  Future<FinancialTransaction?> findTransaction({
    required String shopId,
    required String id,
  }) => (select(
    financialTransactions,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).getSingleOrNull();

  Future<FinancialTransaction?> findByOperationId(String operationId) =>
      (select(
        financialTransactions,
      )..where((t) => t.operationId.equals(operationId))).getSingleOrNull();

  /// The reversal of [transactionId], if it has been reversed.
  Future<FinancialTransaction?> findReversalOf(String transactionId) =>
      (select(financialTransactions)
            ..where((t) => t.reversalOfTransactionId.equals(transactionId)))
          .getSingleOrNull();

  Future<List<PartyLedgerEntry>> entriesOf(String transactionId) =>
      (select(partyLedgerEntries)
            ..where((t) => t.transactionId.equals(transactionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<List<MoneyMovement>> movementsOf(String transactionId) =>
      (select(moneyMovements)
            ..where((t) => t.transactionId.equals(transactionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  /// Allocations touching [entryId], as source or target, that have not
  /// been fully released.
  Future<List<ActiveAllocationRow>> activeAllocationsFor(String entryId) =>
      customSelect(
            '''
        SELECT * FROM (
          SELECT a.id AS event_id, a.party_account_id AS party_account_id,
                 a.source_entry_id AS source_entry_id,
                 a.target_entry_id AS target_entry_id,
                 a.amount_paise - COALESCE((
                   SELECT SUM(r.amount_paise) FROM ledger_allocation_events r
                   WHERE r.event_type = 'release' AND r.reverses_event_id = a.id
                 ), 0) AS remaining_paise
          FROM ledger_allocation_events a
          WHERE a.event_type = 'allocate'
            AND (a.source_entry_id = ? OR a.target_entry_id = ?)
        )
        WHERE remaining_paise > 0
        ORDER BY event_id
        ''',
            variables: [
              Variable.withString(entryId),
              Variable.withString(entryId),
            ],
          )
          .map(
            (row) => ActiveAllocationRow(
              eventId: row.read<String>('event_id'),
              partyAccountId: row.read<String>('party_account_id'),
              sourceEntryId: row.read<String>('source_entry_id'),
              targetEntryId: row.read<String>('target_entry_id'),
              remainingPaise: row.read<int>('remaining_paise'),
            ),
          )
          .get();

  /// Charges of an account that are not fully settled, oldest aging date
  /// first. A reversed charge, a reversal entry and a refund are never
  /// allocation targets.
  Future<List<OpenChargeRow>> openCharges({
    required String shopId,
    required String accountId,
  }) =>
      customSelect(
            '''
    SELECT * FROM (
      SELECT e.id AS entry_id, t.id AS transaction_id,
             t.transaction_type AS transaction_type,
             e.amount_paise AS amount_paise,
             e.amount_paise - COALESCE((
               SELECT SUM(CASE WHEN a.event_type = 'allocate'
                               THEN a.amount_paise ELSE -a.amount_paise END)
               FROM ledger_allocation_events a
               WHERE a.target_entry_id = e.id
             ), 0) AS open_paise,
             t.effective_at AS effective_at, t.recorded_at AS recorded_at,
             e.due_at AS due_at, t.description AS description
      FROM party_ledger_entries e
      JOIN financial_transactions t ON t.id = e.transaction_id
      WHERE e.shop_id = ? AND e.party_account_id = ?
        AND e.amount_paise > 0 AND e.entry_kind IN ('charge', 'opening')
        AND NOT EXISTS (SELECT 1 FROM financial_transactions r
                        WHERE r.reversal_of_transaction_id = t.id)
    )
    WHERE open_paise > 0
    ORDER BY COALESCE(due_at, effective_at), effective_at, recorded_at, entry_id
    ''',
            variables: [
              Variable.withString(shopId),
              Variable.withString(accountId),
            ],
          )
          .map(
            (row) => OpenChargeRow(
              entryId: row.read<String>('entry_id'),
              transactionId: row.read<String>('transaction_id'),
              transactionType: _types.fromSql(
                row.read<String>('transaction_type'),
              ),
              amountPaise: row.read<int>('amount_paise'),
              openPaise: row.read<int>('open_paise'),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              dueAt: _instantOrNull(row.readNullable<int>('due_at')),
              description: row.readNullable<String>('description'),
            ),
          )
          .get();

  /// Settlements (payments, returns, advances) of an account with an
  /// amount not yet applied to any charge, oldest first. Returns pairs of
  /// entry ID and unallocated paise.
  Future<List<(String, int)>> unallocatedSettlements({
    required String shopId,
    required String accountId,
  }) =>
      customSelect(
            '''
    SELECT * FROM (
      SELECT e.id AS entry_id,
             -e.amount_paise - COALESCE((
               SELECT SUM(CASE WHEN a.event_type = 'allocate'
                               THEN a.amount_paise ELSE -a.amount_paise END)
               FROM ledger_allocation_events a
               WHERE a.source_entry_id = e.id
             ), 0) AS unallocated_paise,
             t.effective_at AS effective_at, t.recorded_at AS recorded_at
      FROM party_ledger_entries e
      JOIN financial_transactions t ON t.id = e.transaction_id
      WHERE e.shop_id = ? AND e.party_account_id = ?
        AND e.amount_paise < 0 AND e.entry_kind <> 'reversal'
        AND NOT EXISTS (SELECT 1 FROM financial_transactions r
                        WHERE r.reversal_of_transaction_id = t.id)
    )
    WHERE unallocated_paise > 0
    ORDER BY effective_at, recorded_at, entry_id
    ''',
            variables: [
              Variable.withString(shopId),
              Variable.withString(accountId),
            ],
          )
          .map(
            (row) => (
              row.read<String>('entry_id'),
              row.read<int>('unallocated_paise'),
            ),
          )
          .get();

  /// The money movements of a transaction with their account names.
  Future<List<MovementLineRow>> movementLines(String transactionId) =>
      customSelect(
            '''
        SELECT m.name AS account_name, v.payment_method AS method,
               v.direction AS direction, v.amount_paise AS amount_paise,
               v.reference_number AS reference
        FROM money_movements v
        JOIN money_accounts m ON m.id = v.money_account_id
        WHERE v.transaction_id = ?
        ORDER BY v.id
        ''',
            variables: [Variable.withString(transactionId)],
          )
          .map(
            (row) => MovementLineRow(
              accountName: row.read<String>('account_name'),
              method: _methods.fromSql(row.read<String>('method')),
              direction: _directions.fromSql(row.read<String>('direction')),
              amountPaise: row.read<int>('amount_paise'),
              reference: row.readNullable<String>('reference'),
            ),
          )
          .get();

  /// The charges a settlement entry is applied to, with the net amount
  /// still in force for each.
  Future<List<AllocationTargetRow>> allocationTargetsOf(String sourceEntryId) =>
      customSelect(
            '''
        SELECT * FROM (
          SELECT t.id AS transaction_id, t.transaction_type AS transaction_type,
                 t.effective_at AS effective_at, t.recorded_at AS recorded_at,
                 SUM(CASE WHEN a.event_type = 'allocate'
                          THEN a.amount_paise ELSE -a.amount_paise END)
                   AS amount_paise
          FROM ledger_allocation_events a
          JOIN party_ledger_entries e ON e.id = a.target_entry_id
          JOIN financial_transactions t ON t.id = e.transaction_id
          WHERE a.source_entry_id = ?
          GROUP BY e.id
        )
        WHERE amount_paise > 0
        ORDER BY effective_at, recorded_at, transaction_id
        ''',
            variables: [Variable.withString(sourceEntryId)],
          )
          .map(
            (row) => AllocationTargetRow(
              transactionId: row.read<String>('transaction_id'),
              transactionType: _types.fromSql(
                row.read<String>('transaction_type'),
              ),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              amountPaise: row.read<int>('amount_paise'),
            ),
          )
          .get();

  Future<MoneyAccount?> findMoneyAccount({
    required String shopId,
    required String id,
  }) => (select(
    moneyAccounts,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).getSingleOrNull();

  /// How many transactions of [type] the shop has; the next receipt or
  /// voucher number is one more.
  Future<int> countOfType({
    required String shopId,
    required TransactionType type,
  }) async {
    final row = await customSelect(
      'SELECT COUNT(*) AS n FROM financial_transactions '
      'WHERE shop_id = ? AND transaction_type = ?',
      variables: [Variable.withString(shopId), Variable.withString(type.code)],
    ).getSingle();
    return row.read<int>('n');
  }

  /// `SUM(amount_paise)` of the account: the balance, never stored.
  Future<int> accountBalance(String accountId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(amount_paise), 0) AS balance '
      'FROM party_ledger_entries WHERE party_account_id = ?',
      variables: [Variable.withString(accountId)],
    ).getSingle();
    return row.read<int>('balance');
  }

  Future<PartyAccount?> findAccount({
    required String shopId,
    required String accountId,
  }) =>
      (select(partyAccounts)..where(
            (t) => t.id.equals(accountId) & t.shopId.equals(shopId),
          ))
          .getSingleOrNull();

  Future<Party?> findParty({required String shopId, required String id}) =>
      (select(parties)..where((t) => t.id.equals(id) & t.shopId.equals(shopId)))
          .getSingleOrNull();

  // ---- Writes (call inside a transaction; inserts only) -------------------

  Future<void> insertTransaction(FinancialTransactionsCompanion header) =>
      into(financialTransactions).insert(header);

  Future<void> insertLedgerEntry(PartyLedgerEntriesCompanion entry) =>
      into(partyLedgerEntries).insert(entry);

  Future<void> insertMovement(MoneyMovementsCompanion movement) =>
      into(moneyMovements).insert(movement);

  Future<void> insertAllocationEvent(LedgerAllocationEventsCompanion event) =>
      into(ledgerAllocationEvents).insert(event);

  Future<void> insertAuditLog(AuditLogsCompanion log) =>
      into(auditLogs).insert(log);
}
