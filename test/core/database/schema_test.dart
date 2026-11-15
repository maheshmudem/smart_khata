import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart';

import '../../helpers/test_database.dart';

/// Matches a SQLite failure whose message contains [text].
Matcher sqliteError(String text) => throwsA(
  isA<SqliteException>().having((e) => e.message, 'message', contains(text)),
);

void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    await db.seedShop();
    await db.seedParty(id: 'party-1');
    await db.seedAccount(id: 'cust-1', partyId: 'party-1');
  });

  tearDown(() => db.close());

  group('schema v1', () {
    test('creates every table from schema_v1.sql', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      expect(rows.map((r) => r.read<String>('name')), [
        'app_settings',
        'attachments',
        'audit_logs',
        'backup_history',
        'daily_closings',
        'expense_categories',
        'expenses',
        'financial_transactions',
        'ledger_allocation_events',
        'money_accounts',
        'money_movements',
        'parties',
        'party_accounts',
        'party_ledger_entries',
        'reminders',
        'shops',
        'transaction_items',
      ]);
    });

    test('enforces foreign keys on the connection', () async {
      expect(await db.scalar('PRAGMA foreign_keys'), 1);
    });

    test('passes integrity and foreign-key checks', () async {
      final integrity = await db.customSelect('PRAGMA integrity_check').get();
      expect(integrity.single.data.values.single, 'ok');
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    });

    test('reports schema version 1', () async {
      expect(db.schemaVersion, 1);
      expect(await db.scalar('PRAGMA user_version'), 1);
    });
  });

  group('row constraints', () {
    test('rejects a blank shop name', () {
      expect(
        db.exec(
          'INSERT INTO shops (id, name, time_zone, created_at, updated_at) '
          "VALUES ('s2', '   ', 'Asia/Kolkata', 0, 0)",
        ),
        sqliteError('CHECK'),
      );
    });

    test('rejects a currency other than INR', () {
      expect(
        db.exec(
          'INSERT INTO shops (id, name, currency_code, time_zone, created_at, '
          "updated_at) VALUES ('s2', 'X', 'USD', 'Asia/Kolkata', 0, 0)",
        ),
        sqliteError('CHECK'),
      );
    });

    test('rejects a party in a shop that does not exist', () {
      expect(
        db.seedParty(id: 'party-x', shopId: 'no-such-shop'),
        sqliteError('FOREIGN KEY'),
      );
    });

    test('allows one account per party role and no more', () async {
      await db.seedAccount(id: 'supp-1', partyId: 'party-1', role: 'supplier');
      expect(
        db.seedAccount(id: 'cust-dup', partyId: 'party-1'),
        sqliteError('UNIQUE'),
      );
    });

    test('rejects an unknown party role', () {
      expect(
        db.seedAccount(id: 'a-x', partyId: 'party-1', role: 'staff'),
        sqliteError('CHECK'),
      );
    });

    test('rejects an account whose shop differs from its party', () async {
      await db.seedShop(id: 'shop-2');
      expect(
        db.seedAccount(
          id: 'a-x',
          partyId: 'party-1',
          role: 'supplier',
          shopId: 'shop-2',
        ),
        sqliteError('FOREIGN KEY'),
      );
    });

    test('rejects a zero or negative transaction amount', () {
      expect(
        db.seedTransaction(id: 't0', accountId: 'cust-1', amountPaise: 0),
        sqliteError('CHECK'),
      );
      expect(
        db.seedTransaction(id: 't-neg', accountId: 'cust-1', amountPaise: -1),
        sqliteError('CHECK'),
      );
    });

    test('rejects an unknown transaction type', () {
      expect(
        db.seedTransaction(id: 't1', accountId: 'cust-1', type: 'profit'),
        sqliteError('CHECK'),
      );
    });

    test('rejects a zero ledger entry', () async {
      await db.seedTransaction(id: 't1', accountId: 'cust-1');
      expect(
        db.seedLedgerEntry(
          id: 'e1',
          accountId: 'cust-1',
          transactionId: 't1',
          amountPaise: 0,
        ),
        sqliteError('CHECK'),
      );
    });

    test('rejects a money movement with a non-positive amount', () async {
      await db.seedMoneyAccount();
      await db.seedTransaction(id: 't1', type: 'expense');
      expect(
        db.exec(
          'INSERT INTO money_movements (id, shop_id, transaction_id, '
          'money_account_id, payment_method, direction, amount_paise, '
          "created_at) VALUES ('m1', 'shop-1', 't1', 'cash-1', 'cash', "
          "'outflow', 0, 0)",
        ),
        sqliteError('CHECK'),
      );
    });

    test('allows only one active expense category per name', () async {
      Future<void> addCategory(String id, {int active = 1}) => db.exec(
        'INSERT INTO expense_categories (id, shop_id, name, normalized_name, '
        "is_active, created_at, updated_at) VALUES (?, 'shop-1', 'Rent', "
        "'rent', ?, 0, 0)",
        [id, active],
      );

      await addCategory('c1');
      await addCategory('c-archived', active: 0);
      expect(addCategory('c2'), sqliteError('UNIQUE'));
    });
  });

  group('idempotency and reversal', () {
    test('a repeated operation ID cannot post twice', () async {
      await db.seedTransaction(
        id: 't1',
        accountId: 'cust-1',
        operationId: 'op',
      );
      expect(
        db.seedTransaction(id: 't2', accountId: 'cust-1', operationId: 'op'),
        sqliteError('operation_id'),
      );
    });

    test('a transaction can be fully reversed only once', () async {
      await db.seedTransaction(id: 't1', accountId: 'cust-1');
      await db.seedTransaction(
        id: 'r1',
        accountId: 'cust-1',
        type: 'transaction_reversal',
        reversalOf: 't1',
      );
      expect(
        db.seedTransaction(
          id: 'r2',
          accountId: 'cust-1',
          type: 'transaction_reversal',
          reversalOf: 't1',
        ),
        sqliteError('UNIQUE'),
      );
    });
  });

  group('append-only financial tables', () {
    setUp(() async {
      await db.seedPosting(
        id: 'charge',
        accountId: 'cust-1',
        signedPaise: 50000,
      );
      await db.seedPosting(
        id: 'pay',
        accountId: 'cust-1',
        signedPaise: -20000,
        type: 'customer_payment',
        kind: 'payment',
      );
      await db.seedAllocation(
        id: 'alloc',
        accountId: 'cust-1',
        sourceEntryId: 'pay',
        targetEntryId: 'charge',
        amountPaise: 20000,
      );
      await db.seedMoneyAccount();
      await db.exec(
        'INSERT INTO money_movements (id, shop_id, transaction_id, '
        'money_account_id, payment_method, direction, amount_paise, created_at) '
        "VALUES ('move', 'shop-1', 'txn-pay', 'cash-1', 'cash', 'inflow', 20000, 0)",
      );
      await db.exec(
        'INSERT INTO daily_closings (id, shop_id, money_account_id, '
        'business_date, expected_cash_paise, counted_cash_paise, variance_paise, '
        'denomination_counts_json, revision_number, created_at) '
        "VALUES ('close', 'shop-1', 'cash-1', '2026-11-15', 20000, 20000, 0, '{}', 1, 0)",
      );
      await db.exec(
        'INSERT INTO audit_logs (id, shop_id, entity_type, entity_id, "action", '
        "created_at) VALUES ('audit', 'shop-1', 'transaction', 'txn-pay', 'posted', 0)",
      );
    });

    const tables = {
      'financial_transactions': 'txn-charge',
      'party_ledger_entries': 'charge',
      'ledger_allocation_events': 'alloc',
      'money_movements': 'move',
      'daily_closings': 'close',
      'audit_logs': 'audit',
    };

    for (final MapEntry(key: table, value: id) in tables.entries) {
      test('$table rejects UPDATE', () {
        expect(
          db.exec('UPDATE $table SET shop_id = shop_id WHERE id = ?', [id]),
          sqliteError('append-only'),
        );
      });

      test('$table rejects DELETE', () {
        expect(
          db.exec('DELETE FROM $table WHERE id = ?', [id]),
          sqliteError('append-only'),
        );
      });
    }
  });

  group('allocation guards', () {
    setUp(() async {
      // Two charges of ₹500 and ₹300, one payment of ₹600.
      await db.seedPosting(id: 'c1', accountId: 'cust-1', signedPaise: 50000);
      await db.seedPosting(id: 'c2', accountId: 'cust-1', signedPaise: 30000);
      await db.seedPosting(
        id: 'p1',
        accountId: 'cust-1',
        signedPaise: -60000,
        type: 'customer_payment',
        kind: 'payment',
      );
    });

    Future<void> allocate(
      String id, {
      required int paise,
      String source = 'p1',
      String target = 'c1',
    }) => db.seedAllocation(
      id: id,
      accountId: 'cust-1',
      sourceEntryId: source,
      targetEntryId: target,
      amountPaise: paise,
    );

    test('accepts a payment split across open charges', () async {
      await allocate('a1', paise: 50000);
      await allocate('a2', paise: 10000, target: 'c2');
      expect(
        await db.scalar('SELECT COUNT(*) FROM ledger_allocation_events'),
        2,
      );
    });

    test('rejects allocating more than the charge', () {
      expect(allocate('a1', paise: 50001), sqliteError('exceeds'));
    });

    test('rejects allocating more than the payment in total', () async {
      await allocate('a1', paise: 50000);
      // ₹100 of the payment is left; the second charge is open for ₹300.
      expect(
        allocate('a2', paise: 10001, target: 'c2'),
        sqliteError('exceeds'),
      );
    });

    test('rejects a charge used as the source', () {
      expect(
        allocate('a1', paise: 100, source: 'c2'),
        sqliteError('signs or account'),
      );
    });

    test('rejects a payment used as the target', () {
      expect(
        allocate('a1', paise: 100, target: 'p1'),
        sqliteError('signs or account'),
      );
    });

    test('rejects entries from another party account', () async {
      await db.seedParty(id: 'party-2', name: 'Suresh');
      await db.seedAccount(id: 'cust-2', partyId: 'party-2');
      await db.seedPosting(
        id: 'other',
        accountId: 'cust-2',
        signedPaise: 40000,
      );
      expect(
        allocate('a1', paise: 100, target: 'other'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a release frees the charge for a new allocation', () async {
      await allocate('a1', paise: 50000);
      await db.seedAllocation(
        id: 'r1',
        accountId: 'cust-1',
        sourceEntryId: 'p1',
        targetEntryId: 'c1',
        amountPaise: 50000,
        eventType: 'release',
        reversesEventId: 'a1',
      );
      await allocate('a2', paise: 50000);
    });

    test('rejects releasing more than was allocated', () async {
      await allocate('a1', paise: 20000);
      expect(
        db.seedAllocation(
          id: 'r1',
          accountId: 'cust-1',
          sourceEntryId: 'p1',
          targetEntryId: 'c1',
          amountPaise: 20001,
          eventType: 'release',
          reversesEventId: 'a1',
        ),
        sqliteError('release is invalid'),
      );
    });

    test('rejects a release that names no allocation', () {
      expect(
        db.seedAllocation(
          id: 'r1',
          accountId: 'cust-1',
          sourceEntryId: 'p1',
          targetEntryId: 'c1',
          amountPaise: 100,
          eventType: 'release',
        ),
        // The trigger runs before the CHECK and rejects it first.
        sqliteError('release is invalid'),
      );
    });
  });

  group('balances (test plan 5.3 fixtures)', () {
    test('customer: opening 300 + 1500 + 500 - 1000 = 1300', () async {
      await db.seedPosting(
        id: 'open',
        accountId: 'cust-1',
        signedPaise: 30000,
        type: 'opening_balance',
        kind: 'opening',
      );
      await db.seedPosting(id: 'c1', accountId: 'cust-1', signedPaise: 150000);
      await db.seedPosting(id: 'c2', accountId: 'cust-1', signedPaise: 50000);
      await db.seedPosting(
        id: 'p1',
        accountId: 'cust-1',
        signedPaise: -100000,
        type: 'customer_payment',
        kind: 'payment',
      );

      expect(
        await db.scalar(
          'SELECT SUM(amount_paise) FROM party_ledger_entries '
          "WHERE party_account_id = 'cust-1'",
        ),
        130000,
      );
    });

    test('customer and supplier accounts of one party stay separate', () async {
      await db.seedAccount(id: 'supp-1', partyId: 'party-1', role: 'supplier');
      await db.seedPosting(id: 'c1', accountId: 'cust-1', signedPaise: 60000);
      await db.seedPosting(
        id: 's1',
        accountId: 'supp-1',
        signedPaise: 200000,
        type: 'supplier_purchase',
      );

      Future<int> balance(String account) => db.scalar(
        'SELECT SUM(amount_paise) FROM party_ledger_entries '
        'WHERE party_account_id = ?',
        [account],
      );
      expect(await balance('cust-1'), 60000);
      expect(await balance('supp-1'), 200000);
    });

    test('an excess receipt leaves a negative balance (advance)', () async {
      await db.seedPosting(id: 'c1', accountId: 'cust-1', signedPaise: 60000);
      await db.seedPosting(
        id: 'p1',
        accountId: 'cust-1',
        signedPaise: -80000,
        type: 'customer_payment',
        kind: 'payment',
      );
      expect(
        await db.scalar('SELECT SUM(amount_paise) FROM party_ledger_entries'),
        -20000,
      );
    });
  });
}
