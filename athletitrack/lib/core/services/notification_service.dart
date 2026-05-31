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

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    await _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
  }

  Future<void> scheduleTrainingReminder({
    required int id,
    required String title,
    required String sessionDate,
    required String sessionTime,
  }) async {
    await requestPermissions();

    // Parse the date and time. Assume sessionDate is 'YYYY-MM-DD' and sessionTime is 'HH:MM - HH:MM' or 'HH:MM'
    // Let's just extract the first HH:MM
    try {
      final timeStr = sessionTime.split('-')[0].trim();
      final dateTimeStr = '$sessionDate $timeStr:00';
      final parsedDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeStr);
      
      // Schedule 5 minutes before
      final scheduledTime = parsedDate.subtract(const Duration(minutes: 5));

      if (scheduledTime.isBefore(DateTime.now())) {
        return; // Cannot schedule in the past
      }

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Training Reminder: $title',
        body: 'Your training session starts in 5 minutes!',
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
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
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
