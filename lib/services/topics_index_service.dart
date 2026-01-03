import '../models/topic.dart';
import 'database_service.dart';

/// Service for managing topics index (metadata)
///
/// This service now uses DatabaseService (SQLite) instead of JSON files.
/// It maintains the same public API for backward compatibility.
/// Uses singleton pattern to ensure only one instance exists.
class TopicsIndexService {
  // Singleton pattern
  static final TopicsIndexService _instance = TopicsIndexService._internal();

  /// Factory constructor returns the singleton instance
  factory TopicsIndexService() => _instance;

  /// Private constructor
  TopicsIndexService._internal();

  /// Database service instance
  final DatabaseService _db = DatabaseService();

  /// Cache for loaded topics
  List<Topic>? _cachedTopics;

  /// Load all topics from the database
  ///
  /// Returns cached topics if available, otherwise loads from database.
  /// Returns empty list if no topics exist.
  ///
  /// Returns: List of Topic objects
  /// Throws: Exception if read or parsing fails
  Future<List<Topic>> loadTopicsIndex() async {
    // Return cached topics if available
    if (_cachedTopics != null) {
      print('Returning ${_cachedTopics!.length} cached topics');
      return List.from(_cachedTopics!);
    }

    try {
      final topics = await _db.getAllTopics();
      _cachedTopics = topics;
      print('Loaded ${topics.length} topics from database');
      return List.from(topics);
    } catch (e) {
      print('Error loading topics: $e');
      throw Exception('Failed to load topics from database: $e');
    }
  }

  /// Add a new topic to the database
  ///
  /// Parameters:
  ///   - topic: Topic to add
  ///
  /// Throws: Exception if topic with same ID already exists or save fails
  Future<void> addTopic(Topic topic) async {
    try {
      final result = await _db.insertTopic(topic);
      if (result > 0) {
        // Clear cache to force reload
        clearCache();
        print('Added topic: ${topic.title} (${topic.id})');
      } else {
        throw Exception('Failed to insert topic into database');
      }
    } catch (e) {
      throw Exception('Failed to add topic: $e');
    }
  }

  /// Update an existing topic in the database
  ///
  /// Finds the topic by ID and replaces it with the updated version.
  ///
  /// Parameters:
  ///   - topic: Updated topic with existing ID
  ///
  /// Throws: Exception if topic not found or save fails
  Future<void> updateTopic(Topic topic) async {
    try {
      final result = await _db.updateTopic(topic);
      if (result > 0) {
        // Clear cache to force reload
        clearCache();
        print('Updated topic: ${topic.title} (${topic.id})');
      } else {
        throw Exception('Topic with ID ${topic.id} not found');
      }
    } catch (e) {
      throw Exception('Failed to update topic: $e');
    }
  }

  /// Delete a topic from the database
  ///
  /// Removes the topic with the specified ID from the database.
  /// Note: This does NOT delete the associated markdown file.
  /// Use FileService.deleteMarkdownFile() for that.
  ///
  /// Parameters:
  ///   - id: ID of topic to delete
  ///
  /// Returns: true if topic was deleted, false if not found
  /// Throws: Exception if delete fails
  Future<bool> deleteTopic(String id) async {
    try {
      final result = await _db.deleteTopic(id);
      if (result > 0) {
        // Clear cache to force reload
        clearCache();
        print('Deleted topic with ID: $id');
        return true;
      } else {
        print('Topic with ID $id not found');
        return false;
      }
    } catch (e) {
      throw Exception('Failed to delete topic: $e');
    }
  }

  /// Get a single topic by ID
  ///
  /// Parameters:
  ///   - id: ID of topic to retrieve
  ///
  /// Returns: Topic if found, null otherwise
  Future<Topic?> getTopicById(String id) async {
    try {
      return await _db.getTopic(id);
    } catch (e) {
      print('Error getting topic by ID: $e');
      return null;
    }
  }

  /// Get topics that are due for review
  ///
  /// Returns topics where nextReviewDate is today or earlier.
  ///
  /// Returns: List of topics due for review
  Future<List<Topic>> getDueTopics() async {
    try {
      return await _db.getDueTopics();
    } catch (e) {
      throw Exception('Failed to get due topics: $e');
    }
  }

  /// Get favorite topics
  ///
  /// Returns: List of topics marked as favorite
  Future<List<Topic>> getFavoriteTopics() async {
    try {
      return await _db.getFavoriteTopics();
    } catch (e) {
      throw Exception('Failed to get favorite topics: $e');
    }
  }

  /// Search topics by title or tags
  ///
  /// Parameters:
  ///   - query: Search query (case-insensitive)
  ///
  /// Returns: List of matching topics
  Future<List<Topic>> searchTopics(String query) async {
    try {
      return await _db.searchTopics(query);
    } catch (e) {
      throw Exception('Failed to search topics: $e');
    }
  }

  /// Get topics count
  ///
  /// Returns: Total number of topics
  Future<int> getTopicsCount() async {
    try {
      return await _db.getTopicsCount();
    } catch (e) {
      return 0;
    }
  }

  /// Load topics with pagination for efficient list loading
  ///
  /// Parameters:
  ///   - limit: Maximum number of topics to load (default 20)
  ///   - offset: Number of topics to skip (for pagination)
  ///
  /// Returns: List of Topic objects
  Future<List<Topic>> loadTopicsIndexPaginated({
    required int limit,
    required int offset,
  }) async {
    try {
      final topics = await _db.getTopicsPaginated(
        limit: limit,
        offset: offset,
        orderBy: 'next_review_date',
        ascending: true,
      );
      print('Loaded ${topics.length} topics (offset: $offset, limit: $limit)');
      return topics;
    } catch (e) {
      print('Error loading paginated topics: $e');
      throw Exception('Failed to load topics from database: $e');
    }
  }

  /// Clear the cache
  ///
  /// Forces the next loadTopicsIndex() call to read from database
  void clearCache() {
    _cachedTopics = null;
    print('Topics cache cleared');
  }

  /// Get statistics about topics
  ///
  /// Returns: Map with statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await _db.getStatistics();
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  /// Save the complete topics list to the database
  ///
  /// This method is kept for backward compatibility but is not recommended.
  /// Use addTopic(), updateTopic(), or deleteTopic() for incremental updates.
  ///
  /// Parameters:
  ///   - topics: Complete list of topics to save
  ///
  /// Throws: Exception if save fails
  @Deprecated('Use addTopic(), updateTopic(), or deleteTopic() instead')
  Future<void> saveTopicsIndex(List<Topic> topics) async {
    // This is a legacy method - not recommended for use with database
    throw UnimplementedError(
      'saveTopicsIndex is deprecated. Use addTopic(), updateTopic(), or deleteTopic() instead.',
    );
  }

  /// Delete the database (use with caution!)
  ///
  /// This is useful for testing or resetting the app.
  /// Does not delete markdown content files.
  ///
  /// Returns: true if database was deleted
  Future<bool> deleteIndexFile() async {
    try {
      await _db.deleteDatabase();
      clearCache();
      print('Deleted database');
      return true;
    } catch (e) {
      throw Exception('Failed to delete database: $e');
    }
  }
}
