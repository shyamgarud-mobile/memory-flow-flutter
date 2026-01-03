import 'package:flutter/material.dart';

/// MemoryFlow Design System
///
/// Centralized design tokens for consistent branding across the app.
/// Includes colors, typography, spacing, shadows, and component styles.
///
/// **Usage:**
/// ```dart
/// Container(
///   decoration: MemoryFlowDesign.cardDecoration(context),
///   padding: MemoryFlowDesign.paddingMedium,
///   child: Text('Hello', style: MemoryFlowDesign.heading2(context)),
/// )
/// ```

class MemoryFlowDesign {
  // ============================================================================
  // BRAND COLORS
  // ============================================================================

  /// Primary brand color - Trust & Intelligence
  static const Color primaryBlue = Color(0xFF4A9FD8);

  /// Secondary brand color - Energy & Growth
  static const Color accentOrange = Color(0xFFF59E0B);

  /// Success - Learning & Achievement
  static const Color successGreen = Color(0xFF10B981);

  /// Warning - Attention & Urgency
  static const Color warningAmber = Color(0xFFF59E0B);

  /// Error - Critical & Important
  static const Color errorRed = Color(0xFFEF4444);

  /// Info - Helpful & Neutral
  static const Color infoBlue = Color(0xFF3B82F6);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A9FD8), Color(0xFF3B82F6)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  /// Display - Extra large text (32px)
  static TextStyle display(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      letterSpacing: -0.5,
    );
  }

  /// Heading 1 - Page titles (24px)
  static TextStyle heading1(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      letterSpacing: -0.3,
    );
  }

  /// Heading 2 - Section titles (20px)
  static TextStyle heading2(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  /// Heading 3 - Subsection titles (18px)
  static TextStyle heading3(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  /// Body Large - Main content (16px)
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
    );
  }

  /// Body - Standard content (14px)
  static TextStyle body(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
    );
  }

  /// Caption - Secondary info (12px)
  static TextStyle caption(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.4,
      color: color ?? Theme.of(context).textTheme.bodySmall?.color,
    );
  }

  /// Label - Small labels (11px)
  static TextStyle label(BuildContext context, {Color? color}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: color ?? Theme.of(context).textTheme.bodySmall?.color,
      letterSpacing: 0.5,
    );
  }

  // ============================================================================
  // SPACING
  // ============================================================================

  static const EdgeInsets paddingTiny = EdgeInsets.all(4);
  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(32);

  static const double spaceTiny = 4;
  static const double spaceSmall = 8;
  static const double spaceMedium = 16;
  static const double spaceLarge = 24;
  static const double spaceXLarge = 32;
  static const double spaceXXLarge = 48;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusCircle = BorderRadius.all(Radius.circular(9999));

  // ============================================================================
  // SHADOWS (Figma-style - softer with larger blur radius)
  // ============================================================================

  static List<BoxShadow> shadowSmall(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.3)
            : Colors.black.withOpacity(0.08),
        blurRadius: 8, // Increased from 4
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> shadowMedium(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.4)
            : Colors.black.withOpacity(0.12), // Slightly increased opacity
        blurRadius: 16, // Increased from 8
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> shadowLarge(BuildContext context) {
    return [
      BoxShadow(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.5)
            : Colors.black.withOpacity(0.16), // Slightly increased opacity
        blurRadius: 24, // Increased from 16
        offset: const Offset(0, 8),
      ),
    ];
  }

  // ============================================================================
  // CARD DECORATIONS
  // ============================================================================

  /// Standard card decoration
  static BoxDecoration cardDecoration(BuildContext context, {Color? color}) {
    return BoxDecoration(
      color: color ?? (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1F2937)
          : Colors.white),
      borderRadius: radiusMedium,
      boxShadow: shadowSmall(context),
    );
  }

  /// Elevated card decoration
  static BoxDecoration elevatedCardDecoration(BuildContext context, {Color? color}) {
    return BoxDecoration(
      color: color ?? (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1F2937)
          : Colors.white),
      borderRadius: radiusMedium,
      boxShadow: shadowMedium(context),
    );
  }

  /// Gradient card decoration
  static BoxDecoration gradientCardDecoration(BuildContext context, {Gradient? gradient}) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      borderRadius: radiusMedium,
      boxShadow: shadowMedium(context),
    );
  }

  /// Outlined card decoration
  static BoxDecoration outlinedCardDecoration(BuildContext context, {Color? borderColor}) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1F2937)
          : Colors.white,
      borderRadius: radiusMedium,
      border: Border.all(
        color: borderColor ?? (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[300]!),
        width: 1.5,
      ),
    );
  }

  // ============================================================================
  // ICON SIZES
  // ============================================================================

  static const double iconTiny = 16;
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;
  static const double iconXXLarge = 64;

  // ============================================================================
  // ANIMATION DURATIONS
  // ============================================================================

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get semantic color based on context
  static Color getSemanticColor(String type) {
    switch (type) {
      case 'success':
        return successGreen;
      case 'warning':
        return warningAmber;
      case 'error':
        return errorRed;
      case 'info':
        return infoBlue;
      default:
        return primaryBlue;
    }
  }

  /// Get stage color for spaced repetition
  static Color getStageColor(int stage) {
    switch (stage) {
      case 0:
        return errorRed; // New
      case 1:
        return warningAmber; // 1 day
      case 2:
        return infoBlue; // 3 days
      case 3:
        return Color(0xFF8B5CF6); // 1 week (purple)
      case 4:
        return successGreen; // 2 weeks
      default:
        return successGreen;
    }
  }
}
