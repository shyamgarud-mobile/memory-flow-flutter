import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Reusable custom card widget with consistent styling
class CustomCard extends StatelessWidget {
  /// The widget to display inside the card
  final Widget child;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  /// Background color of the card
  final Color? color;

  /// Border color (if null, no border is shown)
  final Color? borderColor;

  /// Border width (default: 1.0)
  final double borderWidth;

  /// Elevation/shadow depth (default: 2.0)
  final double elevation;

  /// Internal padding (default: AppSpacing.md)
  final EdgeInsetsGeometry? padding;

  /// External margin (default: EdgeInsets.zero)
  final EdgeInsetsGeometry? margin;

  /// Border radius (default: AppBorderRadius.lg)
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.elevation = 2.0,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardTheme.color;
    final effectiveBorderRadius = borderRadius ?? AppBorderRadius.lg;

    Widget cardContent = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Example usage:
///
/// ```dart
/// // Basic card
/// CustomCard(
///   child: Text('Hello World'),
/// )
///
/// // Card with tap action
/// CustomCard(
///   onTap: () => print('Tapped'),
///   child: Text('Tap me'),
/// )
///
/// // Card with custom styling
/// CustomCard(
///   color: AppColors.primary.withOpacity(0.1),
///   borderColor: AppColors.primary,
///   borderWidth: 2.0,
///   elevation: 4.0,
///   padding: EdgeInsets.all(AppSpacing.lg),
///   child: Column(
///     children: [
///       Icon(Icons.star, color: AppColors.primary),
///       Text('Featured'),
///     ],
///   ),
/// )
///
/// // Card with no shadow
/// CustomCard(
///   elevation: 0,
///   borderColor: AppColors.gray300,
///   child: Text('Flat card'),
/// )
/// ```
