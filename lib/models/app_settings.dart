import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// App settings model
class AppSettings {
  // Notifications
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final bool eveningReminderEnabled;
  final TimeOfDay eveningReminderTime;
  final bool overdueAlertsEnabled;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  // Cloud Backup
  final bool googleDriveConnected;
  final bool autoBackupEnabled;
  final DateTime? lastBackupTime;

  // Review Settings
  final List<int> intervalStages; // in days

  // Appearance
  final ThemeMode themeMode;
  final String fontSize; // 'small', 'medium', 'large'
  final AppColorScheme colorScheme; // Color theme

  const AppSettings({
    // Notifications defaults
    this.dailyReminderEnabled = true,
    this.dailyReminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.eveningReminderEnabled = false,
    this.eveningReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.overdueAlertsEnabled = true,
    this.quietHoursEnabled = false,
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 8, minute: 0),

    // Cloud Backup defaults
    this.googleDriveConnected = false,
    this.autoBackupEnabled = false,
    this.lastBackupTime,

    // Review Settings defaults
    this.intervalStages = const [1, 3, 7, 14, 30],

    // Appearance defaults
    this.themeMode = ThemeMode.system,
    this.fontSize = 'medium',
    this.colorScheme = AppColorScheme.modernProfessional,
  });

  AppSettings copyWith({
    bool? dailyReminderEnabled,
    TimeOfDay? dailyReminderTime,
    bool? eveningReminderEnabled,
    TimeOfDay? eveningReminderTime,
    bool? overdueAlertsEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? googleDriveConnected,
    bool? autoBackupEnabled,
    DateTime? lastBackupTime,
    List<int>? intervalStages,
    ThemeMode? themeMode,
    String? fontSize,
    AppColorScheme? colorScheme,
  }) {
    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      eveningReminderEnabled: eveningReminderEnabled ?? this.eveningReminderEnabled,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      overdueAlertsEnabled: overdueAlertsEnabled ?? this.overdueAlertsEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      googleDriveConnected: googleDriveConnected ?? this.googleDriveConnected,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      intervalStages: intervalStages ?? this.intervalStages,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'dailyReminderEnabled': dailyReminderEnabled,
      'dailyReminderHour': dailyReminderTime.hour,
      'dailyReminderMinute': dailyReminderTime.minute,
      'eveningReminderEnabled': eveningReminderEnabled,
      'eveningReminderHour': eveningReminderTime.hour,
      'eveningReminderMinute': eveningReminderTime.minute,
      'overdueAlertsEnabled': overdueAlertsEnabled,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStartHour': quietHoursStart.hour,
      'quietHoursStartMinute': quietHoursStart.minute,
      'quietHoursEndHour': quietHoursEnd.hour,
      'quietHoursEndMinute': quietHoursEnd.minute,
      'googleDriveConnected': googleDriveConnected,
      'autoBackupEnabled': autoBackupEnabled,
      'lastBackupTime': lastBackupTime?.millisecondsSinceEpoch,
      'intervalStages': intervalStages.join(','),
      'themeMode': themeMode.index,
      'fontSize': fontSize,
      'colorScheme': colorScheme.index,
    };
  }

  /// Create from Map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      dailyReminderEnabled: map['dailyReminderEnabled'] ?? true,
      dailyReminderTime: TimeOfDay(
        hour: map['dailyReminderHour'] ?? 9,
        minute: map['dailyReminderMinute'] ?? 0,
      ),
      eveningReminderEnabled: map['eveningReminderEnabled'] ?? false,
      eveningReminderTime: TimeOfDay(
        hour: map['eveningReminderHour'] ?? 20,
        minute: map['eveningReminderMinute'] ?? 0,
      ),
      overdueAlertsEnabled: map['overdueAlertsEnabled'] ?? true,
      quietHoursEnabled: map['quietHoursEnabled'] ?? false,
      quietHoursStart: TimeOfDay(
        hour: map['quietHoursStartHour'] ?? 22,
        minute: map['quietHoursStartMinute'] ?? 0,
      ),
      quietHoursEnd: TimeOfDay(
        hour: map['quietHoursEndHour'] ?? 8,
        minute: map['quietHoursEndMinute'] ?? 0,
      ),
      googleDriveConnected: map['googleDriveConnected'] ?? false,
      autoBackupEnabled: map['autoBackupEnabled'] ?? false,
      lastBackupTime: map['lastBackupTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastBackupTime'])
          : null,
      intervalStages: map['intervalStages'] != null
          ? (map['intervalStages'] as String).split(',').map((e) => int.parse(e)).toList()
          : [1, 3, 7, 14, 30],
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      fontSize: map['fontSize'] ?? 'medium',
      colorScheme: AppColorScheme.values[map['colorScheme'] ?? 0],
    );
  }
}
