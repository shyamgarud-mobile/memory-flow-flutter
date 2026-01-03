import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Figma-style card with clean, minimal design
///
/// Design specs:
/// - Border radius: 12px
/// - Shadow: subtle elevation (0 4px 12px rgba(0,0,0,0.08))
/// - Background: white (light) / surface (dark)
/// - Padding: customizable, default 16px
/// - Border: optional 1px border
///
/// Usage:
/// ```dart
/// FigmaCard(
///   child: Column(
///     children: [
///       Text('Card Title'),
///       Text('Card Content'),
///     ],
///   ),
/// )
/// ```
class FigmaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final bool showBorder;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? elevation;

  const FigmaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ??
            (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
        border: showBorder
            ? Border.all(
                color: borderColor ??
                    (isDark ? AppColors.gray700 : AppColors.gray300),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: elevation ?? 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppBorderRadius.card),
            child: cardChild,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: cardChild,
    );
  }
}

/// Figma-style list card for list items
///
/// Design specs:
/// - Same as FigmaCard but optimized for list items
/// - No padding by default (handled by ListTile)
/// - Subtle hover/tap effect
///
/// Usage:
/// ```dart
/// FigmaListCard(
///   onTap: () => _handleTap(),
///   child: ListTile(
///     leading: Icon(Icons.person),
///     title: Text('Name'),
///     subtitle: Text('Description'),
///   ),
/// )
/// ```
class FigmaListCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;

  const FigmaListCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return FigmaCard(
      padding: EdgeInsets.zero,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      showBorder: showBorder,
      onTap: onTap,
      child: child,
    );
  }
}

/// Figma-style section card with header
///
/// Design specs:
/// - Card with optional header section
/// - Header has background color
/// - Content section below
///
/// Usage:
/// ```dart
/// FigmaSectionCard(
///   title: 'Settings',
///   icon: Icons.settings,
///   child: Column(
///     children: [
///       ListTile(...),
///       ListTile(...),
///     ],
///   ),
/// )
/// ```
class FigmaSectionCard extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Widget? trailing;

  const FigmaSectionCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.margin,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FigmaCard(
      padding: EdgeInsets.zero,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.gray800.withOpacity(0.5)
                    : AppColors.gray50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.card),
                  topRight: Radius.circular(AppBorderRadius.card),
                ),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}
