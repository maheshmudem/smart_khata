import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'parties_dao.g.dart';

/// A party seen in one role, with its derived balance in paise.
class PartyBalanceRow {
  const PartyBalanceRow({
    required this.partyId,
    required this.accountId,
    required this.name,
    required this.phone,
    required this.status,
    required this.balancePaise,
  });

  final String partyId;
  final String accountId;
  final String name;
  final String? phone;
  final PartyStatus status;
  final int balancePaise;
}

/// One account of a party with its derived balance in paise.
class AccountBalanceRow {
  const AccountBalanceRow({
    required this.accountId,
    required this.role,
    required this.balancePaise,
    required this.hasOpening,
  });

  final String accountId;
  final PartyRole role;
  final int balancePaise;
  final bool hasOpening;
}

/// What a posting needs to know about an account before writing to it.
class AccountContextRow {
  const AccountContextRow({
    required this.role,
    required this.partyStatus,
    required this.hasOpening,
  });

  final PartyRole role;
  final PartyStatus partyStatus;
  final bool hasOpening;
}

/// Parties, their role accounts and opening-balance postings.
///
/// Balances are always `SUM(party_ledger_entries.amount_paise)`; nothing
/// here stores a balance (rule 3).
@DriftAccessor(include: {'../schema/operations.drift'})
class PartiesDao extends DatabaseAccessor<AppDatabase> with _$PartiesDaoMixin {
  PartiesDao(super.attachedDatabase);

  static const _roleConverter = CodedEnumConverter<PartyRole>(PartyRole.values);
  static const _statusConverter = CodedEnumConverter<PartyStatus>(
    PartyStatus.values,
  );

