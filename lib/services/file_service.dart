import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing markdown file storage
///
/// This service handles all file operations for storing topic content.
/// - On web: Uses SharedPreferences (browser localStorage)
/// - On mobile/desktop: Uses file system via path_provider
///
/// Uses singleton pattern to ensure only one instance exists.
class FileService {
  // Singleton pattern
  static final FileService _instance = FileService._internal();

  /// Factory constructor returns the singleton instance
  factory FileService() => _instance;

  /// Private constructor
  FileService._internal();

  /// Name of the folder where topics are stored (mobile/desktop only)
  static const String _topicsFolder = 'topics';

  /// Prefix for SharedPreferences keys (web only)
  static const String _webPrefix = 'topic_content_';

  /// Cache for the topics directory path (mobile/desktop only)
  Directory? _topicsDirectory;

  /// Get the topics directory, creating it if it doesn't exist
  ///
  /// This method ensures the topics folder exists in the app's
  /// documents directory. The path is cached after first access.
  ///
  /// Returns: Directory object for the topics folder
  /// Throws: Exception if directory creation fails
  Future<Directory> _getTopicsDirectory() async {
    // Return cached directory if available
    if (_topicsDirectory != null) {
      return _topicsDirectory!;
    }

    try {
      // Get the app's documents directory
      final appDocDir = await getApplicationDocumentsDirectory();

      // Create topics subdirectory path
      final topicsPath = '${appDocDir.path}/$_topicsFolder';
      final topicsDir = Directory(topicsPath);

      // Create directory if it doesn't exist
      if (!await topicsDir.exists()) {
        await topicsDir.create(recursive: true);
        print('Created topics directory: $topicsPath');
      }

      // Cache the directory
      _topicsDirectory = topicsDir;
      return topicsDir;
    } catch (e) {
      throw Exception('Failed to get topics directory: $e');
    }
  }

