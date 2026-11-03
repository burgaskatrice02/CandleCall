import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../models/birthday.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    timezone_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(local.identifier));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('birthday_buddy_notification'),
      ),
    );
  }

  Future<bool> requestPermission() async {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> schedule(
    List<Birthday> birthdays,
    ReminderPreferences preferences,
  ) async {
    await _plugin.cancelAll();
    if (!preferences.enabled) return;
    final now = timezone.TZDateTime.now(timezone.local);
    for (final birthday in birthdays) {
      final firstYear = birthday.nextBirthday.year;
      for (var cycle = 0; cycle < 2; cycle++) {
        final occurrence = birthday.birthdayInYear(firstYear + cycle);
        for (final daysBefore in preferences.daysBefore) {
          final reminderDay = occurrence.subtract(Duration(days: daysBefore));
          final scheduled = timezone.TZDateTime(
            timezone.local,
            reminderDay.year,
            reminderDay.month,
            reminderDay.day,
            9,
          );
          if (!scheduled.isAfter(now)) continue;
          await _plugin.zonedSchedule(
            id: birthday.id! * 100 + cycle * 10 + daysBefore,
            title: '${birthday.name}’s birthday is coming up',
            body: 'Their birthday is in $daysBefore ${daysBefore == 1 ? 'day' : 'days'}.',
            scheduledDate: scheduled,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'birthday_reminders',
                'Birthday reminders',
                channelDescription: 'Reminders before birthdays',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: birthday.id.toString(),
          );
        }
      }
    }
  }
}