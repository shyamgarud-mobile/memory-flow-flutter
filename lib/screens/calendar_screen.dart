import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Calendar screen - Shows review schedule and history
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar placeholder card
            _buildCalendarPlaceholder(context),
            const SizedBox(height: AppSpacing.lg),

            // Upcoming reviews section
            Text(
              'Upcoming Reviews',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildUpcomingReviewsPlaceholder(context),
          ],
        ),
      ),
    );
  }

  /// Build calendar placeholder
  Widget _buildCalendarPlaceholder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 80,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Calendar View',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your review schedule will appear here',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build upcoming reviews placeholder
  Widget _buildUpcomingReviewsPlaceholder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildReviewItem(
              context: context,
              title: 'Today',
              count: 0,
              color: AppColors.danger,
              icon: Icons.today_rounded,
            ),
            const Divider(),
            _buildReviewItem(
              context: context,
              title: 'Tomorrow',
              count: 0,
              color: AppColors.warning,
              icon: Icons.event_rounded,
            ),
            const Divider(),
            _buildReviewItem(
              context: context,
              title: 'This Week',
              count: 0,
              color: AppColors.primary,
              icon: Icons.date_range_rounded,
            ),
          ],
        ),
      ),
    );
  }

  /// Build a review item
  Widget _buildReviewItem({
    required BuildContext context,
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.round),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
