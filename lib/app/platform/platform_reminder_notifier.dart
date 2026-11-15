import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_khata/features/reminders/domain/reminders.dart';
import 'package:timezone/timezone.dart' as tz;

/// [ReminderNotifier] through Android local notifications.
///
/// Alarms are inexact on purpose: a reminder a few minutes late is fine,
/// and it avoids the exact-alarm permission (open decision 17).
final class PlatformReminderNotifier implements ReminderNotifier {
  PlatformReminderNotifier();

  static const String _channelId = 'due_reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> ensurePermission() async {
    await _ensureInitialized();
    final android = _android;
    if (android == null) return false;
    if (await android.areNotificationsEnabled() ?? false) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required ReminderTexts texts,
  }) async {
    await _ensureInitialized();
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      title: texts.title,
      body: texts.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_channelId, texts.channelName),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _ensureInitialized();
    await _plugin.cancel(id: id);
  }
}
