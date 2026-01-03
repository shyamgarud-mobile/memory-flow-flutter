import 'package:flutter/material.dart';
import '../widgets/gamification/streak_counter_widget.dart';
import '../widgets/gamification/achievement_badge_widget.dart';
import '../widgets/gamification/daily_challenge_card.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

/// Gamification Showcase Screen
///
/// Demonstrates all gamification widgets with simulated data.
/// Shows streak counter, achievement badges, and daily challenges.
class GamificationShowcaseScreen extends StatefulWidget {
  const GamificationShowcaseScreen({super.key});

  @override
  State<GamificationShowcaseScreen> createState() => _GamificationShowcaseScreenState();
}

class _GamificationShowcaseScreenState extends State<GamificationShowcaseScreen> {
  final DatabaseService _db = DatabaseService();

  // Streak data (simulated for demo)
  int _currentStreak = 12;
  int _longestStreak = 42;
  bool _hasReviewedToday = true;
  int _freezesAvailable = 2;

  // Achievement data
  List<Achievement> _achievements = [];

  // Challenge data
  late DailyChallenge _dailyChallenge;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load actual data from database
      final topics = await _db.getAllTopics();

      // Calculate stats
      final totalReviews = topics.fold<int>(0, (sum, t) => sum + t.reviewCount);
      final masteredTopics = topics.where((t) => t.currentStage >= 4).length;

      // Generate achievements
      _achievements = Achievement.createDefaultAchievements(
        totalReviews: totalReviews,
        currentStreak: _currentStreak,
        nightReviews: 5, // Would need to track this
        perfectReviews: 8, // Would need to track this
        masteredTopics: masteredTopics,
        maxReviewsInDay: 15, // Would need to track this
      );

      // Generate daily challenge
      final overdueCount = topics.where((t) => t.isOverdue).length;
      _dailyChallenge = DailyChallenge.generateDaily(
        reviewsToday: 3,
        overdueCount: overdueCount,
        totalTopics: topics.length,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading gamification data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Streak Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakDetailRow('Current Streak', '$_currentStreak days'),
            _buildStreakDetailRow('Longest Streak', '$_longestStreak days'),
            _buildStreakDetailRow('Reviewed Today', _hasReviewedToday ? 'Yes ✓' : 'Not yet'),
            _buildStreakDetailRow('Streak Freezes', '$_freezesAvailable available'),
            const SizedBox(height: 16),
            const Text(
              'Keep reviewing daily to maintain your streak! Streak freezes can save your streak if you miss a day.',
              style: TextStyle(fontSize: 12),
            ),
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

  Widget _buildStreakDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(achievement.icon, color: achievement.color),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: achievement.color),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Achievement Unlocked!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Progress: ${achievement.currentValue}/${achievement.targetValue}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
              const SizedBox(height: 8),
              Text(
                '${achievement.remainingValue} more to unlock!',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification Widgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Streak Counter
                    Text(
                      '1. Streak Counter',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track daily review streaks with fire animation and milestones',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full streak counter
                    StreakCounterWidget(
                      currentStreak: _currentStreak,
                      longestStreak: _longestStreak,
                      hasReviewedToday: _hasReviewedToday,
                      freezesAvailable: _freezesAvailable,
                      lastReviewDate: DateTime.now().subtract(const Duration(hours: 5)),
                      onTap: _showStreakDetails,
                    ),

                    const SizedBox(height: 16),

                    // Compact streak counter
                    Text(
                      'Compact Version:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    StreakCounterWidget(
                      currentStreak: _currentStreak,
                      longestStreak: _longestStreak,
                      hasReviewedToday: _hasReviewedToday,
                      compact: true,
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Section 2: Achievement Badges
                    Text(
                      '2. Achievement Badges',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock badges by completing challenges and milestones',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid view
                    AchievementBadgeWidget(
                      achievements: _achievements,
                      gridLayout: true,
                      onBadgeTap: _showAchievementDetails,
                    ),

                    const SizedBox(height: 24),

                    // List view
                    Text(
                      'List View:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    AchievementBadgeWidget(
                      achievements: _achievements.take(3).toList(),
                      gridLayout: false,
                      onBadgeTap: _showAchievementDetails,
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Section 3: Daily Challenge
                    Text(
                      '3. Daily Challenge',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete daily micro-goals for XP rewards',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full daily challenge
                    DailyChallengeCard(
                      challenge: _dailyChallenge,
                      onComplete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Challenge completed! +${_dailyChallenge.xpReward} XP'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Compact challenge
                    Text(
                      'Compact Version:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    DailyChallengeCard(
                      challenge: _dailyChallenge,
                      compact: true,
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Stats Summary
                    _buildStatsCard(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalAchievements = _achievements.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.local_fire_department,
              label: 'Current Streak',
              value: '$_currentStreak days',
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.emoji_events,
              label: 'Achievements',
              value: '$unlockedCount/$totalAchievements unlocked',
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              icon: Icons.bolt,
              label: 'XP Today',
              value: '${_dailyChallenge.xpReward} earned',
              color: const Color(0xFF3B82F6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
