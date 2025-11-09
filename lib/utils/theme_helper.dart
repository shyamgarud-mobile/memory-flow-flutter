import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/common/topic_status_badge.dart';

/// Theme helper utilities for consistent styling throughout the app
class ThemeHelper {
  ThemeHelper._(); // Private constructor to prevent instantiation

  // ============================================================================
  // SPACING HELPERS
  // ============================================================================

  /// Get horizontal padding for screen content
  static EdgeInsets get screenPadding =>
      const EdgeInsets.all(AppSpacing.md);

  /// Get horizontal padding only
  static EdgeInsets get horizontalPadding =>
      const EdgeInsets.symmetric(horizontal: AppSpacing.md);

  /// Get vertical padding only
  static EdgeInsets get verticalPadding =>
      const EdgeInsets.symmetric(vertical: AppSpacing.md);

  /// Get padding for cards
  static EdgeInsets get cardPadding =>
      const EdgeInsets.all(AppSpacing.md);

  /// Get padding for list items
  static EdgeInsets get listItemPadding => const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      );

  /// Get padding for sections
  static EdgeInsets get sectionPadding => const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
      );

  /// Get custom padding
  static EdgeInsets customPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      return EdgeInsets.all(all);
    }
    return EdgeInsets.only(
      top: top ?? vertical ?? 0,
      bottom: bottom ?? vertical ?? 0,
      left: left ?? horizontal ?? 0,
      right: right ?? horizontal ?? 0,
    );
  }

  // ============================================================================
  // BORDER RADIUS HELPERS
  // ============================================================================

  /// Get standard border radius
  static BorderRadius get standardRadius =>
      BorderRadius.circular(AppBorderRadius.md);

  /// Get large border radius
  static BorderRadius get largeRadius =>
      BorderRadius.circular(AppBorderRadius.lg);

  /// Get rounded border radius
  static BorderRadius get roundedRadius =>
      BorderRadius.circular(AppBorderRadius.round);

  /// Get top-only border radius
  static BorderRadius get topRadius => BorderRadius.only(
        topLeft: Radius.circular(AppBorderRadius.lg),
        topRight: Radius.circular(AppBorderRadius.lg),
      );

  /// Get bottom-only border radius
  static BorderRadius get bottomRadius => BorderRadius.only(
        bottomLeft: Radius.circular(AppBorderRadius.lg),
        bottomRight: Radius.circular(AppBorderRadius.lg),
      );

  // ============================================================================
  // STATUS & COLOR HELPERS
  // ============================================================================

  /// Get color for topic status
  static Color getStatusColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.overdue:
        return AppColors.danger;
      case TopicStatus.dueToday:
        return AppColors.warning;
      case TopicStatus.upcoming:
        return AppColors.success;
      case TopicStatus.completed:
        return AppColors.primary;
      case TopicStatus.notStarted:
        return AppColors.gray500;
    }
  }

  /// Get background color for topic status
  static Color getStatusBackgroundColor(TopicStatus status) {
    return getStatusColor(status).withOpacity(0.1);
  }

  /// Get difficulty color
  static Color getDifficultyColor(int difficulty) {
    // 0 = Easy (green), 1 = Medium (orange), 2 = Hard (red)
    switch (difficulty) {
      case 0:
        return AppColors.success;
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.danger;
      default:
        return AppColors.gray500;
    }
  }

  /// Get progress color based on percentage
  static Color getProgressColor(double percentage) {
    if (percentage < 0.3) {
      return AppColors.danger;
    } else if (percentage < 0.7) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  // ============================================================================
  // TEXT STYLE HELPERS
  // ============================================================================

  /// Get text style with color
  static TextStyle textWithColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get bold text style
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.bold);
  }

  /// Get semi-bold text style
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }

  /// Get italic text style
  static TextStyle italic(TextStyle style) {
    return style.copyWith(fontStyle: FontStyle.italic);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get muted text style (lighter color)
  static TextStyle muted(BuildContext context, TextStyle style) {
    return style.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color,
    );
  }

  // ============================================================================
  // SHADOW HELPERS
  // ============================================================================

  /// Get standard box shadow
  static List<BoxShadow> get standardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Get elevated box shadow
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Get custom shadow
  static List<BoxShadow> customShadow({
    double opacity = 0.1,
    double blurRadius = 4,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  // ============================================================================
  // DIVIDER HELPERS
  // ============================================================================

  /// Get standard divider
  static Widget get divider => const Divider(height: 1);

  /// Get divider with spacing
  static Widget dividerWithSpacing({
    double spacing = AppSpacing.md,
  }) {
    return Column(
      children: [
        SizedBox(height: spacing),
        const Divider(height: 1),
        SizedBox(height: spacing),
      ],
    );
  }

  /// Get vertical divider
  static Widget get verticalDivider => const VerticalDivider(width: 1);

  // ============================================================================
  // SPACING WIDGETS
  // ============================================================================

  /// Get vertical spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// Get horizontal spacing
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// Small vertical spacing
  static Widget get vSpaceSmall => const SizedBox(height: AppSpacing.sm);

  /// Medium vertical spacing
  static Widget get vSpaceMedium => const SizedBox(height: AppSpacing.md);

  /// Large vertical spacing
  static Widget get vSpaceLarge => const SizedBox(height: AppSpacing.lg);

  /// Extra large vertical spacing
  static Widget get vSpaceXL => const SizedBox(height: AppSpacing.xl);

  /// Small horizontal spacing
  static Widget get hSpaceSmall => const SizedBox(width: AppSpacing.sm);

  /// Medium horizontal spacing
  static Widget get hSpaceMedium => const SizedBox(width: AppSpacing.md);

  /// Large horizontal spacing
  static Widget get hSpaceLarge => const SizedBox(width: AppSpacing.lg);

  // ============================================================================
  // GRADIENT HELPERS
  // ============================================================================

  /// Get primary gradient
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get success gradient
  static LinearGradient get successGradient => LinearGradient(
        colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get custom gradient
  static LinearGradient customGradient({
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  // ============================================================================
  // THEME DETECTION HELPERS
  // ============================================================================

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Check if current theme is light
  static bool isLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  /// Get adaptive color based on theme
  static Color adaptive(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) {
    return isDark(context) ? dark : light;
  }

  // ============================================================================
  // ICON HELPERS
  // ============================================================================

  /// Get icon with color
  static Icon iconWithColor(IconData icon, Color color, {double? size}) {
    return Icon(icon, color: color, size: size);
  }

  /// Get small icon
  static Icon smallIcon(IconData icon, {Color? color}) {
    return Icon(icon, size: 16, color: color);
  }

  /// Get large icon
  static Icon largeIcon(IconData icon, {Color? color}) {
    return Icon(icon, size: 32, color: color);
  }
}

/// Example usage:
///
/// ```dart
/// // Spacing
/// Padding(
///   padding: ThemeHelper.screenPadding,
///   child: Column(
///     children: [
///       Text('Title'),
///       ThemeHelper.vSpaceMedium,
///       Text('Content'),
///     ],
///   ),
/// )
///
/// // Custom padding
/// Container(
///   padding: ThemeHelper.customPadding(
///     horizontal: AppSpacing.lg,
///     top: AppSpacing.xl,
///   ),
///   child: Text('Hello'),
/// )
///
/// // Border radius
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: ThemeHelper.largeRadius,
///     boxShadow: ThemeHelper.elevatedShadow,
///   ),
///   child: Text('Card'),
/// )
///
/// // Status colors
/// Container(
///   color: ThemeHelper.getStatusColor(TopicStatus.overdue),
///   child: Text('Overdue'),
/// )
///
/// // Text styles
/// Text(
///   'Important',
///   style: ThemeHelper.bold(AppTextStyles.bodyLarge),
/// )
///
/// Text(
///   'Note',
///   style: ThemeHelper.muted(context, AppTextStyles.bodyMedium),
/// )
///
/// // Progress color
/// LinearProgressIndicator(
///   value: 0.75,
///   color: ThemeHelper.getProgressColor(0.75),
/// )
///
/// // Adaptive color
/// Container(
///   color: ThemeHelper.adaptive(
///     context,
///     light: Colors.white,
///     dark: Colors.black,
///   ),
/// )
///
/// // Gradient
/// Container(
///   decoration: BoxDecoration(
///     gradient: ThemeHelper.primaryGradient,
///   ),
/// )
///
/// // Dividers
/// Column(
///   children: [
///     Text('Section 1'),
///     ThemeHelper.dividerWithSpacing(),
///     Text('Section 2'),
///   ],
/// )
/// ```
