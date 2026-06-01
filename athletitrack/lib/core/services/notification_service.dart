import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    if (!kIsWeb) {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
      await _notificationsPlugin.initialize(settings: initSettings);
    } else {
      // Request browser notification permission immediately on init for Web
      await html.Notification.requestPermission();
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      await html.Notification.requestPermission();
    } else {
      await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleTrainingReminder({
    required int id,
    required String title,
    required String teamName,
    String? sessionDate, // Null if weekly
    required String sessionTime,
    bool isWeekly = false,
    String? daysOfWeek,
  }) async {
    await requestPermissions();

    final timeStr = sessionTime.split('-')[0].trim();
    final parts = timeStr.split(':');
    if (parts.length < 2) return;
    
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Subtract 5 minutes for the reminder
    minute -= 5;
    if (minute < 0) {
      minute += 60;
      hour -= 1;
      if (hour < 0) hour += 24;
    }

    final notificationTitle = 'Training Reminder: $title';
    final notificationBody = 'Team: $teamName\nYour training session starts in 5 minutes!';

    if (isWeekly && daysOfWeek != null && daysOfWeek.isNotEmpty) {
      final days = _parseDaysOfWeek(daysOfWeek);
      for (int i = 0; i < days.length; i++) {
        final targetDay = days[i];
        final scheduledTime = _nextInstanceOfDayAndTime(targetDay, hour, minute);
        final uniqueId = id + i; // Offset ID for each day to prevent overwrites

        if (kIsWeb) {
          _scheduleWebTimer(scheduledTime, notificationTitle, notificationBody);
        } else {
          await _scheduleAndroidNotification(
            id: uniqueId,
            title: notificationTitle,
            body: notificationBody,
            scheduledTime: scheduledTime,
            matchComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    } else if (sessionDate != null && sessionDate.isNotEmpty) {
      // One-time session
      try {
        final dateTimeStr = '$sessionDate $timeStr:00';
        final parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
        final scheduledTime = parsedDate.subtract(const Duration(minutes: 5));

        if (scheduledTime.isBefore(DateTime.now())) {
          return; // Cannot schedule in the past
        }

        if (kIsWeb) {
          _scheduleWebTimer(tz.TZDateTime.from(scheduledTime, tz.local), notificationTitle, notificationBody);
        } else {
          await _scheduleAndroidNotification(
            id: id,
            title: notificationTitle,
            body: notificationBody,
            scheduledTime: tz.TZDateTime.from(scheduledTime, tz.local),
          );
        }
      } catch (e) {
        print('Error parsing one-time schedule: $e');
      }
    }
  }

  void _scheduleWebTimer(tz.TZDateTime scheduledTime, String title, String body) {
    final now = tz.TZDateTime.now(tz.local);
    final diff = scheduledTime.difference(now);
    
    // Only schedule if it's within the next 24 hours to prevent memory leaks/excessive timers
    if (diff.inMilliseconds > 0 && diff.inHours < 24) {
      Timer(diff, () {
        if (html.Notification.permission == 'granted') {
          html.Notification(title, body: body);
        }
      });
    }
  }

  Future<void> _scheduleAndroidNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    DateTimeComponents? matchComponents,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'training_reminders',
            'Training Reminders',
            channelDescription: 'Reminders for upcoming training sessions',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchComponents,
      );
    } catch (e) {
      print('Error scheduling android notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int targetDay, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    while (scheduledDate.weekday != targetDay || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  List<int> _parseDaysOfWeek(String daysStr) {
    final List<int> days = [];
    final parts = daysStr.toLowerCase().split(',');
    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;
      
      if (part.startsWith('m')) days.add(DateTime.monday);
      else if (part.startsWith('th')) days.add(DateTime.thursday);
      else if (part.startsWith('tu') || part == 't') days.add(DateTime.tuesday);
      else if (part.startsWith('w')) days.add(DateTime.wednesday);
      else if (part.startsWith('f')) days.add(DateTime.friday);
      else if (part.startsWith('sa')) days.add(DateTime.saturday);
      else if (part.startsWith('su')) days.add(DateTime.sunday);
      else if (part == 's') days.add(DateTime.saturday);
    }
    return days.toSet().toList(); // Return unique days
  }
}
