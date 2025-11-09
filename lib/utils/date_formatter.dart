import 'package:intl/intl.dart';

/// Utility class for date formatting
class DateFormatter {
  /// Format date as 'Jan 1, 2025'
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Format date as 'January 1, 2025'
  static String formatDateLong(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Format time as '3:30 PM'
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format date and time as 'Jan 1, 2025 at 3:30 PM'
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
  }

  /// Format as relative time (e.g., 'Just now', '5 minutes ago', 'Yesterday')
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Format duration as 'X minutes Y seconds'
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '$hours hour${hours == 1 ? '' : 's'} $minutes minute${minutes == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return '$minutes minute${minutes == 1 ? '' : 's'} $seconds second${seconds == 1 ? '' : 's'}';
    } else {
      final seconds = duration.inSeconds;
      return '$seconds second${seconds == 1 ? '' : 's'}';
    }
  }

  /// Format duration as compact string (e.g., '5m 30s', '1h 20m')
  static String formatDurationCompact(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds.remainder(60);
      return '${minutes}m ${seconds}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get days until a date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final start = startOfDay(now);
    final end = startOfDay(date);
    return end.difference(start).inDays;
  }

  /// Format days until as human readable string
  static String formatDaysUntil(DateTime date) {
    final days = daysUntil(date);

    if (days < 0) {
      return 'Overdue';
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else if (days < 7) {
      return 'In $days days';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return 'In $weeks week${weeks == 1 ? '' : 's'}';
    } else {
      final months = (days / 30).floor();
      return 'In $months month${months == 1 ? '' : 's'}';
    }
  }
}
