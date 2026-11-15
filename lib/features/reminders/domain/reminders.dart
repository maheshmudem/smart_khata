import 'package:equatable/equatable.dart';
import 'package:smart_khata/core/date_time/business_date.dart';
import 'package:smart_khata/core/domain/ledger_enums.dart';
import 'package:smart_khata/core/errors/result.dart';
import 'package:smart_khata/core/money/money.dart';

/// A party with unpaid entries that have a due date (WF-060).
class DueItem extends Equatable {
  const DueItem({
    required this.partyId,
    required this.accountId,
    required this.partyName,
    required this.role,
    required this.balance,
    required this.overdue,
    required this.oldestDueDate,
    this.lastSharedAt,
    this.remindAt,
  });

  final String partyId;
  final String accountId;
  final String partyName;
  final PartyRole role;

  /// The whole account balance: what a reminder message asks for.
  final Money balance;

  /// The unpaid part that is past its due date; zero when nothing is.
  final Money overdue;
  final BusinessDate oldestDueDate;

  /// When the share sheet was last opened for a reminder to this party.
  /// It does not mean a message was sent or read (FR-REM-005).
  final DateTime? lastSharedAt;

  /// The owner's own reminder for this party, when one is pending.
  final DateTime? remindAt;

  bool get isOverdue => overdue.isPositive;

  @override
  List<Object?> get props => [
    partyId,
    accountId,
    partyName,
    role,
    balance,
    overdue,
    oldestDueDate,
    lastSharedAt,
    remindAt,
  ];
}

/// How soon a second reminder to the same party is questioned (WF-060:
/// "frequency controls prevent repeated annoying reminders").
abstract final class ReminderPolicy {
  static const Duration quietPeriod = Duration(days: 3);

  /// Whether a reminder was shared so recently that the owner should be
  /// asked before sharing another.
  static bool sharedRecently(DateTime? lastSharedAt, DateTime now) =>
      lastSharedAt != null && now.difference(lastSharedAt) < quietPeriod;

  /// The hour of the day, shop time, at which the owner is notified.
  static const int notifyHour = 9;

  /// The furthest ahead an owner reminder can be set.
  static const int maxDaysAhead = 90;
}

/// The words of the owner's notification, in the app's language. They
/// are fixed and name nobody, so a locked phone shows nothing about a
/// customer.
class ReminderTexts extends Equatable {
  const ReminderTexts({
    required this.title,
    required this.body,
    required this.channelName,
  });

  final String title;
  final String body;

  /// The name of the notification group in the phone's settings.
  final String channelName;

  @override
  List<Object?> get props => [title, body, channelName];
}

/// What setting an owner reminder came to.
enum ScheduleOutcome {
  scheduled,

  /// The phone does not let this app show notifications.
  notificationsOff,
}

/// Shows a notification to the owner at a set time, on this phone only.
/// Nothing is ever sent to a customer or supplier by the app (ADR-012).
abstract interface class ReminderNotifier {
  /// Asks for permission to notify if it is needed. `false` when the
  /// owner refused or the phone forbids it.
  Future<bool> ensurePermission();

  Future<void> schedule({
    required int id,
    required DateTime at,
    required ReminderTexts texts,
  });

  Future<void> cancel(int id);
}

abstract interface class ReminderRepository {
  /// Parties of [role] with unpaid entries that have a due date, oldest
  /// due date first.
  Stream<List<DueItem>> watchDue({
    required PartyRole role,
    required BusinessDate today,
  });

  /// Notes that the share sheet was opened for a reminder to [partyId].
  Future<Result<void>> recordShareOpened({
    required String partyId,
    required PartyRole role,
  });

  /// Sets the owner's own reminder for [on], replacing an earlier one
  /// for the same party.
  Future<Result<ScheduleOutcome>> schedule({
    required String partyId,
    required PartyRole role,
    required BusinessDate on,
    required ReminderTexts texts,
  });

  /// Removes the owner's pending reminder for the party.
  Future<Result<void>> cancel({
    required String partyId,
    required PartyRole role,
  });

  /// Sets the phone's alarms again from the saved reminders: after a
  /// restore on a new phone the rows exist but the alarms do not.
  Future<Result<int>> resync(ReminderTexts texts);
}
