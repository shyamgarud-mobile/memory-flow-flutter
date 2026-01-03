import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'file_cache_service.dart';

/// Performance monitoring and benchmarking service
///
/// Tracks and reports performance metrics for various app operations.
/// Enable detailed logging with `PerformanceService.enableLogging = true`
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  /// Enable detailed performance logging
  static bool enableLogging = kDebugMode;

  // Timing storage
  final Map<String, List<int>> _operationTimes = {};
  final Map<String, int> _operationCounts = {};
  final Stopwatch _appStartTime = Stopwatch();

  /// Start tracking app startup time
  void startAppTimer() {
    _appStartTime.reset();
    _appStartTime.start();
  }

  /// Mark app as fully loaded
  void markAppLoaded() {
    _appStartTime.stop();
    _recordOperation('app_startup', _appStartTime.elapsedMilliseconds);
  }

  /// Record an operation timing
  void _recordOperation(String name, int milliseconds) {
    _operationTimes.putIfAbsent(name, () => []);
    _operationTimes[name]!.add(milliseconds);
    _operationCounts[name] = (_operationCounts[name] ?? 0) + 1;

    if (enableLogging) {
      print('⏱️ $name: ${milliseconds}ms');
    }
  }

  /// Time an async operation
  Future<T> timeAsync<T>(String name, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordOperation(name, stopwatch.elapsedMilliseconds);
    }
  }

  /// Time a sync operation
  T timeSync<T>(String name, T Function() operation) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordOperation(name, stopwatch.elapsedMilliseconds);
    }
  }

  /// Get statistics for an operation
  Map<String, dynamic> getOperationStats(String name) {
    final times = _operationTimes[name];
    if (times == null || times.isEmpty) {
      return {'count': 0, 'avg': 0, 'min': 0, 'max': 0};
    }

    times.sort();
    final sum = times.reduce((a, b) => a + b);

    return {
      'count': times.length,
      'avg': (sum / times.length).round(),
      'min': times.first,
      'max': times.last,
      'median': times[times.length ~/ 2],
      'p95': times[(times.length * 0.95).floor()],
    };
  }

  /// Get all performance metrics
  Map<String, dynamic> getAllMetrics() {
    final metrics = <String, dynamic>{};

    // Operation timings
    final operations = <String, dynamic>{};
    for (final name in _operationTimes.keys) {
      operations[name] = getOperationStats(name);
    }
    metrics['operations'] = operations;

    // Database metrics
    metrics['database'] = DatabaseService.getPerformanceMetrics();

    // Cache metrics
    metrics['cache'] = FileCacheService().getStats();

    return metrics;
  }

  /// Generate performance report
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln('         PERFORMANCE REPORT                 ');
    buffer.writeln('═══════════════════════════════════════════');
    buffer.writeln();

    // App startup
    final startupStats = getOperationStats('app_startup');
    if (startupStats['count'] > 0) {
      buffer.writeln('📱 App Startup');
      buffer.writeln('   Time: ${startupStats['avg']}ms');
      buffer.writeln();
    }

    // Database operations
    buffer.writeln('🗄️ Database Operations');
    final dbMetrics = DatabaseService.getPerformanceMetrics();
    if (dbMetrics.isEmpty) {
      buffer.writeln('   No metrics recorded');
    } else {
      for (final entry in dbMetrics.entries) {
        buffer.writeln('   ${entry.key}: ${entry.value}ms');
      }
    }
    buffer.writeln();

    // Cache performance
    buffer.writeln('💾 Cache Performance');
    final cacheStats = FileCacheService().getStats();
    buffer.writeln('   Memory items: ${cacheStats['memoryItems']}');
    buffer.writeln('   Memory size: ${cacheStats['memoryMB']} MB');
    buffer.writeln('   Hit rate: ${cacheStats['hitRate']}');
    buffer.writeln('   Hits: ${cacheStats['hits']}, Misses: ${cacheStats['misses']}');
    buffer.writeln();

    // Other operations
    final otherOps = _operationTimes.keys
        .where((k) => k != 'app_startup')
        .toList();

    if (otherOps.isNotEmpty) {
      buffer.writeln('⚡ Operation Timings');
      for (final name in otherOps) {
        final stats = getOperationStats(name);
        buffer.writeln('   $name:');
        buffer.writeln('     Count: ${stats['count']}');
        buffer.writeln('     Avg: ${stats['avg']}ms');
        buffer.writeln('     Min/Max: ${stats['min']}/${stats['max']}ms');
      }
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════════════════');

    return buffer.toString();
  }

  /// Run benchmarks and return results
  Future<Map<String, dynamic>> runBenchmarks() async {
    final results = <String, dynamic>{};
    final db = DatabaseService();

    print('🏃 Running performance benchmarks...');
    print('');

    // Database benchmarks
    print('📊 Database Benchmarks:');

    // Single topic insert
    final singleInsert = await _benchmarkOperation('Single insert', () async {
      // This would need actual test data
      return 0;
    });
    results['db_single_insert'] = singleInsert;

    // Paginated query
    final paginatedQuery = await _benchmarkOperation('Paginated query (20 items)', () async {
      final stopwatch = Stopwatch()..start();
      await db.getTopicsPaginated(limit: 20, offset: 0);
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    });
    results['db_paginated_query'] = paginatedQuery;
    print('   Paginated query: ${paginatedQuery}ms');

    // All topics query
    final allTopics = await _benchmarkOperation('All topics query', () async {
      final stopwatch = Stopwatch()..start();
      await db.getAllTopics();
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    });
    results['db_all_topics'] = allTopics;
    print('   All topics: ${allTopics}ms');

    // Statistics query
    final stats = await _benchmarkOperation('Statistics query', () async {
      final stopwatch = Stopwatch()..start();
      await db.getStatistics();
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    });
    results['db_statistics'] = stats;
    print('   Statistics: ${stats}ms');

    print('');
    print('✅ Benchmarks complete');

    return results;
  }

  Future<int> _benchmarkOperation(String name, Future<int> Function() operation) async {
    // Run multiple times for average
    final times = <int>[];
    for (var i = 0; i < 3; i++) {
      times.add(await operation());
    }
    return (times.reduce((a, b) => a + b) / times.length).round();
  }

  /// Clear all metrics
  void clearMetrics() {
    _operationTimes.clear();
    _operationCounts.clear();
    DatabaseService.clearPerformanceMetrics();
  }
}

/// Extension to add performance tracking to any Future
extension PerformanceTracking<T> on Future<T> {
  /// Track this future's execution time
  Future<T> tracked(String name) async {
    return PerformanceService().timeAsync(name, () => this);
  }
}
