import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
  }

  /// Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id: 0,
      title: '🔥 ${AppConstants.appName}',
      body: 'Time to complete your habits! Keep your streak alive!',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.dailyReminderChannel,
          'Daily Reminders',
          channelDescription: 'Daily habit completion reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefReminderTime, '$hour:$minute');
  }

  /// Send streak risk notification
  Future<void> sendStreakRiskAlert() async {
    await _notifications.show(
      id: 1,
      title: '⚠️ Streak at Risk!',
      body:
          'You haven\'t completed all your habits today. Don\'t break your streak!',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.streakAlertChannel,
          'Streak Alerts',
          channelDescription: 'Alerts when your streak is at risk',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Send friend activity notification
  Future<void> sendFriendAlert(String friendName) async {
    await _notifications.show(
      id: 2,
      title: '👋 Friend Activity',
      body: '$friendName completed their habits! Can you keep up?',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.friendAlertChannel,
          'Friend Alerts',
          channelDescription: 'Friend activity notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Send birthday notification
  Future<void> sendBirthdayNotification() async {
    await _notifications.show(
      id: 3,
      title: '🎂 Happy Birthday!',
      body: AppConstants.birthdayMessage,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.dailyReminderChannel,
          'Daily Reminders',
          channelDescription: 'Daily reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
