import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_constants.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to review screen
    // This would require a navigation key or callback
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    // Android 13+ requires runtime permission
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    // iOS permissions
    if (iosImplementation != null) {
      return await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return true;
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule daily review reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    // Cancel existing daily reminder
    await _notifications.cancel(0);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: 0,
      title: 'Time to Review!',
      body: 'You have cards waiting to be reviewed.',
      scheduledDate: scheduledDate,
    );
  }

  /// Schedule notification for specific card review
  Future<void> scheduleCardReview({
    required String cardId,
    required DateTime reviewDate,
    required int cardCount,
  }) async {
    await scheduleNotification(
      id: cardId.hashCode,
      title: 'Review Reminder',
      body: 'You have $cardCount card${cardCount > 1 ? 's' : ''} ready to review!',
      scheduledDate: reviewDate,
      payload: cardId,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
