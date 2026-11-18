import 'dart:async';

import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';
import 'package:smart_khata/features/ledger/domain/ledger.dart';
import 'package:smart_khata/features/parties/domain/party.dart';
import 'package:smart_khata/features/parties/domain/party_repository.dart';
import 'package:smart_khata/features/settings/domain/data_reset_repository.dart';
import 'package:smart_khata/features/shop/domain/shop.dart';
import 'package:smart_khata/features/shop/domain/shop_repository.dart';

/// Fixture parties from the test plan §5.3. No real names or numbers.
final ravi = PartyDetails(
  id: 'p-ravi',
  name: 'Ravi Kumar',
  status: PartyStatus.active,
  phone: '9876543210',
  creditLimit: Money.fromPaise(500000),
  accounts: [
    PartyAccountSummary(
      accountId: 'a-ravi-c',
      role: PartyRole.customer,
      balance: Money.fromPaise(130000),
      hasOpeningBalance: true,
    ),
    const PartyAccountSummary(
      accountId: 'a-ravi-s',
      role: PartyRole.supplier,
      balance: Money.zero,
      hasOpeningBalance: false,
    ),
  ],
);

final List<PartyListItem> fixtureCustomers = [
  PartyListItem(
    partyId: 'p-ravi',
    accountId: 'a-ravi-c',
    name: 'Ravi Kumar',
    phone: '9876543210',
    role: PartyRole.customer,
    balance: Money.fromPaise(130000),
    isArchived: false,
  ),
  PartyListItem(
    partyId: 'p-suresh',
    accountId: 'a-suresh-c',
    name: 'Suresh',
    role: PartyRole.customer,
    balance: Money.fromPaise(-20000),
    isArchived: false,
  ),
];

/// Party repository backed by fixed data. Set [failNextWrite] or
/// [phoneMatches] to drive the unhappy paths.
class FakePartyRepository implements PartyRepository {
  FakePartyRepository({
    this.items,
    this.details,
    this.listFailure,
  });

  List<PartyListItem>? items;
  PartyDetails? details;
  Failure? listFailure;
  Failure? failNextWrite;
  List<PhoneMatch> phoneMatches = const [];
  final List<PartyListQuery> queries = [];
  final List<PartyDraft> created = [];
  final List<OpeningBalancePosting> postings = [];
  int archiveCalls = 0;

  /// Completes writes only when the test says so, to observe "saving".
  Completer<void>? gate;

  Future<Result<T>> _write<T>(T value) async {
    await gate?.future;
    final failure = failNextWrite;
    failNextWrite = null;
    return failure == null ? Ok(value) : Err(failure);
  }

  @override
  Stream<Result<List<PartyListItem>>> watchList(PartyListQuery query) {
    queries.add(query);
    final failure = listFailure;
    if (failure != null) return Stream.value(Err(failure));
    final all = (items ?? const <PartyListItem>[])
        .where((i) => i.role == query.role)
        .where(
          (i) =>
              query.search.isEmpty ||
              i.name.toLowerCase().contains(query.search.toLowerCase()),
        )
        .toList();
    return Stream.value(Ok(all.take(query.limit).toList()));
  }

  @override
  Stream<Result<PartyDetails?>> watchDetails(String partyId) =>
      Stream.value(Ok(details?.id == partyId ? details : null));

  @override
  Future<Result<List<PhoneMatch>>> findByPhone(
    String normalizedPhone, {
    String? excludePartyId,
  }) async => Ok(phoneMatches);

  @override
  Future<Result<String>> create(PartyDraft draft) {
    created.add(draft);
    return _write('p-new');
  }

  @override
  Future<Result<void>> update(String partyId, PartyDraft draft) =>
      _write<void>(null);

  @override
  Future<Result<void>> setArchived(String partyId, {required bool archived}) {
    archiveCalls++;
    return _write<void>(null);
  }

  @override
  Future<Result<void>> postOpeningBalance(OpeningBalancePosting posting) {
    postings.add(posting);
    return _write<void>(null);
  }
}

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository(this.result);

  Result<DashboardSummary> result;

  @override
  Stream<Result<DashboardSummary>> watchSummary() => Stream.value(result);
}

