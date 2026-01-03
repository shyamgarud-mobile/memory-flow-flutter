import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';

/// Figma-style AppBar with clean, minimal design
///
/// Design specs:
/// - Height: 56px (standard)
/// - No elevation (flat design)
/// - Bottom border: 1px subtle divider
/// - Back button: iOS chevron-left or Android arrow-back
/// - Title: 18px semibold
/// - Action icons: 24px
/// - Background: matches scaffold background (transparent effect)
class FigmaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBottomBorder;

  const FigmaAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false, // Android-style by default
    this.backgroundColor,
    this.foregroundColor,
    this.showBottomBorder = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background color: transparent/scaffold background for clean look
    final bgColor = backgroundColor ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);

    final fgColor = foregroundColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    // Check if we can pop (has previous route)
    final canPop = Navigator.canPop(context);

    return Container(
      decoration: showBottomBorder
          ? BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.gray700 : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            )
          : BoxDecoration(color: bgColor),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSpacing.appBarHeight,
        centerTitle: centerTitle,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,

        // Leading: Back button
        leading: (showBackButton && canPop)
            ? IconButton(
                icon: Icon(
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Icons.chevron_left_rounded
                      : Icons.arrow_back_rounded,
                  size: 24,
                  color: fgColor,
                ),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: showBackButton,

        // Title
        title: titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                      letterSpacing: -0.3,
                    ),
                  )
                : null),

        // Actions
        actions: actions
            ?.map((action) => _wrapAction(action, fgColor))
            .toList(),
      ),
    );
  }

  /// Wrap action widget to ensure consistent sizing and color
  Widget _wrapAction(Widget action, Color color) {
    if (action is IconButton) {
      return action;
    }
    return action;
  }
}

/// Helper method to create consistent action buttons
class FigmaAppBarAction {
  /// Create an icon button action
  static Widget icon({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    String? tooltip,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final iconColor = color ??
            (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

        return IconButton(
          icon: Icon(icon, size: 24, color: iconColor),
          onPressed: onPressed,
          tooltip: tooltip,
          padding: const EdgeInsets.all(12),
        );
      },
    );
  }

  /// Create a text button action
  static Widget text({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final textColor = color ??
            (isDark ? AppColors.primary : AppColors.primary);

        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
