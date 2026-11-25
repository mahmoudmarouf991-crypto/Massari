import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

/// جدولة إشعارات محلية حقيقية (بتشتغل والتطبيق مقفول)
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channelId = 'meds_channel';

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(const InitializationSettings(android: android));
      _ready = true;
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  /// بيطلب إذن الإشعارات (أندرويد 13+) وإذن المنبهات الدقيقة
  Future<void> requestPermissions() async {
    try {
      await _android?.requestNotificationsPermission();
      final canExact = await _android?.canScheduleExactNotifications() ?? false;
      if (!canExact) {
        await _android?.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'تذكير الأدوية والمكملات',
          channelDescription: 'تذكيرات مواعيد الأدوية والفيتامينات والكرياتين',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

  tz.TZDateTime _nextInstance(int hour, int minute, int? weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (weekday == null) {
      if (!t.isAfter(now)) {
        t = tz.TZDateTime(tz.local, t.year, t.month, t.day + 1, hour, minute);
      }
    } else {
      while (t.weekday != weekday || !t.isAfter(now)) {
        t = tz.TZDateTime(tz.local, t.year, t.month, t.day + 1, hour, minute);
      }
    }
    return t;
  }

  Future<void> schedule(Reminder r) async {
    if (!_ready) return;
    await cancel(r.id);
    if (!r.enabled) return;
    final canExact = await _android?.canScheduleExactNotifications() ?? false;
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final title = '${r.type.emoji} ${r.name}';
    final body = r.note.isEmpty ? 'حان موعدك' : r.note;

    if (r.days.isEmpty || r.days.length == 7) {
      await _plugin.zonedSchedule(
        r.id * 10,
        title,
        body,
        _nextInstance(r.hour, r.minute, null),
        _details,
        androidScheduleMode: mode,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else {
      for (final wd in r.days) {
        await _plugin.zonedSchedule(
          r.id * 10 + wd,
          title,
          body,
          _nextInstance(r.hour, r.minute, wd),
          _details,
          androidScheduleMode: mode,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  Future<void> cancel(int reminderId) async {
    if (!_ready) return;
    for (int k = 0; k <= 7; k++) {
      await _plugin.cancel(reminderId * 10 + k);
    }
  }

  /// بيعيد جدولة كل التذكيرات (بيتنده عند فتح التطبيق)
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    for (final r in reminders) {
      await schedule(r);
    }
  }

  Future<void> showTest() async {
    if (!_ready) return;
    await _plugin.show(0, '🕌 مساري', 'الإشعارات شغالة تمام ✅', _details);
  }
}
