import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'add_topic_screen.dart';
import 'topics_list_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: const _MainNavigationView(),
    );
  }
}

class _MainNavigationView extends StatelessWidget {
  const _MainNavigationView();

  static final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const AddTopicScreen(),
    const TopicsListScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, navigationProvider),
      floatingActionButton: _buildFloatingActionButton(context, navigationProvider),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Build the bottom navigation bar with custom styling for center button
  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationProvider navigationProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                currentIndex: navigationProvider.currentIndex,
                onTap: () => navigationProvider.setIndex(0),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.calendar_today_rounded,
                label: 'Calendar',
                index: 1,
                currentIndex: navigationProvider.currentIndex,
                onTap: () => navigationProvider.setIndex(1),
              ),
              // Spacer for the FAB
              const SizedBox(width: 60),
              _buildNavItem(
                context: context,
                icon: Icons.topic_rounded,
                label: 'Topics',
                index: 3,
                currentIndex: navigationProvider.currentIndex,
                onTap: () => navigationProvider.setIndex(3),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings_rounded,
                label: 'Settings',
                index: 4,
                currentIndex: navigationProvider.currentIndex,
                onTap: () => navigationProvider.setIndex(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual navigation item
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.bottomNavigationBarTheme.selectedItemColor ?? AppColors.primary
        : theme.bottomNavigationBarTheme.unselectedItemColor ?? AppColors.gray400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: (isSelected
                      ? theme.bottomNavigationBarTheme.selectedLabelStyle
                      : theme.bottomNavigationBarTheme.unselectedLabelStyle) ??
                  AppTextStyles.labelSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// Build elevated floating action button for Add Topic
  Widget _buildFloatingActionButton(
    BuildContext context,
    NavigationProvider navigationProvider,
  ) {
    final isSelected = navigationProvider.currentIndex == 2;

    return FloatingActionButton(
      onPressed: () => navigationProvider.setIndex(2),
      elevation: isSelected ? 8 : 6,
      backgroundColor: isSelected ? AppColors.secondary : AppColors.primary,
      child: Icon(
        Icons.add_rounded,
        size: 32,
        color: AppColors.white,
      ),
    );
  }
}
