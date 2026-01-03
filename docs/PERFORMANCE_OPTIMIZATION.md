# Performance Optimization Guide

## Overview

This document outlines performance optimizations implemented in MemoryFlow and provides guidelines for maintaining optimal performance as the app scales.

## Current Optimizations

### Database Performance

#### 1. Indexed Queries
All frequently queried columns have indexes:
- `next_review_date` - Fast lookup for due topics
- `created_at` - Sorting by creation date
- `is_favorite` - Quick favorite filtering
- `folder_id` - Efficient folder queries
- `title` - Fast text search
- `current_stage` - Stage-based filtering
- Composite indexes: `(folder_id, next_review_date)`, `(is_favorite, next_review_date)`

**Impact:** 10-50x faster queries on large datasets (1000+ topics)

#### 2. Batch Operations
```dart
// Instead of:
for (var topic in topics) {
  await db.insertTopic(topic);
}

// Use:
await db.insertTopicsBatch(topics);
```

**Impact:** ~10x faster for bulk operations

#### 3. Pagination
```dart
final topics = await db.getTopicsPaginated(
  limit: 20,
  offset: 0,
);
```

**Impact:** Constant memory usage regardless of total topics

### File Operations

#### 1. Lazy Loading
- Topic content loaded only when viewing
- Topic list shows metadata only
- Markdown rendering deferred until scroll

#### 2. File Caching
- Recently accessed files cached in memory
- LRU cache eviction policy
- Configurable cache size

```dart
// Implemented in FileCacheService
final content = await fileCacheService.getFile(filePath);
```

### UI Performance

#### 1. List View Optimization
- `ListView.builder` for efficient scrolling
- Item extent estimation for smooth scrolling
- Recycled widgets reduce memory

#### 2. Image Optimization
- Cached network images
- Proper image sizing
- Lazy image loading

#### 3. Build Optimization
- `const` constructors where possible
- Minimal rebuilds with proper state management
- Keys for list items

## Performance Testing

### Load Testing Script

Create `scripts/performance_test.dart`:

```dart
import 'package:memory_flow/services/database_service.dart';
import 'package:memory_flow/models/topic.dart';

Future<void> main() async {
  final db = DatabaseService();
  final stopwatch = Stopwatch();

  // Test 1: Bulk Insert Performance
  print('Test 1: Inserting 1000 topics...');
  final topics = List.generate(
    1000,
    (i) => Topic(
      id: 'perf-test-$i',
      title: 'Performance Test Topic $i',
      filePath: '/test/$i.md',
      createdAt: DateTime.now(),
      currentStage: i % 5,
      nextReviewDate: DateTime.now().add(Duration(days: i % 30)),
      reviewCount: i % 20,
      tags: [],
      isFavorite: i % 10 == 0,
    ),
  );

  stopwatch.start();
  await db.insertTopicsBatch(topics);
  stopwatch.stop();

  print('✓ Inserted 1000 topics in ${stopwatch.elapsedMilliseconds}ms');
  print('  Average: ${stopwatch.elapsedMilliseconds / 1000}ms per topic\n');

  // Test 2: Query Performance
  stopwatch.reset();
  stopwatch.start();
  final dueTopics = await db.getDueTopics();
  stopwatch.stop();

  print('Test 2: Query due topics from 1000 total');
  print('✓ Found ${dueTopics.length} topics in ${stopwatch.elapsedMilliseconds}ms\n');

  // Test 3: Search Performance
  stopwatch.reset();
  stopwatch.start();
  final searchResults = await db.searchTopics('Test');
  stopwatch.stop();

  print('Test 3: Search query');
  print('✓ Found ${searchResults.length} results in ${stopwatch.elapsedMilliseconds}ms\n');

  // Test 4: Pagination Performance
  stopwatch.reset();
  stopwatch.start();
  final page1 = await db.getTopicsPaginated(limit: 20, offset: 0);
  final page2 = await db.getTopicsPaginated(limit: 20, offset: 20);
  final page50 = await db.getTopicsPaginated(limit: 20, offset: 980);
  stopwatch.stop();

  print('Test 4: Paginated queries');
  print('✓ Loaded 3 pages in ${stopwatch.elapsedMilliseconds}ms');
  print('  Page sizes: ${page1.length}, ${page2.length}, ${page50.length}\n');

  // Test 5: Update Performance
  stopwatch.reset();
  stopwatch.start();
  final updateTopics = topics.take(100).map((t) =>
    t.copyWith(reviewCount: t.reviewCount + 1)
  ).toList();
  await db.updateTopicsBatch(updateTopics);
  stopwatch.stop();

  print('Test 5: Batch update 100 topics');
  print('✓ Updated in ${stopwatch.elapsedMilliseconds}ms\n');

  // Cleanup
  await db.deleteTopicsBatch(topics.map((t) => t.id).toList());
  print('Cleanup complete');
}
```

