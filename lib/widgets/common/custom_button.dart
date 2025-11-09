import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Button types
enum CustomButtonType {
  primary,
  secondary,
  text,
}

/// Reusable custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  /// Button text label
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button type (primary, secondary, text)
  final CustomButtonType type;

  /// Optional icon to show before text
  final IconData? icon;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Whether the button should expand to full width
  final bool fullWidth;

  /// Custom background color (overrides type default)
  final Color? backgroundColor;

  /// Custom text color (overrides type default)
  final Color? textColor;

  /// Button size
  final CustomButtonSize size;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.size = CustomButtonSize.medium,
  });

  /// Create a primary button
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.size = CustomButtonSize.medium,
  }) : type = CustomButtonType.primary;

  /// Create a secondary button
  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.size = CustomButtonSize.medium,
  }) : type = CustomButtonType.secondary;

  /// Create a text button
  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.size = CustomButtonSize.medium,
  }) : type = CustomButtonType.text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    // Get padding based on size
    EdgeInsets padding;
    TextStyle textStyle;
    double iconSize;

    switch (size) {
      case CustomButtonSize.small:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
        textStyle = AppTextStyles.labelMedium;
        iconSize = 18;
        break;
      case CustomButtonSize.medium:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
        textStyle = AppTextStyles.labelLarge;
        iconSize = 20;
        break;
      case CustomButtonSize.large:
        padding = const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md + 4,
        );
        textStyle = AppTextStyles.titleMedium;
        iconSize = 24;
        break;
    }

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(theme),
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: iconSize),
        if (icon != null || isLoading) const SizedBox(width: AppSpacing.sm),
        Text(text, style: textStyle),
      ],
    );

    switch (type) {
      case CustomButtonType.primary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primary,
              foregroundColor: textColor ?? AppColors.white,
              disabledBackgroundColor: AppColors.gray300,
              disabledForegroundColor: AppColors.gray500,
              padding: padding,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: buttonChild,
          ),
        );

      case CustomButtonType.secondary:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? AppColors.primary,
              disabledForegroundColor: AppColors.gray400,
              padding: padding,
              side: BorderSide(
                color: isDisabled
                    ? AppColors.gray300
                    : (backgroundColor ?? AppColors.primary),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: buttonChild,
          ),
        );

      case CustomButtonType.text:
        return SizedBox(
          width: fullWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: textColor ?? AppColors.primary,
              disabledForegroundColor: AppColors.gray400,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (textColor != null) return textColor!;

    switch (type) {
      case CustomButtonType.primary:
        return AppColors.white;
      case CustomButtonType.secondary:
      case CustomButtonType.text:
        return backgroundColor ?? AppColors.primary;
    }
  }
}

/// Button size variants
enum CustomButtonSize {
  small,
  medium,
  large,
}

/// Example usage:
///
/// ```dart
/// // Primary button
/// CustomButton.primary(
///   text: 'Save',
///   onPressed: () => print('Saved'),
///   icon: Icons.save,
/// )
///
/// // Secondary button
/// CustomButton.secondary(
///   text: 'Cancel',
///   onPressed: () => print('Cancelled'),
/// )
///
/// // Text button
/// CustomButton.text(
///   text: 'Learn More',
///   onPressed: () => print('Learn more'),
///   icon: Icons.arrow_forward,
/// )
///
/// // Loading state
/// CustomButton.primary(
///   text: 'Submitting...',
///   isLoading: true,
/// )
///
/// // Full width button
/// CustomButton.primary(
///   text: 'Get Started',
///   onPressed: () => print('Started'),
///   fullWidth: true,
///   size: CustomButtonSize.large,
/// )
///
/// // Disabled button (onPressed = null)
/// CustomButton.primary(
///   text: 'Submit',
///   onPressed: null,
/// )
///
/// // Custom colors
/// CustomButton.primary(
///   text: 'Delete',
///   onPressed: () => print('Deleted'),
///   backgroundColor: AppColors.danger,
///   icon: Icons.delete,
/// )
///
/// // Small secondary button
/// CustomButton.secondary(
///   text: 'Edit',
///   onPressed: () => print('Edit'),
///   icon: Icons.edit,
///   size: CustomButtonSize.small,
/// )
/// ```
