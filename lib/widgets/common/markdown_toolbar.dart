import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/markdown_helper.dart';

/// Toolbar for markdown editing
class MarkdownToolbar extends StatelessWidget {
  /// Text controller for the markdown editor
  final TextEditingController controller;

  /// Callback for inserting links with dialog
  final VoidCallback? onInsertLink;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.onInsertLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.gray50,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gray700 : AppColors.gray300,
          ),
          bottom: BorderSide(
            color: isDark ? AppColors.gray700 : AppColors.gray300,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Bold',
              onPressed: () => MarkdownHelper.insertBold(controller),
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italic',
              onPressed: () => MarkdownHelper.insertItalic(controller),
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.title,
              tooltip: 'Heading 1',
              onPressed: () => MarkdownHelper.insertHeading(controller, level: 1),
            ),
            _ToolbarButton(
              icon: Icons.title,
              label: 'H2',
              tooltip: 'Heading 2',
              onPressed: () => MarkdownHelper.insertHeading(controller, level: 2),
              fontSize: 12,
            ),
            _ToolbarButton(
              icon: Icons.title,
              label: 'H3',
              tooltip: 'Heading 3',
              onPressed: () => MarkdownHelper.insertHeading(controller, level: 3),
              fontSize: 10,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Bullet List',
              onPressed: () => MarkdownHelper.insertBulletList(controller),
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Numbered List',
              onPressed: () => MarkdownHelper.insertNumberedList(controller),
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Inline Code',
              onPressed: () => MarkdownHelper.insertInlineCode(controller),
            ),
            _ToolbarButton(
              icon: Icons.code_off,
              tooltip: 'Code Block',
              onPressed: () => MarkdownHelper.insertCodeBlock(controller),
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Blockquote',
              onPressed: () => MarkdownHelper.insertBlockquote(controller),
            ),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Insert Link',
              onPressed: onInsertLink ??
                  () => MarkdownHelper.insertLink(controller),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual toolbar button
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String tooltip;
  final VoidCallback onPressed;
  final double? fontSize;

  const _ToolbarButton({
    required this.icon,
    this.label,
    required this.tooltip,
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: label != null
              ? Text(
                  label!,
                  style: TextStyle(
                    fontSize: fontSize ?? 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(icon, size: 20),
        ),
      ),
    );
  }
}

/// Vertical divider between toolbar sections
class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: 1,
      height: 24,
      color: isDark ? AppColors.gray700 : AppColors.gray300,
    );
  }
}
