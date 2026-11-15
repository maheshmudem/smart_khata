import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

void main() {
  late TestEnv env;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
  });
  tearDown(() => env.dispose());

  Future<String> add(
    String name, {
    String? phone,
    Set<PartyRole> roles = const {PartyRole.customer},
    Money? creditLimit,
  }) => env.addParty(
    SavePartyCommand(
      displayName: name,
      primaryPhone: phone,
      roles: roles,
      creditLimit: creditLimit,
    ),
  );

  Future<List<PartyListItem>> list({
    PartyRole role = PartyRole.customer,
    String search = '',
    PartyListFilter filter = PartyListFilter.all,
    PartyListSort sort = PartyListSort.name,
    int limit = 50,
  }) => env.parties
      .watchParties(
        PartyListQuery(
          role: role,
          searchText: search,
          filter: filter,
          sort: sort,
          limit: limit,
        ),
      )
      .first;

  Future<PartyDetail> detail(String partyId) async =>
      (await env.parties.watchParty(partyId).first)!;

  Future<void> opening(
    String partyId, {
    required Money amount,
    String role = 'customer',
    OpeningBalanceDirection direction = OpeningBalanceDirection.owed,
    String operationId = 'op-opening',
    BusinessDate? date,
  }) async {
    final result = await env.recordOpeningBalance(
      RecordOpeningBalanceCommand(
        operationId: operationId,
        partyId: partyId,
        accountId: await env.accountId(partyId, role),
        amount: amount,
        direction: direction,
        date: date ?? BusinessDate(2026, 11, 15),
      ),
    );
    expect(result.failureOrNull, isNull);
  }

  group('creating and editing (SK-0302)', () {
    test('a new customer has one account and a zero balance', () async {
      final id = await add(
        '  Ravi   Kumar ',
        phone: '+91 98765 43210',
        creditLimit: rupees(5000),
      );
      final party = await detail(id);

      expect(party.party.displayName, 'Ravi Kumar');
      expect(party.party.primaryPhone, '+91 98765 43210');
      expect(party.party.creditLimit, rupees(5000));
      expect(party.party.isArchived, isFalse);
      expect(party.roles, {PartyRole.customer});
      expect(party.accounts.single.balance, Money.zero);
      expect(party.accounts.single.balanceKind, BalanceKind.settled);
      expect(party.accounts.single.hasOpeningBalance, isFalse);
    });

    test('a party with both roles gets two separate accounts', () async {
      final id = await add(
        'ABC Stores',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      final party = await detail(id);
      expect(party.roles, {PartyRole.customer, PartyRole.supplier});
      expect(
        party.accountFor(PartyRole.customer)!.accountId,
        isNot(party.accountFor(PartyRole.supplier)!.accountId),
      );
    });

    test('a credit limit is dropped for a supplier-only party', () async {
      final id = await add(
        'Wholesaler',
        roles: {PartyRole.supplier},
        creditLimit: rupees(100),
      );
      expect((await detail(id)).party.creditLimit, isNull);
    });

    test('an invalid party writes nothing', () async {
      final result = await env.saveParty(
        const SavePartyCommand(displayName: ' ', roles: {PartyRole.customer}),
      );
      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(await env.count('parties'), 0);
      expect(await env.count('party_accounts'), 0);
    });

    test('editing changes contact details and can add a role', () async {
      final id = await add('Ravi', phone: '9876543210');
      final customerAccount = await env.accountId(id, 'customer');

      final result = await env.saveParty(
        SavePartyCommand(
          partyId: id,
          displayName: 'Ravi Kumar',
          primaryPhone: '9000000001',
          roles: const {PartyRole.customer, PartyRole.supplier},
        ),
      );
      expect(result.valueOrNull, id);

      final party = await detail(id);
      expect(party.party.displayName, 'Ravi Kumar');
      expect(party.party.primaryPhone, '9000000001');
      expect(party.roles, {PartyRole.customer, PartyRole.supplier});
      // The existing account is the same row, not a replacement.
      expect(party.accountFor(PartyRole.customer)!.accountId, customerAccount);
      expect((await list(search: '9000000001')).single.partyId, id);
      expect(await list(search: '9876543210'), isEmpty);
    });

    test('editing never removes a role or its account', () async {
      final id = await add(
        'ABC',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      await env.saveParty(
        SavePartyCommand(
          partyId: id,
          displayName: 'ABC',
          roles: const {PartyRole.customer},
        ),
      );
      expect((await detail(id)).roles, {
        PartyRole.customer,
        PartyRole.supplier,
      });
    });

    test(
      'editing a party that does not exist is a not-found failure',
      () async {
        final result = await env.saveParty(
          const SavePartyCommand(
            partyId: 'missing',
            displayName: 'Nobody',
            roles: {PartyRole.customer},
          ),
        );
        expect(result.failureOrNull, const NotFoundFailure('party'));
      },
    );

    test('an unknown party is null, not an error', () async {
      expect(await env.parties.watchParty('missing').first, isNull);
    });

    test('getParty reads the party once, with its accounts', () async {
      final id = await add(
        'ABC',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      await env.postEntry(
        id: 'e1',
        accountId: await env.accountId(id, 'supplier'),
        signed: rupees(750),
        type: 'supplier_purchase',
      );

      final found = (await env.parties.getParty(id)).valueOrNull!;
      expect(found, await detail(id));
      expect(found.accountFor(PartyRole.supplier)!.balance, rupees(750));
      expect((await env.parties.getParty('missing')).valueOrNull, isNull);
    });
  });

  group('duplicate phone warning (FR-PAR-004)', () {
    test('finds parties with the same number in any format', () async {
      final ravi = await add('Ravi', phone: '98765 43210');
      await add('Suresh', phone: '9000000001');

      final found = (await env.findDuplicates('+91-9876543210')).valueOrNull!;
      expect(found.map((p) => p.id), [ravi]);
    });

    test('does not report the party being edited', () async {
      final ravi = await add('Ravi', phone: '9876543210');
      final found = (await env.findDuplicates(
        '9876543210',
        excludingPartyId: ravi,
      )).valueOrNull!;
      expect(found, isEmpty);
    });

    test('no phone means no lookup', () async {
      expect((await env.findDuplicates('  ')).valueOrNull, isEmpty);
    });

    test('a duplicate phone is allowed: families share phones', () async {
      await add('Ravi', phone: '9876543210');
      await add('Ravi wife', phone: '9876543210');
      expect(await list(search: '9876543210'), hasLength(2));
    });
  });

  group('list: tabs, search, filter, sort (SK-0303)', () {
    late String ravi;
    late String suresh;
    late String abc;

    setUp(() async {
      ravi = await add('Ravi Kumar', phone: '9876543210');
      suresh = await add('Suresh', phone: '9000000001');
      abc = await add(
        'ABC Stores',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      await add('Wholesale Traders', roles: {PartyRole.supplier});

      await env.postEntry(
        id: 'e1',
        accountId: await env.accountId(ravi, 'customer'),
        signed: rupees(1800),
      );
      env.clock.now = env.clock.now.add(const Duration(hours: 1));
      await env.postEntry(
        id: 'e2',
        accountId: await env.accountId(suresh, 'customer'),
        signed: rupees(-200),
        type: 'customer_payment',
        kind: 'payment',
      );
      await env.postEntry(
        id: 'e3',
        accountId: await env.accountId(abc, 'supplier'),
        signed: rupees(5000),
        type: 'supplier_purchase',
      );
    });

    test('each tab lists its role; a dual-role party is in both', () async {
      expect((await list()).map((p) => p.displayName), [
        'ABC Stores',
        'Ravi Kumar',
        'Suresh',
      ]);
      expect(
        (await list(role: PartyRole.supplier)).map((p) => p.displayName),
        ['ABC Stores', 'Wholesale Traders'],
      );
    });

    test('balances are per role and never netted', () async {
      final asCustomer = (await list()).firstWhere((p) => p.partyId == abc);
      final asSupplier = (await list(
        role: PartyRole.supplier,
      )).firstWhere((p) => p.partyId == abc);

      expect(asCustomer.balance, Money.zero);
      expect(asCustomer.balanceKind, BalanceKind.settled);
      expect(asSupplier.balance, rupees(5000));
      expect(asSupplier.balanceKind, BalanceKind.youOweSupplier);
    });

    test('rows carry balance direction and last entry time', () async {
      final rows = {for (final p in await list()) p.partyId: p};
      expect(rows[ravi]!.balanceKind, BalanceKind.customerOwes);
      expect(rows[ravi]!.balance, rupees(1800));
      expect(rows[suresh]!.balanceKind, BalanceKind.customerAdvance);
      expect(rows[suresh]!.lastActivityAt, env.clock.now);
      expect(rows[abc]!.lastActivityAt, isNull);
    });

    test('search matches part of a name, ignoring case', () async {
      expect((await list(search: 'rAvI')).single.partyId, ravi);
      expect((await list(search: 'kum')).single.partyId, ravi);
      expect(await list(search: 'nobody'), isEmpty);
    });

    test('search matches part of a phone number', () async {
      expect((await list(search: '98765')).single.partyId, ravi);
      expect((await list(search: '+91 98765 43210')).single.partyId, ravi);
    });

    test('search wildcards are treated as plain text', () async {
      expect(await list(search: '%'), isEmpty);
      expect(await list(search: '_'), isEmpty);
    });

    test('outstanding and advance filters use the derived balance', () async {
      expect(
        (await list(filter: PartyListFilter.outstanding)).map((p) => p.partyId),
        [ravi],
      );
      expect(
        (await list(filter: PartyListFilter.advance)).map((p) => p.partyId),
        [suresh],
      );
    });

    test('sorts by highest balance and by most recent entry', () async {
      expect(
        (await list(sort: PartyListSort.highestBalance)).map((p) => p.partyId),
        [ravi, abc, suresh],
      );
      expect(
        (await list(sort: PartyListSort.recentActivity)).map((p) => p.partyId),
        [suresh, ravi, abc],
      );
    });

    test('the list is bounded by its limit', () async {
      expect(await list(limit: 2), hasLength(2));
    });

    test('the list updates by itself when a balance is posted', () async {
      final updates = env.parties
          .watchParties(const PartyListQuery(role: PartyRole.customer))
          .map((rows) => rows.firstWhere((p) => p.partyId == abc).balance);
      final expectation = expectLater(
        updates,
        emitsInOrder([Money.zero, rupees(600)]),
      );
      await pumpEventQueue();
      // A real write through the repository, not a test shortcut.
      await opening(abc, amount: rupees(600));
      await expectation;
    });

    test(
      'party detail updates by itself after an edit and a posting',
      () async {
        final updates = env.parties
            .watchParty(suresh)
            .map(
              (d) => (d!.party.displayName, d.accounts.single.balance),
            );
        final expectation = expectLater(
          updates,
          emitsInOrder([
            ('Suresh', rupees(-200)),
            ('Suresh Babu', rupees(-200)),
            ('Suresh Babu', rupees(-150)),
          ]),
        );
        await pumpEventQueue();
        await env.saveParty(
          SavePartyCommand(
            partyId: suresh,
            displayName: 'Suresh Babu',
            roles: const {PartyRole.customer},
          ),
        );
        await pumpEventQueue();
        await env.postEntry(
          id: 'e9',
          accountId: await env.accountId(suresh, 'customer'),
          signed: rupees(50),
        );
        await expectation;
      },
    );
  });

  group('archive and reactivate (SK-0305, FR-PAR-007)', () {
    test('an archived party keeps its history and balance', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));

      expect(
        (await env.parties.setArchived(id, archived: true)).isOk,
        isTrue,
      );

      final party = await detail(id);
      expect(party.party.isArchived, isTrue);
      expect(party.accounts.single.balance, rupees(300));
      expect(await env.count('party_ledger_entries'), 1);
    });

    test(
      'archived parties leave the main list and appear under Archived',
      () async {
        final id = await add('Ravi');
        await env.parties.setArchived(id, archived: true);

        expect(await list(), isEmpty);
        expect(
          (await list(filter: PartyListFilter.archived)).single.isArchived,
          isTrue,
        );
      },
    );

    test('reactivating restores the party', () async {
      final id = await add('Ravi');
      await env.parties.setArchived(id, archived: true);
      await env.parties.setArchived(id, archived: false);

      expect((await detail(id)).party.isArchived, isFalse);
      expect(await list(), hasLength(1));
    });

    test(
      'both actions are written to the audit log without personal data',
      () async {
        final id = await add('Ravi', phone: '9876543210');
        await env.parties.setArchived(id, archived: true);
        await env.parties.setArchived(id, archived: false);

        final logs = await env.db.select(env.db.auditLogs).get();
        expect(logs.map((l) => l.action), ['archived', 'reactivated']);
        expect(logs.every((l) => l.entityId == id), isTrue);
        expect(logs.every((l) => l.metadataJson == null), isTrue);
      },
    );

    test('archiving an unknown party fails and logs nothing', () async {
      final result = await env.parties.setArchived('missing', archived: true);
      expect(result.failureOrNull, const NotFoundFailure('party'));
      expect(await env.count('audit_logs'), 0);
    });
  });

  group('opening balance (SK-0306, FR-PAR-008)', () {
    test('posts a dated ledger event: customer owes', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));

      final account = (await detail(id)).accounts.single;
      expect(account.balance, rupees(300));
      expect(account.balanceKind, BalanceKind.customerOwes);
      expect(account.totalCharges, rupees(300));
      expect(account.hasOpeningBalance, isTrue);

      final header = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(header.transactionType, TransactionType.openingBalance);
      expect(header.amountPaise, 30000);
      expect(header.businessDate, '2026-11-15');
      expect(header.operationId, 'op-opening');

      final entry =
          (await env.parties.watchRecentEntries(account.accountId).first)
              .single;
      expect(entry.kind, LedgerEntryKind.opening);
      expect(entry.amount, rupees(300));
    });

    test('an advance is posted as a negative entry', () async {
      final id = await add('Suresh');
      await opening(
        id,
        amount: rupees(200),
        direction: OpeningBalanceDirection.advance,
      );

      final account = (await detail(id)).accounts.single;
      expect(account.balance, rupees(-200));
      expect(account.balanceKind, BalanceKind.customerAdvance);
      expect(account.totalSettlements, rupees(200));
      // The header amount is always positive; the entry carries the sign.
      expect(
        (await env.db.select(env.db.financialTransactions).getSingle())
            .amountPaise,
        20000,
      );
    });

    test('a supplier opening is what the shop owes', () async {
      final id = await add('Wholesaler', roles: {PartyRole.supplier});
      await opening(id, amount: rupees(400), role: 'supplier');
      expect(
        (await detail(id)).accounts.single.balanceKind,
        BalanceKind.youOweSupplier,
      );
    });

    test('creates no cash movement (invariant 13)', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));
      expect(await env.count('money_movements'), 0);
    });

    test('a backdated opening is stamped at the start of its day', () async {
      final id = await add('Ravi');
      await opening(
        id,
        amount: rupees(300),
        date: BusinessDate(2026, 4, 1),
      );
      final header = await env.db
          .select(env.db.financialTransactions)
          .getSingle();
      expect(header.businessDate, '2026-04-01');
      // Midnight in India is 18:30 UTC the day before.
      expect(header.effectiveAt, DateTime.utc(2026, 3, 31, 18, 30));
      expect(header.recordedAt, env.clock.now);
    });

    test('each role of a party has its own opening balance', () async {
      final id = await add(
        'ABC',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      await opening(id, amount: rupees(600), operationId: 'op-c');
      await opening(
        id,
        amount: rupees(2000),
        role: 'supplier',
        operationId: 'op-s',
      );

      final party = await detail(id);
      expect(party.accountFor(PartyRole.customer)!.balance, rupees(600));
      expect(party.accountFor(PartyRole.supplier)!.balance, rupees(2000));
    });

    test('a second opening balance on one account is refused', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));

      final result = await env.recordOpeningBalance(
        RecordOpeningBalanceCommand(
          operationId: 'op-second',
          partyId: id,
          accountId: await env.accountId(id, 'customer'),
          amount: rupees(999),
          direction: OpeningBalanceDirection.owed,
          date: BusinessDate(2026, 11, 15),
        ),
      );

      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.openingBalanceAlreadyRecorded),
      );
      expect((await detail(id)).accounts.single.balance, rupees(300));
      expect(await env.count('financial_transactions'), 1);
    });

    test('repeating the same operation posts once (FR-PAY-006)', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));
      await opening(id, amount: rupees(300));

      expect(await env.count('financial_transactions'), 1);
      expect(await env.count('party_ledger_entries'), 1);
      expect((await detail(id)).accounts.single.balance, rupees(300));
    });

    test('an archived party cannot take an opening balance', () async {
      final id = await add('Ravi');
      await env.parties.setArchived(id, archived: true);

      final result = await env.recordOpeningBalance(
        RecordOpeningBalanceCommand(
          operationId: 'op-1',
          partyId: id,
          accountId: await env.accountId(id, 'customer'),
          amount: rupees(300),
          direction: OpeningBalanceDirection.owed,
          date: BusinessDate(2026, 11, 15),
        ),
      );
      expect(
        result.failureOrNull,
        const RuleFailure(RuleViolation.partyArchived),
      );
      expect(await env.count('financial_transactions'), 0);
    });

    test("an account that is not this party's is refused", () async {
      final ravi = await add('Ravi');
      final suresh = await add('Suresh');

      final result = await env.recordOpeningBalance(
        RecordOpeningBalanceCommand(
          operationId: 'op-1',
          partyId: ravi,
          accountId: await env.accountId(suresh, 'customer'),
          amount: rupees(300),
          direction: OpeningBalanceDirection.owed,
          date: BusinessDate(2026, 11, 15),
        ),
      );
      expect(result.failureOrNull, const NotFoundFailure('party_account'));
    });

    test('a failure part-way leaves no rows at all (invariant 11)', () async {
      final id = await add('Ravi');
      // The audit insert is the last step of the transaction.
      await env.db.exec('DROP TABLE audit_logs');

      final result = await env.recordOpeningBalance(
        RecordOpeningBalanceCommand(
          operationId: 'op-1',
          partyId: id,
          accountId: await env.accountId(id, 'customer'),
          amount: rupees(300),
          direction: OpeningBalanceDirection.owed,
          date: BusinessDate(2026, 11, 15),
        ),
      );

      expect(result.failureOrNull, isA<DatabaseFailure>());
      expect(await env.count('financial_transactions'), 0);
      expect(await env.count('party_ledger_entries'), 0);
      expect((await detail(id)).accounts.single.balance, Money.zero);
    });

    test('is recorded in the audit log without the amount', () async {
      final id = await add('Ravi');
      await opening(id, amount: rupees(300));
      final log = await env.db.select(env.db.auditLogs).getSingle();
      expect(log.action, 'opening_balance_recorded');
      expect(log.entityType, 'financial_transaction');
      expect(log.metadataJson, isNull);
    });
  });

  group('history order', () {
    test('newest first by effective time, then entry order', () async {
      final id = await add('Ravi');
      final account = await env.accountId(id, 'customer');
      await env.postEntry(id: 'a', accountId: account, signed: rupees(100));
      await env.postEntry(id: 'b', accountId: account, signed: rupees(200));
      env.clock.now = env.clock.now.add(const Duration(minutes: 1));
      await env.postEntry(id: 'c', accountId: account, signed: rupees(300));

      final entries = await env.parties.watchRecentEntries(account).first;
      expect(entries.map((e) => e.entryId), ['c', 'b', 'a']);
      expect(
        await env.parties.watchRecentEntries(account, limit: 2).first,
        hasLength(2),
      );
    });
  });

  test('a stream error arrives as a failure, never a raw exception', () async {
    await env.db.exec('DROP TABLE reminders');
    await env.db.exec('DROP TABLE ledger_allocation_events');
    await env.db.exec('DROP TABLE party_ledger_entries');

    await expectLater(
      env.parties.watchParties(const PartyListQuery(role: PartyRole.customer)),
      emitsError(
        isA<FailureException>().having(
          (e) => e.failure,
          'failure',
          isA<DatabaseFailure>(),
        ),
      ),
    );
  });
}
