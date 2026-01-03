import '../models/topic.dart';
import 'database_service.dart';
import 'notification_service.dart';

/// Service for managing spaced repetition scheduling
///
/// This service implements a spaced repetition algorithm based on predefined
/// intervals. Topics are reviewed at increasing intervals to optimize long-term
/// retention.
///
/// **Interval Stages:**
/// - Stage 0: 1 day (initial learning)
/// - Stage 1: 3 days (short-term retention)
/// - Stage 2: 7 days (1 week)
/// - Stage 3: 14 days (2 weeks)
/// - Stage 4+: 30 days (long-term maintenance)
///
/// **Example Usage:**
/// ```dart
/// final service = SpacedRepetitionService();
///
/// // Mark a topic as reviewed
/// final updated = await service.markAsReviewed('topic-123');
/// print('Next review: ${updated.nextReviewDate}');
///
/// // Get topics due today
/// final dueTopics = await service.getDueTopics();
/// print('${dueTopics.length} topics need review');
///
/// // Reset a topic's progress
/// await service.resetTopic('topic-123');
/// ```
///
/// Uses singleton pattern to ensure consistent scheduling across the app.
class SpacedRepetitionService {
  // Singleton pattern
  static final SpacedRepetitionService _instance = SpacedRepetitionService._internal();

  /// Factory constructor returns the singleton instance
  factory SpacedRepetitionService() => _instance;

  /// Private constructor
  SpacedRepetitionService._internal();

  /// Database service instance
  final DatabaseService _db = DatabaseService();

  /// Spaced repetition interval stages in days
  ///
  /// Each stage represents the number of days until the next review.
  /// After stage 4, the interval remains at 30 days for maintenance reviews.
  ///
  /// - Stage 0: 1 day - Initial learning, rapid reinforcement
  /// - Stage 1: 3 days - Short-term memory consolidation
  /// - Stage 2: 7 days - Weekly review checkpoint
  /// - Stage 3: 14 days - Bi-weekly review
  /// - Stage 4+: 30 days - Monthly maintenance (long-term retention)
  static const List<int> intervals = [1, 3, 7, 14, 30];

  /// Maximum stage index (for intervals array)
  static const int maxStageIndex = 4;

  /// Total number of stages tracked
  static const int totalStages = 5;

  // ============================================================================
  // Core Scheduling Methods
  // ============================================================================

  /// Calculate the next review date based on current stage and last review
  ///
  /// **Parameters:**
  /// - `currentStage`: The current stage index (0-based)
  /// - `lastReviewed`: When the topic was last reviewed
  ///
  /// **Returns:** DateTime for the next scheduled review
  ///
  /// **Logic:**
  /// - Stage 0-4: Uses predefined intervals (1, 3, 7, 14, 30 days)
  /// - Stage 5+: Continues using 30-day intervals for maintenance
  ///
  /// **Example:**
  /// ```dart
  /// final lastReview = DateTime(2024, 1, 1);
  ///
  /// // Stage 0: Next review in 1 day
  /// final next0 = calculateNextReviewDate(0, lastReview);
  /// // Returns: 2024-01-02
  ///
  /// // Stage 2: Next review in 7 days
  /// final next2 = calculateNextReviewDate(2, lastReview);
  /// // Returns: 2024-01-08
  ///
  /// // Stage 5+: Next review in 30 days (maintenance)
  /// final next5 = calculateNextReviewDate(5, lastReview);
  /// // Returns: 2024-01-31
  /// ```
  DateTime calculateNextReviewDate(int currentStage, DateTime lastReviewed) {
    // Determine the interval to use
    int daysToAdd;

    if (currentStage < 0) {
      // Safety check: treat negative stages as stage 0
      daysToAdd = intervals[0];
      print('Warning: Negative stage ($currentStage) detected, using stage 0 interval');
    } else if (currentStage <= maxStageIndex) {
      // Use the interval from the array for stages 0-4
      daysToAdd = intervals[currentStage];
    } else {
      // For stages beyond the array, continue using the last interval (30 days)
      daysToAdd = intervals[maxStageIndex];
    }

    // Calculate next review date by adding days to last reviewed date
    final nextReview = lastReviewed.add(Duration(days: daysToAdd));

    print('Stage $currentStage: Adding $daysToAdd days → Next review: ${_formatDate(nextReview)}');

    return nextReview;
  }