  /// Emits once now and again after any change to parties or ledgers.
  Stream<void> changes() async* {
    yield null;
    yield* attachedDatabase
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            parties,
            partyAccounts,
            partyLedgerEntries,
            financialTransactions,
          ]),
        )
        .map((_) {});
  }

  /// One page of parties in [role].
  ///
  /// [nameLike] and [phoneLike] are `LIKE` patterns already escaped with
  /// `\`; empty strings skip that test. [balanceSign] keeps only positive
  /// (1) or negative (-1) balances; 0 keeps all. Ordering: by balance for a
  /// dues/advance filter, otherwise by name; ID breaks ties.
  Future<List<PartyBalanceRow>> listAccounts({
    required String shopId,
    required PartyRole role,
    required PartyStatus status,
    required String nameLike,
    required String phoneLike,
    required int balanceSign,
    required int limit,
  }) async {
    final rows = await customSelect(
      r'''
SELECT * FROM (
  SELECT p.id AS party_id, pa.id AS account_id, p.display_name AS name,
         p.primary_phone AS phone, p.status AS status,
         p.normalized_name AS normalized_name,
         COALESCE((SELECT SUM(e.amount_paise) FROM party_ledger_entries e
                   WHERE e.party_account_id = pa.id), 0) AS balance
  FROM party_accounts pa
  JOIN parties p ON p.id = pa.party_id
  WHERE pa.shop_id = ?1 AND pa.role = ?2 AND p.status = ?3
    AND (?4 = '' OR p.normalized_name LIKE ?4 ESCAPE '\'
         OR (?5 <> '' AND p.normalized_phone LIKE ?5 ESCAPE '\'))
)
WHERE ?6 = 0 OR (?6 = 1 AND balance > 0) OR (?6 = -1 AND balance < 0)
ORDER BY CASE WHEN ?6 = 1 THEN -balance WHEN ?6 = -1 THEN balance ELSE 0 END,
         normalized_name, party_id
LIMIT ?7
''',
      variables: [
        Variable.withString(shopId),
        Variable.withString(role.code),
        Variable.withString(status.code),
        Variable.withString(nameLike),
        Variable.withString(phoneLike),
        Variable.withInt(balanceSign),
        Variable.withInt(limit),
      ],
      readsFrom: {parties, partyAccounts, partyLedgerEntries},
    ).get();
    return [
      for (final row in rows)
        PartyBalanceRow(
          partyId: row.read<String>('party_id'),
          accountId: row.read<String>('account_id'),
          name: row.read<String>('name'),
          phone: row.readNullable<String>('phone'),
          status: _statusConverter.fromSql(row.read<String>('status')),
          balancePaise: row.read<int>('balance'),
        ),
    ];
  }

  Future<Party?> partyById(String partyId, String shopId) =>
      (select(parties)
            ..where((t) => t.id.equals(partyId) & t.shopId.equals(shopId)))
          .getSingleOrNull();

  /// The party's accounts, customer first, with derived balances.
  Future<List<AccountBalanceRow>> accountsOf(String partyId) async {
    final rows = await customSelect(
      '''
SELECT pa.id AS account_id, pa.role AS role,
       COALESCE(SUM(e.amount_paise), 0) AS balance,
       MAX(CASE WHEN e.entry_kind = 'opening' THEN 1 ELSE 0 END) AS has_opening
FROM party_accounts pa
LEFT JOIN party_ledger_entries e ON e.party_account_id = pa.id
WHERE pa.party_id = ?1
GROUP BY pa.id, pa.role
ORDER BY pa.role
''',
      variables: [Variable.withString(partyId)],
      readsFrom: {partyAccounts, partyLedgerEntries},
    ).get();
    return [
      for (final row in rows)
        AccountBalanceRow(
          accountId: row.read<String>('account_id'),
          role: _roleConverter.fromSql(row.read<String>('role')),
          balancePaise: row.read<int>('balance'),
          hasOpening: (row.readNullable<int>('has_opening') ?? 0) == 1,
        ),
    ];
  }

  /// Parties other than [excludePartyId] that use [normalizedPhone].
  Future<List<Party>> partiesWithPhone({
    required String shopId,
    required String normalizedPhone,
    String? excludePartyId,
  }) {
    final query = select(parties)
      ..where(
        (t) =>
            t.shopId.equals(shopId) & t.normalizedPhone.equals(normalizedPhone),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)])
      ..limit(5);
    if (excludePartyId != null) {
      query.where((t) => t.id.equals(excludePartyId).not());
    }
    return query.get();
  }

  Future<void> insertParty(PartiesCompanion row) => into(parties).insert(row);

  Future<int> updateParty(String partyId, PartiesCompanion row) =>
      (update(parties)..where((t) => t.id.equals(partyId))).write(row);

  Future<void> insertAccount(PartyAccountsCompanion row) =>
      into(partyAccounts).insert(row);

  /// The account's role, its party's status and whether it already has an
  /// opening entry; `null` when the account is not in [shopId].
  Future<AccountContextRow?> accountContext(
    String accountId,
    String shopId,
  ) async {
    final row = await customSelect(
      '''
SELECT pa.role AS role, p.status AS status,
       EXISTS (SELECT 1 FROM party_ledger_entries e
               WHERE e.party_account_id = pa.id AND e.entry_kind = 'opening')
         AS has_opening
FROM party_accounts pa
JOIN parties p ON p.id = pa.party_id
WHERE pa.id = ?1 AND pa.shop_id = ?2
''',
      variables: [Variable.withString(accountId), Variable.withString(shopId)],
      readsFrom: {partyAccounts, parties, partyLedgerEntries},
    ).getSingleOrNull();
    if (row == null) return null;
    return AccountContextRow(
      role: _roleConverter.fromSql(row.read<String>('role')),
      partyStatus: _statusConverter.fromSql(row.read<String>('status')),
      hasOpening: row.read<int>('has_opening') == 1,
    );
  }

  Future<bool> operationExists(String operationId) async {
    final row =
        await (selectOnly(financialTransactions)
              ..addColumns([financialTransactions.id])
              ..where(financialTransactions.operationId.equals(operationId))
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<void> insertTransaction(FinancialTransactionsCompanion row) =>
      into(financialTransactions).insert(row);

  Future<void> insertLedgerEntry(PartyLedgerEntriesCompanion row) =>
      into(partyLedgerEntries).insert(row);

  Future<void> insertAudit(AuditLogsCompanion row) =>
      into(auditLogs).insert(row);
}
