import 'package:awesome_period_tracker/domain/models/cycle_event.dart';
import 'package:awesome_period_tracker/utils/extensions/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart';

@injectable
class NotificationService {
  const NotificationService(
    this._notifications,
    this._storage,
  );

  static const String _notificationScheduledKey = 'G10P5XamUn32';

  final FlutterLocalNotificationsPlugin _notifications;
  final FlutterSecureStorage _storage;

  Future<void> scheduleNextPeriodNotification(DateTime nextPeriodDate) async {
    final isScheduled = await _storage.read(key: _notificationScheduledKey);
    if (isScheduled == 'true') return;

    final appL10n = l10n;
    final notificationDate = nextPeriodDate.subtract(const Duration(days: 7));
    if (notificationDate.isBefore(DateTime.now())) return;

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'period_reminder',
        appL10n.periodReminderChannelName,
        channelDescription: appL10n.periodReminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      0,
      appL10n.upcomingPeriodNotificationTitle,
      appL10n.upcomingPeriodNotificationBody,
      _convertToTZDateTime(notificationDate),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    await _storage.write(key: _notificationScheduledKey, value: 'true');
  }

  Future<void> resetNotificationStatus() async {
    await _storage.delete(key: _notificationScheduledKey);
  }

  TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final now = DateTime.now();
    return TZDateTime.local(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      now.hour,
      now.minute,
    );
  }

  Future<void> scheduleNotificationsFromEvents(List<CycleEvent> events) async {
    final now = DateTime.now();

    final nextPeriod = events
        .where((e) => e.isPeriod && e.date.isAfter(now) && !e.isPrediction)
        .firstOrNull;

    if (nextPeriod != null) {
      await scheduleNextPeriodNotification(nextPeriod.date);
    }
  }
}