  /// Mark a topic as reviewed and advance to the next stage
  ///
  /// This is the primary method for updating topic review status.
  /// It handles:
  /// - Advancing to the next stage
  /// - Calculating the new review date
  /// - Updating timestamps and counters
  /// - Saving changes to the database
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic to mark as reviewed
  /// - `returnToAuto`: If true and topic uses custom schedule, switch back to automatic scheduling
  ///
  /// **Returns:** Updated Topic object
  ///
  /// **Throws:** Exception if topic not found or update fails
  ///
  /// **Example:**
  /// ```dart
  /// // Basic usage - mark topic as reviewed
  /// final updated = await service.markAsReviewed('topic-123');
  /// print('Stage: ${updated.currentStage}');
  /// print('Next review: ${updated.nextReviewDate}');
  ///
  /// // Switch from custom to automatic scheduling
  /// final switched = await service.markAsReviewed(
  ///   'topic-123',
  ///   returnToAuto: true,
  /// );
  /// print('Using auto schedule: ${!switched.useCustomSchedule}');
  /// ```
  Future<Topic> markAsReviewed(String topicId, {bool returnToAuto = false}) async {
    try {
      // Fetch current topic from database
      final topic = await _db.getTopic(topicId);

      if (topic == null) {
        throw Exception('Topic with ID $topicId not found');
      }

      print('\n=== Marking Topic as Reviewed ===');
      print('Topic: ${topic.title}');
      print('Current stage: ${topic.currentStage}');
      print('Review count: ${topic.reviewCount}');

      // Check if using custom schedule
      if (topic.useCustomSchedule && !returnToAuto) {
        print('⚠️ Topic uses custom schedule');
        // For custom schedules, just update the review timestamp and count
        // Don't advance stage or recalculate dates
        final updated = topic.copyWith(
          lastReviewedAt: DateTime.now(),
          reviewCount: topic.reviewCount + 1,
        );

        await _db.updateTopic(updated);
        print('✓ Updated review timestamp (custom schedule maintained)');
        return updated;
      }

      // Standard spaced repetition flow
      final now = DateTime.now();
      final nextStage = topic.currentStage + 1;

      // Calculate next review date based on new stage
      // Use 9:00 AM as the default notification time
      final baseDate = DateTime(now.year, now.month, now.day, 9, 0);
      final nextReviewDate = calculateNextReviewDate(nextStage, baseDate);

      // Create updated topic
      final updatedTopic = topic.copyWith(
        currentStage: nextStage,
        nextReviewDate: nextReviewDate,
        lastReviewedAt: now,
        reviewCount: topic.reviewCount + 1,
        useCustomSchedule: returnToAuto ? false : topic.useCustomSchedule,
        customReviewDatetime: returnToAuto ? null : topic.customReviewDatetime,
      );

      // Save to database
      final result = await _db.updateTopic(updatedTopic);

      if (result <= 0) {
        throw Exception('Failed to update topic in database');
      }

      // Schedule notification for next review
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleTopicReminder(topicId, nextReviewDate);
        print('✓ Notification scheduled for next review');
      } catch (e) {
        print('⚠ Failed to schedule notification: $e');
        // Don't fail the operation if notification scheduling fails
      }

      print('✓ Topic advanced to stage $nextStage');
      print('✓ Next review: ${_formatDate(nextReviewDate)}');
      print('✓ Total reviews: ${updatedTopic.reviewCount}');
      print('=================================\n');

      return updatedTopic;
    } catch (e) {
      print('❌ Error marking topic as reviewed: $e');
      throw Exception('Failed to mark topic as reviewed: $e');
    }
  }

  /// Reset a topic's spaced repetition progress
  ///
  /// This sets the topic back to the beginning of the review cycle.
  /// Use this when:
  /// - User wants to relearn a topic from scratch
  /// - Topic content has been significantly updated
  /// - User feels they need to start over
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic to reset
  ///
  /// **Returns:** Updated Topic object with reset progress
  ///
  /// **Throws:** Exception if topic not found or update fails
  ///
  /// **Changes made:**
  /// - currentStage → 0
  /// - nextReviewDate → tomorrow (to give immediate review opportunity)
  /// - reviewCount → 0
  /// - lastReviewedAt → null
  /// - useCustomSchedule → false
  /// - customReviewDatetime → null
  ///
  /// **Example:**
  /// ```dart
  /// // Reset topic progress
  /// final reset = await service.resetTopic('topic-123');
  ///
  /// print('Stage: ${reset.currentStage}'); // 0
  /// print('Reviews: ${reset.reviewCount}'); // 0
  /// print('Next: ${reset.nextReviewDate}'); // Tomorrow
  /// ```
  Future<Topic> resetTopic(String topicId) async {
    try {
      // Fetch current topic
      final topic = await _db.getTopic(topicId);

      if (topic == null) {
        throw Exception('Topic with ID $topicId not found');
      }

      print('\n=== Resetting Topic Progress ===');
      print('Topic: ${topic.title}');
      print('Previous stage: ${topic.currentStage}');
      print('Previous reviews: ${topic.reviewCount}');

      // Calculate tomorrow's date for next review
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Reset to stage 0
      final resetTopic = topic.copyWith(
        currentStage: 0,
        nextReviewDate: tomorrow,
        reviewCount: 0,
        lastReviewedAt: null,
        useCustomSchedule: false,
        customReviewDatetime: null,
      );

      // Save to database
      final result = await _db.updateTopic(resetTopic);

      if (result <= 0) {
        throw Exception('Failed to update topic in database');
      }

      // Schedule notification for tomorrow
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleTopicReminder(topicId, tomorrow);
        print('✓ Notification scheduled for tomorrow');
      } catch (e) {
        print('⚠ Failed to schedule notification: $e');
      }

      print('✓ Reset to stage 0');
      print('✓ Next review: ${_formatDate(tomorrow)} (tomorrow)');
      print('✓ Review count cleared');
      print('================================\n');

      return resetTopic;
    } catch (e) {
      print('❌ Error resetting topic: $e');
      throw Exception('Failed to reset topic: $e');
    }
  }

  // ============================================================================
  // Topic Retrieval Methods
  // ============================================================================

  /// Get all topics that are due for review now
  ///
  /// Returns topics where the next review date is today or earlier.
  /// This includes both overdue topics and topics due today.
  ///
  /// **Returns:** List of topics needing review, sorted by review date (oldest first)
  ///
  /// **Example:**
  /// ```dart
  /// final dueTopics = await service.getDueTopics();
  ///
  /// if (dueTopics.isEmpty) {
  ///   print('All caught up! 🎉');
  /// } else {
  ///   print('You have ${dueTopics.length} topics to review');
  ///   for (var topic in dueTopics) {
  ///     print('- ${topic.title}');
  ///   }
  /// }
  /// ```
  Future<List<Topic>> getDueTopics() async {
    try {
      final topics = await _db.getDueTopics();

      print('Found ${topics.length} topics due for review');

      return topics;
    } catch (e) {
      print('Error getting due topics: $e');
      throw Exception('Failed to get due topics: $e');
    }
  }

  /// Get topics that will be due within the specified number of days
  ///
  /// Use this to plan upcoming reviews or show a preview of what's coming.
  ///
  /// **Parameters:**
  /// - `days`: Number of days to look ahead (inclusive)
  ///
  /// **Returns:** List of topics due in the next X days (excluding already due topics)
  ///
  /// **Example:**
  /// ```dart
  /// // Get topics due in the next 7 days
  /// final upcoming = await service.getUpcomingTopics(7);
  ///
  /// print('Upcoming this week:');
  /// for (var topic in upcoming) {
  ///   final daysUntil = topic.nextReviewDate.difference(DateTime.now()).inDays;
  ///   print('- ${topic.title} (in $daysUntil days)');
  /// }
  /// ```
  Future<List<Topic>> getUpcomingTopics(int days) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      // Get all topics
      final allTopics = await _db.getAllTopics();

      // Filter topics that are upcoming (not already due)
      final upcoming = allTopics.where((topic) {
        return topic.nextReviewDate.isAfter(now) &&
            topic.nextReviewDate.isBefore(endDate);
      }).toList()
        ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

      print('Found ${upcoming.length} topics due in next $days days');

      return upcoming;
    } catch (e) {
      print('Error getting upcoming topics: $e');
      throw Exception('Failed to get upcoming topics: $e');
    }
  }

  /// Get all overdue topics (past their review date)
  ///
  /// Returns topics where next review date is in the past (before today).
  ///
  /// **Returns:** List of overdue topics, sorted by date (most overdue first)
  ///
  /// **Example:**
  /// ```dart
  /// final overdue = await service.getOverdueTopics();
  ///
  /// if (overdue.isNotEmpty) {
  ///   print('⚠️ You have ${overdue.length} overdue topics:');
  ///   for (var topic in overdue) {
  ///     final daysPast = DateTime.now().difference(topic.nextReviewDate).inDays;
  ///     print('- ${topic.title} ($daysPast days overdue)');
  ///   }
  /// }
  /// ```
  Future<List<Topic>> getOverdueTopics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get all topics
      final allTopics = await _db.getAllTopics();

      // Filter overdue topics (before today, not including today)
      final overdue = allTopics.where((topic) {
        return topic.nextReviewDate.isBefore(today);
      }).toList()
        ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate)); // Oldest first

      print('Found ${overdue.length} overdue topics');

      return overdue;
    } catch (e) {
      print('Error getting overdue topics: $e');
      throw Exception('Failed to get overdue topics: $e');
    }
  }

  // ============================================================================
  // Custom Schedule Management
  // ============================================================================

  /// Set a custom review schedule for a topic
  ///
  /// This allows users to override the automatic spaced repetition schedule
  /// and set a specific date/time for review.
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic
  /// - `customDate`: Custom date/time for next review
  ///
  /// **Returns:** Updated Topic object
  ///
  /// **Throws:** Exception if topic not found or update fails
  ///
  /// **Example:**
  /// ```dart
  /// // Set review for next Monday at 9 AM
  /// final nextMonday = DateTime(2024, 1, 8, 9, 0);
  /// final updated = await service.setCustomSchedule('topic-123', nextMonday);
  ///
  /// print('Custom review: ${updated.customReviewDatetime}');
  /// print('Using custom: ${updated.useCustomSchedule}'); // true
  /// ```
  Future<Topic> setCustomSchedule(String topicId, DateTime customDate) async {
    try {
      final topic = await _db.getTopic(topicId);

      if (topic == null) {
        throw Exception('Topic with ID $topicId not found');
      }

      print('\n=== Setting Custom Schedule ===');
      print('Topic: ${topic.title}');
      print('Custom date: ${_formatDate(customDate)}');

      final updated = topic.copyWith(
        useCustomSchedule: true,
        customReviewDatetime: customDate,
        nextReviewDate: customDate, // Sync the next review date
      );

      await _db.updateTopic(updated);

      print('✓ Custom schedule set');
      print('==============================\n');

      return updated;
    } catch (e) {
      print('❌ Error setting custom schedule: $e');
      throw Exception('Failed to set custom schedule: $e');
    }
  }

  /// Remove custom schedule and return to automatic scheduling
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic
  /// - `recalculate`: If true, recalculate next review based on current stage
  ///
  /// **Returns:** Updated Topic object
  ///
  /// **Throws:** Exception if topic not found or update fails
  ///
  /// **Example:**
  /// ```dart
  /// // Remove custom schedule and recalculate
  /// final updated = await service.removeCustomSchedule(
  ///   'topic-123',
  ///   recalculate: true,
  /// );
  ///
  /// print('Back to auto schedule');
  /// print('Next review: ${updated.nextReviewDate}');
  /// ```
  Future<Topic> removeCustomSchedule(String topicId, {bool recalculate = true}) async {
    try {
      final topic = await _db.getTopic(topicId);

      if (topic == null) {
        throw Exception('Topic with ID $topicId not found');
      }

      print('\n=== Removing Custom Schedule ===');
      print('Topic: ${topic.title}');

      DateTime nextReview;
      if (recalculate) {
        // Recalculate based on current stage
        final lastReview = topic.lastReviewedAt ?? DateTime.now();
        nextReview = calculateNextReviewDate(topic.currentStage, lastReview);
        print('Recalculated next review: ${_formatDate(nextReview)}');
      } else {
        // Keep existing next review date
        nextReview = topic.nextReviewDate;
        print('Keeping existing next review: ${_formatDate(nextReview)}');
      }

      final updated = topic.copyWith(
        useCustomSchedule: false,
        customReviewDatetime: null,
        nextReviewDate: nextReview,
      );

      await _db.updateTopic(updated);

      print('✓ Returned to automatic scheduling');
      print('================================\n');

      return updated;
    } catch (e) {
      print('❌ Error removing custom schedule: $e');
      throw Exception('Failed to remove custom schedule: $e');
    }
  }

  /// Reschedule a topic to a specific datetime
  ///
  /// Convenience method that combines setting the review date with
  /// choosing between custom and automatic scheduling.
  ///
  /// **Parameters:**
  /// - `topicId`: ID of the topic to reschedule
  /// - `newDateTime`: New review datetime
  /// - `isCustom`: If true, marks as custom schedule; if false, updates automatic schedule
  ///
  /// **Returns:** Updated Topic object
  ///
  /// **Throws:** Exception if topic not found or update fails
  ///
  /// **Example:**
  /// ```dart
  /// // Set custom schedule
  /// final updated = await service.rescheduleTopicTo(
  ///   'topic-123',
  ///   DateTime.now().add(Duration(days: 3)),
  ///   isCustom: true,
  /// );
  ///
  /// // Update automatic schedule
  /// final updated2 = await service.rescheduleTopicTo(
  ///   'topic-456',
  ///   DateTime.now().add(Duration(days: 1)),
  ///   isCustom: false,
  /// );
  /// ```
  Future<Topic> rescheduleTopicTo(
    String topicId,
    DateTime newDateTime, {
    required bool isCustom,
  }) async {
    try {
      final topic = await _db.getTopic(topicId);

      if (topic == null) {
        throw Exception('Topic with ID $topicId not found');
      }

      print('\n=== Rescheduling Topic ===');
      print('Topic: ${topic.title}');
      print('New datetime: ${_formatDate(newDateTime)}');
      print('Is custom: $isCustom');

      final updated = topic.copyWith(
        nextReviewDate: newDateTime,
        useCustomSchedule: isCustom,
        customReviewDatetime: isCustom ? newDateTime : null,
      );

      await _db.updateTopic(updated);

      // Schedule notification for the new date
      try {
        final notificationService = NotificationService();
        await notificationService.scheduleTopicReminder(topicId, newDateTime);
        print('✓ Notification scheduled for new date');
      } catch (e) {
        print('⚠ Failed to schedule notification: $e');
      }

      print('✓ Topic rescheduled successfully');
      print('=========================\n');

      return updated;
    } catch (e) {
      print('❌ Error rescheduling topic: $e');
      throw Exception('Failed to reschedule topic: $e');
    }
  }

  // ============================================================================
  // Statistics and Analytics
  // ============================================================================

  /// Get scheduling statistics for all topics
  ///
  /// Returns useful metrics about the review schedule.
  ///
  /// **Returns:** Map with statistics
  ///
  /// **Example:**
  /// ```dart
  /// final stats = await service.getSchedulingStats();
  ///
  /// print('Due today: ${stats['dueToday']}');
  /// print('Overdue: ${stats['overdue']}');
  /// print('Total reviews: ${stats['totalReviews']}');
  /// ```
  Future<Map<String, dynamic>> getSchedulingStats() async {
    try {
      final allTopics = await _db.getAllTopics();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final dueToday = allTopics.where((t) =>
          t.nextReviewDate.isAfter(today) &&
          t.nextReviewDate.isBefore(todayEnd)
      ).length;

      final overdue = allTopics.where((t) =>
          t.nextReviewDate.isBefore(today)
      ).length;

      final upcoming7Days = allTopics.where((t) =>
          t.nextReviewDate.isAfter(todayEnd) &&
          t.nextReviewDate.isBefore(now.add(const Duration(days: 7)))
      ).length;

      final totalReviews = allTopics.fold<int>(
        0,
        (sum, topic) => sum + topic.reviewCount,
      );

      final customSchedules = allTopics.where((t) => t.useCustomSchedule).length;

      // Count topics by stage
      final stageDistribution = <int, int>{};
      for (var topic in allTopics) {
        stageDistribution[topic.currentStage] =
            (stageDistribution[topic.currentStage] ?? 0) + 1;
      }

      return {
        'totalTopics': allTopics.length,
        'dueToday': dueToday,
        'overdue': overdue,
        'upcoming7Days': upcoming7Days,
        'totalReviews': totalReviews,
        'customSchedules': customSchedules,
        'averageReviews': allTopics.isEmpty
            ? 0.0
            : (totalReviews / allTopics.length).toStringAsFixed(1),
        'stageDistribution': stageDistribution,
      };
    } catch (e) {
      print('Error getting scheduling stats: $e');
      throw Exception('Failed to get scheduling stats: $e');
    }
  }

  /// Get the description for a given stage number
  ///
  /// **Parameters:**
  /// - `stage`: Stage number (0-based)
  ///
  /// **Returns:** Human-readable description of the stage
  ///
  /// **Example:**
  /// ```dart
  /// print(service.getStageDescription(0)); // "1 day"
  /// print(service.getStageDescription(2)); // "1 week"
  /// print(service.getStageDescription(5)); // "1 month"
  /// ```
  String getStageDescription(int stage) {
    if (stage < 0 || stage >= intervals.length) {
      return '1 month'; // Default for stages beyond the array
    }

    final days = intervals[stage];
    if (days == 1) return '1 day';
    if (days == 7) return '1 week';
    if (days == 14) return '2 weeks';
    if (days == 30) return '1 month';
    return '$days days';
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Format a DateTime for logging
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
