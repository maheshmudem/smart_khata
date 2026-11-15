import 'package:flutter_test/flutter_test.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/submission_status.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/ledger/domain/ledger_models.dart';
import 'package:smart_khata/features/ledger/domain/payment_models.dart';
import 'package:smart_khata/features/parties/domain/party_commands.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:smart_khata/features/reminders/presentation/reminders_cubit.dart';

import '../../helpers/test_database.dart';
import '../../helpers/test_env.dart';

Money rupees(int value) => Money.fromPaise(value * 100);

Future<void> settle() => pumpEventQueue(times: 50);

const texts = ReminderTexts(
  title: 'Smart Khata',
  body: 'You set a payment reminder for today.',
  channelName: 'Reminders',
);

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
    BusinessDate? dueDate,
  }) async {
    env.clock.now = env.clock.now.add(const Duration(minutes: 1));
    final result = await env.recordCharge(
      RecordChargeCommand(
        operationId: 'chg-${op++}',
        role: role,
        partyId: who.$1,
        accountId: who.$2,
        amount: rupees(amount),
        // A past due date needs an entry dated before it.
        date:
            date ??
            (dueDate != null && dueDate.compareTo(today) < 0
                ? dueDate.addDays(-3)
                : today),
        dueDate: dueDate,
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

  Future<List<DueItem>> due([PartyRole role = PartyRole.customer]) =>
      env.reminders.watchDue(role: role, today: today).first;

  group('due list (SK-1002, WF-060)', () {
    test(
      'only unpaid entries with a due date are listed, oldest first',
      () async {
        final ravi = await party('Ravi');
        final sita = await party('Sita');
        final gopal = await party('Gopal');
        final abc = await party('ABC', role: PartyRole.supplier);
        await charge(
          ravi,
          500,
          date: BusinessDate(2026, 11, 1),
          dueDate: BusinessDate(2026, 11, 10),
        );
        await charge(ravi, 200); // no due date: adds to the balance only
        await charge(sita, 300, dueDate: BusinessDate(2026, 11, 20));
        await charge(gopal, 900); // no due date at all: not listed
        await charge(
          abc,
          1000,
          role: PartyRole.supplier,
          dueDate: BusinessDate(2026, 11, 12),
        );

        final customers = await due();
        expect(customers.map((d) => d.partyName), ['Ravi', 'Sita']);
        final first = customers.first;
        expect(first.balance, rupees(700));
        expect(first.overdue, rupees(500));
        expect(first.isOverdue, isTrue);
        expect(first.oldestDueDate, BusinessDate(2026, 11, 10));
        expect(first.lastSharedAt, isNull);
        expect(first.remindAt, isNull);
        // Due later: listed, but not past due.
        expect(customers.last.isOverdue, isFalse);
        expect(customers.last.overdue, Money.zero);

        final suppliers = await due(PartyRole.supplier);
        expect(suppliers.single.partyName, 'ABC');
        expect(suppliers.single.role, PartyRole.supplier);
      },
    );

    test('a paid entry leaves the list; due today is not past due', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: today);
      expect((await due()).single.isOverdue, isFalse);
      await pay(ravi, 500);
      expect(await due(), isEmpty);
    });
  });

  group('sharing a reminder (SK-1004, FR-REM-005)', () {
    test('only that the share sheet was opened is recorded', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));

      final result = await env.reminders.recordShareOpened(
        partyId: ravi.$1,
        role: PartyRole.customer,
      );
      expect(result.isOk, isTrue);
      final row = await env.db.select(env.db.reminders).getSingle();
      expect(row.status, ReminderStatus.shareSheetOpened);
      expect(row.reminderType, ReminderType.customerDue);
      // The schema itself has no "delivered" or "sent" status to store.
      await expectLater(
        env.db.exec("UPDATE reminders SET status = 'delivered'"),
        throwsA(anything),
      );
      expect((await due()).single.lastSharedAt, env.clock.now);
      // Nothing was scheduled on the phone by sharing.
      expect(env.notifier.scheduled, isEmpty);
    });

    test('a second reminder within three days is questioned', () {
      final now = DateTime.utc(2026, 11, 15, 6);
      expect(ReminderPolicy.sharedRecently(null, now), isFalse);
      expect(
        ReminderPolicy.sharedRecently(
          now.subtract(const Duration(days: 2, hours: 23)),
          now,
        ),
        isTrue,
      );
      expect(
        ReminderPolicy.sharedRecently(
          now.subtract(const Duration(days: 3)),
          now,
        ),
        isFalse,
      );
    });
  });

  group("the owner's own reminder (SK-1001, FR-REM-002)", () {
    test('is set for 9 in the morning, shop time, on the chosen day', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));

      final result = await env.reminders.schedule(
        partyId: ravi.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 18),
        texts: texts,
      );
      expect(result.valueOrNull, ScheduleOutcome.scheduled);
      // 09:00 IST is 03:30 UTC.
      final at = DateTime.utc(2026, 11, 18, 3, 30);
      expect(env.notifier.scheduled.values.single, at);
      // The notification names nobody and no amount.
      expect(env.notifier.texts.single, texts);
      expect((await due()).single.remindAt, at);
    });

    test('a new reminder replaces the earlier one for that party', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
      for (final day in [18, 20]) {
        await env.reminders.schedule(
          partyId: ravi.$1,
          role: PartyRole.customer,
          on: BusinessDate(2026, 11, day),
          texts: texts,
        );
      }
      expect(
        env.notifier.scheduled.values.single,
        DateTime.utc(2026, 11, 20, 3, 30),
      );
      final statuses = (await env.db.select(env.db.reminders).get())
          .map((r) => r.status)
          .toList();
      expect(statuses, [ReminderStatus.cancelled, ReminderStatus.scheduled]);
    });

    test('with notifications off nothing is saved', () async {
      final ravi = await party('Ravi');
      env.notifier.permission = false;
      final result = await env.reminders.schedule(
        partyId: ravi.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 18),
        texts: texts,
      );
      expect(result.valueOrNull, ScheduleOutcome.notificationsOff);
      expect(await env.count('reminders'), 0);
    });

    test('if the phone refuses the alarm nothing is saved', () async {
      final ravi = await party('Ravi');
      env.notifier.failSchedule = true;
      final result = await env.reminders.schedule(
        partyId: ravi.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 18),
        texts: texts,
      );
      expect(result.isOk, isFalse);
      expect(await env.count('reminders'), 0);
    });

    test('cancel removes the alarm and marks the row', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
      await env.reminders.schedule(
        partyId: ravi.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 18),
        texts: texts,
      );
      expect(
        (await env.reminders.cancel(
          partyId: ravi.$1,
          role: PartyRole.customer,
        )).isOk,
        isTrue,
      );
      expect(env.notifier.scheduled, isEmpty);
      expect((await due()).single.remindAt, isNull);
      expect(
        (await env.db.select(env.db.reminders).getSingle()).status,
        ReminderStatus.cancelled,
      );
    });

    test('resync sets pending alarms again, and only pending ones', () async {
      final ravi = await party('Ravi');
      final sita = await party('Sita');
      await env.reminders.schedule(
        partyId: ravi.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 16),
        texts: texts,
      );
      await env.reminders.schedule(
        partyId: sita.$1,
        role: PartyRole.customer,
        on: BusinessDate(2026, 11, 25),
        texts: texts,
      );
      // A new phone after a restore: rows exist, alarms do not. A week
      // has passed, so the first reminder is in the past.
      env.notifier.scheduled.clear();
      env.clock.now = env.clock.now.add(const Duration(days: 7));

      expect((await env.reminders.resync(texts)).valueOrNull, 1);
      expect(
        env.notifier.scheduled.values.single,
        DateTime.utc(2026, 11, 25, 3, 30),
      );
    });

    test('before shop setup resync fails quietly', () async {
      final empty = TestEnv();
      addTearDown(empty.dispose);
      expect((await empty.reminders.resync(texts)).isOk, isFalse);
    });
  });

  group('RemindersCubit (WF-060)', () {
    RemindersCubit build() {
      final cubit = RemindersCubit(
        reminders: env.reminders,
        shops: env.shops,
        share: env.share,
        clock: env.clock,
        today: today,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('lists customers, switches to suppliers, has the shop name', () async {
      final ravi = await party('Ravi');
      final abc = await party('ABC', role: PartyRole.supplier);
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
      await charge(
        abc,
        800,
        role: PartyRole.supplier,
        dueDate: BusinessDate(2026, 11, 12),
      );

      final cubit = build();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
      expect(cubit.state.shopName, 'Test Kirana');
      expect(cubit.state.items.single.partyName, 'Ravi');

      cubit.roleSelected(PartyRole.supplier);
      expect(cubit.state.status, LoadStatus.loading);
      await settle();
      expect(cubit.state.items.single.partyName, 'ABC');
    });

    test(
      'share hands the message over and notes the sheet was opened',
      () async {
        final ravi = await party('Ravi');
        await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
        final cubit = build();
        await settle();
        final item = cubit.state.items.single;
        expect(cubit.sharedRecently(item), isFalse);

        await cubit.share(item, 'Hello Ravi');
        await settle();
        expect(env.share.shared.single.content, 'Hello Ravi');
        final after = cubit.state.items.single;
        expect(after.lastSharedAt, isNotNull);
        expect(cubit.sharedRecently(after), isTrue);
        // No notice claims anything was sent.
        expect(cubit.state.notice, isNull);
      },
    );

    test('a share sheet that cannot open records nothing', () async {
      final ravi = await party('Ravi');
      await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
      final cubit = build();
      await settle();
      env.share.fail = true;
      await cubit.share(cubit.state.items.single, 'Hello Ravi');
      expect(cubit.state.notice, ReminderNotice.shareFailed);
      expect(await env.count('reminders'), 0);
    });

    test(
      'remind me, notifications off, and cancel each give a notice',
      () async {
        final ravi = await party('Ravi');
        await charge(ravi, 500, dueDate: BusinessDate(2026, 11, 10));
        final cubit = build();
        await settle();
        final item = cubit.state.items.single;

        env.notifier.permission = false;
        await cubit.remindMe(item, BusinessDate(2026, 11, 18), texts);
        expect(cubit.state.notice, ReminderNotice.notificationsOff);

        env.notifier.permission = true;
        await cubit.remindMe(item, BusinessDate(2026, 11, 18), texts);
        await settle();
        expect(cubit.state.notice, ReminderNotice.reminderSet);
        expect(cubit.state.noticeCount, 2);
        expect(cubit.state.items.single.remindAt, isNotNull);

        await cubit.cancelReminder(cubit.state.items.single);
        await settle();
        expect(cubit.state.notice, ReminderNotice.reminderCancelled);
        expect(cubit.state.items.single.remindAt, isNull);
      },
    );

    test('before shop setup the list fails and can be retried', () async {
      final empty = TestEnv();
      addTearDown(empty.dispose);
      final cubit = RemindersCubit(
        reminders: empty.reminders,
        shops: empty.shops,
        share: empty.share,
        clock: empty.clock,
        today: today,
      );
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.status, LoadStatus.failure);
      await empty.setUpShop();
      cubit.retry();
      await settle();
      expect(cubit.state.status, LoadStatus.loaded);
    });
  });
}
