import 'package:drift/drift.dart' show Variable;
import 'package:smart_khata/core/database/app_database.dart' show AppDatabase;
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/data/allocation_rebalancer.dart';
import 'package:smart_khata/features/ledger/data/drift_ledger_repository.dart';
import 'package:smart_khata/features/ledger/domain/ledger_use_cases.dart';
import 'package:smart_khata/features/money/data/drift_money_account_repository.dart';
import 'package:smart_khata/features/money/domain/money_account.dart';
import 'package:smart_khata/features/parties/data/drift_party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/shop/data/drift_shop_repository.dart';
import 'package:smart_khata/features/shop/domain/create_shop.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

import 'fakes.dart';
import 'test_database.dart';

/// IDs that are predictable and sort in creation order.
class SequentialIdGenerator implements IdGenerator {
  int _next = 1;

  @override
  String newId() => 'id-${(_next++).toString().padLeft(5, '0')}';
}

/// The real repositories and use cases on an in-memory database.
class TestEnv {
  TestEnv() : db = createTestDatabase() {
    shops = DriftShopRepository(
      dao: db.shopDao,
      clock: clock,
      ids: ids,
      logger: logger,
    );
    parties = DriftPartyRepository(
      dao: db.partiesDao,
      shop: shops,
      clock: clock,
      ids: ids,
      logger: logger,
      allocations: AllocationRebalancer(dao: db.ledgerDao, ids: ids),
    );
    money = DriftMoneyAccountRepository(
      dao: db.moneyDao,
      shop: shops,
      clock: clock,
      ids: ids,
      logger: logger,
    );
    createMoneyAccount = CreateMoneyAccount(money);
    ledger = DriftLedgerRepository(
      dao: db.ledgerDao,
      shop: shops,
      clock: clock,
      ids: ids,
      logger: logger,
    );
    recordCharge = RecordCharge(ledger, clock);
    reverseTransaction = ReverseTransaction(ledger, clock);
    recordPayment = RecordPayment(ledger, clock);
    recordReturn = RecordReturn(ledger, clock);
    createShop = CreateShop(shops);
    saveParty = SaveParty(parties);
    findDuplicates = FindDuplicateParties(parties);
    recordOpeningBalance = RecordOpeningBalance(parties, clock);
  }

  final AppDatabase db;
  final FakeClock clock = FakeClock();
  final SequentialIdGenerator ids = SequentialIdGenerator();
  final RecordingLogger logger = RecordingLogger();

  late final DriftShopRepository shops;
  late final DriftPartyRepository parties;
  late final DriftLedgerRepository ledger;
  late final RecordCharge recordCharge;
  late final ReverseTransaction reverseTransaction;
  late final RecordPayment recordPayment;
  late final RecordReturn recordReturn;
  late final DriftMoneyAccountRepository money;
  late final CreateMoneyAccount createMoneyAccount;
  late final CreateShop createShop;
  late final SaveParty saveParty;
  late final FindDuplicateParties findDuplicates;
  late final RecordOpeningBalance recordOpeningBalance;

  static const CreateShopCommand shopCommand = CreateShopCommand(
    name: 'Test Kirana',
    localeCode: 'en',
    cashAccountName: 'Cash',
  );

  Future<Shop> setUpShop() async =>
      (await createShop(shopCommand)).valueOrNull!;

  /// Saves a party through the use case and returns its ID.
  Future<String> addParty(SavePartyCommand command) async =>
      (await saveParty(command)).valueOrNull!;

  /// The account ID of [partyId] for a role code (`customer`/`supplier`).
  Future<String> accountId(String partyId, String role) async {
    final row = await db
        .customSelect(
          'SELECT id FROM party_accounts WHERE party_id = ? AND role = ?',
          variables: [Variable<String>(partyId), Variable<String>(role)],
        )
        .getSingle();
    return row.read<String>('id');
  }

  /// Posts a ledger line straight into the tables, standing in for the
  /// credit and payment flows that later phases add.
  Future<void> postEntry({
    required String id,
    required String accountId,
    required Money signed,
    String type = 'customer_credit',
    String kind = 'charge',
  }) async {
    final shopId = await shops.requireShopId();
    final at = clock.nowUtc().millisecondsSinceEpoch;
    await db.customStatement(
      'INSERT INTO financial_transactions (id, shop_id, party_account_id, '
      'transaction_type, amount_paise, effective_at, recorded_at, '
      'business_date, operation_id, created_at) '
      "VALUES (?, ?, ?, ?, ?, ?, ?, '2026-11-15', ?, ?)",
      [
        'txn-$id',
        shopId,
        accountId,
        type,
        signed.abs().paise,
        at,
        at,
        'op-$id',
        at,
      ],
    );
    await db.customStatement(
      'INSERT INTO party_ledger_entries (id, shop_id, party_account_id, '
      'transaction_id, entry_kind, amount_paise, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, shopId, accountId, 'txn-$id', kind, signed.paise, at],
    );
    // Raw SQL bypasses Drift's change tracking; tell watch queries.
    db.markTablesUpdated({db.financialTransactions, db.partyLedgerEntries});
  }

  Future<int> count(String table) => db.scalar('SELECT COUNT(*) FROM $table');

  Future<void> dispose() => db.close();
}
