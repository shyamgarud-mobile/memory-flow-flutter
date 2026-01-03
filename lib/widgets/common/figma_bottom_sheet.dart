import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Figma-style bottom sheet with clean, minimal design
///
/// Design specs:
/// - Border radius: 16px (top corners only)
/// - Handle: 4px x 32px rounded indicator
/// - Padding: 24px
/// - Max height: 90% of screen
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => FigmaBottomSheet(
///     title: 'Options',
///     child: Column(
///       children: [
///         ListTile(title: Text('Option 1')),
///         ListTile(title: Text('Option 2')),
///       ],
///     ),
///   ),
/// );
/// ```
class FigmaBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget child;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;

  const FigmaBottomSheet({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.showHandle = true,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? screenHeight * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.dialog),
          topRight: Radius.circular(AppBorderRadius.dialog),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          if (showHandle) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.gray700 : AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Title
          if (title != null || titleWidget != null) ...[
            Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
              child: titleWidget ??
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
            ),
          ],

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
              child: child,
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Helper function to show Figma bottom sheet
///
/// Usage:
/// ```dart
/// showFigmaBottomSheet(
///   context: context,
///   title: 'Options',
///   builder: (context) => Column(
///     children: [
///       ListTile(title: Text('Option 1')),
///       ListTile(title: Text('Option 2')),
///     ],
///   ),
/// );
/// ```
Future<T?> showFigmaBottomSheet<T>({
  required BuildContext context,
  String? title,
  Widget? titleWidget,
  required Widget Function(BuildContext) builder,
  bool showHandle = true,
  EdgeInsetsGeometry? padding,
  double? maxHeight,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor ?? Colors.transparent,
    builder: (context) => FigmaBottomSheet(
      title: title,
      titleWidget: titleWidget,
      showHandle: showHandle,
      padding: padding,
      maxHeight: maxHeight,
      child: builder(context),
    ),
  );
}

/// Figma-style list bottom sheet with options
///
/// Design specs:
/// - List of tappable options
/// - Optional icons and subtitles
/// - Optional danger variant for destructive actions
///
/// Usage:
/// ```dart
/// showFigmaListBottomSheet(
///   context: context,
///   title: 'Quick Actions',
///   items: [
///     FigmaBottomSheetItem(
///       icon: Icons.edit,
///       title: 'Edit',
///       onTap: () => _handleEdit(),
///     ),
///     FigmaBottomSheetItem(
///       icon: Icons.delete,
///       title: 'Delete',
///       isDanger: true,
///       onTap: () => _handleDelete(),
///     ),
///   ],
/// );
/// ```
class FigmaBottomSheetItem {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool isDanger;
  final VoidCallback onTap;

  const FigmaBottomSheetItem({
    this.icon,
    required this.title,
    this.subtitle,
    this.isDanger = false,
    required this.onTap,
  });
}

Future<void> showFigmaListBottomSheet({
  required BuildContext context,
  String? title,
  required List<FigmaBottomSheetItem> items,
}) {
  return showFigmaBottomSheet(
    context: context,
    title: title,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return _FigmaBottomSheetListTile(item: item);
      }).toList(),
    ),
  );
}

class _FigmaBottomSheetListTile extends StatelessWidget {
  final FigmaBottomSheetItem item;

  const _FigmaBottomSheetListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = item.isDanger
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
