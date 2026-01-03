import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/topics_index_service.dart';
import '../utils/theme_helper.dart';

/// Statistics dashboard screen
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TopicsIndexService _topicsService = TopicsIndexService();

  bool _isLoading = true;
  int _totalTopics = 0;
  int _totalReviews = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  Map<int, int> _topicsByStage = {};
  List<int> _weeklyReviews = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final topics = await _topicsService.loadTopicsIndex();
      final prefs = await SharedPreferences.getInstance();

      // Calculate statistics
      _totalTopics = topics.length;
      _totalReviews = topics.fold(0, (sum, t) => sum + t.reviewCount);

      // Load streak data
      _currentStreak = prefs.getInt('current_streak') ?? 0;
      _longestStreak = prefs.getInt('longest_streak') ?? 0;

      // Count topics by stage
      _topicsByStage = {};
      for (final topic in topics) {
        final stage = topic.currentStage;
        _topicsByStage[stage] = (_topicsByStage[stage] ?? 0) + 1;
      }

      // Calculate weekly reviews (mock data based on review count)
      _weeklyReviews = _calculateWeeklyReviews(topics);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<int> _calculateWeeklyReviews(List<Topic> topics) {
    // Calculate reviews per day for the last 7 days
    final now = DateTime.now();
    final weeklyReviews = List<int>.filled(7, 0);

    for (final topic in topics) {
      if (topic.lastReviewedAt != null) {
        final daysDiff = now.difference(topic.lastReviewedAt!).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          weeklyReviews[6 - daysDiff]++;
        }
      }
    }

    return weeklyReviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewSection(),
                    ThemeHelper.vSpaceLarge,
                    _buildWeeklyChartSection(),
                    ThemeHelper.vSpaceLarge,
                    _buildStageDistributionSection(),
                    ThemeHelper.vSpaceLarge,
                    _buildAchievementsSection(),
                    ThemeHelper.vSpaceLarge,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ThemeHelper.vSpaceSmall,
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Current Streak',
                        value: '$_currentStreak days',
                        color: AppColors.warning,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.emoji_events_rounded,
                        label: 'Longest Streak',
                        value: '$_longestStreak days',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.check_circle_rounded,
                        label: 'Total Reviews',
                        value: '$_totalReviews',
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.library_books_rounded,
                        label: 'Total Topics',
                        value: '$_totalTopics',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        ThemeHelper.vSpaceSmall,
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeeklyChartSection() {
    final maxReviews = _weeklyReviews.reduce((a, b) => a > b ? a : b);
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ThemeHelper.vSpaceSmall,
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final height = maxReviews > 0
                          ? (_weeklyReviews[index] / maxReviews) * 120
                          : 0.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${_weeklyReviews[index]}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              ThemeHelper.vSpaceSmall,
                              Container(
                                height: height.clamp(4.0, 120.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                ThemeHelper.vSpaceSmall,
                Row(
                  children: days.map((day) {
                    return Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageDistributionSection() {
    final stages = [
      ('Stage 1', '1 day', 0),
      ('Stage 2', '3 days', 1),
      ('Stage 3', '1 week', 2),
      ('Stage 4', '2 weeks', 3),
      ('Stage 5', '1 month', 4),
    ];

    final maxCount = _topicsByStage.values.isEmpty
        ? 1
        : _topicsByStage.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'By Stage',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ThemeHelper.vSpaceSmall,
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: stages.map((stage) {
                final count = _topicsByStage[stage.$3] ?? 0;
                final percentage = maxCount > 0 ? count / maxCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          stage.$1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.gray200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      _Achievement(
        icon: Icons.star_rounded,
        title: 'First Week',
        description: '7 day streak',
        unlocked: _longestStreak >= 7,
      ),
      _Achievement(
        icon: Icons.local_fire_department_rounded,
        title: '10 Day Streak',
        description: 'Review for 10 days',
        unlocked: _longestStreak >= 10,
      ),
      _Achievement(
        icon: Icons.library_books_rounded,
        title: '25 Topics',
        description: 'Create 25 topics',
        unlocked: _totalTopics >= 25,
      ),
      _Achievement(
        icon: Icons.done_all_rounded,
        title: '100 Reviews',
        description: 'Complete 100 reviews',
        unlocked: _totalReviews >= 100,
      ),
      _Achievement(
        icon: Icons.military_tech_rounded,
        title: '50 Day Streak',
        description: 'Review for 50 days',
        unlocked: _longestStreak >= 50,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ThemeHelper.vSpaceSmall,
        Card(
          child: Column(
            children: achievements.map((achievement) {
              return ListTile(
                leading: Icon(
                  achievement.icon,
                  color: achievement.unlocked
                      ? AppColors.warning
                      : AppColors.gray400,
                ),
                title: Text(
                  achievement.title,
                  style: TextStyle(
                    color: achievement.unlocked ? null : AppColors.gray400,
                  ),
                ),
                subtitle: Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: achievement.unlocked
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : const Icon(Icons.lock, color: AppColors.gray400),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;

  _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}
