import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/dashboard/data/drift_dashboard_repository.dart';
import 'package:smart_khata/features/dashboard/domain/dashboard.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late db.AppDatabase database;

  setUp(() => database = createTestDatabase());
  tearDown(() => database.close());

  DriftDashboardRepository repo() => DriftDashboardRepository(
    dashboard: database.dashboardDao,
    shops: database.shopDao,
    // 15 Nov 2026, 12:00 IST.
    clock: FakeClock(DateTime.utc(2026, 11, 15, 6, 30)),
    logger: RecordingLogger(),
  );

  Future<DashboardSummary> summary() async =>
      (await repo().watchSummary().first).valueOrNull!;

  test('before setup there is no shop to summarise', () async {
    final result = await repo().watchSummary().first;
    expect(result.failureOrNull, const NotFoundFailure('shop'));
  });

  test('a new shop has an empty dashboard', () async {
    await database.seedShop();
    final s = await summary();
    expect(s.shopName, 'Test Kirana');
    expect(s.today.toIso(), '2026-11-15');
    expect(s.hasNoParties, isTrue);
    expect(s.customers, RoleTotals.empty);
    expect(s.recent, isEmpty);
  });

  test('owed and advances are separate; roles are never netted', () async {
    await database.seedShop();
    await database.seedParty(id: 'p1');
    await database.seedParty(id: 'p2', name: 'Suresh');
    await database.seedAccount(id: 'c1', partyId: 'p1');
    await database.seedAccount(id: 's1', partyId: 'p1', role: 'supplier');
    await database.seedAccount(id: 'c2', partyId: 'p2');
    // Test plan §5.3: ₹300 + ₹1,500 + ₹500 − ₹1,000 = ₹1,300.
    await database.seedPosting(id: 'e1', accountId: 'c1', signedPaise: 30000);
    await database.seedPosting(id: 'e2', accountId: 'c1', signedPaise: 150000);
    await database.seedPosting(id: 'e3', accountId: 'c1', signedPaise: 50000);
    await database.seedPosting(
      id: 'e4',
      accountId: 'c1',
      signedPaise: -100000,
      type: 'customer_payment',
      kind: 'payment',
    );
    // A ₹200 customer advance.
    await database.seedPosting(
      id: 'e5',
      accountId: 'c2',
      signedPaise: -20000,
      type: 'customer_payment',
      kind: 'payment',
    );
    // The same party owes as a supplier: ₹400.
    await database.seedPosting(
      id: 'e6',
      accountId: 's1',
      signedPaise: 40000,
      type: 'supplier_purchase',
    );

    final s = await summary();
    expect(s.customers.owed, Money.fromPaise(130000));
    expect(s.customers.advance, Money.fromPaise(20000));
    expect(s.customers.accountsWithDues, 1);
    expect(s.customers.accounts, 2);
    expect(s.suppliers.owed, Money.fromPaise(40000));
    // Seeded rows are dated 2026-11-15, today in the shop zone.
    expect(s.todayCredit, Money.fromPaise(230000));
    expect(s.todayCollections, Money.fromPaise(120000));
    expect(s.recent, hasLength(DriftDashboardRepository.recentLimit));
  });
}