DashboardSummary dashboardFixture({bool empty = false}) => DashboardSummary(
  shopName: 'Test Kirana',
  today: BusinessDate(2026, 11, 15),
  customers: empty
      ? RoleTotals.empty
      : RoleTotals(
          owed: Money.fromPaise(130000),
          advance: Money.fromPaise(20000),
          accountsWithDues: 1,
          accounts: 2,
        ),
  suppliers: empty
      ? RoleTotals.empty
      : RoleTotals(
          owed: Money.fromPaise(140000),
          advance: Money.zero,
          accountsWithDues: 1,
          accounts: 1,
        ),
  todayCredit: Money.zero,
  todayCollections: Money.zero,
  todayExpenses: Money.zero,
  recent: empty
      ? const []
      : [
          ActivityItem(
            partyId: 'p-ravi',
            partyName: 'Ravi Kumar',
            role: PartyRole.customer,
            type: TransactionType.openingBalance,
            signedAmount: Money.fromPaise(30000),
            effectiveAt: DateTime.utc(2026, 11, 15, 6),
          ),
        ],
);

class FakeShopRepository implements ShopRepository {
  FakeShopRepository({this.shop});

  Shop? shop;
  Failure? failNextWrite;
  int createCalls = 0;

  @override
  Future<Result<Shop?>> getShop() async => Ok(shop);

  @override
  Stream<Result<Shop?>> watchShop() => Stream.value(Ok(shop));

  @override
  Future<Result<Shop>> createShop({
    required ShopProfile profile,
    required String localeCode,
    required Money openingCash,
  }) async {
    createCalls++;
    final failure = failNextWrite;
    failNextWrite = null;
    if (failure != null) return Err(failure);
    return Ok(
      shop = Shop(id: 's-1', profile: profile, timeZone: 'Asia/Kolkata'),
    );
  }

  @override
  Future<Result<Shop>> updateProfile(String shopId, ShopProfile profile) async {
    final failure = failNextWrite;
    failNextWrite = null;
    if (failure != null) return Err(failure);
    return Ok(
      shop = Shop(id: shopId, profile: profile, timeZone: 'Asia/Kolkata'),
    );
  }
}

/// Ledger with fixed lines; [post] records what it was asked to post.
class FakeLedgerRepository implements LedgerRepository {
  FakeLedgerRepository({this.lines = const []});

  List<LedgerLine> lines;
  final List<EntryPosting> posted = [];
  Failure? failNextPost;

  @override
  Stream<Result<List<LedgerLine>>> watchLedger(String accountId, int limit) =>
      Stream.value(Ok(lines.take(limit).toList()));

  @override
  Future<Result<PostedEntry>> post(EntryPosting posting) async {
    posted.add(posting);
    final failure = failNextPost;
    failNextPost = null;
    if (failure != null) return Err(failure);
    return Ok(PostedEntry(balanceAfter: posting.signedAmount));
  }
}

/// §5.3 customer fixture as ledger lines, newest first.
final List<LedgerLine> fixtureLedger = [
  LedgerLine(
    entryId: 'e4',
    type: TransactionType.customerPayment,
    signedAmount: Money.fromPaise(-100000),
    runningBalance: Money.fromPaise(130000),
    effectiveAt: DateTime.utc(2026, 11, 15, 6),
    method: PaymentMethod.upi,
  ),
  LedgerLine(
    entryId: 'e3',
    type: TransactionType.customerCredit,
    signedAmount: Money.fromPaise(50000),
    runningBalance: Money.fromPaise(230000),
    effectiveAt: DateTime.utc(2026, 11, 14, 6),
    description: 'Rice and dal',
    dueAt: DateTime.utc(2026, 11, 30),
  ),
  LedgerLine(
    entryId: 'e1',
    type: TransactionType.openingBalance,
    signedAmount: Money.fromPaise(30000),
    runningBalance: Money.fromPaise(30000),
    effectiveAt: DateTime.utc(2026, 11, 1, 6),
  ),
];

class FakeDataResetRepository implements DataResetRepository {
  Failure? failure;
  int calls = 0;

  @override
  Future<Result<void>> eraseAllData() async {
    calls++;
    final f = failure;
    return f == null ? const Ok(null) : Err(f);
  }
}
