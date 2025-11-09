import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/topics_index_service.dart';
import '../services/file_service.dart';
import '../providers/navigation_provider.dart';
import 'topic_detail_screen.dart';

/// Home/Dashboard screen - Main overview of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TopicsIndexService _topicsService = TopicsIndexService();
  final FileService _fileService = FileService();

  List<Topic> _allTopics = [];
  List<Topic> _dueToday = [];
  List<Topic> _upcomingWeek = [];
  bool _isLoading = true;
  String? _error;
  int? _lastNavIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen to navigation changes
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    // If we just navigated to home (index 0) from another tab, refresh
    if (_lastNavIndex != null && _lastNavIndex != 0 && currentIndex == 0) {
      _refreshTopics();
    }

    _lastNavIndex = currentIndex;
  }

  /// Load topics from service and categorize them
  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final topics = await _topicsService.loadTopicsIndex();
      final now = DateTime.now();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final weekEnd = now.add(const Duration(days: 7));

      setState(() {
        _allTopics = topics;

        // Due Today: includes overdue and due today
        _dueToday = topics.where((topic) {
          return topic.nextReviewDate.isBefore(todayEnd) ||
              topic.nextReviewDate.isAtSameMomentAs(todayEnd);
        }).toList()
          ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

        // Upcoming This Week: due within next 7 days (excluding today)
        _upcomingWeek = topics.where((topic) {
          return topic.nextReviewDate.isAfter(todayEnd) &&
              topic.nextReviewDate.isBefore(weekEnd);
        }).toList()
          ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load topics: $e';
        _isLoading = false;
      });
    }
  }

  /// Refresh topics on pull-to-refresh
  Future<void> _refreshTopics() async {
    _topicsService.clearCache();
    await _loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoryFlow'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _loadTopics,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_allTopics.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshTopics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Due Today Section
            if (_dueToday.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Due Today',
                _dueToday.length,
                Icons.today,
                AppColors.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._dueToday.map((topic) => _buildTopicCard(context, topic)),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Upcoming This Week Section
            if (_upcomingWeek.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Upcoming This Week',
                _upcomingWeek.length,
                Icons.calendar_today,
                AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._upcomingWeek.map((topic) => _buildTopicCard(context, topic)),
              const SizedBox(height: AppSpacing.lg),
            ],

            // All other topics
            if (_allTopics.length > _dueToday.length + _upcomingWeek.length) ...[
              _buildSectionHeader(
                context,
                'All Topics',
                _allTopics.length,
                Icons.topic,
                AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._allTopics
                  .where((topic) =>
                      !_dueToday.contains(topic) &&
                      !_upcomingWeek.contains(topic))
                  .map((topic) => _buildTopicCard(context, topic)),
            ],
          ],
        ),
      ),
    );
  }

  /// Build empty state when no topics exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.topic_outlined,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No topics yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first topic to start learning',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to create topic screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create topic feature coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Topic'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section header with count
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    int count,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }

  /// Build topic card with swipe-to-delete
  Widget _buildTopicCard(BuildContext context, Topic topic) {
    return Dismissible(
      key: Key(topic.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context, topic);
      },
      onDismissed: (direction) {
        _deleteTopic(topic);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TopicDetailScreen(topic: topic),
              ),
            ).then((_) => _refreshTopics());
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and favorite icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (topic.isFavorite)
                      Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Status badge and next review date
                Row(
                  children: [
                    _buildStatusBadge(topic),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _formatReviewDate(topic.nextReviewDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),

                // Tags if present
                if (topic.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: topic.tags
                        .take(3)
                        .map((tag) => _buildTagChip(context, tag))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build status badge (overdue/due/upcoming)
  Widget _buildStatusBadge(Topic topic) {
    final now = DateTime.now();
    final isOverdue = topic.nextReviewDate.isBefore(now);
    final isDueToday = topic.isDueToday;

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isOverdue) {
      badgeColor = AppColors.error;
      badgeText = 'Overdue';
      badgeIcon = Icons.warning;
    } else if (isDueToday) {
      badgeColor = AppColors.warning;
      badgeText = 'Due Today';
      badgeIcon = Icons.today;
    } else {
      badgeColor = AppColors.success;
      badgeText = 'Upcoming';
      badgeIcon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build tag chip
  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontSize: 11,
            ),
      ),
    );
  }

  /// Format review date for display
  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return 'Due earlier today';
      } else if (daysPast == 1) {
        return 'Due yesterday';
      } else {
        return 'Due $daysPast days ago';
      }
    }

    final daysUntil = difference.inDays;
    if (daysUntil == 0) {
      final formatter = DateFormat('h:mm a');
      return 'Due today at ${formatter.format(date)}';
    } else if (daysUntil == 1) {
      return 'Due tomorrow';
    } else if (daysUntil < 7) {
      final formatter = DateFormat('EEEE');
      return 'Due ${formatter.format(date)}';
    } else {
      final formatter = DateFormat('MMM d, y');
      return 'Due ${formatter.format(date)}';
    }
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context, Topic topic) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic?'),
        content: Text(
          'Are you sure you want to delete "${topic.title}"? '
          'This will delete both the topic data and its markdown file. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete topic from database and file system
  Future<void> _deleteTopic(Topic topic) async {
    try {
      // Delete from database
      await _topicsService.deleteTopic(topic.id);

      // Delete markdown file
      try {
        await _fileService.deleteMarkdownFile(topic.id);
      } catch (e) {
        print('Failed to delete markdown file: $e');
        // Continue even if file deletion fails
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Topic "${topic.title}" deleted'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Undo not yet implemented'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );

        // Refresh the topics list
        _refreshTopics();
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete topic: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

}
