import 'package:drift/drift.dart';
import 'package:smart_khata/core/database/app_database.dart';
import 'package:smart_khata/core/database/converters.dart';
import 'package:smart_khata/core/database/sql_fragments.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';

part 'reminders_dao.g.dart';

/// One party account with unpaid entries that carry a due date.
class DueAccountRow {
  const DueAccountRow({
    required this.partyId,
    required this.accountId,
    required this.partyName,
    required this.balancePaise,
    required this.overduePaise,
    required this.oldestDueAt,
    required this.lastSharedAt,
    required this.remindAt,
  });

  final String partyId;
  final String accountId;
  final String partyName;

  /// The whole account balance.
  final int balancePaise;

  /// The unpaid part of entries whose due date has passed.
  final int overduePaise;
  final DateTime oldestDueAt;

  /// When the share sheet was last opened for a reminder to this party.
  final DateTime? lastSharedAt;

  /// The owner's own pending reminder for this party, if one is set.
  final DateTime? remindAt;
}

const _instants = EpochMsConverter();

DateTime? _instantOrNull(int? millis) =>
    millis == null ? null : _instants.fromSql(millis);

/// Due lists and the log of reminders (E10).
@DriftAccessor(
  include: {
    '../schema/parties.drift',
    '../schema/ledger.drift',
    '../schema/money.drift',
    '../schema/operations.drift',
  },
)
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.attachedDatabase);

  /// Accounts of [role] with an unpaid entry that has a due date, oldest
  /// due date first. [todayStart] is the first instant of today in the
  /// shop's zone; [now] decides which owner reminders are still pending.
  Stream<List<DueAccountRow>> watchDueAccounts({
    required String shopId,
    required PartyRole role,
    required ReminderType type,
    required DateTime todayStart,
    required DateTime now,
    required int limit,
  }) =>
      customSelect(
        '''
    SELECT p.id AS party_id, a.id AS account_id, p.display_name AS party_name,
           (SELECT COALESCE(SUM(b.amount_paise), 0)
              FROM party_ledger_entries b
             WHERE b.party_account_id = a.id) AS balance_paise,
           COALESCE(SUM(CASE WHEN o.due_at < ?3 THEN o.open_paise END), 0)
             AS overdue_paise,
           MIN(o.due_at) AS oldest_due_at,
           (SELECT MAX(r.updated_at) FROM reminders r
             WHERE r.party_id = p.id AND r.reminder_type = ?4
               AND r.status = 'share_sheet_opened') AS last_shared_at,
           (SELECT MIN(r.scheduled_at) FROM reminders r
             WHERE r.party_id = p.id AND r.reminder_type = ?4
               AND r.status = 'scheduled' AND r.scheduled_at > ?5)
             AS remind_at
    FROM ($sqlOpenCharges) o
    JOIN party_accounts a ON a.id = o.account_id
    JOIN parties p ON p.id = a.party_id
    WHERE a.role = ?2 AND o.open_paise > 0 AND o.due_at IS NOT NULL
    GROUP BY a.id
    ORDER BY oldest_due_at ASC, p.normalized_name ASC, a.id ASC
    LIMIT ?6
    ''',
        variables: [
          Variable.withString(shopId),
          Variable.withString(role.code),
          Variable.withInt(todayStart.millisecondsSinceEpoch),
          Variable.withString(type.code),
          Variable.withInt(now.millisecondsSinceEpoch),
          Variable.withInt(limit),
        ],
        readsFrom: {
          parties,
          partyAccounts,
          partyLedgerEntries,
          ledgerAllocationEvents,
          financialTransactions,
          reminders,
        },
      ).watch().map(
        (rows) => [
          for (final row in rows)
            DueAccountRow(
              partyId: row.read<String>('party_id'),
              accountId: row.read<String>('account_id'),
              partyName: row.read<String>('party_name'),
              balancePaise: row.read<int>('balance_paise'),
              overduePaise: row.read<int>('overdue_paise'),
              oldestDueAt: _instants.fromSql(row.read<int>('oldest_due_at')),
              lastSharedAt: _instantOrNull(
                row.readNullable<int>('last_shared_at'),
              ),
              remindAt: _instantOrNull(row.readNullable<int>('remind_at')),
            ),
        ],
      );

  Future<void> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  /// The owner's reminders that are set for after [now].
  Future<List<Reminder>> pendingScheduled({
    required String shopId,
    required DateTime now,
  }) =>
      (select(reminders)..where(
            (t) =>
                t.shopId.equals(shopId) &
                t.status.equalsValue(ReminderStatus.scheduled) &
                t.scheduledAt.isBiggerThanValue(now.millisecondsSinceEpoch),
          ))
          .get();

  /// The pending owner reminders for one party and kind.
  Future<List<Reminder>> pendingFor({
    required String shopId,
    required String partyId,
    required ReminderType type,
    required DateTime now,
  }) =>
      (select(reminders)..where(
            (t) =>
                t.shopId.equals(shopId) &
                t.partyId.equals(partyId) &
                t.reminderType.equalsValue(type) &
                t.status.equalsValue(ReminderStatus.scheduled) &
                t.scheduledAt.isBiggerThanValue(now.millisecondsSinceEpoch),
          ))
          .get();

  Future<int> markCancelled({
    required String shopId,
    required String id,
    required DateTime now,
  }) =>
      (update(
        reminders,
      )..where((t) => t.id.equals(id) & t.shopId.equals(shopId))).write(
        RemindersCompanion(
          status: const Value(ReminderStatus.cancelled),
          updatedAt: Value(now),
        ),
      );

  /// The next unused notification number for this shop.
  Future<int> nextNotificationId(String shopId) async {
    final row = await customSelect(
      'SELECT COALESCE(MAX(notification_id), 999) + 1 AS next '
      'FROM reminders WHERE shop_id = ?',
      variables: [Variable.withString(shopId)],
    ).getSingle();
    return row.read<int>('next');
  }
}
