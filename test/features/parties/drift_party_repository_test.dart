import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/parties_dao.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/data/drift_party_repository.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

/// Fails on the last write of an opening balance, to prove the rollback.
class _FailingAuditPartiesDao extends PartiesDao {
  _FailingAuditPartiesDao(super.attachedDatabase);

  @override
  Future<void> insertAudit(db.AuditLogsCompanion row) =>
      throw StateError('simulated late failure');
}

void main() {
  late db.AppDatabase database;
  late SequenceIdGenerator ids;

  setUp(() async {
    database = createTestDatabase();
    ids = SequenceIdGenerator();
    await database.seedShop();
  });
  tearDown(() => database.close());

  DriftPartyRepository repo({PartiesDao? dao}) => DriftPartyRepository(
    database: database,
    parties: dao ?? database.partiesDao,
    shops: database.shopDao,
    clock: FakeClock(),
    ids: ids,
    logger: RecordingLogger(),
  );

  Future<int> count(String table) =>
      database.scalar('SELECT COUNT(*) FROM $table');

  PartyDraft draft(
    String name, {
    Set<PartyRole> roles = const {PartyRole.customer},
    String? phone,
  }) => PartyDraft(name: name, roles: roles, phone: phone);

  Future<String> create(
    String name, {
    Set<PartyRole> roles = const {PartyRole.customer},
    String? phone,
  }) async => (await repo().create(
    draft(name, roles: roles, phone: phone),
  )).valueOrNull!;

  Future<PartyDetails> details(String partyId) async =>
      (await repo().watchDetails(partyId).first).valueOrNull!;

  Future<List<PartyListItem>> list(PartyListQuery query) async =>
      (await repo().watchList(query).first).valueOrNull!;

  group('create and update', () {
    test('a dual-role party gets two separate accounts', () async {
      final id = await create(
        'Anil Traders',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      final party = await details(id);

      expect(party.roles, {PartyRole.customer, PartyRole.supplier});
      expect(await count('party_accounts'), 2);
      expect(party.accounts.every((a) => a.balance.isZero), isTrue);
    });

    test('update adds a new role and never removes an existing one', () async {
      final id = await create('Ravi');
      await repo().update(
        id,
        draft('Ravi Kumar', roles: {PartyRole.supplier}),
      );
      final party = await details(id);

      expect(party.name, 'Ravi Kumar');
      expect(party.roles, {PartyRole.customer, PartyRole.supplier});
    });

    test('updating a missing party is a not-found failure', () async {
      final result = await repo().update('nope', draft('X'));
      expect(result.failureOrNull, const NotFoundFailure('party'));
    });

    test('a credit limit is kept only for the customer role', () async {
      final id = (await repo().create(
        PartyDraft(
          name: 'Supplier Only',
          roles: const {PartyRole.supplier},
          creditLimit: Money.fromPaise(500000),
        ),
      )).valueOrNull!;
      expect((await details(id)).creditLimit, isNull);
    });
  });

  group('duplicate phone (FR-PAR-004)', () {
    test('finds other parties with the same phone', () async {
      final ravi = await create('Ravi', phone: '9876543210');
      final matches = await repo().findByPhone('9876543210');
      expect(matches.valueOrNull, [PhoneMatch(partyId: ravi, name: 'Ravi')]);
    });

    test('ignores the party being edited', () async {
      final ravi = await create('Ravi', phone: '9876543210');
      final matches = await repo().findByPhone(
        '9876543210',
        excludePartyId: ravi,
      );
      expect(matches.valueOrNull, isEmpty);
    });

    test('SaveParty warns first and saves only when allowed', () async {
      await create('Ravi', phone: '9876543210');
      final save = SaveParty(repo());
      const input = PartyInput(
        name: 'Ravi brother',
        roles: {PartyRole.customer},
        phone: '98765 43210',
      );

      final warned = await save(const SavePartyCommand(input: input));
      expect(warned.valueOrNull, isA<DuplicatePhoneFound>());
      expect(await count('parties'), 1);

      final saved = await save(
        const SavePartyCommand(input: input, allowDuplicatePhone: true),
      );
      expect(saved.valueOrNull, isA<PartySaved>());
      expect(await count('parties'), 2);
    });
  });

  group('list', () {
    test('search matches name or phone, and filters by balance', () async {
      final ravi = await create('Ravi Kumar', phone: '9876543210');
      final suresh = await create('Suresh');
      final ravisAccount = (await details(ravi)).accounts.single.accountId;
      final sureshAccount = (await details(suresh)).accounts.single.accountId;
      await repo().postOpeningBalance(
        OpeningBalancePosting(
          accountId: ravisAccount,
          signedAmount: Money.fromPaise(180000),
          operationId: 'op-1',
        ),
      );
      await repo().postOpeningBalance(
        OpeningBalancePosting(
          accountId: sureshAccount,
          signedAmount: Money.fromPaise(-20000),
          operationId: 'op-2',
        ),
      );

      const customers = PartyListQuery(role: PartyRole.customer);
      expect((await list(customers)).map((p) => p.name), [
        'Ravi Kumar',
        'Suresh',
      ]);
      expect(
        (await list(customers.copyWith(search: 'KUMAR'))).single.name,
        'Ravi Kumar',
      );
      expect(
        (await list(customers.copyWith(search: '43210'))).single.name,
        'Ravi Kumar',
      );
      expect(
        (await list(
          customers.copyWith(filter: PartyListFilter.hasDues),
        )).single.balance,
        Money.fromPaise(180000),
      );
      expect(
        (await list(
          customers.copyWith(filter: PartyListFilter.advance),
        )).single.name,
        'Suresh',
      );
      expect(await list(customers.copyWith(search: 'zzz')), isEmpty);
    });

    test('a typed % in search matches literally, not as a wildcard', () async {
      await create('Ravi');
      expect(
        await list(const PartyListQuery(role: PartyRole.customer, search: '%')),
        isEmpty,
      );
    });

    test('the supplier tab shows only supplier accounts', () async {
      await create('Customer Only');
      await create('Both', roles: {PartyRole.customer, PartyRole.supplier});
      final suppliers = await list(
        const PartyListQuery(role: PartyRole.supplier),
      );
      expect(suppliers.map((p) => p.name), ['Both']);
    });

    test('archived parties move to the archived filter', () async {
      final id = await create('Old Customer');
      await repo().setArchived(id, archived: true);
      const query = PartyListQuery(role: PartyRole.customer);

      expect(await list(query), isEmpty);
      expect(
        (await list(
          query.copyWith(filter: PartyListFilter.archived),
        )).single.isArchived,
        isTrue,
      );

      await repo().setArchived(id, archived: false);
      expect((await list(query)).single.name, 'Old Customer');
    });
  });

  group('opening balance (FR-PAR-008, invariant 13)', () {
    late String accountId;

    setUp(() async {
      final id = await create('Ravi');
      accountId = (await details(id)).accounts.single.accountId;
    });

    OpeningBalancePosting posting(int paise, {String op = 'op-1'}) =>
        OpeningBalancePosting(
          accountId: accountId,
          signedAmount: Money.fromPaise(paise),
          operationId: op,
        );

    test('posts a header, a signed entry and an audit row; no cash', () async {
      final result = await repo().postOpeningBalance(posting(30000));

      expect(result.isOk, isTrue);
      expect(await count('financial_transactions'), 1);
      expect(await count('party_ledger_entries'), 1);
      expect(await count('money_movements'), 0);
      expect(
        await database.scalar(
          "SELECT COUNT(*) FROM audit_logs WHERE action = 'opening_balance_posted'",
        ),
        1,
      );
      final account = (await list(
        const PartyListQuery(role: PartyRole.customer),
      )).single;
      expect(account.balance, Money.fromPaise(30000));
    });

    test('an advance is posted as a negative entry', () async {
      await repo().postOpeningBalance(posting(-50000));
      expect(
        await database.scalar('SELECT amount_paise FROM party_ledger_entries'),
        -50000,
      );
      expect(
        await database.scalar(
          'SELECT amount_paise FROM financial_transactions',
        ),
        50000,
      );
    });

    test('a repeated operation ID posts once', () async {
      await repo().postOpeningBalance(posting(30000));
      final again = await repo().postOpeningBalance(posting(30000));

      expect(again.failureOrNull, const DuplicateOperationFailure());
      expect(await count('party_ledger_entries'), 1);
    });

    test('a second opening balance on the account is refused', () async {
      await repo().postOpeningBalance(posting(30000));
      final second = await repo().postOpeningBalance(
        posting(10000, op: 'op-2'),
      );

      expect(
        second.failureOrNull,
        const BusinessRuleFailure(BusinessRule.openingBalanceAlreadySet),
      );
      expect(await count('party_ledger_entries'), 1);
    });

    test('an archived party takes no opening balance', () async {
      final partyId = await database
          .customSelect(
            'SELECT party_id FROM party_accounts WHERE id = ?',
            variables: [Variable.withString(accountId)],
          )
          .getSingle()
          .then((r) => r.read<String>('party_id'));
      await repo().setArchived(partyId, archived: true);

      final result = await repo().postOpeningBalance(posting(30000));
      expect(
        result.failureOrNull,
        const BusinessRuleFailure(BusinessRule.partyArchived),
      );
      expect(await count('financial_transactions'), 0);
    });

    test('a failure on the last step leaves no rows at all', () async {
      final result = await repo(
        dao: _FailingAuditPartiesDao(database),
      ).postOpeningBalance(posting(30000));

      expect(result, isA<Err<void>>());
      expect(await count('financial_transactions'), 0);
      expect(await count('party_ledger_entries'), 0);
    });

    test('the use case rejects a zero or missing amount', () async {
      final use = PostOpeningBalance(repo());
      for (final amount in [null, Money.zero]) {
        final result = await use(
          PostOpeningBalanceCommand(
            accountId: accountId,
            amount: amount,
            direction: OpeningDirection.owed,
            operationId: 'op-x',
          ),
        );
        expect(result.failureOrNull, isA<ValidationFailure>());
      }
      expect(await count('financial_transactions'), 0);
    });
  });

  group('validateParty', () {
    test('requires a name and a role', () {
      expect(
        validateParty(const PartyInput()).failureOrNull,
        const ValidationFailure({
          PartyFields.name: ValidationError.required,
          PartyFields.roles: ValidationError.required,
        }),
      );
    });

    test('rejects a bad phone and a bad credit limit', () {
      final result = validateParty(
        const PartyInput(
          name: 'Ravi',
          roles: {PartyRole.customer},
          phone: '12',
          creditLimitText: '12.345',
        ),
      );
      expect(
        result.failureOrNull,
        const ValidationFailure({
          PartyFields.phone: ValidationError.invalidPhone,
          PartyFields.creditLimit: ValidationError.invalidAmount,
        }),
      );
    });

    test('accepts a valid party and parses the credit limit', () {
      final result = validateParty(
        const PartyInput(
          name: ' Ravi ',
          roles: {PartyRole.customer},
          phone: '+91 98765 43210',
          creditLimitText: '5,000',
        ),
      );
      expect(result.valueOrNull?.name, 'Ravi');
      expect(result.valueOrNull?.phone, '9876543210');
      expect(result.valueOrNull?.creditLimit, Money.fromPaise(500000));
    });
  });
}
