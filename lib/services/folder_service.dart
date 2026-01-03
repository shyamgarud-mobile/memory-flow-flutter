import '../models/folder.dart';
import '../models/topic.dart';
import 'database_service.dart';

/// Service for managing folders
///
/// Provides CRUD operations and tree structure management for folders.
class FolderService {
  // Singleton pattern
  static final FolderService _instance = FolderService._internal();
  factory FolderService() => _instance;
  FolderService._internal();

  /// Database service instance
  final DatabaseService _db = DatabaseService();

  /// Cache for loaded folders
  List<Folder>? _cachedFolders;

  /// Load all folders from the database
  Future<List<Folder>> loadAllFolders() async {
    if (_cachedFolders != null) {
      return List.from(_cachedFolders!);
    }

    try {
      final folders = await _db.getAllFolders();
      _cachedFolders = folders;
      return List.from(folders);
    } catch (e) {
      print('Error loading folders: $e');
      return [];
    }
  }

  /// Get root-level folders (no parent)
  Future<List<Folder>> getRootFolders() async {
    try {
      return await _db.getChildFolders(null);
    } catch (e) {
      print('Error getting root folders: $e');
      return [];
    }
  }

  /// Get child folders of a parent
  Future<List<Folder>> getChildFolders(String parentId) async {
    try {
      return await _db.getChildFolders(parentId);
    } catch (e) {
      print('Error getting child folders: $e');
      return [];
    }
  }

  /// Get topics in a specific folder
  Future<List<Topic>> getTopicsInFolder(String? folderId) async {
    try {
      return await _db.getTopicsInFolder(folderId);
    } catch (e) {
      print('Error getting topics in folder: $e');
      return [];
    }
  }

  /// Create a new folder
  Future<Folder?> createFolder({
    required String name,
    String? parentId,
    String? color,
    String? iconName,
  }) async {
    try {
      final folder = Folder.create(
        name: name,
        parentId: parentId,
        color: color,
        iconName: iconName,
      );

      final result = await _db.insertFolder(folder);
      if (result > 0) {
        clearCache();
        return folder;
      }
      return null;
    } catch (e) {
      print('Error creating folder: $e');
      return null;
    }
  }

  /// Update a folder
  Future<bool> updateFolder(Folder folder) async {
    try {
      final result = await _db.updateFolder(folder);
      if (result > 0) {
        clearCache();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating folder: $e');
      return false;
    }
  }

  /// Delete a folder
  Future<bool> deleteFolder(String id) async {
    try {
      final result = await _db.deleteFolder(id);
      if (result > 0) {
        clearCache();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting folder: $e');
      return false;
    }
  }

  /// Get a folder by ID
  Future<Folder?> getFolderById(String id) async {
    try {
      return await _db.getFolder(id);
    } catch (e) {
      print('Error getting folder: $e');
      return null;
    }
  }

  /// Toggle folder expanded state
  Future<bool> toggleFolderExpanded(String folderId) async {
    try {
      final folder = await _db.getFolder(folderId);
      if (folder != null) {
        final updated = folder.copyWith(isExpanded: !folder.isExpanded);
        return await updateFolder(updated);
      }
      return false;
    } catch (e) {
      print('Error toggling folder expanded: $e');
      return false;
    }
  }

  /// Get folder path (breadcrumb)
  Future<List<Folder>> getFolderPath(String folderId) async {
    final path = <Folder>[];
    String? currentId = folderId;

    while (currentId != null) {
      final folder = await _db.getFolder(currentId);
      if (folder != null) {
        path.insert(0, folder);
        currentId = folder.parentId;
      } else {
        break;
      }
    }

    return path;
  }

  /// Move folder to a new parent
  Future<bool> moveFolder(String folderId, String? newParentId) async {
    try {
      final folder = await _db.getFolder(folderId);
      if (folder != null) {
        // Prevent moving folder into itself or its children
        if (newParentId != null) {
          final path = await getFolderPath(newParentId);
          if (path.any((f) => f.id == folderId)) {
            print('Cannot move folder into its own child');
            return false;
          }
        }

        final updated = folder.copyWith(parentId: newParentId);
        return await updateFolder(updated);
      }
      return false;
    } catch (e) {
      print('Error moving folder: $e');
      return false;
    }
  }

  /// Get folder tree structure
  Future<List<FolderTreeNode>> getFolderTree() async {
    final allFolders = await loadAllFolders();
    final allTopics = await _db.getAllTopics();

    // Build tree recursively
    return _buildTree(null, allFolders, allTopics);
  }

  List<FolderTreeNode> _buildTree(
    String? parentId,
    List<Folder> allFolders,
    List<Topic> allTopics,
  ) {
    final nodes = <FolderTreeNode>[];

    // Get folders at this level
    final folders = allFolders.where((f) => f.parentId == parentId).toList();
    folders.sort((a, b) {
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) return sortCompare;
      return a.name.compareTo(b.name);
    });

    for (final folder in folders) {
      final children = _buildTree(folder.id, allFolders, allTopics);
      final topics = allTopics.where((t) => t.folderId == folder.id).toList();
      topics.sort((a, b) => a.title.compareTo(b.title));

      nodes.add(FolderTreeNode(
        folder: folder,
        children: children,
        topics: topics,
      ));
    }

    return nodes;
  }

  /// Clear the cache
  void clearCache() {
    _cachedFolders = null;
  }
}

/// Represents a node in the folder tree
class FolderTreeNode {
  final Folder folder;
  final List<FolderTreeNode> children;
  final List<Topic> topics;

  const FolderTreeNode({
    required this.folder,
    required this.children,
    required this.topics,
  });

  /// Total number of topics in this folder and all subfolders
  int get totalTopicCount {
    int count = topics.length;
    for (final child in children) {
      count += child.totalTopicCount;
    }
    return count;
  }

  /// Check if folder has any content
  bool get isEmpty => children.isEmpty && topics.isEmpty;
}
