import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/balance_kind.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/onboarding/presentation/cubit/shop_setup_cubit.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/parties/presentation/cubit/opening_balance_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_detail_cubit.dart';
import 'package:smart_khata/features/parties/presentation/cubit/party_form_cubit.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

/// Lets pending stream events and futures run.
Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;

  setUp(() => env = TestEnv());
  tearDown(() => env.dispose());

  Future<String> add(
    String name, {
    String? phone,
    Set<PartyRole> roles = const {PartyRole.customer},
  }) => env.addParty(
    SavePartyCommand(displayName: name, primaryPhone: phone, roles: roles),
  );

  group('ShopSetupCubit (WF-002)', () {
    ShopSetupCubit build() =>
        ShopSetupCubit(createShop: env.createShop, shops: env.shops);

    Future<void> submit(ShopSetupCubit cubit) =>
        cubit.submit(localeCode: 'en', cashAccountName: 'Cash');

    test('a blank name shows a field error and keeps what was typed', () async {
      final cubit = build()..ownerNameChanged('Lakshmi');
      addTearDown(cubit.close);

      await submit(cubit);

      expect(cubit.state.errors, {
        CreateShopCommand.nameField: ValidationError.required,
      });
      expect(cubit.state.ownerName, 'Lakshmi');
      expect(cubit.state.status, SubmissionStatus.idle);
      expect(await env.count('shops'), 0);
    });

    test('typing in a field clears its error', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await submit(cubit);
      cubit.nameChanged('Sri Lakshmi Kirana');
      expect(cubit.state.errors, isEmpty);
    });

    test('a valid shop is saved, then success is reported', () async {
      final cubit = build()..nameChanged('Sri Lakshmi Kirana');
      addTearDown(cubit.close);

      final states = <SubmissionStatus>[];
      final sub = cubit.stream.listen((s) => states.add(s.status));
      await submit(cubit);
      await settle();
      await sub.cancel();

      expect(states, [SubmissionStatus.submitting, SubmissionStatus.success]);
      expect(await env.count('shops'), 1);
    });

    test('a save failure is reported and the form stays filled', () async {
      await env.db.exec('DROP TABLE money_movements');
      await env.db.exec('DROP TABLE daily_closings');
      await env.db.exec('DROP TABLE money_accounts');
      final cubit = build()..nameChanged('Sri Lakshmi Kirana');
      addTearDown(cubit.close);

      await submit(cubit);

      expect(cubit.state.status, SubmissionStatus.failure);
      expect(cubit.state.failure, isA<DatabaseFailure>());
      expect(cubit.state.name, 'Sri Lakshmi Kirana');
    });

    test('resumes straight to success when the shop already exists', () async {
      await env.setUpShop();
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.resumeIfShopExists();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(await env.count('shops'), 1);
    });
  });

  group('PartiesListCubit (WF-020)', () {
    PartiesListCubit build() => PartiesListCubit(
      repository: env.parties,
      searchDebounce: Duration.zero,
    );

    setUp(() async {
      await env.setUpShop();
      await add('Ravi Kumar', phone: '9876543210');
      await add('Suresh');
      await add('Wholesaler', roles: {PartyRole.supplier});
    });

    test('loads customers first', () async {
      final cubit = build();
      addTearDown(cubit.close);
      expect(cubit.state.status, LoadStatus.loading);

      await settle();

      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.items.map((p) => p.displayName), [
        'Ravi Kumar',
        'Suresh',
      ]);
      expect(cubit.state.hasMore, isFalse);
    });

    test('switching tab lists suppliers and resets the filter', () async {
      final cubit = build()..filterChanged(PartyListFilter.outstanding);
      addTearDown(cubit.close);
      await settle();

      cubit.roleChanged(PartyRole.supplier);
      await settle();

      expect(cubit.state.query.filter, PartyListFilter.all);
      expect(cubit.state.items.single.displayName, 'Wholesaler');
    });

    test('search narrows the list and can be cleared', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();

      cubit.searchChanged('98765');
      await settle();
      expect(cubit.state.items.single.displayName, 'Ravi Kumar');
      expect(cubit.state.isSearching, isTrue);

      cubit.searchChanged('zzz');
      await settle();
      expect(cubit.state.items, isEmpty);

      cubit.clearSearch();
      await settle();
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.isUnfiltered, isTrue);
    });

    test('a new party appears without reloading', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();

      await add('Anil');
      await settle();

      expect(cubit.state.items.first.displayName, 'Anil');
    });

    test('a load failure is reported and retry recovers', () async {
      // A database with no shop yet: the query cannot be scoped.
      final broken = TestEnv();
      addTearDown(broken.dispose);
      final failing = PartiesListCubit(
        repository: broken.parties,
        searchDebounce: Duration.zero,
      );
      addTearDown(failing.close);
      await settle();

      expect(failing.state.status, LoadStatus.failure);
      expect(failing.state.failure, const NotFoundFailure('shop'));

      await broken.setUpShop();
      failing.retry();
      await settle();
      expect(failing.state.status, LoadStatus.loaded);
    });
  });

  group('PartyFormCubit (WF-021)', () {
    setUp(() => env.setUpShop());

    PartyFormCubit build({
      String? partyId,
      PartyRole role = PartyRole.customer,
    }) => PartyFormCubit(
      repository: env.parties,
      saveParty: env.saveParty,
      findDuplicates: env.findDuplicates,
      partyId: partyId,
      initialRole: role,
    );

    test('a new form starts with the role of the tab it came from', () {
      final cubit = build(role: PartyRole.supplier);
      addTearDown(cubit.close);
      expect(cubit.state.loadStatus, LoadStatus.loaded);
      expect(cubit.state.roles, {PartyRole.supplier});
      expect(cubit.state.isDirty, isFalse);
    });

    test(
      'invalid input shows errors, keeps values and saves nothing',
      () async {
        final cubit = build()
          ..primaryPhoneChanged('123')
          ..roleToggled(PartyRole.customer, selected: false);
        addTearDown(cubit.close);

        await cubit.submit();

        expect(cubit.state.errors.keys, {
          SavePartyCommand.nameField,
          SavePartyCommand.primaryPhoneField,
          SavePartyCommand.rolesField,
        });
        expect(cubit.state.primaryPhone, '123');
        expect(cubit.state.isDirty, isTrue);
        expect(await env.count('parties'), 0);
      },
    );

    test(
      'a second tap on Save after it saved creates no second party',
      () async {
        final cubit = build()..nameChanged('Ravi Kumar');
        addTearDown(cubit.close);

        await cubit.submit();
        // The page is still closing; the owner taps again.
        await cubit.submit();
        await cubit.submit();

        expect(await env.count('parties'), 1);
        expect(cubit.state.status, SubmissionStatus.success);
      },
    );

    test('saves a valid party and reports its ID', () async {
      final cubit = build()
        ..nameChanged('Ravi Kumar')
        ..primaryPhoneChanged('9876543210')
        ..creditLimitChanged(rupees(5000));
      addTearDown(cubit.close);

      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(cubit.state.isDirty, isFalse);
      final detail = await env.parties
          .watchParty(cubit.state.savedPartyId!)
          .first;
      expect(detail!.party.displayName, 'Ravi Kumar');
      expect(detail.party.creditLimit, rupees(5000));
    });

    test(
      'a matching phone pauses the save and offers the existing party',
      () async {
        final existing = await add('Ravi', phone: '98765 43210');
        final cubit = build()
          ..nameChanged('Ravi K')
          ..primaryPhoneChanged('+91 9876543210');
        addTearDown(cubit.close);

        await cubit.submit();

        expect(cubit.state.duplicates.single.id, existing);
        expect(cubit.state.status, SubmissionStatus.idle);
        expect(await env.count('parties'), 1);
      },
    );

    test('the owner may still create a separate party', () async {
      await add('Ravi', phone: '9876543210');
      final cubit = build()
        ..nameChanged('Ravi wife')
        ..primaryPhoneChanged('9876543210');
      addTearDown(cubit.close);

      await cubit.submit();
      await cubit.submit(allowDuplicatePhone: true);

      expect(cubit.state.status, SubmissionStatus.success);
      expect(await env.count('parties'), 2);
    });

    test('dismissing the warning leaves the form as it was', () async {
      await add('Ravi', phone: '9876543210');
      final cubit = build()
        ..nameChanged('Ravi K')
        ..primaryPhoneChanged('9876543210');
      addTearDown(cubit.close);

      await cubit.submit();
      cubit.duplicatesDismissed();

      expect(cubit.state.duplicates, isEmpty);
      expect(cubit.state.displayName, 'Ravi K');
      expect(await env.count('parties'), 1);
    });

    test('editing loads the party and locks its existing roles', () async {
      final id = await add('Ravi', phone: '9876543210');
      final cubit = build(partyId: id);
      addTearDown(cubit.close);
      expect(cubit.state.loadStatus, LoadStatus.loading);

      await settle();

      expect(cubit.state.loadStatus, LoadStatus.loaded);
      expect(cubit.state.displayName, 'Ravi');
      expect(cubit.state.lockedRoles, {PartyRole.customer});

      cubit.roleToggled(PartyRole.customer, selected: false);
      expect(cubit.state.roles, {PartyRole.customer});
    });

    test(
      'editing without changing the phone raises no duplicate warning',
      () async {
        final id = await add('Ravi', phone: '9876543210');
        await add('Ravi wife', phone: '9876543210');
        final cubit = build(partyId: id);
        addTearDown(cubit.close);
        await settle();

        cubit.nameChanged('Ravi Kumar');
        await cubit.submit();

        expect(cubit.state.duplicates, isEmpty);
        expect(cubit.state.status, SubmissionStatus.success);
      },
    );

    test('editing a missing party reports not found', () async {
      final cubit = build(partyId: 'missing');
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.loadStatus, LoadStatus.failure);
      expect(cubit.state.failure, const NotFoundFailure('party'));
    });
  });

  group('PartyDetailCubit (WF-022)', () {
    setUp(() => env.setUpShop());

    test('shows one role at a time and switches without netting', () async {
      final id = await add(
        'ABC',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      await env.postEntry(
        id: 'c',
        accountId: await env.accountId(id, 'customer'),
        signed: rupees(600),
      );
      await env.postEntry(
        id: 's',
        accountId: await env.accountId(id, 'supplier'),
        signed: rupees(2000),
        type: 'supplier_purchase',
      );

      final cubit = PartyDetailCubit(repository: env.parties, partyId: id);
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.selectedRole, PartyRole.customer);
      expect(cubit.state.account!.balance, rupees(600));
      expect(cubit.state.entries.single.entryId, 'c');

      cubit.roleSelected(PartyRole.supplier);
      await settle();

      expect(cubit.state.account!.balance, rupees(2000));
      expect(cubit.state.account!.balanceKind, BalanceKind.youOweSupplier);
      expect(cubit.state.entries.single.entryId, 's');
    });

    test('opens on the role it was asked for', () async {
      final id = await add(
        'ABC',
        roles: {PartyRole.customer, PartyRole.supplier},
      );
      final cubit = PartyDetailCubit(
        repository: env.parties,
        partyId: id,
        initialRole: PartyRole.supplier,
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.selectedRole, PartyRole.supplier);
    });

    test('archive and reactivate update the screen', () async {
      final id = await add('Ravi');
      final cubit = PartyDetailCubit(repository: env.parties, partyId: id);
      addTearDown(cubit.close);
      await settle();

      expect(await cubit.setArchived(archived: true), isTrue);
      await settle();
      expect(cubit.state.detail!.party.isArchived, isTrue);

      expect(await cubit.setArchived(archived: false), isTrue);
      await settle();
      expect(cubit.state.detail!.party.isArchived, isFalse);
    });

    test('a missing party is a not-found failure', () async {
      final cubit = PartyDetailCubit(
        repository: env.parties,
        partyId: 'missing',
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure, const NotFoundFailure('party'));
    });
  });

  group('OpeningBalanceCubit (SK-0306)', () {
    late String partyId;
    late String accountId;
    final today = BusinessDate(2026, 11, 15);

    setUp(() async {
      await env.setUpShop();
      partyId = await add('Ravi');
      accountId = await env.accountId(partyId, 'customer');
    });

    OpeningBalanceCubit build({String operationId = 'op-form'}) =>
        OpeningBalanceCubit(
          repository: env.parties,
          recordOpeningBalance: env.recordOpeningBalance,
          partyId: partyId,
          accountId: accountId,
          operationId: operationId,
          today: today,
        );

    test('loads the account and reviews the resulting balance', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.partyName, 'Ravi');
      expect(cubit.state.resultingBalance, isNull);

      cubit.amountChanged(rupees(300));
      expect(cubit.state.resultingBalance, rupees(300));
      expect(cubit.state.resultingKind, BalanceKind.customerOwes);

      cubit.directionChanged(OpeningBalanceDirection.advance);
      expect(cubit.state.resultingBalance, rupees(-300));
      expect(cubit.state.resultingKind, BalanceKind.customerAdvance);
    });

    test('no amount shows an error and posts nothing', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();

      await cubit.submit();

      expect(cubit.state.errors, {
        RecordOpeningBalanceCommand.amountField:
            ValidationError.amountMustBePositive,
      });
      expect(await env.count('financial_transactions'), 0);
    });

    test('success is reported only after the row is committed', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();
      cubit.amountChanged(rupees(300));

      final seen = <(SubmissionStatus, int)>[];
      final sub = cubit.stream.listen((s) async {
        seen.add((s.status, await env.count('party_ledger_entries')));
      });
      await cubit.submit();
      await settle();
      await sub.cancel();

      expect(seen.last, (SubmissionStatus.success, 1));
      expect(
        seen.where((e) => e.$1 == SubmissionStatus.success && e.$2 == 0),
        isEmpty,
      );
    });

    test('tapping Save twice posts once', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await settle();
      cubit.amountChanged(rupees(300));

      await Future.wait([cubit.submit(), cubit.submit()]);
      await cubit.submit();

      expect(cubit.state.status, SubmissionStatus.success);
      expect(await env.count('financial_transactions'), 1);
      expect(await env.count('party_ledger_entries'), 1);
    });

    test(
      'a failed save keeps the form and a retry posts exactly once',
      () async {
        final cubit = build();
        addTearDown(cubit.close);
        await settle();
        cubit
          ..amountChanged(rupees(300))
          ..noteChanged('From the old book');

        // Fail the last step of the transaction, then repair it.
        await env.db.exec('ALTER TABLE audit_logs RENAME TO audit_logs_hidden');
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.failure);
        expect(cubit.state.failure, isA<DatabaseFailure>());
        expect(cubit.state.amount, rupees(300));
        expect(cubit.state.note, 'From the old book');
        expect(await env.count('financial_transactions'), 0);

        await env.db.exec('ALTER TABLE audit_logs_hidden RENAME TO audit_logs');
        await cubit.submit();

        expect(cubit.state.status, SubmissionStatus.success);
        expect(await env.count('financial_transactions'), 1);
      },
    );

    test('a second opening balance is refused with a clear reason', () async {
      final first = build(operationId: 'op-1');
      addTearDown(first.close);
      await settle();
      first.amountChanged(rupees(300));
      await first.submit();

      final second = build(operationId: 'op-2');
      addTearDown(second.close);
      await settle();
      second.amountChanged(rupees(500));
      await second.submit();

      expect(second.state.status, SubmissionStatus.failure);
      expect(
        second.state.failure,
        const RuleFailure(RuleViolation.openingBalanceAlreadyRecorded),
      );
    });
  });
}
