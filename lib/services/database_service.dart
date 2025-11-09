import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/topic.dart';

/// SQLite database service for managing topics with spaced repetition
///
/// This service provides persistent storage for learning topics, replacing
/// the previous JSON-based storage system. It uses SQLite for better
/// performance, querying capabilities, and data integrity.
class DatabaseService {
  // Singleton pattern - ensures only one database instance exists
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Database instance
  Database? _database;

  // Database configuration
  static const String _databaseName = 'memory_flow.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'topics';

  /// Get database instance (initializes if needed)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize the database
  ///
  /// Creates the database file and topics table with proper schema.
  /// Includes indexes for performance optimization on common queries.
  Future<Database> initDatabase() async {
    try {
      // Get the database path
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      print('Initializing database at: $path');

      // Open/create the database
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      print('Database initialized successfully');
      return db;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create database schema on first run
  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Creating topics table...');

      // Create topics table
      await db.execute('''
        CREATE TABLE $_tableName (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          file_path TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          current_stage INTEGER DEFAULT 0,
          next_review_date INTEGER NOT NULL,
          last_reviewed_at INTEGER,
          review_count INTEGER DEFAULT 0,
          tags TEXT,
          is_favorite INTEGER DEFAULT 0,
          use_custom_schedule INTEGER DEFAULT 0,
          custom_review_datetime INTEGER,
          reminder_time TEXT
        )
      ''');

      // Create indexes for better query performance
      await db.execute(
        'CREATE INDEX idx_next_review_date ON $_tableName(next_review_date)'
      );
      await db.execute(
        'CREATE INDEX idx_created_at ON $_tableName(created_at)'
      );
      await db.execute(
        'CREATE INDEX idx_is_favorite ON $_tableName(is_favorite)'
      );

      print('Topics table created successfully');
    } catch (e) {
      print('Error creating database schema: $e');
      rethrow;
    }
  }

