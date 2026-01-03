import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Figma-style bottom navigation bar with icons and labels
///
/// Design specs:
/// - Height: 80px (60px content + 20px safe area padding)
/// - Icon size: 24px
/// - Label: 12px medium weight
/// - Spacing: 4px between icon and label
/// - Active color: primary from theme
/// - Inactive color: #8E8E93 (gray)
class FigmaBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FigmaBottomNavItem> items;

  const FigmaBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gray700 : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70, // Increased from 60 to accommodate icon + label + padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                context: context,
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required FigmaBottomNavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Figma-style colors
    final activeColor = primaryColor;
    final inactiveColor = const Color(0xFF8E8E93); // iOS gray

    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  color: color,
                  size: 24, // Figma spec: consistent 24px
                ),
                const SizedBox(height: 2), // Reduced from 4px to save space
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11, // Reduced from 12px to fit better
                    fontWeight: FontWeight.w500, // Medium weight
                    letterSpacing: 0,
                    height: 1.0, // Tight line height
                  ).copyWith(color: color),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item for FigmaBottomNavBar
class FigmaBottomNavItem {
  final IconData icon;
  final String label;

  const FigmaBottomNavItem({
    required this.icon,
    required this.label,
  });
}
