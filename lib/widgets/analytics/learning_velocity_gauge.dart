import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Learning Velocity Gauge Widget
///
/// Displays learning momentum as a speedometer-style gauge showing reviews per day.
/// The needle indicates current velocity with color zones for different speeds.
///
/// **Features:**
/// - Speedometer-style semicircular gauge
/// - Needle animation with physics-based movement
/// - Color zones: slow (red), steady (yellow), fast (green)
/// - Shows reviews/day metric
/// - Trend indicator (accelerating/decelerating)
/// - Haptic feedback on interaction
///
/// **Example:**
/// ```dart
/// LearningVelocityGauge(
///   currentVelocity: 8.5, // reviews per day
///   maxVelocity: 15.0,
///   trend: VelocityTrend.accelerating,
/// )
/// ```
class LearningVelocityGauge extends StatefulWidget {
  /// Current learning velocity (reviews per day)
  final double currentVelocity;

  /// Maximum velocity for scale (default: 20)
  final double maxVelocity;

  /// Size of the gauge
  final double size;

  /// Show trend indicator
  final bool showTrend;

  /// Velocity trend (accelerating, steady, decelerating)
  final VelocityTrend? trend;

  /// Animation duration for needle movement
  final Duration animationDuration;

  const LearningVelocityGauge({
    super.key,
    required this.currentVelocity,
    this.maxVelocity = 20.0,
    this.size = 200,
    this.showTrend = true,
    this.trend,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<LearningVelocityGauge> createState() => _LearningVelocityGaugeState();
}

enum VelocityTrend {
  accelerating,
  steady,
  decelerating,
}

class _LearningVelocityGaugeState extends State<LearningVelocityGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _needleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(LearningVelocityGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentVelocity != widget.currentVelocity) {
      _setupAnimation();
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    final targetAngle = _velocityToAngle(widget.currentVelocity);
    _needleAnimation = Tween<double>(
      begin: -math.pi / 2, // Start at left (0 velocity)
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Convert velocity to angle (range: -π/2 to π/2)
  double _velocityToAngle(double velocity) {
    final clampedVelocity = velocity.clamp(0.0, widget.maxVelocity);
    final ratio = clampedVelocity / widget.maxVelocity;
    return -math.pi / 2 + (math.pi * ratio);
  }

  /// Get zone color based on velocity
  Color _getZoneColor(double velocity) {
    final ratio = velocity / widget.maxVelocity;
    if (ratio < 0.33) {
      return const Color(0xFFEF4444); // Red (slow)
    } else if (ratio < 0.66) {
      return const Color(0xFFF59E0B); // Yellow (steady)
    } else {
      return const Color(0xFF10B981); // Green (fast)
    }
  }

  /// Get zone label
  String _getZoneLabel(double velocity) {
    final ratio = velocity / widget.maxVelocity;
    if (ratio < 0.33) {
      return 'Slow';
    } else if (ratio < 0.66) {
      return 'Steady';
    } else {
      return 'Fast';
    }
  }

  /// Get trend icon
  IconData _getTrendIcon() {
    switch (widget.trend) {
      case VelocityTrend.accelerating:
        return Icons.trending_up;
      case VelocityTrend.steady:
        return Icons.trending_flat;
      case VelocityTrend.decelerating:
        return Icons.trending_down;
      case null:
        return Icons.remove;
    }
  }

  /// Get trend color
  Color _getTrendColor() {
    switch (widget.trend) {
      case VelocityTrend.accelerating:
        return const Color(0xFF10B981);
      case VelocityTrend.steady:
        return const Color(0xFFF59E0B);
      case VelocityTrend.decelerating:
        return const Color(0xFFEF4444);
      case null:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.7,
      child: Column(
        children: [
          // Gauge
          Expanded(
            child: AnimatedBuilder(
              animation: _needleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size * 0.6),
                  painter: _GaugePainter(
                    needleAngle: _needleAnimation.value,
                    maxVelocity: widget.maxVelocity,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                );
              },
            ),
          ),
          // Velocity display
          Column(
            children: [
              Text(
                widget.currentVelocity.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.bold,
                  color: _getZoneColor(widget.currentVelocity),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'reviews/day',
                style: TextStyle(
                  fontSize: widget.size * 0.06,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getZoneColor(widget.currentVelocity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getZoneLabel(widget.currentVelocity),
                  style: TextStyle(
                    fontSize: widget.size * 0.06,
                    fontWeight: FontWeight.w600,
                    color: _getZoneColor(widget.currentVelocity),
                  ),
                ),
              ),
              if (widget.showTrend && widget.trend != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(),
                      size: widget.size * 0.08,
                      color: _getTrendColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.trend!.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: widget.size * 0.05,
                        fontWeight: FontWeight.w600,
                        color: _getTrendColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the gauge
class _GaugePainter extends CustomPainter {
  final double needleAngle;
  final double maxVelocity;
  final bool isDark;

  _GaugePainter({
    required this.needleAngle,
    required this.maxVelocity,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width / 2.5;

    // Draw color zones (arcs)
    _drawZones(canvas, center, radius);

    // Draw tick marks
    _drawTickMarks(canvas, center, radius);

    // Draw needle
    _drawNeedle(canvas, center, radius);

    // Draw center circle
    final centerPaint = Paint()
      ..color = isDark ? Colors.grey[700]! : Colors.grey[400]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.1, centerPaint);
  }

  void _drawZones(Canvas canvas, Offset center, double radius) {
    final zoneColors = [
      const Color(0xFFEF4444), // Red (0-33%)
      const Color(0xFFF59E0B), // Yellow (33-66%)
      const Color(0xFF10B981), // Green (66-100%)
    ];

    const sweepAngle = math.pi / 3; // Each zone is 60 degrees

    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = zoneColors[i].withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.3;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi + (sweepAngle * i),
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = isDark ? Colors.grey[600]! : Colors.grey[400]!
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw 11 tick marks (0, 2, 4, ..., 20)
    for (int i = 0; i <= 10; i++) {
      final angle = -math.pi / 2 + (math.pi / 10 * i);
      final isMajor = i % 2 == 0;
      final tickLength = isMajor ? radius * 0.15 : radius * 0.08;

      final startX = center.dx + (radius - tickLength) * math.cos(angle);
      final startY = center.dy + (radius - tickLength) * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = isMajor ? 3 : 2,
      );
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final needlePath = Path();
    final needleLength = radius * 0.85;
    final needleWidth = radius * 0.05;

    // Calculate needle tip position
    final tipX = center.dx + needleLength * math.cos(needleAngle);
    final tipY = center.dy + needleLength * math.sin(needleAngle);

    // Calculate needle base positions (perpendicular to needle)
    final baseAngle1 = needleAngle + math.pi / 2;
    final baseAngle2 = needleAngle - math.pi / 2;

    final base1X = center.dx + needleWidth * math.cos(baseAngle1);
    final base1Y = center.dy + needleWidth * math.sin(baseAngle1);
    final base2X = center.dx + needleWidth * math.cos(baseAngle2);
    final base2Y = center.dy + needleWidth * math.sin(baseAngle2);

    needlePath.moveTo(tipX, tipY);
    needlePath.lineTo(base1X, base1Y);
    needlePath.lineTo(base2X, base2Y);
    needlePath.close();

    final needlePaint = Paint()
      ..color = isDark ? Colors.red[400]! : Colors.red[600]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(needlePath, needlePaint);

    // Draw shadow for depth
    canvas.drawPath(
      needlePath.shift(const Offset(1, 1)),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.needleAngle != needleAngle ||
        oldDelegate.maxVelocity != maxVelocity ||
        oldDelegate.isDark != isDark;
  }
}
