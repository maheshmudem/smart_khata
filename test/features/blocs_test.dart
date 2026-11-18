import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/parties/presentation/bloc/opening_balance_bloc.dart';
import 'package:smart_khata/features/parties/presentation/bloc/parties_list_cubit.dart';
import 'package:smart_khata/features/parties/presentation/bloc/party_form_bloc.dart';
import 'package:smart_khata/features/settings/presentation/more_cubit.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';
import 'package:smart_khata/features/shop/presentation/bloc/shop_form_bloc.dart';

import '../helpers/fake_repositories.dart';

void main() {
  group('PartyFormBloc', () {
    late FakePartyRepository repo;
    late PartyFormBloc bloc;

    setUp(() {
      repo = FakePartyRepository();
      bloc = PartyFormBloc(parties: repo, saveParty: SaveParty(repo));
    });
    tearDown(() => bloc.close());

    const input = PartyInput(name: 'Ravi', roles: {PartyRole.customer});

    test('saves and reports the new party only after the write', () async {
      bloc.add(const PartyFormChanged(input));
      await pumpEventQueue();
      final done = expectLater(
        bloc.stream.map((s) => s.status),
        emitsInOrder([SubmitStatus.submitting, SubmitStatus.success]),
      );
      bloc.add(const PartyFormSubmitted());
      await done;
      expect(bloc.state.savedPartyId, 'p-new');
      expect(repo.created.single.name, 'Ravi');
    });

    test('a double tap while saving posts once', () async {
      repo.gate = Completer<void>();
      bloc
        ..add(const PartyFormChanged(input))
        ..add(const PartyFormSubmitted())
        ..add(const PartyFormSubmitted());
      await pumpEventQueue();
      repo.gate!.complete();
      await pumpEventQueue();
      expect(repo.created, hasLength(1));
    });

    test('a failed save keeps what was typed', () async {
      repo.failNextWrite = const DatabaseFailure();
      bloc
        ..add(const PartyFormChanged(input))
        ..add(const PartyFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.failure);
      expect(bloc.state.failure, const DatabaseFailure());
      expect(bloc.state.input, input);
    });

    test('invalid input shows field errors and writes nothing', () async {
      bloc
        ..add(const PartyFormChanged(PartyInput(roles: {PartyRole.customer})))
        ..add(const PartyFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.errors, {PartyFields.name: ValidationError.required});
      expect(repo.created, isEmpty);
    });

    test('a duplicate phone waits for the owner, then saves anyway', () async {
      repo.phoneMatches = const [PhoneMatch(partyId: 'x', name: 'Ravi')];
      bloc
        ..add(PartyFormChanged(input.copyWith(phone: '9876543210')))
        ..add(const PartyFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.duplicates, hasLength(1));
      expect(repo.created, isEmpty);

      bloc.add(const PartyFormSubmitted(allowDuplicatePhone: true));
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.success);
      expect(repo.created, hasLength(1));
    });

    test('editing locks the roles the party already has', () async {
      final edit = PartyFormBloc(
        parties: FakePartyRepository(details: ravi),
        saveParty: SaveParty(repo),
        partyId: ravi.id,
      )..add(const PartyFormStarted());
      await pumpEventQueue();
      expect(edit.state.lockedRoles, ravi.roles);
      expect(edit.state.input.creditLimitText, '5000');

      edit.add(
        PartyFormChanged(
          edit.state.input.copyWith(roles: {PartyRole.supplier}),
        ),
      );
      await pumpEventQueue();
      expect(edit.state.input.roles, ravi.roles);
      await edit.close();
    });
  });

  group('OpeningBalanceBloc', () {
    late FakePartyRepository repo;
    late OpeningBalanceBloc bloc;

    setUp(() {
      repo = FakePartyRepository();
      bloc = OpeningBalanceBloc(
        post: PostOpeningBalance(repo),
        accountId: 'a-1',
        operationId: 'op-1',
      );
    });
    tearDown(() => bloc.close());

    test('an advance is posted as a negative amount', () async {
      bloc
        ..add(OpeningAmountChanged(Money.fromPaise(50000)))
        ..add(const OpeningDirectionChanged(OpeningDirection.advance));
      await pumpEventQueue();
      expect(bloc.state.signedChange, Money.fromPaise(-50000));

      bloc.add(const OpeningBalanceSubmitted());
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.success);
      expect(repo.postings.single.signedAmount, Money.fromPaise(-50000));
      expect(repo.postings.single.operationId, 'op-1');
    });

    test('an empty amount is a field error and posts nothing', () async {
      bloc.add(const OpeningBalanceSubmitted());
      await pumpEventQueue();
      expect(bloc.state.amountError, ValidationError.amountMustBePositive);
      expect(repo.postings, isEmpty);
    });

    test('an already-posted operation counts as saved', () async {
      repo.failNextWrite = const DuplicateOperationFailure();
      bloc
        ..add(OpeningAmountChanged(Money.fromPaise(100)))
        ..add(const OpeningBalanceSubmitted());
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.success);
    });

    test('a refused posting keeps the amount and explains', () async {
      repo.failNextWrite = const BusinessRuleFailure(
        BusinessRule.openingBalanceAlreadySet,
      );
      bloc
        ..add(OpeningAmountChanged(Money.fromPaise(100)))
        ..add(const OpeningBalanceSubmitted());
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.failure);
      expect(bloc.state.amount, Money.fromPaise(100));
    });
  });

  group('PartiesListCubit', () {
    test('loads, then re-queries on search, filter and role', () async {
      final repo = FakePartyRepository(items: fixtureCustomers);
      final cubit = PartiesListCubit(repo);
      await pumpEventQueue();
      expect(cubit.state.items.valueOrNull, hasLength(2));

      cubit.search('ravi');
      await pumpEventQueue();
      expect(cubit.state.items.valueOrNull!.single.name, 'Ravi Kumar');

      cubit
        ..filter(PartyListFilter.hasDues)
        ..selectRole(PartyRole.supplier);
      await pumpEventQueue();
      expect(cubit.state.query.role, PartyRole.supplier);
      expect(cubit.state.query.filter, PartyListFilter.hasDues);
      expect(cubit.state.items.valueOrNull, isEmpty);
      await cubit.close();
    });

    test('asks for one extra row to know whether more exist', () async {
      final many = [
        for (var i = 0; i < PartiesListCubit.pageSize + 1; i++)
          fixtureCustomers.first,
      ];
      final repo = FakePartyRepository(items: many);
      final cubit = PartiesListCubit(repo);
      await pumpEventQueue();
      expect(cubit.state.hasMore, isTrue);
      expect(
        cubit.state.items.valueOrNull,
        hasLength(PartiesListCubit.pageSize),
      );

      cubit.loadMore();
      await pumpEventQueue();
      expect(cubit.state.hasMore, isFalse);
      expect(repo.queries.last.limit, PartiesListCubit.pageSize * 2 + 1);
      await cubit.close();
    });

    test('a failed load becomes a failure state with retry', () async {
      final repo = FakePartyRepository(listFailure: const DatabaseFailure());
      final cubit = PartiesListCubit(repo);
      await pumpEventQueue();
      expect(
        cubit.state.items,
        const LoadFailed<List<PartyListItem>>(DatabaseFailure()),
      );

      repo.listFailure = null;
      cubit.retry();
      await pumpEventQueue();
      expect(cubit.state.items, isA<Loaded<List<PartyListItem>>>());
      await cubit.close();
    });
  });

  group('ShopFormBloc', () {
    test('setup creates the shop with the opening cash', () async {
      final shops = FakeShopRepository();
      final bloc = ShopFormBloc.setup(
        shops: shops,
        setUpShop: SetUpShop(shops),
        localeCode: 'te',
      )..add(const ShopFormStarted());
      await pumpEventQueue();
      expect(bloc.state.isLoading, isFalse);

      bloc
        ..add(const ShopFormChanged(ShopProfileInput(name: 'Test Kirana')))
        ..add(ShopOpeningCashChanged(Money.fromPaise(200000)))
        ..add(const ShopFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.status, SubmitStatus.success);
      expect(shops.shop?.name, 'Test Kirana');
      await bloc.close();
    });

    test('a resumed setup is prefilled from the saved shop', () async {
      final shops = FakeShopRepository(
        shop: const Shop(
          id: 's-1',
          profile: ShopProfile(name: 'Saved Shop', phone: '9876543210'),
          timeZone: 'Asia/Kolkata',
        ),
      );
      final bloc = ShopFormBloc.edit(
        shops: shops,
        updateShopProfile: UpdateShopProfile(shops),
      )..add(const ShopFormStarted());
      await pumpEventQueue();
      expect(bloc.state.input.name, 'Saved Shop');
      expect(bloc.state.hasExistingShop, isTrue);
      await bloc.close();
    });

    test('a failed save keeps the form and the failure', () async {
      final shops = FakeShopRepository()
        ..failNextWrite = const StorageFullFailure();
      final bloc =
          ShopFormBloc.setup(
              shops: shops,
              setUpShop: SetUpShop(shops),
              localeCode: 'en',
            )
            ..add(const ShopFormStarted())
            ..add(const ShopFormChanged(ShopProfileInput(name: 'Test Kirana')))
            ..add(const ShopFormSubmitted());
      await pumpEventQueue();
      expect(bloc.state.failure, const StorageFullFailure());
      expect(bloc.state.input.name, 'Test Kirana');
      await bloc.close();
    });
  });

  group('MoreCubit', () {
    test('erasing reports success so the app can restart', () async {
      final reset = FakeDataResetRepository();
      final cubit = MoreCubit(shops: FakeShopRepository(), reset: reset);
      await cubit.eraseAllData();
      expect(cubit.state.resetStatus, SubmitStatus.success);
      expect(reset.calls, 1);
      await cubit.close();
    });

    test('a failed erase reports the failure and does not restart', () async {
      final reset = FakeDataResetRepository()
        ..failure = const DatabaseFailure();
      final cubit = MoreCubit(shops: FakeShopRepository(), reset: reset);
      await cubit.eraseAllData();
      expect(cubit.state.resetStatus, SubmitStatus.failure);
      expect(cubit.state.resetFailure, const DatabaseFailure());
      await cubit.close();
    });
  });
}
