import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:smart_khata/core/database/app_database.dart';

/// A fresh in-memory database with the full schema, triggers and pragmas.
AppDatabase createTestDatabase() => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(),
    closeStreamsSynchronously: true,
  ),
);

/// Raw-SQL seeding helpers. Tests of the schema write SQL directly so they
/// exercise the constraints themselves rather than Drift's typed layer.
extension SchemaSeed on AppDatabase {
  static const int t0 = 1794700800000; // 2026-11-15T00:00:00Z

  Future<void> exec(String sql, [List<Object?> args = const []]) =>
      customStatement(sql, args);

  Future<void> seedShop({String id = 'shop-1'}) => exec(
    'INSERT INTO shops (id, name, time_zone, created_at, updated_at) '
    "VALUES (?, 'Test Kirana', 'Asia/Kolkata', $t0, $t0)",
    [id],
  );

  Future<void> seedParty({
    required String id,
    String shopId = 'shop-1',
    String name = 'Ravi',
  }) => exec(
    'INSERT INTO parties (id, shop_id, display_name, normalized_name, '
    'created_at, updated_at) VALUES (?, ?, ?, lower(?), $t0, $t0)',
    [id, shopId, name, name],
  );

  Future<void> seedAccount({
    required String id,
    required String partyId,
    String role = 'customer',
    String shopId = 'shop-1',
  }) => exec(
    'INSERT INTO party_accounts (id, shop_id, party_id, role, created_at) '
    'VALUES (?, ?, ?, ?, $t0)',
    [id, shopId, partyId, role],
  );

  Future<void> seedTransaction({
    required String id,
    String? accountId,
    String type = 'customer_credit',
    int amountPaise = 50000,
    String shopId = 'shop-1',
    String? operationId,
    String? reversalOf,
  }) => exec(
    'INSERT INTO financial_transactions (id, shop_id, party_account_id, '
    'transaction_type, amount_paise, effective_at, recorded_at, '
    'business_date, operation_id, reversal_of_transaction_id, created_at) '
    "VALUES (?, ?, ?, ?, ?, $t0, $t0, '2026-11-15', ?, ?, $t0)",
    [
      id,
      shopId,
      accountId,
      type,
      amountPaise,
      operationId ?? 'op-$id',
      reversalOf,
    ],
  );

  Future<void> seedLedgerEntry({
    required String id,
    required String accountId,
    required String transactionId,
    required int amountPaise,
    String kind = 'charge',
    String shopId = 'shop-1',
  }) => exec(
    'INSERT INTO party_ledger_entries (id, shop_id, party_account_id, '
    'transaction_id, entry_kind, amount_paise, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, $t0)',
    [id, shopId, accountId, transactionId, kind, amountPaise],
  );

  /// Posts a transaction header plus its ledger line in one call.
  Future<void> seedPosting({
    required String id,
    required String accountId,
    required int signedPaise,
    String type = 'customer_credit',
    String kind = 'charge',
  }) async {
    await seedTransaction(
      id: 'txn-$id',
      accountId: accountId,
      type: type,
      amountPaise: signedPaise.abs(),
    );
    await seedLedgerEntry(
      id: id,
      accountId: accountId,
      transactionId: 'txn-$id',
      amountPaise: signedPaise,
      kind: kind,
    );
  }

  Future<void> seedAllocation({
    required String id,
    required String accountId,
    required String sourceEntryId,
    required String targetEntryId,
    required int amountPaise,
    String eventType = 'allocate',
    String? reversesEventId,
  }) => exec(
    'INSERT INTO ledger_allocation_events (id, shop_id, party_account_id, '
    'source_entry_id, target_entry_id, event_type, amount_paise, '
    "reverses_event_id, created_at) VALUES (?, 'shop-1', ?, ?, ?, ?, ?, ?, $t0)",
    [
      id,
      accountId,
      sourceEntryId,
      targetEntryId,
      eventType,
      amountPaise,
      reversesEventId,
    ],
  );

  Future<void> seedMoneyAccount({String id = 'cash-1'}) => exec(
    'INSERT INTO money_accounts (id, shop_id, name, account_type, '
    "opening_effective_at, created_at) VALUES (?, 'shop-1', 'Cash', 'cash', $t0, $t0)",
    [id],
  );

  Future<int> scalar(String sql, [List<Object?> args = const []]) async {
    final row = await customSelect(
      sql,
      variables: [for (final arg in args) Variable<Object>(arg)],
    ).getSingle();
    return row.data.values.first as int;
  }
}
