import 'dart:async';
import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:crypto/crypto.dart';
import 'google_drive_service.dart';
import 'notification_service.dart';
import 'sync_queue_database.dart';
import 'database_service.dart';

/// Background sync service using WorkManager
class BackgroundSyncService {
  static const String _syncTaskName = 'memoryflow_sync_task';
  static const String _uniqueTaskName = 'memoryflow_periodic_sync';

  // Preference keys
  static const String _prefKeyAutoSync = 'auto_sync_enabled';
  static const String _prefKeyWifiOnly = 'sync_wifi_only';
  static const String _prefKeySyncInterval = 'sync_interval_hours';
  static const String _prefKeyQuietHoursEnabled = 'quiet_hours_enabled';
  static const String _prefKeyQuietHoursStart = 'quiet_hours_start';
  static const String _prefKeyQuietHoursEnd = 'quiet_hours_end';
  static const String _prefKeySilentSync = 'silent_sync';
  static const String _prefKeyReviewedCountTrigger = 'reviewed_count_trigger';
  static const String _prefKeyCurrentReviewedCount = 'current_reviewed_count';

  // Default values
  static const int _defaultSyncIntervalHours = 12;
  static const int _defaultQuietHoursStart = 22; // 10 PM
  static const int _defaultQuietHoursEnd = 7; // 7 AM
  static const int _defaultReviewedCountTrigger = 5;
  static const int _minBatteryPercent = 15;
  static const int _maxRetries = 3;
  static const int _batchUploadSize = 10; // Upload in batches of 10
  static const String _prefKeyLastSyncHash = 'last_sync_hash';

  final GoogleDriveService _driveService;
  final SyncQueueDatabase _queueDb;
  final DatabaseService _dbHelper;
  final NotificationService _notificationService;

  BackgroundSyncService({
    required GoogleDriveService driveService,
    required SyncQueueDatabase queueDb,
    required DatabaseService dbHelper,
    required NotificationService notificationService,
  })  : _driveService = driveService,
        _queueDb = queueDb,
        _dbHelper = dbHelper,
        _notificationService = notificationService;

  /// Initialize background sync
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Register periodic sync task if auto-sync is enabled
    final prefs = await SharedPreferences.getInstance();
    final autoSyncEnabled = prefs.getBool(_prefKeyAutoSync) ?? true;

    if (autoSyncEnabled) {
      await registerPeriodicSync();
    }

