import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Figma-style primary button with pill shape
///
/// Design specs:
/// - Height: 56px
/// - Border radius: 24px (pill-shaped)
/// - Font: 16px semibold
/// - Horizontal padding: 24px
/// - Shadow: 0 4px 12px rgba(primary, 0.2)
/// - States: normal, pressed, disabled
///
/// Usage:
/// ```dart
/// FigmaButton(
///   text: 'Save',
///   onPressed: () => _handleSave(),
/// )
/// ```
class FigmaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FigmaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final fgColor = foregroundColor ?? Colors.white;
    final isDisabled = onPressed == null && !isLoading;

    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: fgColor),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0,
                ),
              );

    return SizedBox(
      height: height ?? AppSpacing.buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.gray500,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Figma-style outlined button
///
/// Design specs:
/// - Height: 56px
/// - Border radius: 24px (pill-shaped)
/// - Border: 2px solid
/// - Font: 16px semibold
/// - Transparent background
///
/// Usage:
/// ```dart
/// FigmaOutlinedButton(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class FigmaOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? borderColor;
  final Color? foregroundColor;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FigmaOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderColor,
    this.foregroundColor,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = borderColor ?? theme.primaryColor;
    final fgColor = foregroundColor ?? color;
    final isDisabled = onPressed == null && !isLoading;

    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: fgColor),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0,
                ),
              );

    return SizedBox(
      height: height ?? AppSpacing.buttonHeight,
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          disabledForegroundColor: AppColors.gray400,
          side: BorderSide(
            color: isDisabled ? AppColors.gray300 : color,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.button),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Figma-style text button
///
/// Design specs:
/// - Height: 48px (slightly smaller)
/// - No background
/// - No border
/// - Font: 16px semibold
/// - Ripple effect on tap
///
/// Usage:
/// ```dart
/// FigmaTextButton(
///   text: 'Skip',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class FigmaTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const FigmaTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fgColor = color ?? theme.primaryColor;
    final isDisabled = onPressed == null && !isLoading;

    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: fgColor),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                  letterSpacing: 0,
                ),
              );

    return SizedBox(
      height: height ?? 48,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: fgColor,
          disabledForegroundColor: AppColors.gray400,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
        ),
        child: buttonChild,
      ),
    );
  }
}
