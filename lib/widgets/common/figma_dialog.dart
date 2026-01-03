import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Figma-style dialog with clean, minimal design
///
/// Design specs:
/// - Border radius: 16px
/// - Padding: 24px
/// - Title: 20px semibold
/// - Content: 16px regular
/// - Actions: Row layout with spacing
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => FigmaDialog(
///     title: 'Delete Item',
///     content: Text('Are you sure you want to delete this item?'),
///     actions: [
///       FigmaTextButton(text: 'Cancel', onPressed: () => Navigator.pop(context)),
///       FigmaButton(text: 'Delete', onPressed: () => _handleDelete()),
///     ],
///   ),
/// )
/// ```
class FigmaDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final Color? backgroundColor;
  final bool dismissible;

  const FigmaDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.actions,
    this.contentPadding,
    this.actionsPadding,
    this.backgroundColor,
    this.dismissible = true,
  }) : assert(
          title != null || titleWidget != null,
          'Either title or titleWidget must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: backgroundColor ??
          (isDark ? AppColors.surfaceDark : AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            if (titleWidget != null)
              titleWidget!
            else if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),

            // Content
            if (content != null) ...[
              const SizedBox(height: AppSpacing.md),
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ) ??
                    const TextStyle(),
                child: Padding(
                  padding: contentPadding ?? EdgeInsets.zero,
                  child: content!,
                ),
              ),
            ],

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: actionsPadding ?? EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      actions![i],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Figma-style confirmation dialog
///
/// Design specs:
/// - Preset layout for confirm/cancel actions
/// - Danger variant for destructive actions
/// - Optional icon support
///
/// Usage:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (context) => FigmaConfirmDialog(
///     title: 'Delete Item',
///     message: 'Are you sure you want to delete this item? This cannot be undone.',
///     confirmText: 'Delete',
///     isDanger: true,
///     onConfirm: () => Navigator.pop(context, true),
///   ),
/// );
/// ```
class FigmaConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;
  final IconData? icon;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const FigmaConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDanger = false,
    this.icon,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (optional)
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: isDanger ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel ?? () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.button),
                      ),
                      side: BorderSide(
                        color: isDark ? AppColors.gray700 : AppColors.gray300,
                        width: 2,
                      ),
                    ),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm ?? () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: isDanger ? AppColors.error : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppBorderRadius.button),
                      ),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma-style loading dialog
///
/// Design specs:
/// - Centered loading indicator
/// - Optional message
/// - Non-dismissible by default
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (context) => FigmaLoadingDialog(
///     message: 'Loading...',
///   ),
/// );
/// ```
class FigmaLoadingDialog extends StatelessWidget {
  final String? message;
  final String? subtitle;

  const FigmaLoadingDialog({
    super.key,
    this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
