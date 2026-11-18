import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'dashboard_dao.g.dart';

/// Owed and advance totals for one role, in paise.
class RoleTotalsRow {
  const RoleTotalsRow({
    required this.role,
    required this.owedPaise,
    required this.advancePaise,
    required this.accountsWithDues,
    required this.accounts,
  });

  final PartyRole role;
  final int owedPaise;
  final int advancePaise;
  final int accountsWithDues;
  final int accounts;
}

/// One recent ledger line.
class ActivityRow {
  const ActivityRow({
    required this.partyId,
    required this.partyName,
    required this.role,
    required this.type,
    required this.signedPaise,
    required this.effectiveAt,
  });

  final String partyId;
  final String partyName;
  final PartyRole role;
  final TransactionType type;
  final int signedPaise;
  final DateTime effectiveAt;
}

/// Read-only aggregates for the Home dashboard (FR-REP-001, PRD 9.5).
@DriftAccessor(include: {'../schema/operations.drift'})
class DashboardDao extends DatabaseAccessor<AppDatabase>
    with _$DashboardDaoMixin {
  DashboardDao(super.attachedDatabase);

  static const _roles = CodedEnumConverter<PartyRole>(PartyRole.values);
  static const _types = CodedEnumConverter<TransactionType>(
    TransactionType.values,
  );
  static const _instant = EpochMsConverter();

  /// Emits once now and again after any change the dashboard shows.
  Stream<void> changes() async* {
    yield null;
    yield* attachedDatabase
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            shops,
            parties,
            partyAccounts,
            partyLedgerEntries,
            financialTransactions,
            moneyMovements,
          ]),
        )
        .map((_) {});
  }

  /// Totals per role. Each account's balance is summed first, then positive
  /// balances count as owed and negative ones as advance; they are never
  /// netted against each other (PRD 9.5).
  Future<List<RoleTotalsRow>> roleTotals(String shopId) async {
    final rows = await customSelect(
      '''
SELECT role,
       SUM(CASE WHEN balance > 0 THEN balance ELSE 0 END) AS owed,
       SUM(CASE WHEN balance < 0 THEN -balance ELSE 0 END) AS advance,
       SUM(CASE WHEN balance > 0 THEN 1 ELSE 0 END) AS with_dues,
       COUNT(*) AS accounts
FROM (
  SELECT pa.role AS role, COALESCE(SUM(e.amount_paise), 0) AS balance
  FROM party_accounts pa
  LEFT JOIN party_ledger_entries e ON e.party_account_id = pa.id
  WHERE pa.shop_id = ?1
  GROUP BY pa.id, pa.role
)
GROUP BY role
''',
      variables: [Variable.withString(shopId)],
      readsFrom: {partyAccounts, partyLedgerEntries},
    ).get();
    return [
      for (final row in rows)
        RoleTotalsRow(
          role: _roles.fromSql(row.read<String>('role')),
          owedPaise: row.read<int>('owed'),
          advancePaise: row.read<int>('advance'),
          accountsWithDues: row.read<int>('with_dues'),
          accounts: row.read<int>('accounts'),
        ),
    ];
  }

  /// Header totals per transaction type for one business date.
  Future<Map<TransactionType, int>> dayTotals(
    String shopId,
    String businessDate,
  ) async {
    final rows = await customSelect(
      '''
SELECT transaction_type AS type, SUM(amount_paise) AS total
FROM financial_transactions
WHERE shop_id = ?1 AND business_date = ?2
GROUP BY transaction_type
''',
      variables: [
        Variable.withString(shopId),
        Variable.withString(businessDate),
      ],
      readsFrom: {financialTransactions},
    ).get();
    return {
      for (final row in rows)
        _types.fromSql(row.read<String>('type')): row.read<int>('total'),
    };
  }

  /// The latest ledger lines, newest first, in ledger order.
  Future<List<ActivityRow>> recentActivity(String shopId, int limit) async {
    final rows = await customSelect(
      '''
SELECT p.id AS party_id, p.display_name AS name, pa.role AS role,
       t.transaction_type AS type, e.amount_paise AS amount,
       t.effective_at AS effective_at
FROM party_ledger_entries e
JOIN financial_transactions t ON t.id = e.transaction_id
JOIN party_accounts pa ON pa.id = e.party_account_id
JOIN parties p ON p.id = pa.party_id
WHERE e.shop_id = ?1
ORDER BY t.effective_at DESC, t.recorded_at DESC, e.id DESC
LIMIT ?2
''',
      variables: [Variable.withString(shopId), Variable.withInt(limit)],
      readsFrom: {
        partyLedgerEntries,
        financialTransactions,
        partyAccounts,
        parties,
      },
    ).get();
    return [
      for (final row in rows)
        ActivityRow(
          partyId: row.read<String>('party_id'),
          partyName: row.read<String>('name'),
          role: _roles.fromSql(row.read<String>('role')),
          type: _types.fromSql(row.read<String>('type')),
          signedPaise: row.read<int>('amount'),
          effectiveAt: _instant.fromSql(row.read<int>('effective_at')),
        ),
    ];
  }
}
