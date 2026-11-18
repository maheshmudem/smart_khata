import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/load_state.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/parties/domain/party_use_cases.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_use_cases.dart';

import '../helpers/fake_repositories.dart';

/// BLoC states hold these values and only re-render when they differ, so
/// value equality is part of the contract.
void main() {
  test('domain values compare by value', () {
    final values = <Object Function()>[
      () => ravi,
      () => fixtureCustomers.first,
      () => const PartyListQuery(role: PartyRole.customer, search: 'r'),
      () => const PartyDraft(name: 'Ravi', roles: {PartyRole.customer}),
      () => const PhoneMatch(partyId: 'p', name: 'Ravi'),
      () => OpeningBalancePosting(
        accountId: 'a',
        signedAmount: Money.fromPaise(1),
        operationId: 'op',
      ),
      () => const PartyInput(name: 'Ravi'),
      () => const SavePartyCommand(input: PartyInput()),
      () => const PartySaved('p'),
      () => const DuplicatePhoneFound([]),
      () => PostOpeningBalanceCommand(
        accountId: 'a',
        amount: Money.fromPaise(1),
        direction: OpeningDirection.owed,
        operationId: 'op',
      ),
      () => const Shop(
        id: 's',
        profile: ShopProfile(name: 'Test Kirana'),
        timeZone: 'Asia/Kolkata',
      ),
      () => const ShopProfileInput(name: 'Test Kirana'),
      () => const SetUpShopCommand(
        profile: ShopProfileInput(),
        localeCode: 'en',
      ),
      dashboardFixture,
      () => RoleTotals.empty,
      () => const BusinessRuleFailure(BusinessRule.partyArchived),
      () => const ConstraintFailure(ConstraintKind.unique),
      () => const Loading<int>(),
      () => const Loaded(1),
      () => const LoadFailed<int>(UnexpectedFailure()),
    ];
    for (final make in values) {
      final a = make();
      final b = make();
      expect(a, b, reason: '${a.runtimeType}');
      expect(a.hashCode, b.hashCode, reason: '${a.runtimeType}');
    }
  });

  test('party details helpers', () {
    expect(ravi.isArchived, isFalse);
    expect(ravi.account(PartyRole.supplier)?.accountId, 'a-ravi-s');
    final customerOnly = PartyDetails(
      id: 'x',
      name: 'X',
      status: PartyStatus.archived,
      accounts: [ravi.accounts.first],
    );
    expect(customerOnly.account(PartyRole.supplier), isNull);
    expect(customerOnly.isArchived, isTrue);
    expect(dashboardFixture(empty: true).hasNoParties, isTrue);
  });

  test('copyWith changes only what it is given', () {
    const query = PartyListQuery(role: PartyRole.customer);
    expect(
      query.copyWith(filter: PartyListFilter.advance),
      const PartyListQuery(
        role: PartyRole.customer,
        filter: PartyListFilter.advance,
      ),
    );
    const input = PartyInput(name: 'Ravi');
    expect(
      input.copyWith(
        alternatePhone: '1',
        address: 'a',
        locality: 'l',
        notes: 'n',
        creditLimitText: '5',
      ),
      const PartyInput(
        name: 'Ravi',
        alternatePhone: '1',
        address: 'a',
        locality: 'l',
        notes: 'n',
        creditLimitText: '5',
      ),
    );
    const profile = ShopProfileInput(name: 'A');
    expect(
      profile.copyWith(ownerName: 'o', address: 'a', locality: 'l'),
      const ShopProfileInput(
        name: 'A',
        ownerName: 'o',
        address: 'a',
        locality: 'l',
      ),
    );
    expect(const Loaded(3).valueOrNull, 3);
    expect(const Loading<int>().valueOrNull, isNull);
    expect(
      LoadState.from(const Err<int>(UnexpectedFailure())),
      isA<LoadFailed<int>>(),
    );
  });

  group('use cases', () {
    test('editing a party goes to update, not create', () async {
      final repo = FakePartyRepository();
      final result = await SaveParty(repo).call(
        const SavePartyCommand(
          partyId: 'p-1',
          input: PartyInput(name: 'Ravi', roles: {PartyRole.customer}),
        ),
      );
      expect(result.valueOrNull, const PartySaved('p-1'));
      expect(repo.created, isEmpty);
    });

    test('a failed duplicate lookup is returned, nothing saved', () async {
      final repo = _FailingLookupRepository();
      final result = await SaveParty(repo).call(
        const SavePartyCommand(
          input: PartyInput(
            name: 'Ravi',
            roles: {PartyRole.customer},
            phone: '9876543210',
          ),
        ),
      );
      expect(result.failureOrNull, const DatabaseFailure());
      expect(repo.created, isEmpty);
    });

    test('updating the shop validates first', () async {
      final shops = FakeShopRepository();
      final bad = await UpdateShopProfile(
        shops,
      ).call('s-1', const ShopProfileInput());
      expect(bad.failureOrNull, isA<ValidationFailure>());

      final good = await UpdateShopProfile(
        shops,
      ).call('s-1', const ShopProfileInput(name: 'New'));
      expect(good.valueOrNull?.name, 'New');
    });
  });
}

class _FailingLookupRepository extends FakePartyRepository {
  @override
  Future<Result<List<PhoneMatch>>> findByPhone(
    String normalizedPhone, {
    String? excludePartyId,
  }) async => const Err(DatabaseFailure());
}
