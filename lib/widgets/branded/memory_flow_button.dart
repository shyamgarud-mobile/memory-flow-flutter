import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// MemoryFlow Branded Button System
///
/// Consistent button styling across the app.
/// Supports primary, secondary, outlined, text, and icon variants.
///
/// **Usage:**
/// ```dart
/// MemoryFlowButton.primary(
///   label: 'Start Review',
///   icon: Icons.play_arrow,
///   onPressed: () => startReview(),
/// )
/// ```

enum MemoryFlowButtonSize {
  small,
  medium,
  large,
}

class MemoryFlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final MemoryFlowButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final bool fullWidth;
  final Widget? trailing;

  const MemoryFlowButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = MemoryFlowButtonSize.medium,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.fullWidth = false,
    this.trailing,
  });

  /// Primary button - Main actions
  factory MemoryFlowButton.primary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    MemoryFlowButtonSize size = MemoryFlowButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return MemoryFlowButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      size: size,
      backgroundColor: MemoryFlowDesign.primaryBlue,
      textColor: Colors.white,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  /// Secondary button - Secondary actions
  factory MemoryFlowButton.secondary({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    MemoryFlowButtonSize size = MemoryFlowButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return MemoryFlowButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      size: size,
      backgroundColor: MemoryFlowDesign.primaryBlue.withOpacity(0.1),
      textColor: MemoryFlowDesign.primaryBlue,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  /// Success button - Positive actions
  factory MemoryFlowButton.success({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    MemoryFlowButtonSize size = MemoryFlowButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return MemoryFlowButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      size: size,
      backgroundColor: MemoryFlowDesign.successGreen,
      textColor: Colors.white,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  /// Danger button - Destructive actions
  factory MemoryFlowButton.danger({
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    MemoryFlowButtonSize size = MemoryFlowButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return MemoryFlowButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      size: size,
      backgroundColor: MemoryFlowDesign.errorRed,
      textColor: Colors.white,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  double _getHeight() {
    switch (size) {
      case MemoryFlowButtonSize.small:
        return 36;
      case MemoryFlowButtonSize.large:
        return 56;
      case MemoryFlowButtonSize.medium:
      default:
        return 48;
    }
  }

  double _getFontSize() {
    switch (size) {
      case MemoryFlowButtonSize.small:
        return 13;
      case MemoryFlowButtonSize.large:
        return 16;
      case MemoryFlowButtonSize.medium:
      default:
        return 14;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case MemoryFlowButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case MemoryFlowButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24);
      case MemoryFlowButtonSize.medium:
      default:
        return const EdgeInsets.symmetric(horizontal: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: MemoryFlowDesign.radiusSmall,
          ),
          padding: _getPadding(),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: _getFontSize() + 4),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}

/// Outlined Button
class MemoryFlowOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final MemoryFlowButtonSize size;
  final Color? borderColor;
  final bool fullWidth;

  const MemoryFlowOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = MemoryFlowButtonSize.medium,
    this.borderColor,
    this.fullWidth = false,
  });

  double _getHeight() {
    switch (size) {
      case MemoryFlowButtonSize.small:
        return 36;
      case MemoryFlowButtonSize.large:
        return 56;
      case MemoryFlowButtonSize.medium:
      default:
        return 48;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? MemoryFlowDesign.primaryBlue;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: MemoryFlowDesign.radiusSmall,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon Button
class MemoryFlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final String? tooltip;

  const MemoryFlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size ?? 40,
      height: size ?? 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? MemoryFlowDesign.primaryBlue.withOpacity(0.1),
        borderRadius: MemoryFlowDesign.radiusSmall,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color ?? MemoryFlowDesign.primaryBlue,
        iconSize: (size ?? 40) * 0.5,
        onPressed: onPressed,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Floating Action Button
class MemoryFlowFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;

  const MemoryFlowFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? MemoryFlowDesign.primaryBlue,
        icon: Icon(icon),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? MemoryFlowDesign.primaryBlue,
      child: Icon(icon),
    );
  }
}
