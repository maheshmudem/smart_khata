import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'parties_dao.g.dart';

/// Which balances a list query keeps.
enum BalanceSign { any, positive, negative }

/// Ordering of a party list query. The SQL fragments are fixed strings;
/// nothing from the user reaches the ORDER BY clause.
enum PartyListOrder {
  name('p.normalized_name ASC, a.id ASC'),
  highestBalance('balance_paise DESC, p.normalized_name ASC, a.id ASC'),
  recentActivity(
    'last_activity_at IS NULL, last_activity_at DESC, '
    'p.normalized_name ASC, a.id ASC',
  );

  const PartyListOrder(this.sql);

  final String sql;
}

/// One party account with its derived balance.
class PartyListRow {
  const PartyListRow({
    required this.partyId,
    required this.accountId,
    required this.role,
    required this.displayName,
    required this.primaryPhone,
    required this.status,
    required this.balancePaise,
    required this.lastActivityAt,
  });

  final String partyId;
  final String accountId;
  final PartyRole role;
  final String displayName;
  final String? primaryPhone;
  final PartyStatus status;
  final int balancePaise;
  final DateTime? lastActivityAt;
}

/// Derived totals of one party account.
class PartyAccountTotalsRow {
  const PartyAccountTotalsRow({
    required this.accountId,
    required this.role,
    required this.balancePaise,
    required this.chargesPaise,
    required this.settlementsPaise,
    required this.openingCount,
  });

  final String accountId;
  final PartyRole role;
  final int balancePaise;
  final int chargesPaise;
  final int settlementsPaise;
  final int openingCount;
}

/// A ledger line joined with its transaction header.
class LedgerEntryRow {
  const LedgerEntryRow({
    required this.entryId,
    required this.transactionId,
    required this.kind,
    required this.transactionType,
    required this.amountPaise,
    required this.effectiveAt,
    required this.description,
  });

  final String entryId;
  final String transactionId;
  final LedgerEntryKind kind;
  final TransactionType transactionType;
  final int amountPaise;
  final DateTime effectiveAt;
  final String? description;
}

const _roles = CodedEnumConverter<PartyRole>(PartyRole.values);
const _statuses = CodedEnumConverter<PartyStatus>(PartyStatus.values);
const _kinds = CodedEnumConverter<LedgerEntryKind>(LedgerEntryKind.values);
const _types = CodedEnumConverter<TransactionType>(TransactionType.values);
const _instants = EpochMsConverter();

@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/operations.drift',
  },
)
class PartiesDao extends DatabaseAccessor<AppDatabase> with _$PartiesDaoMixin {
  PartiesDao(super.attachedDatabase);

  // ---- Reads -------------------------------------------------------------

  /// Party accounts of one role with balances derived from the ledger.
  ///
  /// [namePattern] and [phonePattern] are LIKE patterns already escaped
  /// with `\`; a row matches if either does. Always bounded by [limit].
  Stream<List<PartyListRow>> watchPartyList({
    required String shopId,
    required PartyRole role,
    required PartyStatus status,
    required BalanceSign balanceSign,
    required PartyListOrder order,
    required int limit,
    String? namePattern,
    String? phonePattern,
  }) {
    final having = switch (balanceSign) {
      BalanceSign.any => '',
      BalanceSign.positive => 'HAVING balance_paise > 0',
      BalanceSign.negative => 'HAVING balance_paise < 0',
    };
    final hasSearch = namePattern != null || phonePattern != null;
    final search = hasSearch
        ? r"AND (p.normalized_name LIKE ? ESCAPE '\' "
              r"OR p.normalized_phone LIKE ? ESCAPE '\')"
        : '';

    return customSelect(
      '''
      SELECT p.id AS party_id, a.id AS account_id, a.role AS role,
             p.display_name AS display_name, p.primary_phone AS primary_phone,
             p.status AS status,
             COALESCE(SUM(e.amount_paise), 0) AS balance_paise,
             MAX(e.created_at) AS last_activity_at
      FROM party_accounts a
      JOIN parties p ON p.id = a.party_id
      LEFT JOIN party_ledger_entries e ON e.party_account_id = a.id
      WHERE a.shop_id = ? AND a.role = ? AND p.status = ? $search
      GROUP BY a.id
      $having
      ORDER BY ${order.sql}
      LIMIT ?
      ''',
      variables: [
        Variable.withString(shopId),
        Variable.withString(role.code),
        Variable.withString(status.code),
        if (hasSearch) ...[
          // A pattern that cannot match keeps the SQL shape fixed.
          Variable.withString(namePattern ?? ''),
          Variable.withString(phonePattern ?? ''),
        ],
        Variable.withInt(limit),
      ],
      readsFrom: {parties, partyAccounts, partyLedgerEntries},
    ).watch().map(
      (rows) => [
        for (final row in rows)
          PartyListRow(
            partyId: row.read<String>('party_id'),
            accountId: row.read<String>('account_id'),
            role: _roles.fromSql(row.read<String>('role')),
            displayName: row.read<String>('display_name'),
            primaryPhone: row.readNullable<String>('primary_phone'),
            status: _statuses.fromSql(row.read<String>('status')),
            balancePaise: row.read<int>('balance_paise'),
            lastActivityAt: switch (row.readNullable<int>('last_activity_at')) {
              final ms? => _instants.fromSql(ms),
              null => null,
            },
          ),
      ],
    );
  }

  Stream<Party?> watchParty({required String shopId, required String id}) =>
      (select(parties)..where((t) => t.id.equals(id) & t.shopId.equals(shopId)))
          .watchSingleOrNull();

