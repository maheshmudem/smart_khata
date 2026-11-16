import 'package:drift/drift.dart' show Value;
import 'package:smart_khata/core/database/app_database.dart' as db;
import 'package:smart_khata/core/database/daos/reminders_dao.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/date_time/clock.dart';
import 'package:smart_khata/core/date_time/shop_time_zone.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/domain/shop_context.dart';
import 'package:smart_khata/core/errors/failure_mapper.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/ids/id_generator.dart';
import 'package:smart_khata/core/logging/app_logger.dart';
import 'package:smart_khata/core/money/money.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:timezone/timezone.dart' as tz;

final class DriftReminderRepository implements ReminderRepository {
  const DriftReminderRepository({
    required this._dao,
    required this._shop,
    required this._clock,
    required this._ids,
    required this._logger,
    required this._notifier,
  });

  static const int listLimit = 200;

  final RemindersDao _dao;
  final ShopContext _shop;
  final Clock _clock;
  final IdGenerator _ids;
  final AppLogger _logger;
  final ReminderNotifier _notifier;

  static ReminderType _typeOf(PartyRole role) => switch (role) {
    PartyRole.customer => ReminderType.customerDue,
    PartyRole.supplier => ReminderType.supplierDue,
  };

  @override
  Stream<List<DueItem>> watchDue({
    required PartyRole role,
    required BusinessDate today,
  }) {
    final zone = ShopTimeZone.resolve(null);
    return Stream.fromFuture(_shop.requireShopId())
        .asyncExpand(
          (shopId) => _dao.watchDueAccounts(
            shopId: shopId,
            role: role,
            type: _typeOf(role),
            todayStart: today.startUtc(zone),
            now: _clock.nowUtc(),
            limit: listLimit,
          ),
        )
        .map(
          (rows) => [
            for (final row in rows)
              DueItem(
                partyId: row.partyId,
                accountId: row.accountId,
                partyName: row.partyName,
                role: role,
                balance: Money.fromPaise(row.balancePaise),
                overdue: Money.fromPaise(row.overduePaise),
                oldestDueDate: BusinessDate.fromInstant(row.oldestDueAt, zone),
                lastSharedAt: row.lastSharedAt,
                remindAt: row.remindAt,
              ),
          ],
        )
        .mapErrorsToFailures(logger: _logger, operation: 'reminders.due');
  }

  @override
  Future<Result<void>> recordShareOpened({
    required String partyId,
    required PartyRole role,
  }) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final now = _clock.nowUtc();
      await _dao.insertReminder(
        db.RemindersCompanion.insert(
          id: _ids.newId(),
          shopId: shopId,
          partyId: Value(partyId),
          reminderType: _typeOf(role),
          scheduledAt: now,
          notificationId: await _dao.nextNotificationId(shopId),
          // Only that the sheet was opened: the app cannot know whether
          // anything was sent (ADR-012).
          status: ReminderStatus.shareSheetOpened,
          createdAt: now,
          updatedAt: now,
        ),
      );
    },
    logger: _logger,
    operation: 'reminders.recordShareOpened',
  );

  @override
  Future<Result<ScheduleOutcome>> schedule({
    required String partyId,
    required PartyRole role,
    required BusinessDate on,
    required ReminderTexts texts,
  }) => guard(
    () async {
      if (!await _notifier.ensurePermission()) {
        return ScheduleOutcome.notificationsOff;
      }
      final shopId = await _shop.requireShopId();
      final now = _clock.nowUtc();
      final type = _typeOf(role);
      final zone = ShopTimeZone.resolve(null);
      final at = tz.TZDateTime(
        zone,
        on.year,
        on.month,
        on.day,
        ReminderPolicy.notifyHour,
      ).toUtc();
      // The row and the phone's alarm must agree. The number is taken and
      // the row written in one transaction; the alarm is set inside it,
      // so a refused alarm rolls the row back, and a failed commit leaves
      // an alarm that is taken down again below.
      int? scheduledId;
      final List<db.Reminder> earlier;
      try {
        earlier = await _dao.transaction(() async {
          final pending = await _dao.pendingFor(
            shopId: shopId,
            partyId: partyId,
            type: type,
            now: now,
          );
          for (final reminder in pending) {
            await _dao.markCancelled(shopId: shopId, id: reminder.id, now: now);
          }
          final notificationId = await _dao.nextNotificationId(shopId);
          await _dao.insertReminder(
            db.RemindersCompanion.insert(
              id: _ids.newId(),
              shopId: shopId,
              partyId: Value(partyId),
              reminderType: type,
              scheduledAt: at,
              notificationId: notificationId,
              status: ReminderStatus.scheduled,
              createdAt: now,
              updatedAt: now,
            ),
          );
          await _notifier.schedule(id: notificationId, at: at, texts: texts);
          scheduledId = notificationId;
          return pending;
        });
      } on Object {
        final orphan = scheduledId;
        if (orphan != null) await _notifier.cancel(orphan);
        rethrow;
      }
      for (final reminder in earlier) {
        await _notifier.cancel(reminder.notificationId);
      }
      return ScheduleOutcome.scheduled;
    },
    logger: _logger,
    operation: 'reminders.schedule',
  );

  @override
  Future<Result<void>> cancel({
    required String partyId,
    required PartyRole role,
  }) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final now = _clock.nowUtc();
      final pending = await _dao.pendingFor(
        shopId: shopId,
        partyId: partyId,
        type: _typeOf(role),
        now: now,
      );
      for (final reminder in pending) {
        await _dao.markCancelled(shopId: shopId, id: reminder.id, now: now);
        await _notifier.cancel(reminder.notificationId);
      }
    },
    logger: _logger,
    operation: 'reminders.cancel',
  );

  @override
  Future<Result<int>> resync(ReminderTexts texts) => guard(
    () async {
      final shopId = await _shop.requireShopId();
      final pending = await _dao.pendingScheduled(
        shopId: shopId,
        now: _clock.nowUtc(),
      );
      for (final reminder in pending) {
        await _notifier.schedule(
          id: reminder.notificationId,
          at: reminder.scheduledAt,
          texts: texts,
        );
      }
      return pending.length;
    },
    logger: _logger,
    operation: 'reminders.resync',
  );
}
