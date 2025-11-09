import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF8B5CF6); // Purple
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color error = danger; // Alias for danger
  static const Color textSecondary = gray500; // Text secondary color

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
}

/// Text styles used throughout the app
class AppTextStyles {
  // Display Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  // Headline Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  // Title Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

/// Spacing values for consistent padding and margins
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Border radius values
class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double round = 9999.0;
}

/// Animation durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Spaced repetition interval stages (in days)
class SpacedRepetitionIntervals {
  static const List<int> intervals = [1, 3, 7, 14, 30];

  /// Get the next interval based on current stage
  static int getNextInterval(int currentStage) {
    if (currentStage >= intervals.length - 1) {
      return intervals.last;
    }
    return intervals[currentStage + 1];
  }

  /// Get interval for a specific stage
  static int getIntervalForStage(int stage) {
    if (stage < 0) return intervals.first;
    if (stage >= intervals.length) return intervals.last;
    return intervals[stage];
  }

  /// Calculate next review date
  static DateTime calculateNextReviewDate(int stage, {DateTime? fromDate}) {
    final baseDate = fromDate ?? DateTime.now();
    final interval = getIntervalForStage(stage);
    return baseDate.add(Duration(days: interval));
  }
}

/// App-wide configuration constants
class AppConfig {
  static const String appName = 'MemoryFlow';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'memory_flow.db';
  static const int databaseVersion = 1;

  // Notifications
  static const String notificationChannelId = 'memory_flow_reviews';
  static const String notificationChannelName = 'Review Reminders';
  static const String notificationChannelDescription =
      'Notifications for scheduled card reviews';

  // Shared Preferences Keys
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyNotificationsEnabled = 'notifications_enabled';
  static const String prefKeyDailyGoal = 'daily_goal';
  static const String prefKeyLastSyncTime = 'last_sync_time';

  // Default values
  static const int defaultDailyGoal = 20;
  static const int maxCardsPerSession = 50;
  static const int minCardInterval = 1;
  static const int maxCardInterval = 365;
}

/// Card difficulty levels
enum CardDifficulty {
  again,
  hard,
  good,
  easy;

  String get label {
    switch (this) {
      case CardDifficulty.again:
        return 'Again';
      case CardDifficulty.hard:
        return 'Hard';
      case CardDifficulty.good:
        return 'Good';
      case CardDifficulty.easy:
        return 'Easy';
    }
  }

  Color get color {
    switch (this) {
      case CardDifficulty.again:
        return AppColors.danger;
      case CardDifficulty.hard:
        return AppColors.warning;
      case CardDifficulty.good:
        return AppColors.success;
      case CardDifficulty.easy:
        return AppColors.primary;
    }
  }
}
