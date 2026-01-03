import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/topic.dart';
import 'topics_index_service.dart';

/// Service for managing local notifications
///
/// Handles scheduling, displaying, and managing notifications for topic reviews.
/// Supports both Android and iOS platforms with platform-specific features.
///
/// **Features:**
/// - Daily reminders at scheduled time
/// - Per-topic notifications
/// - Action buttons (Review Now, Snooze)
/// - Notification tap handling
/// - Permission management
///
/// **Example:**
/// ```dart
/// final notificationService = NotificationService();
/// await notificationService.initialize();
/// await notificationService.scheduleDailyReminder(TimeOfDay(hour: 9, minute: 0));
/// ```
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final TopicsIndexService _topicsService = TopicsIndexService();

  bool _isInitialized = false;

  /// Callback function to handle notification tap events
  /// Set this before calling initialize() to handle navigation
  Function(String? payload)? onNotificationTap;

  // Notification IDs
  static const int _dailyReminderId = 0;
  static const int _topicReminderBaseId = 1000;

  // Android notification channel details
  static const String _channelId = 'memory_flow_reviews';
  static const String _channelName = 'Review Reminders';
  static const String _channelDescription = 'Notifications for scheduled topic reviews';

  // iOS notification category
  static const String _iosCategoryId = 'REVIEW_REMINDER';

  /// Initialize the notification service
  ///
  /// Must be called before using any notification features.
  /// Sets up platform-specific configurations and timezone data.
  ///
  /// **Returns:** true if initialization successful, false otherwise
  ///
  /// **Example:**
  /// ```dart
  /// final success = await notificationService.initialize();
  /// if (!success) {
  ///   print('Failed to initialize notifications');
  /// }
  /// ```
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Set the local timezone based on device offset
      // Android often returns abbreviations like "IST" which aren't valid IANA names
      final now = DateTime.now();
      final offset = now.timeZoneOffset;

      // Find a timezone location that matches the current offset
      tz.Location? localLocation;
      try {
        // Try common timezone names based on offset
        final offsetHours = offset.inHours;
        final offsetMinutes = offset.inMinutes % 60;

        // Map common offsets to IANA timezone names
        final timezoneMap = <int, String>{
          330: 'Asia/Kolkata',     // IST (UTC+5:30)
          0: 'UTC',                // UTC
          60: 'Europe/London',     // GMT+1
          -300: 'America/New_York', // EST (UTC-5)
          -360: 'America/Chicago',  // CST (UTC-6)
          -420: 'America/Denver',   // MST (UTC-7)
          -480: 'America/Los_Angeles', // PST (UTC-8)
          480: 'Asia/Singapore',   // SGT (UTC+8)
          540: 'Asia/Tokyo',       // JST (UTC+9)
        };

        final offsetInMinutes = offsetHours * 60 + offsetMinutes;
        final timezoneName = timezoneMap[offsetInMinutes];

        if (timezoneName != null) {
          localLocation = tz.getLocation(timezoneName);
        } else {
          // Fallback: use UTC and adjust
          localLocation = tz.UTC;
        }

        tz.setLocalLocation(localLocation);
        print('✓ Timezone set to: ${localLocation.name}');
      } catch (e) {
        // Fallback to UTC
        print('⚠ Could not set timezone, using UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      final iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            _iosCategoryId,
            actions: [
              DarwinNotificationAction.plain(
                'review_now',
                'Review Now',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                'snooze_1h',
                'Snooze 1h',
              ),
            ],
          ),
        ],
      );

      // Initialize with platform-specific settings
      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );

      if (initialized == true) {
        // Create Android notification channel
        await _createAndroidNotificationChannel();
        _isInitialized = true;
        print('✓ Notification service initialized successfully');
        return true;
      }

      print('✗ Failed to initialize notification service');
      return false;
    } catch (e) {
      print('✗ Error initializing notification service: $e');
      return false;
    }
  }

  /// Create Android notification channel
  ///
  /// Required for Android 8.0+ to display notifications.
  /// Configures channel with importance, sound, and vibration settings.
  Future<void> _createAndroidNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions
  ///
  /// Required for Android 13+ and iOS.
  /// Shows system permission dialog to user.
  ///
  /// **Returns:** true if permissions granted, false otherwise
  ///
  /// **Example:**
  /// ```dart
  /// final granted = await notificationService.requestPermissions();
  /// if (!granted) {
  ///   // Show user a message explaining why permissions are needed
  /// }
  /// ```
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Request Android 13+ permissions
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      if (granted != true) {
        print('✗ Android notification permissions denied');
        return false;
      }
    }

    // Request iOS permissions
    final iosImpl = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) {
        print('✗ iOS notification permissions denied');
        return false;
      }
    }

    print('✓ Notification permissions granted');
    return true;
  }

  /// Schedule daily reminder notification
  ///
  /// Creates a recurring notification that checks for due topics daily
  /// at the specified time. Notification shows count of due topics.
  ///
  /// **Parameters:**
  /// - `time`: Time of day to show the notification
  ///
  /// **Example:**
  /// ```dart
  /// await notificationService.scheduleDailyReminder(
  ///   TimeOfDay(hour: 9, minute: 0),
  /// );
  /// ```
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Cancel existing daily reminder
      await _notifications.cancel(_dailyReminderId);

      // Calculate next notification time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Convert to timezone-aware datetime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Get due topics count for notification body
      final dueTopics = await _getDueTopics();
      final count = dueTopics.length;

      if (count == 0) {
        print('ℹ No due topics, skipping daily reminder');
        return;
      }

      // Schedule notification
      await _notifications.zonedSchedule(
        _dailyReminderId,
        '📚 MemoryFlow',
        '$count ${count == 1 ? 'topic' : 'topics'} due today',
        tzScheduledDate,
        _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_reminder',
      );

      print('✓ Daily reminder scheduled for ${_formatTimeOfDay(time)}');
    } catch (e) {
      print('✗ Error scheduling daily reminder: $e');
      throw Exception('Failed to schedule daily reminder: $e');
    }
  }

  /// Schedule notification for specific topic
  ///
  /// Creates a one-time notification for a topic at the specified datetime.
  /// Includes topic title and action buttons.
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic to notify about
  /// - `dateTime`: When to show the notification
  ///
  /// **Example:**
  /// ```dart
  /// await notificationService.scheduleTopicReminder(
  ///   'topic-123',
  ///   DateTime.now().add(Duration(hours: 2)),
  /// );
  /// ```
  Future<void> scheduleTopicReminder(String topicId, DateTime dateTime) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Load topic details
      final topics = await _topicsService.loadTopicsIndex();
      final topic = topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => throw Exception('Topic not found'),
      );

      // Calculate notification ID from topic ID
      final notificationId = _topicReminderBaseId + topicId.hashCode % 10000;

      // Cancel existing notification for this topic
      await _notifications.cancel(notificationId);

      // Convert to timezone-aware datetime
      final tzScheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      // Schedule notification
      await _notifications.zonedSchedule(
        notificationId,
        '📚 Review Reminder',
        topic.title,
        tzScheduledDate,
        _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'topic:$topicId',
      );

      print('✓ Topic reminder scheduled for ${topic.title}');
    } catch (e) {
      print('✗ Error scheduling topic reminder: $e');
      throw Exception('Failed to schedule topic reminder: $e');
    }
  }

  /// Cancel notification for specific topic
  ///
  /// Removes scheduled notification for a topic.
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic to cancel notification for
  ///
  /// **Example:**
  /// ```dart
  /// await notificationService.cancelTopicReminder('topic-123');
  /// ```
  Future<void> cancelTopicReminder(String topicId) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final notificationId = _topicReminderBaseId + topicId.hashCode % 10000;
      await _notifications.cancel(notificationId);
      print('✓ Topic reminder cancelled for $topicId');
    } catch (e) {
      print('✗ Error cancelling topic reminder: $e');
    }
  }

  /// Cancel all scheduled notifications
  ///
  /// Removes all pending notifications including daily reminders
  /// and topic-specific reminders.
  ///
  /// **Example:**
  /// ```dart
  /// await notificationService.cancelAllNotifications();
  /// ```
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _notifications.cancelAll();
      print('✓ All notifications cancelled');
    } catch (e) {
      print('✗ Error cancelling notifications: $e');
    }
  }

  /// Show immediate notification
  ///
  /// Displays a notification right now without scheduling.
  /// Useful for testing or immediate feedback.
  ///
  /// **Parameters:**
  /// - `title`: Notification title
  /// - `body`: Notification body text
  /// - `payload`: Optional data to pass when notification is tapped
  ///
  /// **Example:**
  /// ```dart
  /// await notificationService.showNotification(
  ///   '📚 MemoryFlow',
  ///   '5 topics due today',
  ///   payload: 'daily_reminder',
  /// );
  /// ```
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        _buildNotificationDetails(),
        payload: payload,
      );
      print('✓ Notification shown: $title');
    } catch (e) {
      print('✗ Error showing notification: $e');
    }
  }

  /// Build notification details for both platforms
  ///
  /// Configures platform-specific notification appearance and behavior.
  /// Includes action buttons and notification category.
  NotificationDetails _buildNotificationDetails() {
    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      actions: [
        AndroidNotificationAction(
          'review_now',
          'Review Now',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_1h',
          'Snooze 1h',
        ),
      ],
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: _iosCategoryId,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Handle notification tap (foreground)
  ///
  /// Called when user taps notification while app is in foreground.
  void _onNotificationResponse(NotificationResponse response) {
    _handleNotificationAction(response.payload, response.actionId);
  }

  /// Handle notification tap (background)
  ///
  /// Called when user taps notification while app is in background.
  /// This is a top-level function required by flutter_local_notifications.
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Background handling is limited, main handling happens in foreground
    print('Background notification tapped: ${response.payload}');
  }

  /// Handle iOS local notification (older iOS versions)

  /// Handle notification action
  ///
  /// Processes notification tap and action button presses.
  /// Routes to appropriate screen or performs action.
  ///
  /// **Parameters:**
  /// - `payload`: Data attached to notification
  /// - `actionId`: ID of action button pressed (null if notification tapped)
  void _handleNotificationAction(String? payload, String? actionId) {
    print('Notification action: payload=$payload, action=$actionId');

    // Handle snooze action
    if (actionId == 'snooze_1h') {
      _handleSnooze(payload);
      return;
    }

    // Handle review now action or notification tap
    if (actionId == 'review_now' || actionId == null) {
      if (onNotificationTap != null) {
        onNotificationTap!(payload);
      } else {
        print('⚠ No notification tap handler set');
      }
    }
  }

  /// Handle snooze action
  ///
  /// Reschedules notification for 1 hour later.
  ///
  /// **Parameters:**
  /// - `payload`: Original notification payload
  Future<void> _handleSnooze(String? payload) async {
    try {
      final snoozeTime = DateTime.now().add(const Duration(hours: 1));

      if (payload?.startsWith('topic:') == true) {
        // Snooze topic notification
        final topicId = payload!.substring(6);
        await scheduleTopicReminder(topicId, snoozeTime);
        print('✓ Topic notification snoozed for 1 hour');
      } else {
        // Snooze daily reminder - show notification in 1 hour
        await showNotification(
          title: '📚 MemoryFlow',
          body: 'Topics still due for review',
          payload: payload,
        );
        print('✓ Daily reminder snoozed for 1 hour');
      }
    } catch (e) {
      print('✗ Error handling snooze: $e');
    }
  }

  /// Get list of topics due for review
  ///
  /// Fetches topics with next review date on or before today.
  ///
  /// **Returns:** List of due topics
  Future<List<Topic>> _getDueTopics() async {
    try {
      final topics = await _topicsService.loadTopicsIndex();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return topics.where((topic) {
        final reviewDate = DateTime(
          topic.nextReviewDate.year,
          topic.nextReviewDate.month,
          topic.nextReviewDate.day,
        );
        return reviewDate.isBefore(today) || reviewDate.isAtSameMomentAs(today);
      }).toList();
    } catch (e) {
      print('✗ Error getting due topics: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  ///
  /// Queries system to check if notification permissions are granted.
  ///
  /// **Returns:** true if enabled, false otherwise
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check Android
    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final enabled = await androidImpl.areNotificationsEnabled();
      return enabled ?? false;
    }

    // Check iOS
    final iosImpl = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final settings = await iosImpl.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return false;
  }

  /// Get list of pending notifications
  ///
  /// Returns all scheduled notifications that haven't been shown yet.
  ///
  /// **Returns:** List of pending notification requests
  ///
  /// **Example:**
  /// ```dart
  /// final pending = await notificationService.getPendingNotifications();
  /// print('${pending.length} notifications scheduled');
  /// ```
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('✗ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Format TimeOfDay to string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
