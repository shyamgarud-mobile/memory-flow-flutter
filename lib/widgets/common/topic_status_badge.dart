import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Topic review status enum
enum TopicStatus {
  overdue,
  dueToday,
  upcoming,
  completed,
  notStarted,
}

/// Badge size variants
enum BadgeSize {
  small,
  medium,
  large,
}

/// Reusable status badge widget for topics
class TopicStatusBadge extends StatelessWidget {
  /// The status to display
  final TopicStatus status;

  /// Badge size
  final BadgeSize size;

  /// Whether to show the icon
  final bool showIcon;

  /// Custom label (overrides default status label)
  final String? customLabel;

  const TopicStatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.medium,
    this.showIcon = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    final sizeConfig = _getSizeConfig(size);

    return Container(
      padding: sizeConfig.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.round),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: sizeConfig.iconSize,
              color: config.color,
            ),
            SizedBox(width: sizeConfig.spacing),
          ],
          Text(
            customLabel ?? config.label,
            style: sizeConfig.textStyle.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(TopicStatus status) {
    switch (status) {
      case TopicStatus.overdue:
        return _StatusConfig(
          label: 'Overdue',
          color: AppColors.danger,
          backgroundColor: AppColors.danger.withOpacity(0.1),
          borderColor: AppColors.danger.withOpacity(0.3),
          icon: Icons.error_outline_rounded,
        );
      case TopicStatus.dueToday:
        return _StatusConfig(
          label: 'Due Today',
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning.withOpacity(0.3),
          icon: Icons.today_rounded,
        );
      case TopicStatus.upcoming:
        return _StatusConfig(
          label: 'Upcoming',
          color: AppColors.success,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success.withOpacity(0.3),
          icon: Icons.schedule_rounded,
        );
      case TopicStatus.completed:
        return _StatusConfig(
          label: 'Completed',
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary.withOpacity(0.3),
          icon: Icons.check_circle_outline_rounded,
        );
      case TopicStatus.notStarted:
        return _StatusConfig(
          label: 'Not Started',
          color: AppColors.gray500,
          backgroundColor: AppColors.gray100,
          borderColor: AppColors.gray300,
          icon: Icons.radio_button_unchecked_rounded,
        );
    }
  }

  _SizeConfig _getSizeConfig(BadgeSize size) {
    switch (size) {
      case BadgeSize.small:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTextStyles.labelSmall,
          iconSize: 12,
          spacing: 4,
        );
      case BadgeSize.medium:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          textStyle: AppTextStyles.labelMedium,
          iconSize: 14,
          spacing: 6,
        );
      case BadgeSize.large:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.labelLarge,
          iconSize: 16,
          spacing: AppSpacing.xs,
        );
    }
  }
}

/// Status configuration
class _StatusConfig {
  final String label;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  _StatusConfig({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}

/// Size configuration
class _SizeConfig {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double spacing;

  _SizeConfig({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.spacing,
  });
}

/// Helper method to determine status based on date
TopicStatus getTopicStatusFromDate(DateTime? dueDate) {
  if (dueDate == null) return TopicStatus.notStarted;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

  if (due.isBefore(today)) {
    return TopicStatus.overdue;
  } else if (due.isAtSameMomentAs(today)) {
    return TopicStatus.dueToday;
  } else {
    return TopicStatus.upcoming;
  }
}

/// Example usage:
///
/// ```dart
/// // Basic badge
/// TopicStatusBadge(
///   status: TopicStatus.overdue,
/// )
///
/// // Small badge without icon
/// TopicStatusBadge(
///   status: TopicStatus.dueToday,
///   size: BadgeSize.small,
///   showIcon: false,
/// )
///
/// // Large badge with custom label
/// TopicStatusBadge(
///   status: TopicStatus.upcoming,
///   size: BadgeSize.large,
///   customLabel: 'In 3 days',
/// )
///
/// // Using in a list tile
/// ListTile(
///   title: Text('Topic Name'),
///   trailing: TopicStatusBadge(
///     status: TopicStatus.overdue,
///     size: BadgeSize.small,
///   ),
/// )
///
/// // Dynamic status from date
/// final status = getTopicStatusFromDate(
///   DateTime.now().add(Duration(days: 2)),
/// );
/// TopicStatusBadge(status: status)
///
/// // All status variants
/// Column(
///   children: [
///     TopicStatusBadge(status: TopicStatus.overdue),
///     SizedBox(height: 8),
///     TopicStatusBadge(status: TopicStatus.dueToday),
///     SizedBox(height: 8),
///     TopicStatusBadge(status: TopicStatus.upcoming),
///     SizedBox(height: 8),
///     TopicStatusBadge(status: TopicStatus.completed),
///     SizedBox(height: 8),
///     TopicStatusBadge(status: TopicStatus.notStarted),
///   ],
/// )
/// ```
