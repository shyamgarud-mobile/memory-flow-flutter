import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/topics_index_service.dart';
import '../services/file_service.dart';
import '../providers/navigation_provider.dart';
import '../widgets/common/figma_app_bar.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/common/figma_card.dart';
import '../widgets/common/figma_dialog.dart';
import 'topic_detail_screen.dart';
import 'statistics_screen.dart';

/// Home/Dashboard screen - Main overview of the app
///
/// Performance optimizations:
/// - Uses ListView.builder for efficient rendering
/// - Implements pagination (20 items per load)
/// - Caches topic data to reduce DB calls
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TopicsIndexService _topicsService = TopicsIndexService();
  final FileService _fileService = FileService();

  // Pagination settings
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();

  List<Topic> _allTopics = [];
  List<Topic> _dueToday = [];
  List<Topic> _upcomingWeek = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int? _lastNavIndex;
  int _currentPage = 0;

  // Stats for progress card
  int _currentStreak = 0;
  int _reviewedToday = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTopics();
    }
  }

  /// Load more topics when scrolling
  Future<void> _loadMoreTopics() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newTopics = await _topicsService.loadTopicsIndexPaginated(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (newTopics.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
        return;
      }

      _currentPage++;
      _categorizeTopics([..._allTopics, ...newTopics]);

      setState(() {
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
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
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      // Load first page only for faster initial render
      final topics = await _topicsService.loadTopicsIndexPaginated(
        limit: _pageSize,
        offset: 0,
      );

      _currentPage = 1;
      _hasMore = topics.length >= _pageSize;
      _categorizeTopics(topics);

      // Load streak data
      await _loadStreakData(topics);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load topics: $e';
        _isLoading = false;
      });
    }
  }

  /// Categorize topics into due today, upcoming, etc.
  void _categorizeTopics(List<Topic> topics) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final weekEnd = now.add(const Duration(days: 7));

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
  }

  /// Load streak and review stats
  Future<void> _loadStreakData(List<Topic> topics) async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('current_streak') ?? 0;

    // Count topics reviewed today
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    _reviewedToday = topics.where((topic) {
      if (topic.lastReviewedAt == null) return false;
      return topic.lastReviewedAt!.isAfter(todayStart);
    }).length;
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
      appBar: const FigmaAppBar(
        title: 'MemoryFlow',
        showBackButton: false, // Home screen doesn't need back button
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
              FigmaButton(
                text: 'Retry',
                icon: Icons.refresh,
                onPressed: _loadTopics,
              ),
            ],
          ),
        ),
      );
    }

    if (_allTopics.isEmpty) {
      return _buildEmptyState();
    }

    // Build list items for ListView.builder
    final List<_ListItem> items = [];

    // Progress Card at the top
    items.add(_ListItem(type: _ItemType.progressCard));
    items.add(_ListItem(type: _ItemType.spacer));

    // All caught up state
    if (_dueToday.isEmpty && _allTopics.isNotEmpty) {
      items.add(_ListItem(type: _ItemType.allCaughtUp));
      items.add(_ListItem(type: _ItemType.spacer));
    }

    // Due Today Section
    if (_dueToday.isNotEmpty) {
      items.add(_ListItem(type: _ItemType.header, data: {
        'title': 'Due Today',
        'count': _dueToday.length,
        'icon': Icons.today,
        'color': AppColors.error,
      }));
      for (final topic in _dueToday) {
        items.add(_ListItem(type: _ItemType.topic, topic: topic));
      }
      items.add(_ListItem(type: _ItemType.spacer));
    }

    // Upcoming This Week Section
    if (_upcomingWeek.isNotEmpty) {
      items.add(_ListItem(type: _ItemType.header, data: {
        'title': 'Upcoming This Week',
        'count': _upcomingWeek.length,
        'icon': Icons.calendar_today,
        'color': AppColors.primary,
      }));
      for (final topic in _upcomingWeek) {
        items.add(_ListItem(type: _ItemType.topic, topic: topic));
      }
      items.add(_ListItem(type: _ItemType.spacer));
    }

    // All other topics
    final otherTopics = _allTopics
        .where((topic) =>
            !_dueToday.contains(topic) && !_upcomingWeek.contains(topic))
        .toList();

    if (otherTopics.isNotEmpty) {
      items.add(_ListItem(type: _ItemType.header, data: {
        'title': 'All Topics',
        'count': _allTopics.length,
        'icon': Icons.topic,
        'color': AppColors.textSecondary,
      }));
      for (final topic in otherTopics) {
        items.add(_ListItem(type: _ItemType.topic, topic: topic));
      }
    }

    // Add loading indicator if loading more
    if (_isLoadingMore) {
      items.add(_ListItem(type: _ItemType.loading));
    }

    return RefreshIndicator(
      onRefresh: _refreshTopics,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          switch (item.type) {
            case _ItemType.progressCard:
              return _buildProgressCard();
            case _ItemType.allCaughtUp:
              return _buildAllCaughtUpCard();
            case _ItemType.header:
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildSectionHeader(
                  context,
                  item.data!['title'] as String,
                  item.data!['count'] as int,
                  item.data!['icon'] as IconData,
                  item.data!['color'] as Color,
                ),
              );
            case _ItemType.topic:
              return _buildTopicCard(context, item.topic!);
            case _ItemType.spacer:
              return const SizedBox(height: AppSpacing.lg);
            case _ItemType.loading:
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(),
                ),
              );
          }
        },
      ),
    );
  }

  /// Build progress card with streak and stats
  Widget _buildProgressCard() {
    return FigmaCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StatisticsScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                icon: Icons.local_fire_department_rounded,
                value: '$_currentStreak',
                label: 'Day Streak',
                color: AppColors.warning,
              ),
              _buildStatColumn(
                icon: Icons.library_books_rounded,
                value: '${_allTopics.length}',
                label: 'Topics',
                color: Theme.of(context).colorScheme.primary,
              ),
              _buildStatColumn(
                icon: Icons.check_circle_rounded,
                value: '$_reviewedToday',
                label: 'Reviewed Today',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stat column for progress card
  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Build "All caught up" card
  Widget _buildAllCaughtUpCard() {
    return FigmaCard(
      color: AppColors.success.withOpacity(0.1),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'All caught up!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No reviews due today. Great job keeping up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          if (_upcomingWeek.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Next review: ${_formatReviewDate(_upcomingWeek.first.nextReviewDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
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
            FigmaButton(
              text: 'Create Topic',
              icon: Icons.add,
              onPressed: () {
                // TODO: Navigate to create topic screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create topic feature coming soon!'),
                  ),
                );
              },
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

  /// Build topic card with swipe actions
  Widget _buildTopicCard(BuildContext context, Topic topic) {
    return Dismissible(
      key: Key(topic.id),
      direction: DismissDirection.horizontal,
      // Swipe right - Reschedule
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Reschedule',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Swipe left - Delete
      secondaryBackground: Container(
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
        if (direction == DismissDirection.endToStart) {
          // Delete
          return await _showDeleteConfirmation(context, topic);
        } else {
          // Reschedule
          await _showRescheduleDialog(context, topic);
          return false; // Don't dismiss, we handled it
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteTopic(topic);
        }
      },
      child: FigmaCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopicDetailScreen(topic: topic),
            ),
          ).then((_) => _refreshTopics());
        },
        child: GestureDetector(
          onLongPress: () {
            _showQuickActionsMenu(context, topic);
          },
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
      builder: (context) => FigmaDialog(
        title: 'Delete Topic?',
        content: Text(
          'Are you sure you want to delete "${topic.title}"? '
          'This will delete both the topic data and its markdown file. '
          'This action cannot be undone.',
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          FigmaTextButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }

  /// Show reschedule dialog
  Future<void> _showRescheduleDialog(BuildContext context, Topic topic) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9, 0);
    final in3Days = DateTime(now.year, now.month, now.day + 3, 9, 0);

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Reschedule Review',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text('Tomorrow morning'),
                subtitle: Text(DateFormat('MMM d, h:mm a').format(tomorrow)),
                onTap: () {
                  Navigator.pop(context);
                  _rescheduleTopic(topic, tomorrow);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('In 3 days'),
                subtitle: Text(DateFormat('MMM d, h:mm a').format(in3Days)),
                onTap: () {
                  Navigator.pop(context);
                  _rescheduleTopic(topic, in3Days);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar),
                title: const Text('Custom date & time'),
                onTap: () async {
                  Navigator.pop(context);
                  final date = await showDatePicker(
                    context: context,
                    initialDate: topic.nextReviewDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(topic.nextReviewDate),
                    );
                    if (time != null) {
                      final newDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      _rescheduleTopic(topic, newDate);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reschedule topic to new date
  Future<void> _rescheduleTopic(Topic topic, DateTime newDate) async {
    try {
      final updatedTopic = topic.copyWith(nextReviewDate: newDate);
      await _topicsService.updateTopic(updatedTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rescheduled to ${DateFormat('MMM d, h:mm a').format(newDate)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _refreshTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reschedule: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Show quick actions menu on long press
  void _showQuickActionsMenu(BuildContext context, Topic topic) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                topic.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
              title: const Text('Mark as Reviewed'),
              onTap: () {
                Navigator.pop(context);
                _markAsReviewed(topic);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.schedule,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                _showRescheduleDialog(context, topic);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.star_border,
                color: AppColors.warning,
              ),
              title: Text(topic.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(topic);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.refresh,
                color: AppColors.secondary,
              ),
              title: const Text('Reset Progress'),
              onTap: () {
                Navigator.pop(context);
                _resetProgress(topic);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation(context, topic);
                if (confirmed == true) {
                  _deleteTopic(topic);
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  /// Mark topic as reviewed
  Future<void> _markAsReviewed(Topic topic) async {
    try {
      final now = DateTime.now();
      final nextStage = (topic.currentStage + 1).clamp(0, 4);
      final intervals = [1, 3, 7, 14, 30];
      final nextReviewDate = now.add(Duration(days: intervals[nextStage]));

      final updatedTopic = topic.copyWith(
        lastReviewedAt: now,
        nextReviewDate: nextReviewDate,
        currentStage: nextStage,
        reviewCount: topic.reviewCount + 1,
      );

      await _topicsService.updateTopic(updatedTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Marked as reviewed! Next review in ${intervals[nextStage]} days.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _refreshTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite(Topic topic) async {
    try {
      final updatedTopic = topic.copyWith(isFavorite: !topic.isFavorite);
      await _topicsService.updateTopic(updatedTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedTopic.isFavorite ? 'Added to favorites' : 'Removed from favorites',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _refreshTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Reset topic progress
  Future<void> _resetProgress(Topic topic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset the topic back to Stage 1. '
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final updatedTopic = topic.copyWith(
        currentStage: 0,
        nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      );
      await _topicsService.updateTopic(updatedTopic);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress reset to Stage 1'),
            backgroundColor: AppColors.success,
          ),
        );
        _refreshTopics();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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

// Helper enum for list item types
enum _ItemType { progressCard, allCaughtUp, header, topic, spacer, loading }

// Helper class for ListView.builder items
class _ListItem {
  final _ItemType type;
  final Topic? topic;
  final Map<String, dynamic>? data;

  _ListItem({required this.type, this.topic, this.data});
}
