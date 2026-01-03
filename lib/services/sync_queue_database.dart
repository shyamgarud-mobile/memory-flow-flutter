import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper for managing sync queue
class SyncQueueDatabase {
  static final SyncQueueDatabase instance = SyncQueueDatabase._init();
  static Database? _database;

  SyncQueueDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sync_queue.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        priority INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_status (
        id INTEGER PRIMARY KEY,
        last_sync_time INTEGER,
        last_successful_sync INTEGER,
        pending_changes_count INTEGER DEFAULT 0,
        is_syncing INTEGER DEFAULT 0
      )
    ''');

    // Initialize sync status
    await db.insert('sync_status', {
      'id': 1,
      'last_sync_time': 0,
      'last_successful_sync': 0,
      'pending_changes_count': 0,
      'is_syncing': 0,
    });
  }

  /// Add item to sync queue
  Future<int> addToQueue(SyncQueueItem item) async {
    final db = await database;
    final id = await db.insert('sync_queue', item.toMap());
    await _updatePendingCount();
    return id;
  }

  /// Get all pending items
  Future<List<SyncQueueItem>> getPendingItems({int? limit}) async {
    final db = await database;
    final result = await db.query(
      'sync_queue',
      orderBy: 'priority DESC, created_at ASC',
      limit: limit,
    );

    return result.map((json) => SyncQueueItem.fromMap(json)).toList();
  }

  /// Get items by operation type
  Future<List<SyncQueueItem>> getItemsByOperation(String operation) async {
    final db = await database;
    final result = await db.query(
      'sync_queue',
      where: 'operation = ?',
      whereArgs: [operation],
      orderBy: 'created_at ASC',
    );

    return result.map((json) => SyncQueueItem.fromMap(json)).toList();
  }

  /// Mark item as completed and remove from queue
  Future<void> removeFromQueue(int id) async {
    final db = await database;
    await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _updatePendingCount();
  }

  /// Update retry count and error for an item
  Future<void> updateRetryInfo(int id, String error) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1, last_error = ? WHERE id = ?',
      [error, id],
    );
  }

  /// Remove items that have exceeded max retry count
  Future<void> removeFailedItems(int maxRetries) async {
    final db = await database;
    await db.delete(
      'sync_queue',
      where: 'retry_count >= ?',
      whereArgs: [maxRetries],
    );
    await _updatePendingCount();
  }

  /// Clear entire queue
  Future<void> clearQueue() async {
    final db = await database;
    await db.delete('sync_queue');
    await _updatePendingCount();
  }

  /// Get queue size
  Future<int> getQueueSize() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sync_queue');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Update pending changes count
  Future<void> _updatePendingCount() async {
    final db = await database;
    final count = await getQueueSize();
    await db.update(
      'sync_status',
      {'pending_changes_count': count},
      where: 'id = 1',
    );
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    final db = await database;
    final result = await db.query(
      'sync_status',
      where: 'id = 1',
    );

    if (result.isEmpty) {
      return SyncStatus(
        lastSyncTime: DateTime.fromMillisecondsSinceEpoch(0),
        lastSuccessfulSync: DateTime.fromMillisecondsSinceEpoch(0),
        pendingChangesCount: 0,
        isSyncing: false,
      );
    }

    return SyncStatus.fromMap(result.first);
  }

  /// Update sync status
  Future<void> updateSyncStatus({
    DateTime? lastSyncTime,
    DateTime? lastSuccessfulSync,
    bool? isSyncing,
  }) async {
    final db = await database;
    final Map<String, dynamic> values = {};

    if (lastSyncTime != null) {
      values['last_sync_time'] = lastSyncTime.millisecondsSinceEpoch;
    }
    if (lastSuccessfulSync != null) {
      values['last_successful_sync'] = lastSuccessfulSync.millisecondsSinceEpoch;
    }
    if (isSyncing != null) {
      values['is_syncing'] = isSyncing ? 1 : 0;
    }

    await db.update(
      'sync_status',
      values,
      where: 'id = 1',
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

/// Represents an item in the sync queue
class SyncQueueItem {
  final int? id;
  final String operation; // 'backup', 'update_topic', 'delete_topic', etc.
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  final int priority; // Higher priority = processed first

  SyncQueueItem({
    this.id,
    required this.operation,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
    this.priority = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation': operation,
      'data': jsonEncode(data),
      'created_at': createdAt.millisecondsSinceEpoch,
      'retry_count': retryCount,
      'last_error': lastError,
      'priority': priority,
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as int?,
      operation: map['operation'] as String,
      data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      priority: map['priority'] as int? ?? 0,
    );
  }
}

/// Represents sync status
class SyncStatus {
  final DateTime lastSyncTime;
  final DateTime lastSuccessfulSync;
  final int pendingChangesCount;
  final bool isSyncing;

  SyncStatus({
    required this.lastSyncTime,
    required this.lastSuccessfulSync,
    required this.pendingChangesCount,
    required this.isSyncing,
  });

  factory SyncStatus.fromMap(Map<String, dynamic> map) {
    return SyncStatus(
      lastSyncTime: DateTime.fromMillisecondsSinceEpoch(
        map['last_sync_time'] as int? ?? 0,
      ),
      lastSuccessfulSync: DateTime.fromMillisecondsSinceEpoch(
        map['last_successful_sync'] as int? ?? 0,
      ),
      pendingChangesCount: map['pending_changes_count'] as int? ?? 0,
      isSyncing: (map['is_syncing'] as int? ?? 0) == 1,
    );
  }

  bool needsSync(Duration minInterval) {
    if (pendingChangesCount > 0) return true;
    final timeSinceSync = DateTime.now().difference(lastSuccessfulSync);
    return timeSinceSync >= minInterval;
  }
}
