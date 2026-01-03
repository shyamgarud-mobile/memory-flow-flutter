import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/file_service.dart';
import '../services/topics_index_service.dart';
import '../services/spaced_repetition_service.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/dialogs/reschedule_dialog.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/analytics/circular_progress_ring.dart';
import 'fullscreen_reader_screen.dart';
import 'edit_topic_screen.dart';

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
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();

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
        // Fullscreen reader button
        if (!_isLoading && _error == null)
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Open in fullscreen',
            onPressed: _openFullscreenReader,
          ),
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
          // Circular Progress Ring
          Center(
            child: CircularProgressRing(
              currentStage: _currentTopic.currentStage,
              totalStages: 5,
              size: 120,
              onTap: () => _showStageDetails(context),
            ),
          ),
          ThemeHelper.vSpaceMedium,
          ThemeHelper.divider,
          ThemeHelper.vSpaceMedium,

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

          // Review count
          _buildMetadataRow(
            context,
            icon: Icons.repeat,
            label: 'Reviews',
            value: 'Reviewed ${_currentTopic.reviewCount} times',
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

  Widget _buildStageRow(BuildContext context) {
    final stageDescription = _spacedRepService.getStageDescription(_currentTopic.currentStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.layers,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            ThemeHelper.hSpaceSmall,
            Expanded(
              child: Text(
                'Current Stage',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ),
          ],
        ),
        ThemeHelper.vSpaceSmall,
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stage ${_currentTopic.currentStage + 1} of ${SpacedRepetitionService.totalStages}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '$stageDescription interval',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
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

  /// Open fullscreen reader
  void _openFullscreenReader() {
    if (_content == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenReaderScreen(
          title: _currentTopic.title,
          content: _content!,
        ),
      ),
    );
  }

  Future<void> _handleMarkAsReviewed(BuildContext context) async {
    try {
      // Use SpacedRepetitionService to mark as reviewed
      final updatedTopic = await _spacedRepService.markAsReviewed(_currentTopic.id);

      // Update local state
      setState(() {
        _currentTopic = updatedTopic;
      });

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ReviewSuccessDialog(
          topic: updatedTopic,
          spacedRepService: _spacedRepService,
        ),
      );

      if (!mounted) return;

      // Auto-dismiss after 2 seconds and navigate back
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.pop(context, true); // Return to previous screen with update flag
      }
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

  Future<void> _handleReschedule(BuildContext context) async {
    await RescheduleDialog.show(
      context: context,
      topic: _currentTopic,
      onRescheduled: (updatedTopic) {
        setState(() {
          _currentTopic = updatedTopic;
        });
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _handleEditTopic(context);
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

  /// Handle edit topic
  Future<void> _handleEditTopic(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTopicScreen(topic: _currentTopic),
      ),
    );

    // Reload content if topic was updated
    if (result != null && result is Topic && mounted) {
      setState(() {
        _currentTopic = result;
      });
      _loadContent();
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
          'You will start from Stage 1 again with a 1-day interval.',
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          FigmaTextButton(
            text: 'Reset',
            onPressed: () => Navigator.pop(context, true),
            color: AppColors.danger,
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Use SpacedRepetitionService to reset topic
      final resetTopic = await _spacedRepService.resetTopic(_currentTopic.id);

      // Update local state
      setState(() {
        _currentTopic = resetTopic;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress has been reset to Stage 1'),
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

  /// Show stage details dialog
  void _showStageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stage Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Stage: ${_currentTopic.currentStage}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Progress: ${(_currentTopic.currentStage / 5 * 100).toInt()}%'),
            const SizedBox(height: 16),
            const Text(
              'Stage Intervals:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStageInfo('Stage 0', 'New', _currentTopic.currentStage >= 0),
            _buildStageInfo('Stage 1', '1 day', _currentTopic.currentStage >= 1),
            _buildStageInfo('Stage 2', '3 days', _currentTopic.currentStage >= 2),
            _buildStageInfo('Stage 3', '1 week', _currentTopic.currentStage >= 3),
            _buildStageInfo('Stage 4', '2 weeks', _currentTopic.currentStage >= 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStageInfo(String stage, String interval, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: completed ? AppColors.success : AppColors.gray400,
          ),
          const SizedBox(width: 8),
          Text('$stage: $interval'),
        ],
      ),
    );
  }
}

/// Success dialog shown after marking topic as reviewed
class _ReviewSuccessDialog extends StatefulWidget {
  final Topic topic;
  final SpacedRepetitionService spacedRepService;

  const _ReviewSuccessDialog({
    required this.topic,
    required this.spacedRepService,
  });

  @override
  State<_ReviewSuccessDialog> createState() => _ReviewSuccessDialogState();
}

class _ReviewSuccessDialogState extends State<_ReviewSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stageDescription = widget.spacedRepService.getStageDescription(widget.topic.currentStage);
    final nextReviewFormatted = DateFormat('MMM d').format(widget.topic.nextReviewDate);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              ThemeHelper.vSpaceMedium,

              // Title
              Text(
                'Great Job!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
              ),
              ThemeHelper.vSpaceSmall,

              // Success message
              Text(
                'Topic reviewed successfully',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              ThemeHelper.vSpaceLarge,

              // Stage info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    // Stage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stage',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${widget.topic.currentStage + 1} of ${SpacedRepetitionService.totalStages}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    ThemeHelper.vSpaceSmall,

                    // Next review
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Next Review',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '$nextReviewFormatted ($stageDescription)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
