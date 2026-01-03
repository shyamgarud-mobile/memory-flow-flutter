import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/folder.dart';
import '../models/topic.dart';
import '../services/folder_service.dart';
import '../services/topics_index_service.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/figma_app_bar.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/common/figma_text_field.dart';
import '../widgets/common/figma_dialog.dart';
import 'topic_detail_screen.dart';

/// Topics List screen - Display topics in tree structure with folders
class TopicsListScreen extends StatefulWidget {
  const TopicsListScreen({super.key});

  @override
  State<TopicsListScreen> createState() => _TopicsListScreenState();
}

class _TopicsListScreenState extends State<TopicsListScreen> {
  final FolderService _folderService = FolderService();
  final TopicsIndexService _topicsService = TopicsIndexService();

  List<FolderTreeNode> _folderTree = [];
  List<Topic> _rootTopics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tree = await _folderService.getFolderTree();
      final rootTopics = await _folderService.getTopicsInFolder(null);

      setState(() {
        _folderTree = tree;
        _rootTopics = rootTopics;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FigmaAppBar(
        title: 'All Topics',
        showBackButton: false,
        actions: [
          FigmaAppBarAction.icon(
            icon: Icons.create_new_folder_rounded,
            onPressed: () => _showCreateFolderDialog(context),
            tooltip: 'New Folder',
          ),
          FigmaAppBarAction.icon(
            icon: Icons.search_rounded,
            onPressed: () {
              // TODO: Implement search
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folderTree.isEmpty && _rootTopics.isEmpty
              ? _buildEmptyState(context)
              : _buildTreeView(context),
    );
  }

  /// Build the tree view with folders and topics
  Widget _buildTreeView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Root folders
          ..._folderTree.map((node) => _buildFolderNode(context, node, 0)),

          // Root-level topics (not in any folder)
          ..._rootTopics.map((topic) => _buildTopicItem(context, topic, 0)),
        ],
      ),
    );
  }

