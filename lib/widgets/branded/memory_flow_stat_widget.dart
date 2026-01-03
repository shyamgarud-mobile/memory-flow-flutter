import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// MemoryFlow Stat Widget
///
/// Displays key metrics in a consistent, branded format.
/// Perfect for dashboards and overview screens.
///
/// **Usage:**
/// ```dart
/// MemoryFlowStatWidget(
///   icon: Icons.local_fire_department,
///   value: '42',
///   label: 'Day Streak',
///   color: MemoryFlowDesign.warningAmber,
/// )
/// ```

class MemoryFlowStatWidget extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue; // Positive = up, negative = down
  final bool compact;

  const MemoryFlowStatWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? MemoryFlowDesign.primaryBlue;

    if (compact) {
      return _buildCompact(context, statColor);
    } else {
      return _buildStandard(context, statColor);
    }
  }

  Widget _buildStandard(BuildContext context, Color statColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MemoryFlowDesign.paddingMedium,
        decoration: MemoryFlowDesign.cardDecoration(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statColor.withOpacity(0.1),
                borderRadius: MemoryFlowDesign.radiusMedium,
              ),
              child: Icon(
                icon,
                color: statColor,
                size: MemoryFlowDesign.iconLarge,
              ),
            ),
            const SizedBox(height: MemoryFlowDesign.spaceSmall),
            Text(
              value,
              style: MemoryFlowDesign.heading1(context, color: statColor),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: MemoryFlowDesign.caption(context),
              textAlign: TextAlign.center,
            ),
            if (showTrend && trendValue != null) ...[
              const SizedBox(height: 4),
              _buildTrend(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, Color statColor) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statColor.withOpacity(0.1),
              borderRadius: MemoryFlowDesign.radiusSmall,
            ),
            child: Icon(
              icon,
              color: statColor,
              size: MemoryFlowDesign.iconSmall,
            ),
          ),
          const SizedBox(width: MemoryFlowDesign.spaceSmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: MemoryFlowDesign.heading2(context, color: statColor),
              ),
              Text(
                label,
                style: MemoryFlowDesign.caption(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrend(BuildContext context) {
    if (trendValue == null) return const SizedBox.shrink();

    final isPositive = trendValue! > 0;
    final trendColor = isPositive ? MemoryFlowDesign.successGreen : MemoryFlowDesign.errorRed;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          size: 12,
          color: trendColor,
        ),
        const SizedBox(width: 2),
        Text(
          '${trendValue!.abs().toStringAsFixed(0)}%',
          style: MemoryFlowDesign.label(context, color: trendColor),
        ),
      ],
    );
  }
}

/// Stat Row - Displays multiple stats horizontally
class MemoryFlowStatRow extends StatelessWidget {
  final List<MemoryFlowStatWidget> stats;
  final MainAxisAlignment alignment;

  const MemoryFlowStatRow({
    super.key,
    required this.stats,
    this.alignment = MainAxisAlignment.spaceAround,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: stats.map((stat) => Expanded(child: stat)).toList(),
    );
  }
}

/// Progress Stat - Shows value with progress bar
class MemoryFlowProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final double progress; // 0.0 to 1.0
  final Color? color;
  final IconData? icon;

  const MemoryFlowProgressStat({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? MemoryFlowDesign.primaryBlue;

    return Container(
      padding: MemoryFlowDesign.paddingMedium,
      decoration: MemoryFlowDesign.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: MemoryFlowDesign.iconSmall, color: statColor),
                const SizedBox(width: MemoryFlowDesign.spaceSmall),
              ],
              Expanded(
                child: Text(
                  label,
                  style: MemoryFlowDesign.body(context),
                ),
              ),
              Text(
                value,
                style: MemoryFlowDesign.heading2(context, color: statColor),
              ),
            ],
          ),
          const SizedBox(height: MemoryFlowDesign.spaceSmall),
          ClipRRect(
            borderRadius: MemoryFlowDesign.radiusSmall,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Metric Card - Large stat display with subtitle
class MemoryFlowMetricCard extends StatelessWidget {
  final String metric;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MemoryFlowMetricCard({
    super.key,
    required this.metric,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color = const Color(0xFF4A9FD8),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MemoryFlowDesign.paddingLarge,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: MemoryFlowDesign.radiusMedium,
          boxShadow: MemoryFlowDesign.shadowMedium(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.9),
              size: MemoryFlowDesign.iconLarge,
            ),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            Text(
              value,
              style: MemoryFlowDesign.display(context, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              metric,
              style: MemoryFlowDesign.bodyLarge(
                context,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: MemoryFlowDesign.caption(
                  context,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
