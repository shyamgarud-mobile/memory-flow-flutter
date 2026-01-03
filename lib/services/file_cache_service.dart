import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// Service for caching file content with LRU eviction
///
/// Performance optimizations:
/// - In-memory LRU cache for recently accessed files
/// - Disk cache for larger/persistent storage
/// - File compression for large markdown files
/// - Lazy loading (only load when needed)
class FileCacheService {
  static final FileCacheService _instance = FileCacheService._internal();
  factory FileCacheService() => _instance;
  FileCacheService._internal();

  // Cache configuration
  static const int _maxMemoryCacheSize = 50; // Max items in memory
  static const int _maxMemoryCacheMB = 10; // Max MB in memory
  static const int _compressionThreshold = 10000; // Compress files > 10KB
  static const Duration _diskCacheExpiry = Duration(days: 7);

  // In-memory LRU cache
  final Map<String, _CacheEntry> _memoryCache = {};
  final List<String> _accessOrder = [];
  int _currentMemoryBytes = 0;

  // Performance tracking
  int _cacheHits = 0;
  int _cacheMisses = 0;
  final Stopwatch _perfTimer = Stopwatch();

  /// Get cached content or null if not cached
  Future<String?> get(String key) async {
    _perfTimer.reset();
    _perfTimer.start();

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      _updateAccessOrder(key);
      _cacheHits++;
      _perfTimer.stop();
      print('Cache hit (memory): $key [${_perfTimer.elapsedMilliseconds}ms]');
      return _memoryCache[key]!.content;
    }

    // Check disk cache
    final diskContent = await _getFromDisk(key);
    if (diskContent != null) {
      // Promote to memory cache
      await _addToMemoryCache(key, diskContent);
      _cacheHits++;
      _perfTimer.stop();
      print('Cache hit (disk): $key [${_perfTimer.elapsedMilliseconds}ms]');
      return diskContent;
    }

    _cacheMisses++;
    _perfTimer.stop();
    print('Cache miss: $key');
    return null;
  }

  /// Store content in cache
  Future<void> put(String key, String content) async {
    // Add to memory cache
    await _addToMemoryCache(key, content);

    // Also persist to disk
    await _saveToDisk(key, content);
  }

  /// Remove item from cache
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    _accessOrder.remove(key);
    await _removeFromDisk(key);
  }

  /// Clear all caches
  Future<void> clear() async {
    _memoryCache.clear();
    _accessOrder.clear();
    _currentMemoryBytes = 0;
    await _clearDiskCache();
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final hitRate = _cacheHits + _cacheMisses > 0
        ? (_cacheHits / (_cacheHits + _cacheMisses) * 100).toStringAsFixed(1)
        : '0';

    return {
      'memoryItems': _memoryCache.length,
      'memoryBytes': _currentMemoryBytes,
      'memoryMB': (_currentMemoryBytes / 1024 / 1024).toStringAsFixed(2),
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'hitRate': '$hitRate%',
    };
  }

  // Private methods

  Future<void> _addToMemoryCache(String key, String content) async {
    final bytes = utf8.encode(content).length;

    // Remove old entry if exists
    if (_memoryCache.containsKey(key)) {
      _currentMemoryBytes -= _memoryCache[key]!.bytes;
      _memoryCache.remove(key);
      _accessOrder.remove(key);
    }

    // Evict if necessary
    while (_memoryCache.length >= _maxMemoryCacheSize ||
        _currentMemoryBytes + bytes > _maxMemoryCacheMB * 1024 * 1024) {
      if (_accessOrder.isEmpty) break;
      final oldest = _accessOrder.removeAt(0);
      _currentMemoryBytes -= _memoryCache[oldest]!.bytes;
      _memoryCache.remove(oldest);
    }

    // Add new entry
    _memoryCache[key] = _CacheEntry(content: content, bytes: bytes);
    _accessOrder.add(key);
    _currentMemoryBytes += bytes;
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  Future<String> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/file_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String _getHashedKey(String key) {
    return md5.convert(utf8.encode(key)).toString();
  }

  Future<String?> _getFromDisk(String key) async {
    try {
      final cacheDir = await _getCacheDir();
      final hashedKey = _getHashedKey(key);
      final file = File('$cacheDir/$hashedKey');

      if (!await file.exists()) return null;

      // Check if expired
      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) > _diskCacheExpiry) {
        await file.delete();
        return null;
      }

      final bytes = await file.readAsBytes();

      // Check if compressed (starts with gzip magic number)
      if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
        return utf8.decode(gzip.decode(bytes));
      }

      return utf8.decode(bytes);
    } catch (e) {
      print('Error reading from disk cache: $e');
      return null;
    }
  }

  Future<void> _saveToDisk(String key, String content) async {
    try {
      final cacheDir = await _getCacheDir();
      final hashedKey = _getHashedKey(key);
      final file = File('$cacheDir/$hashedKey');

      List<int> bytes = utf8.encode(content);

      // Compress if large
      if (bytes.length > _compressionThreshold) {
        bytes = gzip.encode(bytes);
        print('Compressed ${content.length} -> ${bytes.length} bytes');
      }

      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error writing to disk cache: $e');
    }
  }

  Future<void> _removeFromDisk(String key) async {
    try {
      final cacheDir = await _getCacheDir();
      final hashedKey = _getHashedKey(key);
      final file = File('$cacheDir/$hashedKey');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error removing from disk cache: $e');
    }
  }

  Future<void> _clearDiskCache() async {
    try {
      final cacheDir = await _getCacheDir();
      final dir = Directory(cacheDir);

      if (await dir.exists()) {
        await for (var entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      print('Error clearing disk cache: $e');
    }
  }

  /// Preload multiple files in background
  Future<void> preload(List<String> keys, Future<String?> Function(String) loader) async {
    await Future.wait(
      keys.map((key) async {
        if (!_memoryCache.containsKey(key)) {
          final content = await loader(key);
          if (content != null) {
            await put(key, content);
          }
        }
      }),
    );
  }
}

class _CacheEntry {
  final String content;
  final int bytes;

  _CacheEntry({required this.content, required this.bytes});
}

/// Extension to add caching to file operations
extension CachedFileOperations on File {
  static final FileCacheService _cache = FileCacheService();

  /// Read file with caching
  Future<String> readAsStringCached() async {
    final key = path;

    // Try cache first
    final cached = await _cache.get(key);
    if (cached != null) {
      return cached;
    }

    // Read from disk and cache
    final content = await readAsString();
    await _cache.put(key, content);

    return content;
  }

  /// Write file and update cache
  Future<void> writeAsStringCached(String content) async {
    await writeAsString(content);
    await _cache.put(path, content);
  }

  /// Delete file and remove from cache
  Future<void> deleteCached() async {
    await delete();
    await _cache.remove(path);
  }
}
