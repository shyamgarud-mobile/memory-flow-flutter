import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/theme_helper.dart';
import 'main_navigation.dart';

/// Key for storing onboarding completion status
const String _onboardingCompleteKey = 'onboarding_complete';

/// Onboarding screen shown to first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.psychology_rounded,
      title: 'Remember Everything',
      description: 'Use spaced repetition to remember what you learn forever. '
          'Review at optimal intervals to maximize retention.',
      color: AppColors.primary,
    ),
    OnboardingPageData(
      icon: Icons.calendar_month_rounded,
      title: 'Smart Scheduling',
      description: 'Reviews at optimal intervals: 1 day, 3 days, 1 week, '
          '2 weeks, 1 month. The app schedules everything automatically.',
      color: AppColors.success,
    ),
    OnboardingPageData(
      icon: Icons.cloud_done_rounded,
      title: 'Backup to Cloud',
      description: 'Keep your topics safe with Google Drive backup. '
          'Sync across devices and never lose your data.',
      color: AppColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),

            // Navigation button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started!'
                        : 'Next',
                  ),
                ),
              ),
            ),

            ThemeHelper.vSpaceMedium,
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),

          ThemeHelper.vSpaceXLarge,

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          ThemeHelper.vSpaceMedium,

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Data model for onboarding page
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

/// Check if onboarding has been completed
Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_onboardingCompleteKey) ?? false;
}