    print('✓ Background sync service initialized');
  }

  /// Register periodic sync task
  Future<void> registerPeriodicSync() async {
    final prefs = await SharedPreferences.getInstance();
    final intervalHours = prefs.getInt(_prefKeySyncInterval) ?? _defaultSyncIntervalHours;

    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      _syncTaskName,
      frequency: Duration(hours: intervalHours),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    print('✓ Periodic sync registered (every $intervalHours hours)');
  }

  /// Cancel periodic sync
  Future<void> cancelPeriodicSync() async {
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
    print('✓ Periodic sync cancelled');
  }

  /// Trigger immediate sync
  Future<void> triggerImmediateSync() async {
    await Workmanager().registerOneOffTask(
      'immediate_sync_${DateTime.now().millisecondsSinceEpoch}',
      _syncTaskName,
      initialDelay: Duration.zero,
    );
    print('✓ Immediate sync triggered');
  }

  /// Check if should sync based on conditions
  Future<bool> shouldSync() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if auto-sync is enabled
    final autoSyncEnabled = prefs.getBool(_prefKeyAutoSync) ?? true;
    if (!autoSyncEnabled) {
      print('ℹ️ Auto-sync is disabled');
      return false;
    }

    // Check if signed in to Google Drive
    if (!await _driveService.isSignedIn()) {
      print('ℹ️ Not signed in to Google Drive');
      return false;
    }

    // Check battery level
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;
    if (batteryLevel < _minBatteryPercent) {
      print('ℹ️ Battery too low: $batteryLevel%');
      return false;
    }

    // Check battery saver mode
    if (await battery.isInBatterySaveMode) {
      print('ℹ️ Battery saver mode is enabled');
      return false;
    }

    // Check WiFi requirement
    final wifiOnly = prefs.getBool(_prefKeyWifiOnly) ?? false;
    if (wifiOnly) {
      final connectivity = Connectivity();
      final result = await connectivity.checkConnectivity();
      if (!result.contains(ConnectivityResult.wifi)) {
        print('ℹ️ WiFi required but not connected');
        return false;
      }
    }

    // Check quiet hours
    if (isInQuietHours(prefs)) {
      print('ℹ️ In quiet hours');
      return false;
    }

    return true;
  }

  /// Check if currently in quiet hours
  bool isInQuietHours(SharedPreferences prefs) {
    final quietHoursEnabled = prefs.getBool(_prefKeyQuietHoursEnabled) ?? true;
    if (!quietHoursEnabled) return false;

    final now = DateTime.now();
    final currentHour = now.hour;

    final startHour = prefs.getInt(_prefKeyQuietHoursStart) ?? _defaultQuietHoursStart;
    final endHour = prefs.getInt(_prefKeyQuietHoursEnd) ?? _defaultQuietHoursEnd;

    // Handle overnight quiet hours (e.g., 22:00 to 7:00)
    if (startHour > endHour) {
      return currentHour >= startHour || currentHour < endHour;
    } else {
      return currentHour >= startHour && currentHour < endHour;
    }
  }

  /// Perform sync operation
  Future<bool> performSync() async {
    print('🔄 Starting sync...');

    try {
      // Check sync conditions
      if (!await shouldSync()) {
        return false;
      }

      // Update sync status
      await _queueDb.updateSyncStatus(
        lastSyncTime: DateTime.now(),
        isSyncing: true,
      );

      // Process sync queue
      final pendingItems = await _queueDb.getPendingItems(limit: 50);

      if (pendingItems.isEmpty) {
        print('ℹ️ No pending items to sync');

        // Do a full backup anyway
        await _performFullBackup();

        await _queueDb.updateSyncStatus(
          lastSuccessfulSync: DateTime.now(),
          isSyncing: false,
        );

        await _showSuccessNotification();
        return true;
      }

      print('📦 Processing ${pendingItems.length} pending items...');

      int successCount = 0;
      int failCount = 0;

      for (final item in pendingItems) {
        try {
          await _processSyncItem(item);
          await _queueDb.removeFromQueue(item.id!);
          successCount++;
        } catch (e) {
          print('❌ Failed to sync item ${item.id}: $e');
          await _queueDb.updateRetryInfo(item.id!, e.toString());
          failCount++;
        }
      }

      // Remove items that exceeded max retries
      await _queueDb.removeFailedItems(_maxRetries);

      // Perform full backup after processing queue
      await _performFullBackup();

      // Update sync status
      await _queueDb.updateSyncStatus(
        lastSuccessfulSync: DateTime.now(),
        isSyncing: false,
      );

      print('✅ Sync complete: $successCount succeeded, $failCount failed');

      // Show notification
      if (failCount > 0) {
        await _showErrorNotification(failCount);
      } else {
        await _showSuccessNotification();
      }

      return true;
    } catch (e) {
      print('❌ Sync failed: $e');

      await _queueDb.updateSyncStatus(isSyncing: false);
      await _showErrorNotification(0, message: e.toString());

      return false;
    }
  }

  /// Process individual sync item
  Future<void> _processSyncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case 'backup':
        await _performFullBackup();
        break;

      case 'update_topic':
        // Topic updates are included in full backup
        await _performFullBackup();
        break;

      case 'delete_topic':
        // Deletions are reflected in full backup
        await _performFullBackup();
        break;

      default:
        print('⚠️ Unknown operation: ${item.operation}');
    }
  }

  /// Perform full backup to Google Drive with delta sync
  Future<void> _performFullBackup() async {
    print('💾 Performing backup...');

    // Get all topics
    final topics = await _dbHelper.getAllTopics();

    // Prepare backup data
    final backupData = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'topics': topics.map((t) => t.toJson()).toList(),
      'settings': await _exportSettings(),
    };

    // Check if data has changed (delta sync)
    final currentHash = _computeDataHash(backupData);
    final prefs = await SharedPreferences.getInstance();
    final lastHash = prefs.getString(_prefKeyLastSyncHash);

    if (lastHash == currentHash) {
      print('ℹ️ No changes detected, skipping backup');
      return;
    }

    // Upload to Google Drive
    final success = await _driveService.backup(backupData);

    if (!success) {
      throw Exception('Failed to backup to Google Drive');
    }

    // Save hash for next delta check
    await prefs.setString(_prefKeyLastSyncHash, currentHash);

    print('✅ Backup completed');
  }

  /// Compute hash of data for delta sync
  String _computeDataHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return md5.convert(utf8.encode(jsonString)).toString();
  }

  /// Perform batch upload of topics
  Future<void> performBatchUpload(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) return;

    print('📦 Batch uploading ${items.length} items in batches of $_batchUploadSize...');

    int successCount = 0;
    int batchNumber = 0;

    // Split into batches
    for (var i = 0; i < items.length; i += _batchUploadSize) {
      batchNumber++;
      final batch = items.skip(i).take(_batchUploadSize).toList();

      print('  Batch $batchNumber: ${batch.length} items');

      // Upload batch
      final batchData = {
        'type': 'batch',
        'timestamp': DateTime.now().toIso8601String(),
        'items': batch,
      };

      final success = await _driveService.backup(batchData);
      if (success) {
        successCount += batch.length;
      } else {
        print('  ❌ Batch $batchNumber failed');
      }

      // Small delay between batches to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('✅ Batch upload complete: $successCount/${items.length} items');
  }

  /// Get changed topics since last sync
  Future<List<String>> getChangedTopicIds() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncTime = prefs.getInt('last_sync_timestamp') ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncTime);

    final allTopics = await _dbHelper.getAllTopics();
    final changedIds = <String>[];

    for (final topic in allTopics) {
      // Check if topic was modified after last sync
      if (topic.lastReviewedAt != null &&
          topic.lastReviewedAt!.isAfter(lastSync)) {
        changedIds.add(topic.id);
      }
    }

    return changedIds;
  }

  /// Perform incremental sync (only changed items)
  Future<bool> performIncrementalSync() async {
    print('🔄 Starting incremental sync...');

    try {
      if (!await shouldSync()) {
        return false;
      }

      final changedIds = await getChangedTopicIds();

      if (changedIds.isEmpty) {
        print('ℹ️ No changes to sync');
        return true;
      }

      print('📦 Syncing ${changedIds.length} changed topics...');

      // Get changed topics
      final changedTopics = <Map<String, dynamic>>[];
      for (final id in changedIds) {
        final topic = await _dbHelper.getTopic(id);
        if (topic != null) {
          changedTopics.add(topic.toJson());
        }
      }

      // Batch upload
      await performBatchUpload(changedTopics);

      // Update last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'last_sync_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      await _queueDb.updateSyncStatus(
        lastSuccessfulSync: DateTime.now(),
        isSyncing: false,
      );

      print('✅ Incremental sync complete');
      return true;
    } catch (e) {
      print('❌ Incremental sync failed: $e');
      return false;
    }
  }

  /// Export settings for backup
  Future<Map<String, dynamic>> _exportSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'auto_sync_enabled': prefs.getBool(_prefKeyAutoSync),
      'sync_wifi_only': prefs.getBool(_prefKeyWifiOnly),
      'sync_interval_hours': prefs.getInt(_prefKeySyncInterval),
      'quiet_hours_enabled': prefs.getBool(_prefKeyQuietHoursEnabled),
      'quiet_hours_start': prefs.getInt(_prefKeyQuietHoursStart),
      'quiet_hours_end': prefs.getInt(_prefKeyQuietHoursEnd),
      'silent_sync': prefs.getBool(_prefKeySilentSync),
    };
  }

  /// Queue a sync operation
  Future<void> queueSync(String operation, Map<String, dynamic> data, {int priority = 0}) async {
    final item = SyncQueueItem(
      operation: operation,
      data: data,
      createdAt: DateTime.now(),
      priority: priority,
    );

    await _queueDb.addToQueue(item);
    print('📝 Queued sync operation: $operation');
  }

  /// Increment reviewed count and trigger sync if needed
  Future<void> incrementReviewedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_prefKeyCurrentReviewedCount) ?? 0;
    final trigger = prefs.getInt(_prefKeyReviewedCountTrigger) ?? _defaultReviewedCountTrigger;

    final newCount = currentCount + 1;
    await prefs.setInt(_prefKeyCurrentReviewedCount, newCount);

    if (newCount >= trigger) {
      print('📊 Reviewed count trigger reached: $newCount/$trigger');
      await prefs.setInt(_prefKeyCurrentReviewedCount, 0);
      await triggerImmediateSync();
    }
  }

  /// Check and sync on app resume
  Future<void> checkAndSyncOnResume() async {
    final status = await _queueDb.getSyncStatus();
    final hoursSinceSync = DateTime.now().difference(status.lastSuccessfulSync).inHours;

    if (hoursSinceSync >= 1 || status.pendingChangesCount > 0) {
      await triggerImmediateSync();
    }
  }

  /// Show success notification
  Future<void> _showSuccessNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final silentSync = prefs.getBool(_prefKeySilentSync) ?? true;

    if (!silentSync) {
      await _notificationService.showNotification(
        title: 'Sync Complete',
        body: 'Your data has been backed up successfully',
      );
    }
  }

  /// Show error notification
  Future<void> _showErrorNotification(int failCount, {String? message}) async {
    await _notificationService.showNotification(
      title: 'Sync Error',
      body: message ?? 'Failed to sync $failCount items. Will retry later.',
    );
  }

  /// Get sync status
  Future<SyncStatus> getSyncStatus() async {
    return await _queueDb.getSyncStatus();
  }

  /// Get pending changes count
  Future<int> getPendingChangesCount() async {
    return await _queueDb.getQueueSize();
  }
}

/// Background callback dispatcher (runs in separate isolate)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 Background task started: $task');

    try {
      // Initialize services
      final driveService = GoogleDriveService();
      final queueDb = SyncQueueDatabase.instance;
      final dbHelper = DatabaseService();
      final notificationService = NotificationService();

      await notificationService.initialize();

      final syncService = BackgroundSyncService(
        driveService: driveService,
        queueDb: queueDb,
        dbHelper: dbHelper,
        notificationService: notificationService,
      );

      // Perform sync
      final success = await syncService.performSync();

      print(success ? '✅ Background task completed successfully' : '⚠️ Background task completed with warnings');
      return success;
    } catch (e) {
      print('❌ Background task failed: $e');
      return Future.error(e);
    }
  });
}
