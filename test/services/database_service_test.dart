import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:memory_flow/services/database_service.dart';
import 'package:memory_flow/models/topic.dart';
import 'package:memory_flow/models/folder.dart';

void main() {
  // Initialize FFI for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;

  setUp(() async {
    dbService = DatabaseService();
    await dbService.deleteDatabase();
  });

  tearDown(() async {
    await dbService.close();
  });

  group('Database Initialization', () {
    test('should initialize database successfully', () async {
      final db = await dbService.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('should get database path', () async {
      final path = await dbService.getDatabasePath();
      expect(path, isNotEmpty);
      expect(path, contains('memory_flow.db'));
    });
  });

  group('Topic CRUD Operations', () {
    test('should insert a topic', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/to/file.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final result = await dbService.insertTopic(topic);
      expect(result, 1);

      final retrieved = await dbService.getTopic('test-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Test Topic');
    });

    test('should update a topic', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Original Title',
        filePath: '/path/to/file.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final updatedTopic = topic.copyWith(
        title: 'Updated Title',
        currentStage: 1,
        reviewCount: 5,
      );

      final result = await dbService.updateTopic(updatedTopic);
      expect(result, 1);

      final retrieved = await dbService.getTopic('test-1');
      expect(retrieved!.title, 'Updated Title');
      expect(retrieved.currentStage, 1);
      expect(retrieved.reviewCount, 5);
    });

    test('should delete a topic', () async {
      final topic = Topic(
        id: 'test-1',
        title: 'Test Topic',
        filePath: '/path/to/file.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);
      final result = await dbService.deleteTopic('test-1');
      expect(result, 1);

      final retrieved = await dbService.getTopic('test-1');
      expect(retrieved, isNull);
    });

    test('should get all topics', () async {
      final topic1 = Topic(
        id: 'test-1',
        title: 'Topic 1',
        filePath: '/path/1.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final topic2 = Topic(
        id: 'test-2',
        title: 'Topic 2',
        filePath: '/path/2.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic1);
      await dbService.insertTopic(topic2);

      final topics = await dbService.getAllTopics();
      expect(topics.length, 2);
    });
  });

  group('Topic Queries', () {
    test('should get due topics', () async {
      final dueTopic = Topic(
        id: 'due-1',
        title: 'Due Topic',
        filePath: '/path/due.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now().subtract(Duration(days: 1)),
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

      final dueTopics = await dbService.getDueTopics();
      expect(dueTopics.length, 1);
      expect(dueTopics.first.id, 'due-1');
    });

    test('should get upcoming topics', () async {
      final now = DateTime.now();

      final tomorrow = Topic(
        id: 'tomorrow-1',
        title: 'Tomorrow Topic',
        filePath: '/path/tomorrow.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 1)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final nextWeek = Topic(
        id: 'nextweek-1',
        title: 'Next Week Topic',
        filePath: '/path/nextweek.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: now.add(Duration(days: 8)),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(tomorrow);
      await dbService.insertTopic(nextWeek);

      final upcoming = await dbService.getUpcomingTopics(7);
      expect(upcoming.length, 1);
      expect(upcoming.first.id, 'tomorrow-1');
    });

    test('should get favorite topics', () async {
      final favorite = Topic(
        id: 'fav-1',
        title: 'Favorite Topic',
        filePath: '/path/fav.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: true,
      );

      final regular = Topic(
        id: 'reg-1',
        title: 'Regular Topic',
        filePath: '/path/reg.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(favorite);
      await dbService.insertTopic(regular);

      final favorites = await dbService.getFavoriteTopics();
      expect(favorites.length, 1);
      expect(favorites.first.id, 'fav-1');
    });

    test('should search topics by title', () async {
      final topic1 = Topic(
        id: 'test-1',
        title: 'Flutter Development',
        filePath: '/path/1.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final topic2 = Topic(
        id: 'test-2',
        title: 'Python Basics',
        filePath: '/path/2.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic1);
      await dbService.insertTopic(topic2);

      final results = await dbService.searchTopics('Flutter');
      expect(results.length, 1);
      expect(results.first.title, contains('Flutter'));
    });

    test('should get topics by date range', () async {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month, 15);

      final inRange = Topic(
        id: 'in-1',
        title: 'In Range',
        filePath: '/path/in.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: DateTime(now.year, now.month, 10),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      final outRange = Topic(
        id: 'out-1',
        title: 'Out of Range',
        filePath: '/path/out.md',
        createdAt: now,
        currentStage: 0,
        nextReviewDate: DateTime(now.year, now.month, 20),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(inRange);
      await dbService.insertTopic(outRange);

      final results = await dbService.getTopicsByDateRange(start, end);
      expect(results.length, 1);
      expect(results.first.id, 'in-1');
    });
  });

  group('Batch Operations', () {
    test('should insert topics in batch', () async {
      final topics = List.generate(
        10,
        (i) => Topic(
          id: 'batch-$i',
          title: 'Batch Topic $i',
          filePath: '/path/$i.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now(),
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
      );

      final result = await dbService.insertTopicsBatch(topics);
      expect(result, 10);

      final all = await dbService.getAllTopics();
      expect(all.length, 10);
    });

    test('should update topics in batch', () async {
      final topics = List.generate(
        5,
        (i) => Topic(
          id: 'batch-$i',
          title: 'Original $i',
          filePath: '/path/$i.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now(),
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
      );

      await dbService.insertTopicsBatch(topics);

      final updated = topics
          .map((t) => t.copyWith(title: 'Updated ${t.id}', reviewCount: 10))
          .toList();

      final result = await dbService.updateTopicsBatch(updated);
      expect(result, 5);

      final retrieved = await dbService.getTopic('batch-0');
      expect(retrieved!.title, contains('Updated'));
      expect(retrieved.reviewCount, 10);
    });

    test('should delete topics in batch', () async {
      final topics = List.generate(
        5,
        (i) => Topic(
          id: 'batch-$i',
          title: 'Topic $i',
          filePath: '/path/$i.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now(),
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
      );

      await dbService.insertTopicsBatch(topics);

      final ids = ['batch-0', 'batch-1', 'batch-2'];
      final result = await dbService.deleteTopicsBatch(ids);
      expect(result, 3);

      final remaining = await dbService.getAllTopics();
      expect(remaining.length, 2);
    });
  });

  group('Pagination', () {
    test('should get paginated topics', () async {
      final topics = List.generate(
        25,
        (i) => Topic(
          id: 'page-$i',
          title: 'Topic $i',
          filePath: '/path/$i.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now().add(Duration(days: i)),
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
      );

      await dbService.insertTopicsBatch(topics);

      final page1 = await dbService.getTopicsPaginated(
        limit: 10,
        offset: 0,
      );
      expect(page1.length, 10);

      final page2 = await dbService.getTopicsPaginated(
        limit: 10,
        offset: 10,
      );
      expect(page2.length, 10);

      final page3 = await dbService.getTopicsPaginated(
        limit: 10,
        offset: 20,
      );
      expect(page3.length, 5);
    });

    test('should get topics count', () async {
      final topics = List.generate(
        15,
        (i) => Topic(
          id: 'count-$i',
          title: 'Topic $i',
          filePath: '/path/$i.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now(),
          reviewCount: 0,
          tags: [],
          isFavorite: false,
        ),
      );

      await dbService.insertTopicsBatch(topics);

      final count = await dbService.getTopicsCount();
      expect(count, 15);
    });
  });

  group('Folder Operations', () {
    test('should insert a folder', () async {
      final folder = Folder(
        id: 'folder-1',
        name: 'Test Folder',
        createdAt: DateTime.now(),
      );

      final result = await dbService.insertFolder(folder);
      expect(result, 1);

      final retrieved = await dbService.getFolder('folder-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Folder');
    });

    test('should update a folder', () async {
      final folder = Folder(
        id: 'folder-1',
        name: 'Original Name',
        createdAt: DateTime.now(),
      );

      await dbService.insertFolder(folder);

      final updated = folder.copyWith(name: 'Updated Name', color: '#FF0000');
      final result = await dbService.updateFolder(updated);
      expect(result, 1);

      final retrieved = await dbService.getFolder('folder-1');
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.color, '#FF0000');
    });

    test('should delete a folder', () async {
      final folder = Folder(
        id: 'folder-1',
        name: 'Test Folder',
        createdAt: DateTime.now(),
      );

      await dbService.insertFolder(folder);
      final result = await dbService.deleteFolder('folder-1');
      expect(result, 1);

      final retrieved = await dbService.getFolder('folder-1');
      expect(retrieved, isNull);
    });

    test('should get all folders', () async {
      final folder1 = Folder(
        id: 'folder-1',
        name: 'Folder 1',
        createdAt: DateTime.now(),
      );

      final folder2 = Folder(
        id: 'folder-2',
        name: 'Folder 2',
        createdAt: DateTime.now(),
      );

      await dbService.insertFolder(folder1);
      await dbService.insertFolder(folder2);

      final folders = await dbService.getAllFolders();
      expect(folders.length, 2);
    });

    test('should get child folders', () async {
      final parent = Folder(
        id: 'parent-1',
        name: 'Parent',
        createdAt: DateTime.now(),
      );

      final child = Folder(
        id: 'child-1',
        name: 'Child',
        parentId: 'parent-1',
        createdAt: DateTime.now(),
      );

      await dbService.insertFolder(parent);
      await dbService.insertFolder(child);

      final children = await dbService.getChildFolders('parent-1');
      expect(children.length, 1);
      expect(children.first.id, 'child-1');
    });

    test('should get topics in folder', () async {
      final folder = Folder(
        id: 'folder-1',
        name: 'Test Folder',
        createdAt: DateTime.now(),
      );

      await dbService.insertFolder(folder);

      final topic1 = Topic(
        id: 'topic-1',
        title: 'Topic in Folder',
        filePath: '/path/1.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
        folderId: 'folder-1',
      );

      final topic2 = Topic(
        id: 'topic-2',
        title: 'Topic without Folder',
        filePath: '/path/2.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic1);
      await dbService.insertTopic(topic2);

      final topicsInFolder = await dbService.getTopicsInFolder('folder-1');
      expect(topicsInFolder.length, 1);
      expect(topicsInFolder.first.id, 'topic-1');
    });
  });

  group('Statistics', () {
    test('should get database statistics', () async {
      final topics = [
        Topic(
          id: 'stat-1',
          title: 'Due Topic',
          filePath: '/path/1.md',
          createdAt: DateTime.now(),
          currentStage: 0,
          nextReviewDate: DateTime.now().subtract(Duration(days: 1)),
          reviewCount: 5,
          tags: [],
          isFavorite: true,
        ),
        Topic(
          id: 'stat-2',
          title: 'Future Topic',
          filePath: '/path/2.md',
          createdAt: DateTime.now(),
          currentStage: 1,
          nextReviewDate: DateTime.now().add(Duration(days: 1)),
          reviewCount: 3,
          tags: [],
          isFavorite: false,
        ),
      ];

      await dbService.insertTopicsBatch(topics);

      final stats = await dbService.getStatistics();
      expect(stats['total'], 2);
      expect(stats['due'], 1);
      expect(stats['favorites'], 1);
      expect(stats['averageReviews'], 4); // (5 + 3) / 2 = 4
    });
  });

  group('Tags Handling', () {
    test('should handle tags correctly', () async {
      final topic = Topic(
        id: 'tag-1',
        title: 'Topic with Tags',
        filePath: '/path/tag.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: ['flutter', 'dart', 'mobile'],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final retrieved = await dbService.getTopic('tag-1');
      expect(retrieved!.tags, ['flutter', 'dart', 'mobile']);
    });

    test('should handle empty tags', () async {
      final topic = Topic(
        id: 'notag-1',
        title: 'Topic without Tags',
        filePath: '/path/notag.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
      );

      await dbService.insertTopic(topic);

      final retrieved = await dbService.getTopic('notag-1');
      expect(retrieved!.tags, isEmpty);
    });
  });

  group('Custom Schedule', () {
    test('should handle custom review datetime', () async {
      final customDate = DateTime.now().add(Duration(days: 5, hours: 14));

      final topic = Topic(
        id: 'custom-1',
        title: 'Custom Scheduled Topic',
        filePath: '/path/custom.md',
        createdAt: DateTime.now(),
        currentStage: 0,
        nextReviewDate: DateTime.now(),
        reviewCount: 0,
        tags: [],
        isFavorite: false,
        useCustomSchedule: true,
        customReviewDatetime: customDate,
      );

      await dbService.insertTopic(topic);

      final retrieved = await dbService.getTopic('custom-1');
      expect(retrieved!.useCustomSchedule, true);
      expect(retrieved.customReviewDatetime, isNotNull);
      expect(
        retrieved.customReviewDatetime!.difference(customDate).inSeconds,
        lessThan(2),
      );
    });
  });
}
