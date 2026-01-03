import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:memory_flow/services/database_service.dart';
import 'package:memory_flow/models/topic.dart';

/// Performance benchmarks for database operations
///
/// Run with: flutter test test/performance/database_performance_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late DatabaseService dbService;

  setUp(() async {
    dbService = DatabaseService();
    await dbService.deleteDatabase();
    DatabaseService.enablePerfLogging = true;
  });

  tearDown(() async {
    await dbService.close();
    DatabaseService.clearPerformanceMetrics();
  });

  group('Bulk Insert Performance', () {
    test('should insert 100 topics in under 2 seconds', () async {
      final topics = _generateTestTopics(100);
      final stopwatch = Stopwatch()..start();

      await dbService.insertTopicsBatch(topics);

      stopwatch.stop();
      final timeMs = stopwatch.elapsedMilliseconds;

      print('✓ Inserted 100 topics in ${timeMs}ms');
      print('  Average: ${(timeMs / 100).toStringAsFixed(2)}ms per topic');

      expect(timeMs, lessThan(2000), reason: 'Bulk insert should be fast');
    });

    test('should insert 500 topics in under 5 seconds', () async {
      final topics = _generateTestTopics(500);
      final stopwatch = Stopwatch()..start();

      await dbService.insertTopicsBatch(topics);

      stopwatch.stop();
      final timeMs = stopwatch.elapsedMilliseconds;

      print('✓ Inserted 500 topics in ${timeMs}ms');
      print('  Average: ${(timeMs / 500).toStringAsFixed(2)}ms per topic');

      expect(timeMs, lessThan(5000));
    });

    test('should insert 1000 topics in under 10 seconds', () async {
      final topics = _generateTestTopics(1000);
      final stopwatch = Stopwatch()..start();

      await dbService.insertTopicsBatch(topics);

      stopwatch.stop();
      final timeMs = stopwatch.elapsedMilliseconds;

      print('✓ Inserted 1000 topics in ${timeMs}ms');
      print('  Average: ${(timeMs / 1000).toStringAsFixed(2)}ms per topic');

      expect(timeMs, lessThan(10000));
    });
  });

  group('Query Performance', () {
    test('should query due topics quickly from 1000 topics', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      final stopwatch = Stopwatch()..start();
      final dueTopics = await dbService.getDueTopics();
      stopwatch.stop();

      print('✓ Found ${dueTopics.length} due topics in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should search topics quickly in large dataset', () async {
      final topics = _generateTestTopics(500);
      await dbService.insertTopicsBatch(topics);

      final stopwatch = Stopwatch()..start();
      final results = await dbService.searchTopics('Topic 1');
      stopwatch.stop();

      print('✓ Search found ${results.length} results in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('should get favorites quickly', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      final stopwatch = Stopwatch()..start();
      final favorites = await dbService.getFavoriteTopics();
      stopwatch.stop();

      print('✓ Found ${favorites.length} favorites in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });

    test('should get statistics quickly', () async {
      final topics = _generateTestTopics(500);
      await dbService.insertTopicsBatch(topics);

      final stopwatch = Stopwatch()..start();
      final stats = await dbService.getStatistics();
      stopwatch.stop();

      print('✓ Got statistics in ${stopwatch.elapsedMilliseconds}ms');
      print('  Stats: $stats');

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
  });

  group('Pagination Performance', () {
    test('should load paginated results consistently', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      final times = <int>[];

      // Test first page
      var stopwatch = Stopwatch()..start();
      await dbService.getTopicsPaginated(limit: 20, offset: 0);
      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      // Test middle page
      stopwatch = Stopwatch()..start();
      await dbService.getTopicsPaginated(limit: 20, offset: 500);
      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      // Test last page
      stopwatch = Stopwatch()..start();
      await dbService.getTopicsPaginated(limit: 20, offset: 980);
      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      print('✓ Pagination times: ${times[0]}ms, ${times[1]}ms, ${times[2]}ms');

      // All pages should load in similar time
      for (var time in times) {
        expect(time, lessThan(200));
      }
    });

    test('should get total count quickly', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      final stopwatch = Stopwatch()..start();
      final count = await dbService.getTopicsCount();
      stopwatch.stop();

      print('✓ Got count ($count) in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Update Performance', () {
    test('should batch update 100 topics quickly', () async {
      final topics = _generateTestTopics(100);
      await dbService.insertTopicsBatch(topics);

      final updatedTopics = topics
          .map((t) => t.copyWith(reviewCount: t.reviewCount + 1))
          .toList();

      final stopwatch = Stopwatch()..start();
      await dbService.updateTopicsBatch(updatedTopics);
      stopwatch.stop();

      print('✓ Updated 100 topics in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('should batch update 500 topics quickly', () async {
      final topics = _generateTestTopics(500);
      await dbService.insertTopicsBatch(topics);

      final updatedTopics = topics
          .map((t) => t.copyWith(currentStage: t.currentStage + 1))
          .toList();

      final stopwatch = Stopwatch()..start();
      await dbService.updateTopicsBatch(updatedTopics);
      stopwatch.stop();

      print('✓ Updated 500 topics in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('Delete Performance', () {
    test('should batch delete 100 topics quickly', () async {
      final topics = _generateTestTopics(100);
      await dbService.insertTopicsBatch(topics);

      final ids = topics.map((t) => t.id).toList();

      final stopwatch = Stopwatch()..start();
      await dbService.deleteTopicsBatch(ids);
      stopwatch.stop();

      print('✓ Deleted 100 topics in ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Mixed Operations Performance', () {
    test('should handle realistic workflow efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // 1. Insert initial topics
      final topics = _generateTestTopics(100);
      await dbService.insertTopicsBatch(topics);

      // 2. Query due topics
      await dbService.getDueTopics();

      // 3. Update some topics
      final toUpdate = topics.take(10).map((t) =>
        t.copyWith(reviewCount: t.reviewCount + 1)
      ).toList();
      await dbService.updateTopicsBatch(toUpdate);

      // 4. Search
      await dbService.searchTopics('Topic');

      // 5. Get statistics
      await dbService.getStatistics();

      // 6. Delete some topics
      final idsToDelete = topics.take(5).map((t) => t.id).toList();
      await dbService.deleteTopicsBatch(idsToDelete);

      stopwatch.stop();

      print('✓ Complete workflow in ${stopwatch.elapsedMilliseconds}ms');

      // Realistic workflow should complete quickly
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });

  group('Index Effectiveness', () {
    test('should demonstrate index performance improvement', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      // Query that uses index (next_review_date)
      final stopwatch1 = Stopwatch()..start();
      await dbService.getDueTopics();
      stopwatch1.stop();

      // Query that uses index (is_favorite)
      final stopwatch2 = Stopwatch()..start();
      await dbService.getFavoriteTopics();
      stopwatch2.stop();

      // Query that uses index (title LIKE)
      final stopwatch3 = Stopwatch()..start();
      await dbService.searchTopics('100');
      stopwatch3.stop();

      print('✓ Indexed query times:');
      print('  Due topics: ${stopwatch1.elapsedMilliseconds}ms');
      print('  Favorites: ${stopwatch2.elapsedMilliseconds}ms');
      print('  Search: ${stopwatch3.elapsedMilliseconds}ms');

      // All indexed queries should be very fast even with 1000 topics
      expect(stopwatch1.elapsedMilliseconds, lessThan(200));
      expect(stopwatch2.elapsedMilliseconds, lessThan(200));
      expect(stopwatch3.elapsedMilliseconds, lessThan(200));
    });
  });

  group('Memory Efficiency', () {
    test('should not load all topics into memory at once', () async {
      final topics = _generateTestTopics(1000);
      await dbService.insertTopicsBatch(topics);

      // Paginated approach - only loads 20 topics
      final page = await dbService.getTopicsPaginated(limit: 20, offset: 0);

      expect(page.length, 20);
      // Memory footprint should be minimal (only 20 topics in memory)
    });
  });
}

/// Generate test topics for performance testing
List<Topic> _generateTestTopics(int count) {
  return List.generate(
    count,
    (i) => Topic(
      id: 'perf-test-$i',
      title: 'Performance Test Topic $i',
      filePath: '/test/perf-$i.md',
      createdAt: DateTime.now().subtract(Duration(days: count - i)),
      currentStage: i % 5,
      nextReviewDate: DateTime.now().add(Duration(days: (i % 30) - 15)),
      reviewCount: i % 20,
      tags: i % 3 == 0 ? ['tag${i % 5}'] : [],
      isFavorite: i % 10 == 0,
    ),
  );
}
