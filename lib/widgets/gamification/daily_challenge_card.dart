import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Daily Challenge Card Widget
///
/// Displays auto-generated daily micro-goals to keep users engaged.
/// Challenges reset at midnight and reward XP/badges.
///
/// **Challenge Types:**
/// - Review X topics today
/// - Clear all overdue topics
/// - Add 1 new topic
/// - Review 5 topics before noon
/// - Achieve 100% accuracy today
///
/// **Example:**
/// ```dart
/// DailyChallengeCard(
///   challenge: currentChallenge,
///   onComplete: () => markChallengeComplete(),
/// )
/// ```

/// Daily Challenge model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final bool isCompleted;
  final DateTime date;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.targetValue,
    required this.currentValue,
    required this.xpReward,
    required this.isCompleted,
    required this.date,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  int get remainingValue => (targetValue - currentValue).clamp(0, targetValue);

  /// Generate random daily challenge
  static DailyChallenge generateDaily({
    required int reviewsToday,
    required int overdueCount,
    required int totalTopics,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final random = math.Random(now.year * 10000 + now.month * 100 + now.day);
    final challengeType = random.nextInt(5);

    switch (challengeType) {
      case 0:
        // Review X topics
        final target = math.max(3, (totalTopics * 0.3).ceil());
        return DailyChallenge(
          id: 'review_topics_${now.day}',
          title: 'Daily Review',
          description: 'Review $target topics today',
          icon: Icons.task_alt,
          color: const Color(0xFF10B981),
          targetValue: target,
          currentValue: reviewsToday,
          xpReward: target * 10,
          isCompleted: reviewsToday >= target,
          date: now,
        );

      case 1:
        // Clear overdue
        return DailyChallenge(
          id: 'clear_overdue_${now.day}',
          title: 'Catch Up',
          description: 'Clear all overdue topics',
          icon: Icons.cleaning_services,
          color: const Color(0xFFEF4444),
          targetValue: math.max(1, overdueCount),
          currentValue: overdueCount == 0 ? 1 : 0,
          xpReward: 50,
          isCompleted: overdueCount == 0,
          date: now,
        );

      case 2:
        // Add new topic
        return DailyChallenge(
          id: 'add_topic_${now.day}',
          title: 'Expand Knowledge',
          description: 'Add 1 new topic',
          icon: Icons.add_circle,
          color: const Color(0xFF3B82F6),
          targetValue: 1,
          currentValue: 0, // Would need to track new topics today
          xpReward: 30,
          isCompleted: false,
          date: now,
        );

      case 3:
        // Morning review
        final target = 3;
        final isMorning = now.hour < 12;
        return DailyChallenge(
          id: 'morning_review_${now.day}',
          title: 'Early Bird',
          description: 'Review $target topics before noon',
          icon: Icons.wb_sunny,
          color: const Color(0xFFF59E0B),
          targetValue: target,
          currentValue: isMorning ? reviewsToday : 0,
          xpReward: 40,
          isCompleted: false,
          date: now,
        );

      case 4:
      default:
        // Perfect day (no snoozes)
        final target = 5;
        return DailyChallenge(
          id: 'perfect_day_${now.day}',
          title: 'Perfect Day',
          description: 'Complete $target reviews without snoozing',
          icon: Icons.stars,
          color: const Color(0xFF8B5CF6),
          targetValue: target,
          currentValue: reviewsToday,
          xpReward: 60,
          isCompleted: reviewsToday >= target,
          date: now,
        );
    }
  }
}

class DailyChallengeCard extends StatefulWidget {
  /// Current daily challenge
  final DailyChallenge challenge;

  /// Callback when challenge is completed
  final VoidCallback? onComplete;

  /// Compact mode
  final bool compact;

  const DailyChallengeCard({
    super.key,
    required this.challenge,
    this.onComplete,
    this.compact = false,
  });

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _justCompleted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(DailyChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.challenge.isCompleted && widget.challenge.isCompleted) {
      _justCompleted = true;
      _animationController.forward(from: 0);
      widget.onComplete?.call();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _justCompleted = false);
        }
      });
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Card(
      color: widget.challenge.color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.challenge.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.challenge.icon,
                color: widget.challenge.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.challenge.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.challenge.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.challenge.isCompleted)
              Icon(
                Icons.check_circle,
                color: widget.challenge.color,
                size: 24,
              )
            else
              Text(
                '${widget.challenge.currentValue}/${widget.challenge.targetValue}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.challenge.color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _justCompleted ? _pulseAnimation.value : 1.0,
          child: Card(
            elevation: widget.challenge.isCompleted ? 4 : 2,
            color: widget.challenge.isCompleted
                ? widget.challenge.color.withOpacity(0.1)
                : null,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: widget.challenge.isCompleted
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.challenge.color.withOpacity(0.1),
                          widget.challenge.color.withOpacity(0.05),
                        ],
                      )
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: widget.challenge.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.challenge.icon,
                            color: widget.challenge.color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Challenge',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: widget.challenge.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.challenge.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.challenge.xpReward} XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      widget.challenge.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 16),

                    // Progress
                    if (!widget.challenge.isCompleted) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${widget.challenge.currentValue}/${widget.challenge.targetValue}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: widget.challenge.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: widget.challenge.progress,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(widget.challenge.color),
                          minHeight: 12,
                        ),
                      ),
                      if (widget.challenge.remainingValue > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${widget.challenge.remainingValue} more to go!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ] else ...[
                      // Completed state
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.challenge.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.celebration,
                              color: widget.challenge.color,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Challenge Complete! 🎉',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.challenge.color,
                                    ),
                                  ),
                                  Text(
                                    'You earned ${widget.challenge.xpReward} XP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