  /// Save markdown content to a file
  ///
  /// Creates or overwrites a markdown file with the given ID and content.
  /// - On web: Saves to SharedPreferences with key 'topic_content_{id}'
  /// - On mobile/desktop: Saves as {id}.md in the topics directory
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic (typically UUID)
  ///   - content: Markdown content to save
  ///
  /// Returns: File path (or key for web) where content was saved
  /// Throws: Exception if save fails
  Future<String> saveMarkdownFile(String id, String content) async {
    if (kIsWeb) {
      // Web: Use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = '$_webPrefix$id';
        await prefs.setString(key, content);
        print('Saved markdown to SharedPreferences: $key (${content.length} characters)');
        return key;
      } catch (e) {
        throw Exception('Failed to save markdown to SharedPreferences for topic $id: $e');
      }
    } else {
      // Mobile/Desktop: Use file system
      try {
        final topicsDir = await _getTopicsDirectory();
        final filePath = '${topicsDir.path}/$id.md';
        final file = File(filePath);
        await file.writeAsString(content);
        print('Saved markdown file: $filePath (${content.length} characters)');
        return filePath;
      } catch (e) {
        throw Exception('Failed to save markdown file for topic $id: $e');
      }
    }
  }

  /// Read markdown content from a file
  ///
  /// Reads and returns the content of a markdown file with the given ID.
  /// - On web: Reads from SharedPreferences with key 'topic_content_{id}'
  /// - On mobile/desktop: Reads from {id}.md in the topics directory
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic
  ///
  /// Returns: String content of the markdown file
  /// Throws: Exception if content doesn't exist or read fails
  Future<String> readMarkdownFile(String id) async {
    if (kIsWeb) {
      // Web: Use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = '$_webPrefix$id';
        final content = prefs.getString(key);

        if (content == null) {
          throw Exception('Markdown content not found for topic $id');
        }

        print('Read markdown from SharedPreferences: $key (${content.length} characters)');
        return content;
      } catch (e) {
        throw Exception('Failed to read markdown from SharedPreferences for topic $id: $e');
      }
    } else {
      // Mobile/Desktop: Use file system
      try {
        final topicsDir = await _getTopicsDirectory();
        final filePath = '${topicsDir.path}/$id.md';
        final file = File(filePath);

        if (!await file.exists()) {
          throw Exception('Markdown file not found for topic $id');
        }

        final content = await file.readAsString();
        print('Read markdown file: $filePath (${content.length} characters)');
        return content;
      } catch (e) {
        throw Exception('Failed to read markdown file for topic $id: $e');
      }
    }
  }

  /// Delete a markdown file
  ///
  /// Deletes the markdown file associated with the given topic ID.
  /// - On web: Removes from SharedPreferences
  /// - On mobile/desktop: Deletes the .md file
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic
  ///
  /// Returns: true if content was deleted, false if it didn't exist
  /// Throws: Exception if deletion fails
  Future<bool> deleteMarkdownFile(String id) async {
    if (kIsWeb) {
      // Web: Use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = '$_webPrefix$id';
        final existed = prefs.containsKey(key);

        if (!existed) {
          print('Markdown content not found in SharedPreferences (already deleted?): $key');
          return false;
        }

        await prefs.remove(key);
        print('Deleted markdown from SharedPreferences: $key');
        return true;
      } catch (e) {
        throw Exception('Failed to delete markdown from SharedPreferences for topic $id: $e');
      }
    } else {
      // Mobile/Desktop: Use file system
      try {
        final topicsDir = await _getTopicsDirectory();
        final filePath = '${topicsDir.path}/$id.md';
        final file = File(filePath);

        if (!await file.exists()) {
          print('Markdown file not found (already deleted?): $filePath');
          return false;
        }

        await file.delete();
        print('Deleted markdown file: $filePath');
        return true;
      } catch (e) {
        throw Exception('Failed to delete markdown file for topic $id: $e');
      }
    }
  }

  /// Get all markdown file IDs
  ///
  /// Scans storage and returns a list of all topic IDs.
  /// - On web: Lists all SharedPreferences keys with the topic prefix
  /// - On mobile/desktop: Lists all .md files in the topics directory
  ///
  /// Returns: List of topic IDs (empty list if no content exists)
  /// Throws: Exception if read fails
  Future<List<String>> getAllMarkdownFiles() async {
    if (kIsWeb) {
      // Web: List SharedPreferences keys
      try {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();

        // Filter for topic content keys and extract IDs
        final topicIds = keys
            .where((key) => key.startsWith(_webPrefix))
            .map((key) => key.substring(_webPrefix.length))
            .toList();

        print('Found ${topicIds.length} topics in SharedPreferences');
        return topicIds;
      } catch (e) {
        throw Exception('Failed to list topics from SharedPreferences: $e');
      }
    } else {
      // Mobile/Desktop: List files
      try {
        final topicsDir = await _getTopicsDirectory();
        final files = await topicsDir.list().toList();

        final markdownFiles = files
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'))
            .map((file) {
              final filename = file.path.split('/').last;
              return filename.substring(0, filename.length - 3);
            })
            .toList();

        print('Found ${markdownFiles.length} markdown files');
        return markdownFiles;
      } catch (e) {
        throw Exception('Failed to list markdown files: $e');
      }
    }
  }

  /// Check if a markdown file exists
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic
  ///
  /// Returns: true if content exists, false otherwise
  Future<bool> fileExists(String id) async {
    if (kIsWeb) {
      // Web: Check SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = '$_webPrefix$id';
        return prefs.containsKey(key);
      } catch (e) {
        print('Error checking SharedPreferences existence for $id: $e');
        return false;
      }
    } else {
      // Mobile/Desktop: Check file system
      try {
        final topicsDir = await _getTopicsDirectory();
        final filePath = '${topicsDir.path}/$id.md';
        final file = File(filePath);
        return await file.exists();
      } catch (e) {
        print('Error checking file existence for $id: $e');
        return false;
      }
    }
  }

  /// Get file size in bytes
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic
  ///
  /// Returns: File size in bytes, or -1 if file doesn't exist
  Future<int> getFileSize(String id) async {
    try {
      final topicsDir = await _getTopicsDirectory();
      final filePath = '${topicsDir.path}/$id.md';
      final file = File(filePath);

      if (!await file.exists()) {
        return -1;
      }

      return await file.length();
    } catch (e) {
      print('Error getting file size for $id: $e');
      return -1;
    }
  }

  /// Clear all markdown files (use with caution!)
  ///
  /// Deletes all topic content from storage.
  /// This is useful for testing or resetting the app.
  ///
  /// Returns: Number of items deleted
  Future<int> clearAllFiles() async {
    if (kIsWeb) {
      // Web: Clear SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();

        int deletedCount = 0;
        for (final key in keys) {
          if (key.startsWith(_webPrefix)) {
            await prefs.remove(key);
            deletedCount++;
          }
        }

        print('Cleared $deletedCount topics from SharedPreferences');
        return deletedCount;
      } catch (e) {
        throw Exception('Failed to clear topics from SharedPreferences: $e');
      }
    } else {
      // Mobile/Desktop: Delete files
      try {
        final topicsDir = await _getTopicsDirectory();
        final files = await topicsDir.list().toList();

        int deletedCount = 0;
        for (final file in files.whereType<File>()) {
          if (file.path.endsWith('.md')) {
            await file.delete();
            deletedCount++;
          }
        }

        print('Cleared $deletedCount markdown files');
        return deletedCount;
      } catch (e) {
        throw Exception('Failed to clear markdown files: $e');
      }
    }
  }

  /// Get the full path for a topic's markdown file
  ///
  /// Parameters:
  ///   - id: Unique identifier for the topic
  ///
  /// Returns: Full file path
  Future<String> getFilePath(String id) async {
    final topicsDir = await _getTopicsDirectory();
    return '${topicsDir.path}/$id.md';
  }
}
