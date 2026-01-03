import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Streak Counter Widget with Milestones
///
/// Displays the user's daily review streak with fire animation and milestone badges.
/// Inspired by Duolingo's streak system.
///
/// **Features:**
/// - Fire icon with animated flame effect
/// - Current streak count with large display
/// - Milestone badges (7, 30, 100, 365 days)
/// - "At Risk" warning if no review today
/// - Freeze/pause streak option
/// - Celebration animation on new records
///
/// **Example:**
/// ```dart
/// StreakCounterWidget(
///   currentStreak: 42,
///   longestStreak: 100,
///   hasReviewedToday: true,
///   onTap: () => showStreakDetails(),
/// )
/// ```
class StreakCounterWidget extends StatefulWidget {
  /// Current active streak in days
  final int currentStreak;

  /// Longest streak ever achieved
  final int longestStreak;

  /// Whether user has reviewed today
  final bool hasReviewedToday;

  /// Number of streak freezes available
  final int freezesAvailable;

  /// Last review date
  final DateTime? lastReviewDate;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Show milestone badges
  final bool showMilestones;

  /// Compact mode (smaller display)
  final bool compact;

  const StreakCounterWidget({
    super.key,
    required this.currentStreak,
    this.longestStreak = 0,
    this.hasReviewedToday = false,
    this.freezesAvailable = 0,
    this.lastReviewDate,
    this.onTap,
    this.showMilestones = true,
    this.compact = false,
  });

  @override
  State<StreakCounterWidget> createState() => _StreakCounterWidgetState();
}

class _StreakCounterWidgetState extends State<StreakCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _flameAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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

  /// Check if streak is at risk
  bool get _isAtRisk {
    if (widget.hasReviewedToday) return false;
    if (widget.lastReviewDate == null) return false;

    final now = DateTime.now();
    final lastReview = widget.lastReviewDate!;
    final daysSinceReview = now.difference(lastReview).inDays;

    return daysSinceReview >= 1;
  }

  /// Get milestone badges earned
  List<int> get _earnedMilestones {
    const milestones = [7, 30, 100, 365];
    return milestones.where((m) => widget.currentStreak >= m).toList();
  }

  /// Get next milestone
  int? get _nextMilestone {
    const milestones = [7, 30, 100, 365];
    for (var milestone in milestones) {
      if (widget.currentStreak < milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Get streak status color
  Color _getStreakColor() {
    if (_isAtRisk) {
      return const Color(0xFFEF4444); // Red
    } else if (widget.hasReviewedToday) {
      return const Color(0xFFF59E0B); // Orange/Gold
    } else {
      return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get streak status text
  String _getStreakStatus() {
    if (_isAtRisk) {
      return 'At Risk! Review today to save streak';
    } else if (widget.hasReviewedToday) {
      return 'Streak safe for today! 🎉';
    } else {
      return 'Review today to continue streak';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  /// Build compact view (for cards/small spaces)
  Widget _buildCompactView(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStreakColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _getStreakColor().withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.local_fire_department,
                    color: _getStreakColor(),
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 6),
            Text(
              '${widget.currentStreak}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getStreakColor(),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'day${widget.currentStreak == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build full view (for main display)
  Widget _buildFullView(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Daily Streak',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.freezesAvailable > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.ac_unit, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.freezesAvailable}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Streak counter with fire animation
              Row(
                children: [
                  // Animated fire icon
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFFCD34D), // Yellow
                              _getStreakColor(),
                            ],
                          ).createShader(bounds),
                          child: Icon(
                            Icons.local_fire_department,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),

                  // Streak count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.currentStreak}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getStreakColor(),
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'day${widget.currentStreak == 1 ? '' : 's'} streak',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStreakColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAtRisk ? Icons.warning_amber : Icons.check_circle,
                      size: 20,
                      color: _getStreakColor(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStreakStatus(),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getStreakColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Milestone badges
              if (widget.showMilestones && _earnedMilestones.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Milestones Achieved',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _earnedMilestones.map((milestone) {
                    return _buildMilestoneBadge(context, milestone, true);
                  }).toList(),
                ),
              ],

              // Next milestone progress
              if (_nextMilestone != null) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Next: $_nextMilestone days',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_nextMilestone! - widget.currentStreak} days to go',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.currentStreak / _nextMilestone!,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(_getStreakColor()),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],

              // Longest streak
              if (widget.longestStreak > widget.currentStreak) ...[
                const SizedBox(height: 12),
                Text(
                  'Your best: ${widget.longestStreak} days 🏆',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build milestone badge
  Widget _buildMilestoneBadge(BuildContext context, int days, bool earned) {
    final color = earned ? const Color(0xFFF59E0B) : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? Icons.emoji_events : Icons.lock,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$days days',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
