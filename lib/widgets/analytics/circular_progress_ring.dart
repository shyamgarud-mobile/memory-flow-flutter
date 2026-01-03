import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Circular Progress Ring Widget
///
/// Displays topic completion progress in a circular ring format with animations.
/// The ring fills clockwise based on the current stage (0-4) and changes color
/// from red (stage 0) to green (stage 4).
///
/// **Features:**
/// - Animated progress transitions
/// - Color gradient based on progress (red → yellow → green)
/// - Center displays current stage and percentage
/// - Tap callback for detailed breakdown
/// - Customizable size and stroke width
///
/// **Example:**
/// ```dart
/// CircularProgressRing(
///   currentStage: 2,
///   totalStages: 5,
///   size: 120,
///   onTap: () => showDetailedProgress(),
/// )
/// ```
class CircularProgressRing extends StatefulWidget {
  /// Current stage of the topic (0-4)
  final int currentStage;

  /// Total number of stages (default: 5)
  final int totalStages;

  /// Size of the widget (diameter)
  final double size;

  /// Stroke width of the ring
  final double strokeWidth;

  /// Optional callback when tapped
  final VoidCallback? onTap;

  /// Show percentage text in center
  final bool showPercentage;

  /// Show stage text in center
  final bool showStage;

  /// Animation duration
  final Duration animationDuration;

  const CircularProgressRing({
    super.key,
    required this.currentStage,
    this.totalStages = 5,
    this.size = 120,
    this.strokeWidth = 12,
    this.onTap,
    this.showPercentage = true,
    this.showStage = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<CircularProgressRing> createState() => _CircularProgressRingState();
}

class _CircularProgressRingState extends State<CircularProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(CircularProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStage != widget.currentStage) {
      _updateAnimation();
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    final targetProgress = widget.currentStage / widget.totalStages;
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _updateAnimation() {
    // Reset and update the animation with new target
    _animationController.reset();

    final targetProgress = widget.currentStage / widget.totalStages;
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get color based on progress (red → yellow → green)
  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      // Red to Yellow (0% - 33%)
      return Color.lerp(
        const Color(0xFFEF4444), // Red
        const Color(0xFFF59E0B), // Yellow
        progress / 0.33,
      )!;
    } else if (progress < 0.66) {
      // Yellow to Light Green (33% - 66%)
      return Color.lerp(
        const Color(0xFFF59E0B), // Yellow
        const Color(0xFF84CC16), // Light Green
        (progress - 0.33) / 0.33,
      )!;
    } else {
      // Light Green to Green (66% - 100%)
      return Color.lerp(
        const Color(0xFF84CC16), // Light Green
        const Color(0xFF10B981), // Green
        (progress - 0.66) / 0.34,
      )!;
    }
  }

  /// Get stage description
  String _getStageDescription() {
    switch (widget.currentStage) {
      case 0:
        return 'New';
      case 1:
        return '1 day';
      case 2:
        return '3 days';
      case 3:
        return '1 week';
      case 4:
        return '2 weeks';
      default:
        return 'Stage ${widget.currentStage}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final progress = _progressAnimation.value;
            final progressColor = _getProgressColor(progress);
            final percentage = (progress * 100).toInt();

            return Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: 1.0,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
                // Progress ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: progress,
                    color: progressColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showStage) ...[
                      Text(
                        'Stage ${widget.currentStage}',
                        style: TextStyle(
                          fontSize: widget.size * 0.12,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      SizedBox(height: widget.size * 0.02),
                    ],
                    if (widget.showPercentage)
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: widget.size * 0.15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    SizedBox(height: widget.size * 0.02),
                    Text(
                      _getStageDescription(),
                      style: TextStyle(
                        fontSize: widget.size * 0.08,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                // Tap indicator
                if (widget.onTap != null)
                  Positioned(
                    bottom: widget.size * 0.08,
                    child: Icon(
                      Icons.touch_app,
                      size: widget.size * 0.1,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.3),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the circular ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees) clockwise
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      2 * math.pi * progress, // Sweep angle based on progress
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