### Running Performance Tests

```bash
dart scripts/performance_test.dart
```

### Expected Performance Benchmarks

#### Small Dataset (< 100 topics)
- App startup: < 1s
- Topic list load: < 100ms
- Search: < 50ms
- Topic save: < 50ms

#### Medium Dataset (100-500 topics)
- App startup: < 2s
- Topic list load: < 200ms
- Search: < 100ms
- Topic save: < 100ms

#### Large Dataset (500-1000 topics)
- App startup: < 3s
- Topic list load: < 500ms (with pagination)
- Search: < 200ms
- Topic save: < 150ms

#### Very Large Dataset (1000+ topics)
- App startup: < 5s
- Topic list load: < 1s (paginated)
- Search: < 300ms
- Topic save: < 200ms

## Memory Optimization

### 1. Limit In-Memory Cache
```dart
// FileCacheService configuration
static const int maxCacheSize = 50; // Files
static const int maxCacheMemory = 10 * 1024 * 1024; // 10 MB
```

### 2. Dispose Unused Resources
```dart
@override
void dispose() {
  _controller.dispose();
  _pageController.dispose();
  super.dispose();
}
```

### 3. Lazy Initialization
```dart
late final service = SomeHeavyService(); // Only created when first accessed
```

## App Size Optimization

### 1. Asset Optimization
- Compress images before including
- Use vector graphics (SVG) where possible
- Remove unused assets

### 2. Code Size
- Enable tree shaking (automatic in release builds)
- Split large features into lazy-loaded modules
- Remove debug code in production

### 3. Dependencies
- Audit dependency sizes regularly
- Use lightweight alternatives where possible
- Remove unused dependencies

## Network Optimization

### 1. Google Drive Sync
- Batch sync operations
- Compress data before upload
- Only sync changed files
- Implement exponential backoff for retries

### 2. Offline-First
- All operations work offline
- Queue operations when offline
- Sync in background when online

## Monitoring Performance

### 1. Enable Performance Logging
```dart
DatabaseService.enablePerfLogging = true;
```

### 2. Check Performance Metrics
```dart
final metrics = DatabaseService.getPerformanceMetrics();
print('Query times: $metrics');
```

### 3. Profile in Production
```bash
flutter run --profile
```

Use DevTools to:
- Monitor frame rendering
- Check memory usage
- Identify slow operations
- Track rebuild frequency

## Best Practices

### 1. Database
- ✅ Use indexes on frequently queried columns
- ✅ Batch operations when possible
- ✅ Use transactions for multiple operations
- ✅ Paginate large result sets
- ❌ Don't load all topics at once
- ❌ Don't perform heavy operations on UI thread

### 2. UI
- ✅ Use `ListView.builder` for long lists
- ✅ Implement const constructors
- ✅ Cache expensive computations
- ✅ Dispose controllers and listeners
- ❌ Don't rebuild entire widget tree unnecessarily
- ❌ Don't load images without size constraints

### 3. State Management
- ✅ Update only affected widgets
- ✅ Use Provider selectors for granular updates
- ✅ Separate UI state from business logic
- ❌ Don't overuse setState
- ❌ Don't put heavy logic in build methods

## Troubleshooting Performance Issues

### Slow Startup
1. Check database migration time
2. Reduce initial data loading
3. Defer non-critical initialization
4. Use splash screen while loading

### Janky Scrolling
1. Profile with DevTools
2. Check for synchronous file I/O
3. Verify images are properly sized
4. Ensure list items are lightweight

### High Memory Usage
1. Check file cache size
2. Dispose unused resources
3. Limit in-memory topic count
4. Profile with Memory view in DevTools

### Slow Queries
1. Verify indexes are created
2. Use EXPLAIN QUERY PLAN in SQLite
3. Check for N+1 query problems
4. Consider denormalization for hot paths

## Future Optimizations

### Planned Improvements
- [ ] Background isolate for heavy computations
- [ ] Incremental database migration
- [ ] Virtual scrolling for very large lists
- [ ] Service worker for web version
- [ ] Native platform optimizations

### Monitoring Goals
- [ ] Set up crash reporting
- [ ] Track performance metrics
- [ ] Monitor battery usage
- [ ] Measure sync efficiency

## Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [SQLite Performance Tips](https://www.sqlite.org/optoverview.html)
- [DevTools Profiling](https://docs.flutter.dev/tools/devtools/performance)

---

**Last Updated:** November 29, 2025