  /// Handle database upgrades for future schema changes
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Add migration logic here when schema changes in future versions
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $_tableName ADD COLUMN new_field TEXT');
    // }
  }

  /// Insert a new topic into the database
  ///
  /// Returns the number of rows affected (1 if successful, 0 if failed)
  Future<int> insertTopic(Topic topic) async {
    try {
      final db = await database;
      final map = _topicToMap(topic);

      await db.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Topic inserted: ${topic.title} (${topic.id})');
      return 1;
    } catch (e) {
      print('Error inserting topic: $e');
      return 0;
    }
  }

  /// Update an existing topic in the database
  ///
  /// Returns the number of rows affected (1 if successful, 0 if not found)
  Future<int> updateTopic(Topic topic) async {
    try {
      final db = await database;
      final map = _topicToMap(topic);

      final result = await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [topic.id],
      );

      print('Topic updated: ${topic.title} (${topic.id})');
      return result;
    } catch (e) {
      print('Error updating topic: $e');
      return 0;
    }
  }

  /// Delete a topic from the database
  ///
  /// Returns the number of rows affected (1 if successful, 0 if not found)
  Future<int> deleteTopic(String id) async {
    try {
      final db = await database;

      final result = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      print('Topic deleted: $id');
      return result;
    } catch (e) {
      print('Error deleting topic: $e');
      return 0;
    }
  }

  /// Get a single topic by ID
  ///
  /// Returns the topic if found, null otherwise
  Future<Topic?> getTopic(String id) async {
    try {
      final db = await database;

      final maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        print('Topic not found: $id');
        return null;
      }

      return _mapToTopic(maps.first);
    } catch (e) {
      print('Error getting topic: $e');
      return null;
    }
  }

  /// Get all topics from the database
  ///
  /// Returns list of all topics, ordered by next review date
  Future<List<Topic>> getAllTopics() async {
    try {
      final db = await database;

      final maps = await db.query(
        _tableName,
        orderBy: 'next_review_date ASC',
      );

      print('Retrieved ${maps.length} topics');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error getting all topics: $e');
      return [];
    }
  }

  /// Get topics within a specific date range
  ///
  /// Returns topics where next_review_date falls between start and end dates
  Future<List<Topic>> getTopicsByDateRange(DateTime start, DateTime end) async {
    try {
      final db = await database;

      final startMillis = start.millisecondsSinceEpoch;
      final endMillis = end.millisecondsSinceEpoch;

      final maps = await db.query(
        _tableName,
        where: 'next_review_date >= ? AND next_review_date <= ?',
        whereArgs: [startMillis, endMillis],
        orderBy: 'next_review_date ASC',
      );

      print('Retrieved ${maps.length} topics in date range');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error getting topics by date range: $e');
      return [];
    }
  }

  /// Get all topics that are due for review
  ///
  /// Returns topics where next_review_date <= current time
  Future<List<Topic>> getDueTopics() async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final maps = await db.query(
        _tableName,
        where: 'next_review_date <= ?',
        whereArgs: [now],
        orderBy: 'next_review_date ASC',
      );

      print('Retrieved ${maps.length} due topics');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error getting due topics: $e');
      return [];
    }
  }

  /// Get topics due in the next X days
  ///
  /// Returns topics scheduled for review within the specified number of days
  Future<List<Topic>> getUpcomingTopics(int days) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final future = now.add(Duration(days: days));

      final nowMillis = now.millisecondsSinceEpoch;
      final futureMillis = future.millisecondsSinceEpoch;

      final maps = await db.query(
        _tableName,
        where: 'next_review_date > ? AND next_review_date <= ?',
        whereArgs: [nowMillis, futureMillis],
        orderBy: 'next_review_date ASC',
      );

      print('Retrieved ${maps.length} upcoming topics in next $days days');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error getting upcoming topics: $e');
      return [];
    }
  }

  /// Get all favorite topics
  Future<List<Topic>> getFavoriteTopics() async {
    try {
      final db = await database;

      final maps = await db.query(
        _tableName,
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'next_review_date ASC',
      );

      print('Retrieved ${maps.length} favorite topics');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error getting favorite topics: $e');
      return [];
    }
  }

  /// Search topics by title
  ///
  /// Performs case-insensitive search on topic titles
  Future<List<Topic>> searchTopics(String query) async {
    try {
      final db = await database;

      final maps = await db.query(
        _tableName,
        where: 'title LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'title ASC',
      );

      print('Found ${maps.length} topics matching "$query"');
      return maps.map((map) => _mapToTopic(map)).toList();
    } catch (e) {
      print('Error searching topics: $e');
      return [];
    }
  }

  /// Get database statistics
  ///
  /// Returns useful statistics about the topics in the database
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Total topics
      final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      final total = Sqflite.firstIntValue(totalResult) ?? 0;

      // Due topics
      final dueResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE next_review_date <= ?',
        [now],
      );
      final due = Sqflite.firstIntValue(dueResult) ?? 0;

      // Favorite topics
      final favResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE is_favorite = 1',
      );
      final favorites = Sqflite.firstIntValue(favResult) ?? 0;

      // Average review count
      final avgResult = await db.rawQuery(
        'SELECT AVG(review_count) as avg FROM $_tableName',
      );
      final avgReviews = avgResult.first['avg'] as double? ?? 0.0;

      final stats = {
        'total': total,
        'due': due,
        'favorites': favorites,
        'averageReviews': avgReviews.round(),
      };

      print('Database statistics: $stats');
      return stats;
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'total': 0,
        'due': 0,
        'favorites': 0,
        'averageReviews': 0,
      };
    }
  }

  /// Convert Topic model to database map
  Map<String, dynamic> _topicToMap(Topic topic) {
    return {
      'id': topic.id,
      'title': topic.title,
      'file_path': topic.filePath,
      'created_at': topic.createdAt.millisecondsSinceEpoch,
      'current_stage': topic.currentStage,
      'next_review_date': topic.nextReviewDate.millisecondsSinceEpoch,
      'last_reviewed_at': topic.lastReviewedAt?.millisecondsSinceEpoch,
      'review_count': topic.reviewCount,
      'tags': topic.tags.join(','), // Store tags as comma-separated string
      'is_favorite': topic.isFavorite ? 1 : 0,
      // Future fields for custom scheduling
      'use_custom_schedule': 0,
      'custom_review_datetime': null,
      'reminder_time': null,
    };
  }

  /// Convert database map to Topic model
  Topic _mapToTopic(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['file_path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      currentStage: map['current_stage'] as int,
      nextReviewDate: DateTime.fromMillisecondsSinceEpoch(map['next_review_date'] as int),
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_reviewed_at'] as int)
          : null,
      reviewCount: map['review_count'] as int,
      tags: _parseTags(map['tags'] as String?),
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  /// Parse comma-separated tags string into list
  List<String> _parseTags(String? tagsString) {
    if (tagsString == null || tagsString.isEmpty) {
      return [];
    }
    return tagsString.split(',').where((tag) => tag.isNotEmpty).toList();
  }

  /// Close the database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('Database connection closed');
  }

  /// Delete the entire database (use with caution!)
  ///
  /// Useful for testing or complete app reset
  Future<void> deleteDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);

      await databaseFactory.deleteDatabase(path);
      _database = null;

      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
      rethrow;
    }
  }

  /// Get database file path (useful for debugging)
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, _databaseName);
  }
}
