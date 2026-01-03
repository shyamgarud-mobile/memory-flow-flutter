import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/navigation_provider.dart';
import '../services/notification_service.dart';
import '../widgets/common/figma_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'add_topic_screen.dart';
import 'topics_list_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _setupNotificationHandler();
  }

  /// Set up notification tap handler for navigation
  void _setupNotificationHandler() {
    _notificationService.onNotificationTap = (payload) {
      if (!mounted) return;

      final navigationProvider = context.read<NavigationProvider>();

      if (payload != null && payload.startsWith('topic:')) {
        // Navigate to home screen to show the specific topic
        // The topic ID is extracted from the payload
        navigationProvider.setIndex(0);
        // TODO: Navigate to topic detail screen when implemented
        print('Navigate to topic: ${payload.substring(6)}');
      } else if (payload == 'daily_reminder') {
        // Navigate to home screen for daily review
        navigationProvider.setIndex(0);
      } else {
        // Default: navigate to home
        navigationProvider.setIndex(0);
      }
    };
  }

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
      bottomNavigationBar: FigmaBottomNavBar(
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) => navigationProvider.setIndex(index),
        items: const [
          FigmaBottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          FigmaBottomNavItem(
            icon: Icons.calendar_today_rounded,
            label: 'Calendar',
          ),
          FigmaBottomNavItem(
            icon: Icons.add_circle_rounded,
            label: 'Add',
          ),
          FigmaBottomNavItem(
            icon: Icons.topic_rounded,
            label: 'Topics',
          ),
          FigmaBottomNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

}
