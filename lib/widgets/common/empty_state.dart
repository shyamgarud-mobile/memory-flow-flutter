import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'custom_button.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Main title text
  final String title;

  /// Subtitle/description text
  final String subtitle;

  /// Optional button text
  final String? buttonText;

  /// Optional button callback
  final VoidCallback? onButtonPressed;

  /// Optional secondary button text
  final String? secondaryButtonText;

  /// Optional secondary button callback
  final VoidCallback? onSecondaryButtonPressed;

  /// Icon color (default: gray)
  final Color? iconColor;

  /// Icon size (default: 80)
  final double iconSize;

  /// Whether to show illustration background
  final bool showBackground;

  /// Maximum width of content
  final double maxWidth;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.iconColor,
    this.iconSize = 80,
    this.showBackground = true,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ??
        theme.textTheme.bodySmall?.color?.withOpacity(0.4) ??
        AppColors.gray400;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon with optional background
              _buildIcon(effectiveIconColor),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),

              // Buttons
              if (buttonText != null || secondaryButtonText != null) ...[
                const SizedBox(height: AppSpacing.xl),
                _buildButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (showBackground) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      );
    }

    return Icon(
      icon,
      size: iconSize,
      color: color,
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        if (buttonText != null)
          CustomButton.primary(
            text: buttonText!,
            onPressed: onButtonPressed,
            fullWidth: true,
          ),
        if (secondaryButtonText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          CustomButton.text(
            text: secondaryButtonText!,
            onPressed: onSecondaryButtonPressed,
            fullWidth: true,
          ),
        ],
      ],
    );
  }
}

/// Predefined empty state configurations
class EmptyStatePresets {
  /// No topics found
  static Widget noTopics({
    VoidCallback? onAddTopic,
  }) {
    return EmptyState(
      icon: Icons.topic_outlined,
      title: 'No Topics Yet',
      subtitle: 'Create your first topic to start learning and reviewing',
      buttonText: 'Add Topic',
      onButtonPressed: onAddTopic,
    );
  }

  /// No search results
  static Widget noSearchResults({
    String? searchQuery,
    VoidCallback? onClearSearch,
  }) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      subtitle: searchQuery != null
          ? 'No topics match "$searchQuery"'
          : 'Try adjusting your search criteria',
      buttonText: onClearSearch != null ? 'Clear Search' : null,
      onButtonPressed: onClearSearch,
      iconColor: AppColors.gray400,
    );
  }

  /// No reviews today
  static Widget noReviewsToday({
    VoidCallback? onBrowseTopics,
  }) {
    return EmptyState(
      icon: Icons.check_circle_outline_rounded,
      title: 'All Caught Up!',
      subtitle: 'You have no reviews scheduled for today. Great job!',
      buttonText: 'Browse Topics',
      onButtonPressed: onBrowseTopics,
      iconColor: AppColors.success,
    );
  }

  /// No flashcards in topic
  static Widget noFlashcards({
    VoidCallback? onAddFlashcard,
  }) {
    return EmptyState(
      icon: Icons.style_outlined,
      title: 'No Flashcards',
      subtitle: 'Add flashcards to this topic to start learning',
      buttonText: 'Add Flashcard',
      onButtonPressed: onAddFlashcard,
    );
  }

  /// Connection error
  static Widget connectionError({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Connection Error',
      subtitle: 'Unable to connect to the server. Please check your internet connection.',
      buttonText: 'Retry',
      onButtonPressed: onRetry,
      iconColor: AppColors.danger,
    );
  }

  /// Something went wrong
  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Something Went Wrong',
      subtitle: message ?? 'An unexpected error occurred. Please try again.',
      buttonText: 'Try Again',
      onButtonPressed: onRetry,
      iconColor: AppColors.danger,
    );
  }

  /// Coming soon
  static Widget comingSoon({String? feature}) {
    return EmptyState(
      icon: Icons.rocket_launch_rounded,
      title: 'Coming Soon',
      subtitle: feature != null
          ? '$feature is coming soon!'
          : 'This feature is under development',
      iconColor: AppColors.primary,
      showBackground: true,
    );
  }
}

/// Example usage:
///
/// ```dart
/// // Basic empty state
/// EmptyState(
///   icon: Icons.folder_open_rounded,
///   title: 'No Items Found',
///   subtitle: 'Start by adding your first item',
///   buttonText: 'Add Item',
///   onButtonPressed: () => print('Add item'),
/// )
///
/// // With secondary button
/// EmptyState(
///   icon: Icons.inbox_rounded,
///   title: 'Inbox Empty',
///   subtitle: 'All your tasks are complete',
///   buttonText: 'Create Task',
///   onButtonPressed: () => print('Create'),
///   secondaryButtonText: 'View Archive',
///   onSecondaryButtonPressed: () => print('Archive'),
/// )
///
/// // Using presets
/// EmptyStatePresets.noTopics(
///   onAddTopic: () => Navigator.push(...),
/// )
///
/// EmptyStatePresets.noSearchResults(
///   searchQuery: 'Flutter',
///   onClearSearch: () => searchController.clear(),
/// )
///
/// EmptyStatePresets.noReviewsToday(
///   onBrowseTopics: () => Navigator.push(...),
/// )
///
/// EmptyStatePresets.connectionError(
///   onRetry: () => fetchData(),
/// )
///
/// EmptyStatePresets.comingSoon(
///   feature: 'Statistics Dashboard',
/// )
///
/// // Custom styling
/// EmptyState(
///   icon: Icons.star_outline_rounded,
///   title: 'No Favorites',
///   subtitle: 'Items you favorite will appear here',
///   iconColor: AppColors.warning,
///   iconSize: 120,
///   showBackground: false,
///   maxWidth: 300,
/// )
/// ```