  /// Build a folder node with its children
  Widget _buildFolderNode(BuildContext context, FolderTreeNode node, int depth) {
    final folder = node.folder;
    final isExpanded = folder.isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Folder header
        InkWell(
          onTap: () => _toggleFolder(folder.id),
          onLongPress: () => _showFolderOptions(context, folder),
          borderRadius: ThemeHelper.standardRadius,
          child: Container(
            padding: EdgeInsets.only(
              left: AppSpacing.md + (depth * 20.0),
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Expand/Collapse icon
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 24,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 4),
                // Folder icon
                Icon(
                  isExpanded
                      ? Icons.folder_open_rounded
                      : Icons.folder_rounded,
                  color: folder.color != null
                      ? _parseColor(folder.color!)
                      : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                // Folder name
                Expanded(
                  child: Text(
                    folder.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                // Topic count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray700
                        : AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    '${node.totalTopicCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Children (if expanded)
        if (isExpanded) ...[
          // Sub-folders
          ...node.children.map((child) => _buildFolderNode(context, child, depth + 1)),
          // Topics in this folder
          ...node.topics.map((topic) => _buildTopicItem(context, topic, depth + 1)),
        ],
      ],
    );
  }

  /// Build a topic item
  Widget _buildTopicItem(BuildContext context, Topic topic, int depth) {
    final isOverdue = topic.isOverdue;

    return InkWell(
      onTap: () => _openTopic(context, topic),
      onLongPress: () => _showTopicOptions(context, topic),
      borderRadius: ThemeHelper.standardRadius,
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.md + (depth * 20.0) + 28, // Align with folder names
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Topic icon
            Icon(
              Icons.description_rounded,
              size: 20,
              color: isOverdue
                  ? AppColors.danger
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Topic title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Stage ${topic.currentStage + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Overdue',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  /// Parse hex color string to Color
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  /// Toggle folder expanded state
  Future<void> _toggleFolder(String folderId) async {
    await _folderService.toggleFolderExpanded(folderId);
    await _loadData();
  }

  /// Open topic detail screen
  Future<void> _openTopic(BuildContext context, Topic topic) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Show topic options (long press menu)
  void _showTopicOptions(BuildContext context, Topic topic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_move_rounded),
              title: const Text('Move to Folder'),
              onTap: () {
                Navigator.pop(context);
                _showMoveToFolderDialog(context, topic);
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Open Topic'),
              onTap: () {
                Navigator.pop(context);
                _openTopic(context, topic);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show move to folder dialog
  Future<void> _showMoveToFolderDialog(BuildContext context, Topic topic) async {
    final allFolders = await _folderService.loadAllFolders();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray700
                        : AppColors.gray300,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.drive_file_move_rounded),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Move to Folder',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          topic.title,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Folder list
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // No folder option (root)
                  ListTile(
                    leading: Icon(
                      Icons.folder_off_rounded,
                      color: topic.folderId == null
                          ? AppColors.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    title: const Text('No folder (root level)'),
                    trailing: topic.folderId == null
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      await _moveTopicToFolder(topic, null);
                    },
                  ),
                  const Divider(),

                  // Folders
                  ..._buildMoveFolderList(allFolders, null, 0, topic),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMoveFolderList(List<Folder> folders, String? parentId, int depth, Topic topic) {
    final widgets = <Widget>[];
    final childFolders = folders.where((f) => f.parentId == parentId).toList();

    for (final folder in childFolders) {
      widgets.add(
        ListTile(
          contentPadding: EdgeInsets.only(
            left: AppSpacing.md + (depth * 24.0),
            right: AppSpacing.md,
          ),
          leading: Icon(
            Icons.folder_rounded,
            color: topic.folderId == folder.id
                ? AppColors.primary
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
          title: Text(folder.name),
          trailing: topic.folderId == folder.id
              ? const Icon(Icons.check, color: AppColors.primary)
              : null,
          onTap: () async {
            Navigator.pop(context);
            await _moveTopicToFolder(topic, folder.id);
          },
        ),
      );

      // Add children recursively
      widgets.addAll(_buildMoveFolderList(folders, folder.id, depth + 1, topic));
    }

    return widgets;
  }

  /// Move topic to a folder
  Future<void> _moveTopicToFolder(Topic topic, String? folderId) async {
    try {
      final updatedTopic = topic.copyWith(folderId: folderId);
      await _topicsService.updateTopic(updatedTopic);
      await _loadData();

      if (mounted) {
        final folderName = folderId != null
            ? (await _folderService.getFolderById(folderId))?.name ?? 'folder'
            : 'root level';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${topic.title}" to $folderName'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move topic: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Show create folder dialog
  Future<void> _showCreateFolderDialog(BuildContext context, {String? parentId}) async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => FigmaDialog(
        title: 'New Folder',
        content: FigmaTextField(
          controller: nameController,
          label: 'Folder name',
          hintText: 'Enter folder name',
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          FigmaButton(
            text: 'Create',
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final folder = await _folderService.createFolder(
        name: result,
        parentId: parentId,
      );

      if (folder != null) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Folder "$result" created'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  /// Show folder options (long press menu)
  void _showFolderOptions(BuildContext context, Folder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.create_new_folder_rounded),
              title: const Text('New Subfolder'),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog(context, parentId: folder.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameFolderDialog(context, folder);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.danger),
              title: const Text('Delete', style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteFolderDialog(context, folder);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show rename folder dialog
  Future<void> _showRenameFolderDialog(BuildContext context, Folder folder) async {
    final nameController = TextEditingController(text: folder.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => FigmaDialog(
        title: 'Rename Folder',
        content: FigmaTextField(
          controller: nameController,
          label: 'Folder name',
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          FigmaButton(
            text: 'Rename',
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != folder.name) {
      final updated = folder.copyWith(name: result);
      await _folderService.updateFolder(updated);
      await _loadData();
    }
  }

  /// Show delete folder confirmation dialog
  Future<void> _showDeleteFolderDialog(BuildContext context, Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"?\n\n'
          'Topics inside will be moved to the root level.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _folderService.deleteFolder(folder.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder "${folder.name}" deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// Build empty state when no topics exist
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 120,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Topics Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first topic to start learning',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FigmaButton(
              text: 'Create Folder',
              icon: Icons.create_new_folder_rounded,
              onPressed: () => _showCreateFolderDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
