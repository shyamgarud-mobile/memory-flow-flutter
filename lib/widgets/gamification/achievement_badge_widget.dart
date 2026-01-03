import 'package:flutter/material.dart';

/// Achievement Badge Widget
///
/// Displays unlockable achievement badges with progress tracking.
/// Gamifies the learning experience with goals and rewards.
///
/// **Badge Categories:**
/// - 🏆 First Steps: Complete 1 review
/// - 🔥 Week Warrior: 7-day streak
/// - 📚 Century Club: 100 total reviews
/// - 🌙 Night Owl: 10 reviews after 10 PM
/// - 🎯 Perfect Score: 10 reviews without snoozing
/// - 🌟 Master: Topic reaches stage 4
/// - 🚀 Speed Reader: 20 reviews in 1 day
///
/// **Example:**
/// ```dart
/// AchievementBadgeWidget(
///   achievements: userAchievements,
///   onBadgeTap: (achievement) => showDetails(achievement),
/// )
/// ```

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
    this.category = 'general',
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  int get remainingValue => (targetValue - currentValue).clamp(0, targetValue);

  /// Create predefined achievements
  static List<Achievement> createDefaultAchievements({
    required int totalReviews,
    required int currentStreak,
    required int nightReviews,
    required int perfectReviews,
    required int masteredTopics,
    required int maxReviewsInDay,
  }) {
    return [
      // First Steps
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Complete your first review',
        icon: Icons.rocket_launch,
        color: const Color(0xFF10B981),
        targetValue: 1,
        currentValue: totalReviews >= 1 ? 1 : 0,
        isUnlocked: totalReviews >= 1,
        category: 'beginner',
      ),

      // Week Warrior
      Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: Icons.local_fire_department,
        color: const Color(0xFFF59E0B),
        targetValue: 7,
        currentValue: currentStreak.clamp(0, 7),
        isUnlocked: currentStreak >= 7,
        category: 'streak',
      ),

      // Month Master
      Achievement(
        id: 'month_master',
        title: 'Month Master',
        description: 'Maintain a 30-day streak',
        icon: Icons.local_fire_department,
        color: const Color(0xFFEF4444),
        targetValue: 30,
        currentValue: currentStreak.clamp(0, 30),
        isUnlocked: currentStreak >= 30,
        category: 'streak',
      ),

      // Century Club
      Achievement(
        id: 'century_club',
        title: 'Century Club',
        description: 'Complete 100 reviews',
        icon: Icons.military_tech,
        color: const Color(0xFF8B5CF6),
        targetValue: 100,
        currentValue: totalReviews.clamp(0, 100),
        isUnlocked: totalReviews >= 100,
        category: 'reviews',
      ),

      // Night Owl
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete 10 reviews after 10 PM',
        icon: Icons.nightlight_round,
        color: const Color(0xFF6366F1),
        targetValue: 10,
        currentValue: nightReviews.clamp(0, 10),
        isUnlocked: nightReviews >= 10,
        category: 'timing',
      ),

      // Perfect Score
      Achievement(
        id: 'perfect_score',
        title: 'Perfect Score',
        description: 'Complete 10 reviews without snoozing',
        icon: Icons.stars,
        color: const Color(0xFFFCD34D),
        targetValue: 10,
        currentValue: perfectReviews.clamp(0, 10),
        isUnlocked: perfectReviews >= 10,
        category: 'quality',
      ),

      // Master
      Achievement(
        id: 'master',
        title: 'Master',
        description: 'Get a topic to stage 4',
        icon: Icons.school,
        color: const Color(0xFF3B82F6),
        targetValue: 1,
        currentValue: masteredTopics >= 1 ? 1 : 0,
        isUnlocked: masteredTopics >= 1,
        category: 'mastery',
      ),

      // Speed Reader
      Achievement(
        id: 'speed_reader',
        title: 'Speed Reader',
        description: 'Complete 20 reviews in one day',
        icon: Icons.flash_on,
        color: const Color(0xFFEC4899),
        targetValue: 20,
        currentValue: maxReviewsInDay.clamp(0, 20),
        isUnlocked: maxReviewsInDay >= 20,
        category: 'speed',
      ),

      // Dedicated Learner
      Achievement(
        id: 'dedicated_learner',
        title: 'Dedicated Learner',
        description: 'Complete 500 total reviews',
        icon: Icons.workspace_premium,
        color: const Color(0xFFD97706),
        targetValue: 500,
        currentValue: totalReviews.clamp(0, 500),
        isUnlocked: totalReviews >= 500,
        category: 'reviews',
      ),

      // Legend
      Achievement(
        id: 'legend',
        title: 'Legend',
        description: 'Maintain a 100-day streak',
        icon: Icons.emoji_events,
        color: const Color(0xFFDC2626),
        targetValue: 100,
        currentValue: currentStreak.clamp(0, 100),
        isUnlocked: currentStreak >= 100,
        category: 'streak',
      ),
    ];
  }
}

class AchievementBadgeWidget extends StatelessWidget {
  /// List of achievements
  final List<Achievement> achievements;

  /// Callback when badge is tapped
  final Function(Achievement)? onBadgeTap;

  /// Show only unlocked badges
  final bool showOnlyUnlocked;

  /// Grid layout (vs list)
  final bool gridLayout;

  const AchievementBadgeWidget({
    super.key,
    required this.achievements,
    this.onBadgeTap,
    this.showOnlyUnlocked = false,
    this.gridLayout = true,
  });

  List<Achievement> get _displayAchievements {
    if (showOnlyUnlocked) {
      return achievements.where((a) => a.isUnlocked).toList();
    }
    return achievements;
  }

  int get _unlockedCount => achievements.where((a) => a.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    if (gridLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _displayAchievements.length,
            itemBuilder: (context, index) {
              return _buildBadgeCard(context, _displayAchievements[index]);
            },
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          ..._displayAchievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildListItem(context, achievement),
            );
          }),
        ],
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$_unlockedCount/${achievements.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(BuildContext context, Achievement achievement) {
    final isLocked = !achievement.isUnlocked;

    return GestureDetector(
      onTap: () => onBadgeTap?.call(achievement),
      child: Card(
        elevation: isLocked ? 0 : 2,
        color: isLocked
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[100]
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (isLocked ? Colors.grey : achievement.color)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? Icons.lock : achievement.icon,
                  color: isLocked ? Colors.grey : achievement.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isLocked
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),

              // Progress (if locked)
              if (isLocked && achievement.progress > 0) ...[
                const SizedBox(height: 6),
                SizedBox(
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.color.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${achievement.currentValue}/${achievement.targetValue}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Achievement achievement) {
    final isLocked = !achievement.isUnlocked;

    return GestureDetector(
      onTap: () => onBadgeTap?.call(achievement),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isLocked ? Colors.grey : achievement.color)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isLocked ? Icons.lock : achievement.icon,
              color: isLocked ? Colors.grey : achievement.color,
              size: 24,
            ),
          ),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? Colors.grey
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.description),
              if (isLocked && achievement.progress > 0) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.color.withOpacity(0.5),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${achievement.currentValue}/${achievement.targetValue} - ${achievement.remainingValue} to go',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
          trailing: isLocked
              ? null
              : Icon(Icons.check_circle, color: achievement.color),
        ),
      ),
    );
  }
}
