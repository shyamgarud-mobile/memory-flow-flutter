import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:memory_flow/services/spaced_repetition_service.dart';
import 'package:memory_flow/services/database_service.dart';
import 'package:memory_flow/models/topic.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late SpacedRepetitionService srService;
  late DatabaseService dbService;

  setUp(() async {
    srService = SpacedRepetitionService();
    dbService = DatabaseService();
    await dbService.deleteDatabase();
  });

  tearDown(() async {
    await dbService.close();
  });

  group('Interval Calculation', () {
    test('should calculate correct intervals for all stages', () {
      final baseDate = DateTime(2024, 1, 1);

      // Stage 0: 1 day
      final stage0 = srService.calculateNextReviewDate(0, baseDate);
      expect(stage0, DateTime(2024, 1, 2));

      // Stage 1: 3 days
      final stage1 = srService.calculateNextReviewDate(1, baseDate);
      expect(stage1, DateTime(2024, 1, 4));

      // Stage 2: 7 days
      final stage2 = srService.calculateNextReviewDate(2, baseDate);
      expect(stage2, DateTime(2024, 1, 8));

      // Stage 3: 14 days
      final stage3 = srService.calculateNextReviewDate(3, baseDate);
      expect(stage3, DateTime(2024, 1, 15));

      // Stage 4: 30 days
      final stage4 = srService.calculateNextReviewDate(4, baseDate);
      expect(stage4, DateTime(2024, 1, 31));
    });

    test('should use 30 days for stages beyond max', () {
      final baseDate = DateTime(2024, 1, 1);

      final stage5 = srService.calculateNextReviewDate(5, baseDate);
      expect(stage5, DateTime(2024, 1, 31));

      final stage10 = srService.calculateNextReviewDate(10, baseDate);
      expect(stage10, DateTime(2024, 1, 31));
    });

    test('should handle negative stages safely', () {
      final baseDate = DateTime(2024, 1, 1);

      final negativeStage = srService.calculateNextReviewDate(-1, baseDate);
      expect(negativeStage, DateTime(2024, 1, 2)); // Should use stage 0 interval
    });
  });

  group('Mark as Reviewed', () {
    test('should advance topic to next stage', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final updated = await srService.markAsReviewed('test-1');

      expect(updated.currentStage, 1);
      expect(updated.reviewCount, 1);
      expect(updated.lastReviewedAt, isNotNull);
    });

    test('should increment review count correctly', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 2,
        nextReviewDate: DateTime.now(),
        reviewCount: 5,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final updated = await srService.markAsReviewed('test-1');

      expect(updated.reviewCount, 6);
      expect(updated.currentStage, 3);
    });

    test('should handle custom schedule when marking as reviewed', () async {
      final customDate = DateTime.now().add(Duration(days: 10));

      final topic = Topic(
        id: 'test-1',
        title: 'Custom Topic',
        filePath: '/path/custom.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: customDate,
        reviewCount: 0,
        tags: [],
        isFavorite: false,
        useCustomSchedule: true,
        customReviewDatetime: customDate,
      );

      await dbService.insertTopic(topic);

      final updated = await srService.markAsReviewed('test-1');

      // Should not advance stage when using custom schedule
      expect(updated.currentStage, 0);
      expect(updated.reviewCount, 1);
      expect(updated.useCustomSchedule, true);
    });

    test('should switch to auto schedule when returnToAuto is true', () async {
      final customDate = DateTime.now().add(Duration(days: 10));

      final topic = Topic(
        id: 'test-1',
        title: 'Custom Topic',
        filePath: '/path/custom.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: customDate,
        reviewCount: 0,
        tags: [],
        isFavorite: false,
        useCustomSchedule: true,
        customReviewDatetime: customDate,
      );

      await dbService.insertTopic(topic);

      final updated = await srService.markAsReviewed('test-1', returnToAuto: true);

      expect(updated.currentStage, 1);
      expect(updated.useCustomSchedule, false);
      expect(updated.customReviewDatetime, isNull);
    });

    test('should throw exception for non-existent topic', () async {
      expect(
        () => srService.markAsReviewed('non-existent'),
        throwsException,
      );
    });
  });

  group('Reset Topic', () {
    test('should reset topic to stage 0', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Advanced Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 3,
        nextReviewDate: DateTime.now().add(Duration(days: 14)),
        reviewCount: 10,
        lastReviewedAt: DateTime.now().subtract(Duration(days: 7)),
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final reset = await srService.resetTopic('test-1');

      expect(reset.currentStage, 0);
      expect(reset.reviewCount, 0);
      expect(reset.lastReviewedAt, isNull);
      expect(reset.useCustomSchedule, false);
      expect(reset.customReviewDatetime, isNull);
    });

    test('should set next review to tomorrow when resetting', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 2,
        nextReviewDate: DateTime.now().add(Duration(days: 7)),
        reviewCount: 5,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final reset = await srService.resetTopic('test-1');
      final tomorrow = DateTime.now().add(Duration(days: 1));

      expect(reset.nextReviewDate.day, tomorrow.day);
      expect(reset.nextReviewDate.month, tomorrow.month);
      expect(reset.nextReviewDate.year, tomorrow.year);
    });

    test('should throw exception for non-existent topic', () async {
      expect(
        () => srService.resetTopic('non-existent'),
        throwsException,
      );
    });
  });

  group('Get Due Topics', () {
    test('should return topics due for review', () async {
      final dueTopic = Topic(
        id: 'due-1',
        title: 'Due Topic',
        filePath: '/path/due.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().subtract(Duration(hours: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final futureTopic = Topic(
        id: 'future-1',
        title: 'Future Topic',
        filePath: '/path/future.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(dueTopic);
      await dbService.insertTopic(futureTopic);

      final dueTopics = await srService.getDueTopics();

      expect(dueTopics.length, 1);
      expect(dueTopics.first.id, 'due-1');
    });

    test('should return empty list when no topics are due', () async {
      final futureTopic = Topic(
        id: 'future-1',
        title: 'Future Topic',
        filePath: '/path/future.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 5)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(futureTopic);

      final dueTopics = await srService.getDueTopics();

      expect(dueTopics, isEmpty);
    });
  });

  group('Get Upcoming Topics', () {
    test('should return topics due within specified days', () async {
      final now = DateTime.now();

      final tomorrow = Topic(
        id: 'tomorrow',
        title: 'Tomorrow',
        filePath: '/path/1.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final nextWeek = Topic(
        id: 'nextweek',
        title: 'Next Week',
        filePath: '/path/2.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 8)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(tomorrow);
      await dbService.insertTopic(nextWeek);

      final upcoming = await srService.getUpcomingTopics(7);

      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'tomorrow');
    });

    test('should not include already due topics', () async {
      final now = DateTime.now();

      final dueTopic = Topic(
        id: 'due',
        title: 'Due Now',
        filePath: '/path/due.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.subtract(Duration(hours: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final upcomingTopic = Topic(
        id: 'upcoming',
        title: 'Upcoming',
        filePath: '/path/upcoming.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 2)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(dueTopic);
      await dbService.insertTopic(upcomingTopic);

      final upcoming = await srService.getUpcomingTopics(7);

      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'upcoming');
    });
  });

  group('Get Overdue Topics', () {
    test('should return topics past their review date', () async {
      final now = DateTime.now();

      final overdueOld = Topic(
        id: 'overdue-old',
        title: 'Old Overdue',
        filePath: '/path/old.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.subtract(Duration(days: 5)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final overdueRecent = Topic(
        id: 'overdue-recent',
        title: 'Recent Overdue',
        filePath: '/path/recent.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.subtract(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final futureTopic = Topic(
        id: 'future',
        title: 'Future',
        filePath: '/path/future.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(overdueOld);
      await dbService.insertTopic(overdueRecent);
      await dbService.insertTopic(futureTopic);

      final overdue = await srService.getOverdueTopics();

      expect(overdue.length, 2);
      expect(overdue.first.id, 'overdue-old'); // Sorted oldest first
    });
  });

  group('Custom Schedule Management', () {
    test('should set custom schedule correctly', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final customDate = DateTime.now().add(Duration(days: 5, hours: 14));
      final updated = await srService.setCustomSchedule('test-1', customDate);

      expect(updated.useCustomSchedule, true);
      expect(updated.customReviewDatetime, isNotNull);
      expect(updated.nextReviewDate.day, customDate.day);
    });

    test('should remove custom schedule and recalculate', () async {
      final customDate = DateTime.now().add(Duration(days: 10));

      final topic = Topic(
        id: 'test-1',
        title: 'Custom Topic',
        filePath: '/path/custom.md',
        createdAt: DateTime.now(),
        currentStage: 2,
        nextReviewDate: customDate,
        reviewCount: 3,
        lastReviewedAt: DateTime.now().subtract(Duration(days: 5)),
        tags: [],
        isFavorite: false,
        useCustomSchedule: true,
        customReviewDatetime: customDate,
      );

      await dbService.insertTopic(topic);

      final updated = await srService.removeCustomSchedule('test-1', recalculate: true);

      expect(updated.useCustomSchedule, false);
      expect(updated.customReviewDatetime, isNull);
      // Should recalculate based on stage 2 (7 days)
      expect(updated.nextReviewDate.isAfter(DateTime.now()), true);
    });

    test('should reschedule topic with custom flag', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final newDate = DateTime.now().add(Duration(days: 7, hours: 10));
      final updated = await srService.rescheduleTopicTo('test-1', newDate, isCustom: true);

      expect(updated.useCustomSchedule, true);
      expect(updated.nextReviewDate.day, newDate.day);
      expect(updated.customReviewDatetime, isNotNull);
    });

    test('should reschedule topic without custom flag', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/test.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final newDate = DateTime.now().add(Duration(days: 2));
      final updated = await srService.rescheduleTopicTo('test-1', newDate, isCustom: false);

      expect(updated.useCustomSchedule, false);
      expect(updated.nextReviewDate.day, newDate.day);
      expect(updated.customReviewDatetime, isNull);
    });
  });

  group('Scheduling Statistics', () {
    test('should calculate statistics correctly', () async {
      final now = DateTime.now();

      final topics = [
        Topic(
          id: 'due-1',
          title: 'Due Today',
          filePath: '/path/1.md',
          createdAt: now,
          currentStage: 0,
          nextReviewDate: now,
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
        Topic(
          id: 'overdue-1',
          title: 'Overdue',
          filePath: '/path/2.md',
          createdAt: now,
          currentStage: 1,
          nextReviewDate: now.subtract(Duration(days: 2)),
          reviewCount: 3,
          tags: [],
          isFavorite: false,
        ),
        Topic(
          id: 'upcoming-1',
          title: 'Upcoming',
          filePath: '/path/3.md',
          createdAt: now,
          currentStage: 2,
          nextReviewDate: now.add(Duration(days: 3)),
          reviewCount: 5,
          tags: [],
          isFavorite: false,
          useCustomSchedule: true,
          customReviewDatetime: now.add(Duration(days: 3)),
        ),
      ];

      for (var topic in topics) {
        await dbService.insertTopic(topic);
      }

      final stats = await srService.getSchedulingStats();

      expect(stats['totalTopics'], 3);
      expect(stats['totalReviews'], 8); // 0 + 3 + 5
      expect(stats['customSchedules'], 1);
      expect(stats['stageDistribution'][0], 1);
      expect(stats['stageDistribution'][1], 1);
      expect(stats['stageDistribution'][2], 1);
    });
  });

  group('Stage Description', () {
    test('should return correct descriptions', () {
      expect(srService.getStageDescription(0), '1 day');
      expect(srService.getStageDescription(1), '3 days');
      expect(srService.getStageDescription(2), '1 week');
      expect(srService.getStageDescription(3), '2 weeks');
      expect(srService.getStageDescription(4), '1 month');
      expect(srService.getStageDescription(5), '1 month');
    });

    test('should handle negative stages', () {
      expect(srService.getStageDescription(-1), '1 month');
    });

    test('should handle very large stages', () {
      expect(srService.getStageDescription(100), '1 month');
    });
  });
}
