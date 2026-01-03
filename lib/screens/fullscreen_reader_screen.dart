import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_constants.dart';

/// Fullscreen reader for topic content
class FullscreenReaderScreen extends StatelessWidget {
  final String title;
  final String content;

  const FullscreenReaderScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.white,
      appBar: AppBar(
        title: const Text('Reading Mode'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Exit fullscreen',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Content
              MarkdownBody(
                data: content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  h1: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  h2: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  h3: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  p: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.8,
                    fontSize: 16,
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    backgroundColor: isDark ? AppColors.gray800 : AppColors.gray100,
                    color: AppColors.danger,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isDark ? AppColors.gray800 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: isDark ? AppColors.gray700 : AppColors.gray300,
                    ),
                  ),
                  codeblockPadding: const EdgeInsets.all(AppSpacing.md),
                  blockquote: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 16,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 4,
                      ),
                    ),
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                  blockquotePadding: const EdgeInsets.all(AppSpacing.md),
                  listBullet: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  listIndent: 24,
                  h1Padding: const EdgeInsets.only(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.md,
                  ),
                  h2Padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  h3Padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  pPadding: const EdgeInsets.only(bottom: AppSpacing.md),
                ),
              ),

              // Bottom spacing
              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }
}
