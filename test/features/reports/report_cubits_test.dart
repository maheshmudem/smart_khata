import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/app/localization/locale_cubit.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/date_range.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/errors/failure.dart';
import 'package:smart_khata/core/export/csv_writer.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/reports/presentation/report_cubits.dart';
import 'package:smart_khata/features/reports/presentation/report_exports.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

Future<void> settle() => pumpEventQueue(times: 50);

void main() {
  late TestEnv env;
  late String cash;
  final today = BusinessDate(2026, 11, 15);
  var op = 0;

  setUp(() async {
    env = TestEnv();
    await env.setUpShop();
    cash = (await env.money.getAccounts()).valueOrNull!.single.id;
  });
  tearDown(() => env.dispose());

  Future<(String, String)> party(
    String name, {
    PartyRole role = PartyRole.customer,
  }) async {
    final id = await env.addParty(
      SavePartyCommand(displayName: name, roles: {role}),
    );
    return (id, await env.accountId(id, role.code));
  }

  Future<void> charge(
    (String, String) who,
    int amount, {
    PartyRole role = PartyRole.customer,
    BusinessDate? date,
    String? description,
  }) async {
    env.clock.now = env.clock.now.add(const Duration(minutes: 1));
    final result = await env.recordCharge(
      RecordChargeCommand(
        operationId: 'chg-${op++}',
        role: role,
        partyId: who.$1,
        accountId: who.$2,
        amount: rupees(amount),
        date: date ?? today,
        description: description,
      ),
    );
    expect(result.failureOrNull, isNull);
  }

  Future<void> pay((String, String) who, int amount) async {
    env.clock.now = env.clock.now.add(const Duration(minutes: 1));
    final result = await env.recordPayment(
      RecordPaymentCommand(
        operationId: 'pay-${op++}',
        role: PartyRole.customer,
        partyId: who.$1,
        accountId: who.$2,
        amount: rupees(amount),
        date: today,
        splits: [
          PaymentSplit(
            method: PaymentMethod.cash,
            moneyAccountId: cash,
            amount: null,
          ),
        ],
      ),
    );
    expect(result.failureOrNull, isNull);
  }

  test('a period is a shortcut or two chosen dates', () {
    final preset = PeriodSelection.preset(DateRangePreset.yesterday, today);
    expect(preset.isCustom, isFalse);
    expect(
      preset.range,
      DateRange(start: today.addDays(-1), end: today.addDays(-1)),
    );
    expect(preset, PeriodSelection.preset(DateRangePreset.yesterday, today));

    final custom = PeriodSelection.custom(preset.range);
    expect(custom.isCustom, isTrue);
    expect(custom, isNot(preset));
  });

  group('DashboardCubit (WF-010)', () {
    DashboardCubit build({BusinessDate Function()? day}) {
      final cubit = DashboardCubit(
        reports: env.reports,
        shops: env.shops,
        today: day ?? () => today,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('a new shop loads as first run, with the shop name', () async {
      final cubit = build();
      expect(cubit.state.status, LoadStatus.loading);
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.shopName, 'Test Kirana');
      expect(cubit.state.isFirstRun, isTrue);
      expect(cubit.state.today, today);
    });

    test('figures and recent entries follow new entries', () async {
      final cubit = build();
      await settle();
      final ravi = await party('Ravi');
      await charge(ravi, 500);
      await settle();
      expect(cubit.state.isFirstRun, isFalse);
      expect(cubit.state.summary!.customerOutstanding, rupees(500));
      expect(cubit.state.summary!.todayCredit, rupees(500));
      expect(cubit.state.activity.single.partyName, 'Ravi');
    });

    test('recent entries are capped', () async {
      final ravi = await party('Ravi');
      for (var i = 0; i < DashboardCubit.activityLimit + 2; i++) {
        await charge(ravi, 10 + i);
      }
      final cubit = build();
      await settle();
      expect(cubit.state.activity, hasLength(DashboardCubit.activityLimit));
    });

    test('refreshDay moves today on only when the date changed', () async {
      var day = today;
      final ravi = await party('Ravi');
      await charge(ravi, 500);
      final cubit = build(day: () => day);
      await settle();
      expect(cubit.state.summary!.todayCredit, rupees(500));

      final before = cubit.state;
      cubit.refreshDay();
      expect(cubit.state, same(before));

      day = today.addDays(1);
      cubit.refreshDay();
      await settle();
      expect(cubit.state.today, today.addDays(1));
      // Yesterday's credit is no longer "today"; the due stays.
      expect(cubit.state.summary!.todayCredit, Money.zero);
      expect(cubit.state.summary!.customerOutstanding, rupees(500));
    });

    test('a failed query shows a failure, and retry recovers', () async {
      final broken = TestEnv();
      addTearDown(broken.dispose);
      final cubit = DashboardCubit(
        reports: broken.reports,
        shops: broken.shops,
        today: () => today,
      );
      addTearDown(cubit.close);
      await settle();
      // No shop yet: the stream fails.
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure, isA<NotFoundFailure>());

      await broken.setUpShop();
      cubit.retry();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.failure, isNull);
    });
  });

  group('OutstandingCubit (WF-051)', () {
    OutstandingCubit build({PartyRole role = PartyRole.customer}) {
      final cubit = OutstandingCubit(
        reports: env.reports,
        shareService: env.share,
        shareLogger: env.logger,
        today: today,
        role: role,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('loads a role and switches to the other', () async {
      final ravi = await party('Ravi');
      final abc = await party('ABC', role: PartyRole.supplier);
      await charge(ravi, 400);
      await charge(abc, 900, role: PartyRole.supplier);

      final cubit = build();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.report!.rows.single.partyName, 'Ravi');

      cubit.roleSelected(PartyRole.supplier);
      expect(cubit.state.status, LoadStatus.loading);
      expect(cubit.state.report, isNull);
      await settle();
      expect(cubit.state.report!.role, PartyRole.supplier);
      expect(cubit.state.report!.totals.total, rupees(900));
    });

    test('load() picks up a payment made meanwhile', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 400);
      final cubit = build();
      await settle();
      await pay(ravi, 400);
      await cubit.load();
      expect(cubit.state.report!.rows, isEmpty);
    });

    test('before shop setup it fails and can be retried', () async {
      final broken = TestEnv();
      addTearDown(broken.dispose);
      final cubit = OutstandingCubit(
        reports: broken.reports,
        shareService: env.share,
        shareLogger: env.logger,
        today: today,
        role: PartyRole.customer,
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      await broken.setUpShop();
      cubit.retry();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
    });

    test('CSV export is handed to the share sheet as a file', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 400);
      final cubit = build();
      await settle();

      await cubit.shareCsv(
        fileName: 'dues.csv',
        content: ReportExports.outstandingCsv(
          l10n: l10nFor(AppLocales.english),
          report: cubit.state.report!,
        ),
      );
      final item = env.share.shared.single;
      expect(item.fileName, 'dues.csv');
      expect(item.mimeType, 'text/csv');
      expect(item.content, startsWith(CsvWriter.byteOrderMark));
      expect(item.content, contains('Ravi,400.00,400.00,0.00,0.00,0.00'));
      expect(cubit.state.shareFailures, 0);
    });

    test(
      'a share sheet that cannot open is reported, not logged in full',
      () async {
        final cubit = build();
        await settle();
        env.share.fail = true;
        await cubit.shareText('Ravi owes 400');
        expect(cubit.state.shareFailures, 1);
        expect(env.share.shared, isEmpty);
        final record = env.logger.records.last;
        expect(record.message, 'share failed');
        expect(record.errorDescription, isNot(contains('Ravi')));
      },
    );
  });

  group('PeriodReportCubit (WF-053)', () {
    test('starts on today and reloads for another period', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 100);
      await charge(ravi, 700, date: today.addDays(-1));

      final cubit = PeriodReportCubit(reports: env.reports, today: today);
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.period.preset, DateRangePreset.today);
      expect(cubit.state.report!.creditGiven, rupees(100));

      cubit.periodSelected(
        PeriodSelection.preset(DateRangePreset.yesterday, today),
      );
      expect(cubit.state.status, LoadStatus.loading);
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.report!.creditGiven, rupees(700));
    });

    test('an end date before the start date is ignored', () async {
      final cubit = PeriodReportCubit(reports: env.reports, today: today);
      addTearDown(cubit.close);
      await settle();
      final before = cubit.state;
      cubit.periodSelected(
        PeriodSelection.custom(
          DateRange(start: today, end: today.addDays(-1)),
        ),
      );
      expect(cubit.state, same(before));
    });

    test('before shop setup it fails and can be retried', () async {
      final broken = TestEnv();
      addTearDown(broken.dispose);
      final cubit = PeriodReportCubit(reports: broken.reports, today: today);
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      await broken.setUpShop();
      cubit.retry();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
    });
  });

  group('StatementCubit (WF-052)', () {
    StatementCubit build(String accountId) {
      final cubit = StatementCubit(
        reports: env.reports,
        shops: env.shops,
        shareService: env.share,
        shareLogger: env.logger,
        accountId: accountId,
        today: today,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('opens on everything to date, with the shop name', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 300, date: today.addDays(-40));
      await charge(ravi, 200);

      final cubit = build(ravi.$2);
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.shopName, 'Test Kirana');
      expect(cubit.state.period.preset, DateRangePreset.allTime);
      expect(cubit.state.statement!.lines, hasLength(2));
      expect(cubit.state.statement!.closingBalance, rupees(500));

      cubit.periodSelected(
        PeriodSelection.preset(DateRangePreset.thisMonth, today),
      );
      await settle();
      expect(cubit.state.statement!.openingBalance, rupees(300));
      expect(cubit.state.statement!.lines, hasLength(1));
    });

    test('an unknown account is a not-found failure', () async {
      final cubit = build('nope');
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      expect(cubit.state.failure, isA<NotFoundFailure>());
      cubit.retry();
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
    });

    test('shared text and CSV hold this party only', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      await charge(ravi, 500, description: 'Rice, 25 kg');
      await pay(ravi, 200);
      await charge(sita, 9999, description: 'Secret');

      final cubit = build(ravi.$2);
      await settle();
      final l10n = l10nFor(AppLocales.english);
      final statement = cubit.state.statement!;

      final text = ReportExports.statementText(
        l10n: l10n,
        statement: statement,
        shopName: cubit.state.shopName,
        periodText: 'All entries up to 15 Nov 2026',
        formatDate: (date) => date.toIso(),
      );
      await cubit.shareText(text, subject: l10n.statementTitle);
      expect(text.split('\n'), [
        'Test Kirana',
        'Ravi (${l10n.roleCustomer})',
        'Period: All entries up to 15 Nov 2026.',
        l10n.statementCurrencyNote,
        '',
        '${l10n.statementOpening}: ${l10n.balanceSettled}',
        [
          '2026-11-15 · Credit given · ₹500 · Rice, 25 kg',
          'Balance: Customer owes ₹500',
        ].join(' · '),
        '2026-11-15 · Payment received · ₹200 · Balance: Customer owes ₹300',
        '${l10n.statementClosing}: Customer owes ₹300',
      ]);

      final csv = ReportExports.statementCsv(l10n: l10n, statement: statement);
      await cubit.shareCsv(fileName: 'statement.csv', content: csv);
      expect(csv.split(CsvWriter.lineBreak), [
        [
          '${CsvWriter.byteOrderMark}Date,Entry,Description,Change (INR)',
          'Balance (INR),Balance meaning',
        ].join(','),
        ',${l10n.statementOpening},,,0.00,${l10n.balanceSettled}',
        '2026-11-15,Credit given,"Rice, 25 kg",500.00,500.00,Customer owes',
        '2026-11-15,Payment received,,-200.00,300.00,Customer owes',
        ',${l10n.statementClosing},,,300.00,Customer owes',
      ]);

      for (final item in env.share.shared) {
        expect(item.content, isNot(contains('Sita')));
        expect(item.content, isNot(contains('Secret')));
        expect(item.content, isNot(contains('9999')));
      }
      expect(env.share.shared.map((i) => i.isFile), [false, true]);
    });

    test('a name that looks like a formula is made harmless in CSV', () async {
      final evil = await party('=HYPERLINK("http://x","Ravi")');
      await charge(evil, 100, description: '+91 trick');
      final report = (await env.reports.outstanding(
        role: PartyRole.customer,
        today: today,
      )).valueOrNull!;
      final l10n = l10nFor(AppLocales.english);

      final dues = ReportExports.outstandingCsv(l10n: l10n, report: report);
      expect(dues, contains('"\'=HYPERLINK(""http://x"",""Ravi"")"'));

      final statement = (await env.reports.statement(
        accountId: evil.$2,
        range: const DateRange(),
      )).valueOrNull!;
      final csv = ReportExports.statementCsv(l10n: l10n, statement: statement);
      expect(csv, contains(",'+91 trick,"));
    });
  });
}
