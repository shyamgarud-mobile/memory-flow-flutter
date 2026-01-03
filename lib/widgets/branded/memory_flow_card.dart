import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// MemoryFlow Branded Card Widget
///
/// Standardized card component with consistent styling across the app.
/// Supports multiple variants: standard, elevated, gradient, outlined.
///
/// **Usage:**
/// ```dart
/// MemoryFlowCard(
///   title: 'Your Progress',
///   icon: Icons.insights,
///   child: Text('Content here'),
/// )
/// ```

enum MemoryFlowCardVariant {
  standard,
  elevated,
  gradient,
  outlined,
}

class MemoryFlowCard extends StatelessWidget {
  /// Card title
  final String? title;

  /// Optional subtitle
  final String? subtitle;

  /// Leading icon
  final IconData? icon;

  /// Icon color
  final Color? iconColor;

  /// Trailing widget (e.g., arrow, badge)
  final Widget? trailing;

  /// Card content
  final Widget child;

  /// Card variant
  final MemoryFlowCardVariant variant;

  /// Custom gradient (for gradient variant)
  final Gradient? gradient;

  /// Tap callback
  final VoidCallback? onTap;

  /// Padding
  final EdgeInsets? padding;

  /// Custom background color
  final Color? backgroundColor;

  /// Show header divider
  final bool showDivider;

  const MemoryFlowCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    required this.child,
    this.variant = MemoryFlowCardVariant.standard,
    this.gradient,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.showDivider = false,
  });

  BoxDecoration _getDecoration(BuildContext context) {
    switch (variant) {
      case MemoryFlowCardVariant.elevated:
        return MemoryFlowDesign.elevatedCardDecoration(context, color: backgroundColor);
      case MemoryFlowCardVariant.gradient:
        return MemoryFlowDesign.gradientCardDecoration(context, gradient: gradient);
      case MemoryFlowCardVariant.outlined:
        return MemoryFlowDesign.outlinedCardDecoration(context);
      case MemoryFlowCardVariant.standard:
      default:
        return MemoryFlowDesign.cardDecoration(context, color: backgroundColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: _getDecoration(context),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MemoryFlowDesign.radiusMedium,
          child: Padding(
            padding: padding ?? MemoryFlowDesign.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                if (title != null || icon != null) ...[
                  Row(
                    children: [
                      if (icon != null) ...[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (iconColor ?? MemoryFlowDesign.primaryBlue)
                                .withOpacity(0.1),
                            borderRadius: MemoryFlowDesign.radiusSmall,
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? MemoryFlowDesign.primaryBlue,
                            size: MemoryFlowDesign.iconSmall,
                          ),
                        ),
                        const SizedBox(width: MemoryFlowDesign.spaceSmall),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style: MemoryFlowDesign.heading3(context),
                              ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: MemoryFlowDesign.caption(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                      if (onTap != null && trailing == null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    ],
                  ),
                  if (showDivider) ...[
                    const SizedBox(height: MemoryFlowDesign.spaceMedium),
                    Divider(
                      height: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  ],
                  const SizedBox(height: MemoryFlowDesign.spaceMedium),
                ],
                // Content
                child,
              ],
            ),
          ),
        ),
      ),
    );

    return content;
  }
}

/// Compact Card - Smaller padding, no header
class MemoryFlowCompactCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;

  const MemoryFlowCompactCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MemoryFlowDesign.cardDecoration(context, color: color),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MemoryFlowDesign.radiusMedium,
          child: Padding(
            padding: padding ?? MemoryFlowDesign.paddingSmall,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Info Card - With colored left border accent
class MemoryFlowInfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MemoryFlowInfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color = const Color(0xFF3B82F6),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: MemoryFlowDesign.radiusMedium,
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: MemoryFlowDesign.radiusMedium,
          child: Padding(
            padding: MemoryFlowDesign.paddingMedium,
            child: Row(
              children: [
                Icon(icon, color: color, size: MemoryFlowDesign.iconMedium),
                const SizedBox(width: MemoryFlowDesign.spaceMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MemoryFlowDesign.heading3(context, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: MemoryFlowDesign.body(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
