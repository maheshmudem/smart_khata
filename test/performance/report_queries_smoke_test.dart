import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

import '../helpers/test_database.dart';
import '../helpers/test_env.dart';

/// A smoke test for query cost, not a benchmark: with a shop's worth of
/// data, no report query may take seconds on a development machine.
///
/// It guards against a query that quietly becomes quadratic. The real
/// targets (PRD 10.2) are measured on the reference phone; that is on the
/// device checklist.
void main() {
  const parties = 400;
  const entriesPerParty = 30;
  final today = BusinessDate(2026, 11, 15);
  const day = Duration(days: 1);

  late TestEnv env;
  late String anAccount;

  setUpAll(() async {
    env = TestEnv();
    final shop = await env.setUpShop();
    final t0 = env.clock.now.subtract(day * 120).millisecondsSinceEpoch;

    await env.db.transaction(() async {
      for (var p = 0; p < parties; p++) {
        final role = p.isEven ? 'customer' : 'supplier';
        await env.db.exec(
          'INSERT INTO parties (id, shop_id, display_name, normalized_name, '
          'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
          ['p$p', shop.id, 'Party $p', 'party $p', t0, t0],
        );
        await env.db.exec(
          'INSERT INTO party_accounts (id, shop_id, party_id, role, '
          'created_at) VALUES (?, ?, ?, ?, ?)',
          ['a$p', shop.id, 'p$p', role, t0],
        );
        for (var e = 0; e < entriesPerParty; e++) {
          final id = '$p-$e';
          final at = t0 + (e * 4 + p % 4) * day.inMilliseconds;
          final date = BusinessDate.fromInstant(
            DateTime.fromMillisecondsSinceEpoch(at, isUtc: true),
            // The exact zone does not matter for a cost test.
            env.zone,
          ).toIso();
          await env.db.exec(
            'INSERT INTO financial_transactions (id, shop_id, '
            'party_account_id, transaction_type, amount_paise, effective_at, '
            'recorded_at, business_date, operation_id, created_at) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              't$id',
              shop.id,
              'a$p',
              if (role == 'customer')
                'customer_credit'
              else
                'supplier_purchase',
              10000 + e,
              at,
              at,
              date,
              'op$id',
              at,
            ],
          );
          await env.db.exec(
            'INSERT INTO party_ledger_entries (id, shop_id, party_account_id, '
            'transaction_id, entry_kind, amount_paise, due_at, created_at) '
            "VALUES (?, ?, ?, ?, 'charge', ?, ?, ?)",
            [
              'e$id',
              shop.id,
              'a$p',
              't$id',
              10000 + e,
              // Every third entry has a due date a week later.
              if (e % 3 == 0) at + 7 * day.inMilliseconds else null,
              at,
            ],
          );
        }
      }
    });
    anAccount = 'a0';
  });

  tearDownAll(() => env.dispose());

  /// Runs [query] and fails if it takes longer than [limit].
  Future<T> timed<T>(
    String name,
    Future<T> Function() query, {
    Duration limit = const Duration(seconds: 2),
  }) async {
    final watch = Stopwatch()..start();
    final result = await query();
    watch.stop();
    // Shown with `flutter test -r expanded`, for comparison over time.
    printOnFailure('$name: ${watch.elapsedMilliseconds} ms');
    expect(watch.elapsed, lessThan(limit), reason: name);
    return result;
  }

  test('the data is a shop of realistic size', () async {
    expect(await env.count('parties'), parties);
    expect(await env.count('party_ledger_entries'), parties * entriesPerParty);
  });

  test('dashboard, recent entries and reminders', () async {
    final summary = await timed(
      'dashboard',
      () => env.reports.watchDashboard(today).first,
    );
    expect(summary.partyCount, parties);
    expect(summary.customersWithDues, parties ~/ 2);

    final recent = await timed(
      'recent entries',
      () => env.reports.watchRecentActivity(limit: 5).first,
    );
    expect(recent, hasLength(5));

    final due = await timed(
      'reminders',
      () =>
          env.reminders.watchDue(role: PartyRole.customer, today: today).first,
    );
    expect(due, hasLength(parties ~/ 2));
  });

  test('dues and aging for both roles', () async {
    for (final role in PartyRole.values) {
      final report = await timed(
        'aging ${role.code}',
        () => env.reports.outstanding(role: role, today: today),
      );
      expect(report.valueOrNull!.rows, hasLength(parties ~/ 2));
    }
  });

  test('period summary over everything, and a statement', () async {
    final period = await timed(
      'period',
      () => env.reports.period(const DateRange()),
    );
    expect(period.valueOrNull!.creditGiven.isPositive, isTrue);

    final statement = await timed(
      'statement',
      () =>
          env.reports.statement(accountId: anAccount, range: const DateRange()),
    );
    expect(statement.valueOrNull!.lines, hasLength(entriesPerParty));
  });

  test('party list and one ledger', () async {
    final list = await timed(
      'party list',
      () =>
          env.db.customSelect('SELECT COUNT(*) AS c FROM parties').getSingle(),
    );
    expect(list.read<int>('c'), parties);

    final ledger = await timed(
      'ledger',
      () => env.ledger.watchLedger(anAccount, limit: 50).first,
    );
    expect(ledger, hasLength(entriesPerParty));
  });
}
