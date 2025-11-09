import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/file_service.dart';
import '../services/topics_index_service.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/custom_button.dart';

/// Topic Detail screen - View topic content and metadata
class TopicDetailScreen extends StatefulWidget {
  /// Topic to display
  final Topic topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  final FileService _fileService = FileService();
  final TopicsIndexService _topicsService = TopicsIndexService();

  late Topic _currentTopic;
  String? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
    _loadContent();
  }

  /// Load markdown content from file
  Future<void> _loadContent() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Try to load from file
      try {
        final content = await _fileService.readMarkdownFile(_currentTopic.id);
        setState(() {
          _content = content;
          _isLoading = false;
        });
      } catch (e) {
        // If file doesn't exist, use sample content for demo
        print('Could not load file, using sample content: $e');
        setState(() {
          _content = Topic.sampleContent;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(context)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            _buildTitle(context),
                            ThemeHelper.vSpaceMedium,

                            // Metadata section
                            _buildMetadataSection(context),
                            ThemeHelper.vSpaceLarge,

                            // Tags
                            if (_currentTopic.tags.isNotEmpty) ...[
                              _buildTags(context),
                              ThemeHelper.vSpaceLarge,
                            ],

                            // Divider
                            ThemeHelper.divider,
                            ThemeHelper.vSpaceLarge,

                            // Markdown content
                            _buildMarkdownContent(context),
                          ],
                        ),
                      ),
          ),

          // Bottom action buttons
          if (!_isLoading && _error == null) _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.danger,
            ),
            ThemeHelper.vSpaceMedium,
            Text(
              'Failed to load content',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ThemeHelper.vSpaceSmall,
            Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            ThemeHelper.vSpaceLarge,
            CustomButton.primary(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: _loadContent,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Topic Details'),
      elevation: 0,
      actions: [
        // Favorite button
        IconButton(
          icon: Icon(
            _currentTopic.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _currentTopic.isFavorite ? AppColors.danger : null,
          ),
          tooltip: _currentTopic.isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: _toggleFavorite,
        ),
        // Menu button
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'More options',
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Reset Progress'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.danger, size: 20),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: AppColors.danger)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _currentTopic.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.gray50,
        borderRadius: ThemeHelper.standardRadius,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.gray700
              : AppColors.gray300,
        ),
      ),
      child: Column(
        children: [
          // Next review date
          _buildMetadataRow(
            context,
            icon: Icons.event,
            label: 'Next Review',
            value: _formatNextReviewDate(),
            valueColor: _getReviewDateColor(),
          ),
          ThemeHelper.vSpaceSmall,
          ThemeHelper.divider,
          ThemeHelper.vSpaceSmall,

          // Current stage
          _buildMetadataRow(
            context,
            icon: Icons.layers,
            label: 'Current Stage',
            value: 'Stage ${_currentTopic.currentStage + 1} of ${_currentTopic.totalStages} - ${_currentTopic.stageDescription}',
          ),
          ThemeHelper.vSpaceSmall,

          // Progress bar
          _buildProgressBar(context),
          ThemeHelper.vSpaceSmall,
          ThemeHelper.divider,
          ThemeHelper.vSpaceSmall,

          // Review count
          _buildMetadataRow(
            context,
            icon: Icons.repeat,
            label: 'Reviews',
            value: '${_currentTopic.reviewCount} times',
          ),
          ThemeHelper.vSpaceSmall,
          ThemeHelper.divider,
          ThemeHelper.vSpaceSmall,

          // Last reviewed
          _buildMetadataRow(
            context,
            icon: Icons.history,
            label: 'Last Reviewed',
            value: _currentTopic.lastReviewedAt != null
                ? _formatDate(_currentTopic.lastReviewedAt!)
                : 'Never',
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        ThemeHelper.hSpaceSmall,
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.round),
                child: LinearProgressIndicator(
                  value: _currentTopic.progress,
                  minHeight: 8,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.gray700
                      : AppColors.gray300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeHelper.getProgressColor(_currentTopic.progress),
                  ),
                ),
              ),
            ),
            ThemeHelper.hSpaceSmall,
            Text(
              '${(_currentTopic.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _currentTopic.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.round),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.label,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                tag,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MarkdownBody(
      data: _content ?? '',
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        h2: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        h3: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        p: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: isDark ? AppColors.gray800 : AppColors.gray100,
          color: AppColors.danger,
        ),
        codeblockDecoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: ThemeHelper.standardRadius,
          border: Border.all(
            color: isDark ? AppColors.gray700 : AppColors.gray300,
          ),
        ),
        codeblockPadding: const EdgeInsets.all(AppSpacing.md),
        blockquote: theme.textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.textTheme.bodySmall?.color,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: AppColors.primary,
              width: 4,
            ),
          ),
          color: AppColors.primary.withOpacity(0.05),
        ),
        blockquotePadding: const EdgeInsets.all(AppSpacing.md),
        listBullet: theme.textTheme.bodyLarge,
        listIndent: 24,
        h1Padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
        h2Padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
        h3Padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
        pPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white,
        boxShadow: ThemeHelper.standardShadow,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray700
                : AppColors.gray300,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mark as Reviewed button
            CustomButton.primary(
              text: 'Mark as Reviewed',
              icon: Icons.check_circle,
              onPressed: () => _handleMarkAsReviewed(context),
              fullWidth: true,
            ),
            ThemeHelper.vSpaceSmall,

            // Reschedule button
            CustomButton.secondary(
              text: 'Reschedule Review',
              icon: Icons.schedule,
              onPressed: () => _handleReschedule(context),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods

  String _formatNextReviewDate() {
    final now = DateTime.now();
    final difference = _currentTopic.nextReviewDate.difference(now);

    if (_currentTopic.isOverdue) {
      final daysPast = -difference.inDays;
      if (daysPast == 0) {
        return 'Today (Overdue)';
      } else if (daysPast == 1) {
        return '1 day ago';
      } else {
        return '$daysPast days ago';
      }
    } else if (_currentTopic.isDueToday) {
      return 'Today at ${DateFormat('h:mm a').format(_currentTopic.nextReviewDate)}';
    } else {
      final daysUntil = difference.inDays;
      if (daysUntil == 0) {
        return 'Today at ${DateFormat('h:mm a').format(_currentTopic.nextReviewDate)}';
      } else if (daysUntil == 1) {
        return 'Tomorrow at ${DateFormat('h:mm a').format(_currentTopic.nextReviewDate)}';
      } else if (daysUntil < 7) {
        return '${DateFormat('EEEE').format(_currentTopic.nextReviewDate)} at ${DateFormat('h:mm a').format(_currentTopic.nextReviewDate)}';
      } else {
        return DateFormat('MMM d, y - h:mm a').format(_currentTopic.nextReviewDate);
      }
    }
  }

  Color? _getReviewDateColor() {
    if (_currentTopic.isOverdue) {
      return AppColors.danger;
    } else if (_currentTopic.isDueToday) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  // Action handlers

  Future<void> _handleMarkAsReviewed(BuildContext context) async {
    try {
      // Mark topic as reviewed and advance stage
      final updatedTopic = _currentTopic.markAsReviewed();

      // Save to database
      await _topicsService.updateTopic(updatedTopic);

      // Update local state
      setState(() {
        _currentTopic = updatedTopic;
      });

      if (!mounted) return;

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Review Completed!'),
          content: Text(
            'Great job! Topic "${updatedTopic.title}" has been marked as reviewed.\n\n'
            'Stage: ${updatedTopic.currentStage + 1}/${updatedTopic.totalStages}\n'
            'Next review: ${updatedTopic.stageDescription}',
          ),
          actions: [
            CustomButton.primary(
              text: 'Done',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return to previous screen with update flag
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update topic: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleReschedule(BuildContext context) {
    print('Reschedule topic: ${_currentTopic.id}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose when to review this topic:'),
            ThemeHelper.vSpaceMedium,
            _buildRescheduleOption(context, 'Later today', () {
              print('Rescheduled to: later today');
              Navigator.pop(context);
            }),
            _buildRescheduleOption(context, 'Tomorrow', () {
              print('Rescheduled to: tomorrow');
              Navigator.pop(context);
            }),
            _buildRescheduleOption(context, 'In 3 days', () {
              print('Rescheduled to: 3 days');
              Navigator.pop(context);
            }),
            _buildRescheduleOption(context, 'Next week', () {
              print('Rescheduled to: next week');
              Navigator.pop(context);
            }),
          ],
        ),
        actions: [
          CustomButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRescheduleOption(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: ThemeHelper.standardRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        print('Edit topic: ${_currentTopic.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Edit functionality coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case 'reset':
        _handleResetProgress(context);
        break;

      case 'share':
        print('Share topic: ${_currentTopic.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share functionality coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case 'delete':
        _handleDeleteTopic(context);
        break;
    }
  }

  /// Handle delete topic
  Future<void> _handleDeleteTopic(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Topic?'),
        content: Text(
          'Are you sure you want to delete "${_currentTopic.title}"? '
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

    if (confirmed != true || !mounted) return;

    try {
      // Delete from database
      await _topicsService.deleteTopic(_currentTopic.id);

      // Delete markdown file
      try {
        await _fileService.deleteMarkdownFile(_currentTopic.id);
      } catch (e) {
        print('Failed to delete markdown file: $e');
        // Continue even if file deletion fails
      }

      if (!mounted) return;

      // Show success message and navigate back
      Navigator.pop(context, true); // Return with update flag
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Topic "${_currentTopic.title}" deleted'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete topic: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite() async {
    try {
      final updatedTopic = _currentTopic.copyWith(
        isFavorite: !_currentTopic.isFavorite,
      );

      // Save to database
      await _topicsService.updateTopic(updatedTopic);

      // Update local state
      setState(() {
        _currentTopic = updatedTopic;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedTopic.isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite status: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle reset progress
  Future<void> _handleResetProgress(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset all review progress for this topic. '
          'You will start from Stage 1 again.',
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
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final resetTopic = _currentTopic.resetProgress();

      // Save to database
      await _topicsService.updateTopic(resetTopic);

      // Update local state
      setState(() {
        _currentTopic = resetTopic;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress has been reset'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset progress: $e'),
          backgroundColor: AppColors.danger,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