  Future<Party?> findParty({required String shopId, required String id}) =>
      (select(parties)..where((t) => t.id.equals(id) & t.shopId.equals(shopId)))
          .getSingleOrNull();

  /// Every role account of a party with its balance and totals.
  Stream<List<PartyAccountTotalsRow>> watchAccountTotals({
    required String shopId,
    required String partyId,
  }) => _accountTotals(shopId, partyId).watch();

  Future<List<PartyAccountTotalsRow>> getAccountTotals({
    required String shopId,
    required String partyId,
  }) => _accountTotals(shopId, partyId).get();

  Selectable<PartyAccountTotalsRow> _accountTotals(
    String shopId,
    String partyId,
  ) =>
      customSelect(
        '''
    SELECT a.id AS account_id, a.role AS role,
           COALESCE(SUM(e.amount_paise), 0) AS balance_paise,
           COALESCE(SUM(CASE WHEN e.amount_paise > 0
                             THEN e.amount_paise END), 0) AS charges_paise,
           COALESCE(SUM(CASE WHEN e.amount_paise < 0
                             THEN -e.amount_paise END), 0) AS settlements_paise,
           COALESCE(SUM(CASE WHEN e.entry_kind = 'opening'
                             THEN 1 END), 0) AS opening_count
    FROM party_accounts a
    LEFT JOIN party_ledger_entries e ON e.party_account_id = a.id
    WHERE a.shop_id = ? AND a.party_id = ?
    GROUP BY a.id
    ORDER BY a.role ASC
    ''',
        variables: [Variable.withString(shopId), Variable.withString(partyId)],
        readsFrom: {partyAccounts, partyLedgerEntries},
      ).map(
        (row) => PartyAccountTotalsRow(
          accountId: row.read<String>('account_id'),
          role: _roles.fromSql(row.read<String>('role')),
          balancePaise: row.read<int>('balance_paise'),
          chargesPaise: row.read<int>('charges_paise'),
          settlementsPaise: row.read<int>('settlements_paise'),
          openingCount: row.read<int>('opening_count'),
        ),
      );

  /// Newest ledger lines of an account: effective time, then recorded
  /// time, then ID (schema doc 5.5), descending.
  Stream<List<LedgerEntryRow>> watchRecentEntries({
    required String shopId,
    required String accountId,
    required int limit,
  }) =>
      customSelect(
        '''
    SELECT e.id AS entry_id, t.id AS transaction_id, e.entry_kind AS kind,
           t.transaction_type AS transaction_type,
           e.amount_paise AS amount_paise, t.effective_at AS effective_at,
           t.description AS description
    FROM party_ledger_entries e
    JOIN financial_transactions t ON t.id = e.transaction_id
    WHERE e.shop_id = ? AND e.party_account_id = ?
    ORDER BY t.effective_at DESC, t.recorded_at DESC, e.id DESC
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
            LedgerEntryRow(
              entryId: row.read<String>('entry_id'),
              transactionId: row.read<String>('transaction_id'),
              kind: _kinds.fromSql(row.read<String>('kind')),
              transactionType: _types.fromSql(
                row.read<String>('transaction_type'),
              ),
              amountPaise: row.read<int>('amount_paise'),
              effectiveAt: _instants.fromSql(row.read<int>('effective_at')),
              description: row.readNullable<String>('description'),
            ),
        ],
      );

  Future<List<Party>> findByNormalizedPhone({
    required String shopId,
    required String normalizedPhone,
    String? excludingPartyId,
  }) {
    final query = select(parties)
      ..where(
        (t) =>
            t.shopId.equals(shopId) & t.normalizedPhone.equals(normalizedPhone),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)])
      ..limit(5);
    if (excludingPartyId != null) {
      query.where((t) => t.id.equals(excludingPartyId).not());
    }
    return query.get();
  }

  Future<List<PartyAccount>> accountsOf({
    required String shopId,
    required String partyId,
  }) =>
      (select(partyAccounts)..where(
            (t) => t.partyId.equals(partyId) & t.shopId.equals(shopId),
          ))
          .get();

  Future<PartyAccount?> findAccount({
    required String shopId,
    required String accountId,
  }) =>
      (select(partyAccounts)..where(
            (t) => t.id.equals(accountId) & t.shopId.equals(shopId),
          ))
          .getSingleOrNull();

  Future<bool> hasOpeningEntry(String accountId) async {
    final row =
        await (select(partyLedgerEntries)
              ..where(
                (t) =>
                    t.partyAccountId.equals(accountId) &
                    t.entryKind.equalsValue(LedgerEntryKind.opening),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<bool> operationExists(String operationId) async {
    final row =
        await (select(financialTransactions)
              ..where((t) => t.operationId.equals(operationId))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  // ---- Writes (call inside a transaction) ---------------------------------

  Future<void> insertParty(PartiesCompanion party) =>
      into(parties).insert(party);

  Future<void> insertAccount(PartyAccountsCompanion account) =>
      into(partyAccounts).insert(account);

  Future<int> updateParty({
    required String shopId,
    required String id,
    required PartiesCompanion changes,
  }) => (update(
    parties,
  )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).write(changes);

  Future<void> insertTransaction(FinancialTransactionsCompanion header) =>
      into(financialTransactions).insert(header);

  Future<void> insertLedgerEntry(PartyLedgerEntriesCompanion entry) =>
      into(partyLedgerEntries).insert(entry);

  Future<void> insertAuditLog(AuditLogsCompanion log) =>
      into(auditLogs).insert(log);
}
