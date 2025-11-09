import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Topics List screen - Display all topics/decks
class TopicsListScreen extends StatelessWidget {
  const TopicsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Topics'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: _buildEmptyState(context),
    );
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
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  /// Build quick stats placeholder
  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'When you add topics, you\'ll see:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFeatureItem(
              context: context,
              icon: Icons.topic_rounded,
              text: 'All your learning topics',
            ),
            _buildFeatureItem(
              context: context,
              icon: Icons.trending_up_rounded,
              text: 'Progress tracking',
            ),
            _buildFeatureItem(
              context: context,
              icon: Icons.schedule_rounded,
              text: 'Review schedules',
            ),
            _buildFeatureItem(
              context: context,
              icon: Icons.analytics_rounded,
              text: 'Learning statistics',
            ),
          ],
        ),
      ),
    );
  }

  /// Build a feature item
  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Build topics list (for future use when topics exist)
  Widget _buildTopicsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 0, // TODO: Replace with actual topic count
      itemBuilder: (context, index) {
        return _buildTopicCard(context);
      },
    );
  }

  /// Build a topic card (for future use)
  Widget _buildTopicCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to topic detail
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(
                  Icons.topic_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic Title',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '0 cards • Last reviewed: Never',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
