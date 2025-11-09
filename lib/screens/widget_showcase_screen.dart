import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/topic_status_badge.dart';
import '../widgets/common/empty_state.dart';
import '../utils/theme_helper.dart';

/// Showcase screen demonstrating all reusable widgets
/// This is for development/testing purposes only
class WidgetShowcaseScreen extends StatelessWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Showcase'),
        elevation: 0,
      ),
      body: ListView(
        padding: ThemeHelper.screenPadding,
        children: [
          _buildSection(
            context,
            title: 'Custom Cards',
            children: [
              _buildCardsShowcase(),
            ],
          ),
          ThemeHelper.vSpaceXL,
          _buildSection(
            context,
            title: 'Custom Buttons',
            children: [
              _buildButtonsShowcase(),
            ],
          ),
          ThemeHelper.vSpaceXL,
          _buildSection(
            context,
            title: 'Status Badges',
            children: [
              _buildBadgesShowcase(),
            ],
          ),
          ThemeHelper.vSpaceXL,
          _buildSection(
            context,
            title: 'Empty States',
            children: [
              _buildEmptyStatesShowcase(context),
            ],
          ),
          ThemeHelper.vSpaceXL,
          _buildSection(
            context,
            title: 'Theme Helpers',
            children: [
              _buildThemeHelpersShowcase(context),
            ],
          ),
          ThemeHelper.vSpaceXL,
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ThemeHelper.bold(
            Theme.of(context).textTheme.titleLarge!,
          ),
        ),
        ThemeHelper.vSpaceMedium,
        ...children,
      ],
    );
  }

  Widget _buildCardsShowcase() {
    return Column(
      children: [
        // Basic card
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Card', style: AppTextStyles.titleMedium),
              ThemeHelper.vSpaceSmall,
              Text(
                'This is a basic card with default styling.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
        ThemeHelper.vSpaceMedium,

        // Card with tap action
        CustomCard(
          onTap: () {},
          borderColor: AppColors.primary,
          child: Row(
            children: [
              Icon(Icons.touch_app_rounded, color: AppColors.primary),
              ThemeHelper.hSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tappable Card', style: AppTextStyles.titleMedium),
                    ThemeHelper.vSpaceSmall,
                    Text(
                      'This card has an onTap action.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.gray400),
            ],
          ),
        ),
        ThemeHelper.vSpaceMedium,

        // Colored card
        CustomCard(
          color: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary,
          borderWidth: 2,
          elevation: 4,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: ThemeHelper.standardRadius,
                ),
                child: Icon(Icons.star, color: AppColors.white),
              ),
              ThemeHelper.hSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Featured Card', style: AppTextStyles.titleMedium),
                    ThemeHelper.vSpaceSmall,
                    Text(
                      'Custom colors and elevated shadow.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary buttons
        Text('Primary Buttons', style: AppTextStyles.labelLarge),
        ThemeHelper.vSpaceSmall,
        CustomButton.primary(
          text: 'Primary Button',
          onPressed: () {},
          icon: Icons.check,
        ),
        ThemeHelper.vSpaceSmall,
        CustomButton.primary(
          text: 'Loading...',
          isLoading: true,
        ),
        ThemeHelper.vSpaceSmall,
        CustomButton.primary(
          text: 'Disabled',
          onPressed: null,
        ),
        ThemeHelper.vSpaceMedium,

        // Secondary buttons
        Text('Secondary Buttons', style: AppTextStyles.labelLarge),
        ThemeHelper.vSpaceSmall,
        CustomButton.secondary(
          text: 'Secondary Button',
          onPressed: () {},
          icon: Icons.edit,
        ),
        ThemeHelper.vSpaceSmall,
        CustomButton.secondary(
          text: 'Small Size',
          onPressed: () {},
          size: CustomButtonSize.small,
        ),
        ThemeHelper.vSpaceMedium,

        // Text buttons
        Text('Text Buttons', style: AppTextStyles.labelLarge),
        ThemeHelper.vSpaceSmall,
        CustomButton.text(
          text: 'Text Button',
          onPressed: () {},
          icon: Icons.arrow_forward,
        ),
        ThemeHelper.vSpaceMedium,

        // Custom color button
        Text('Custom Colors', style: AppTextStyles.labelLarge),
        ThemeHelper.vSpaceSmall,
        CustomButton.primary(
          text: 'Delete Item',
          onPressed: () {},
          backgroundColor: AppColors.danger,
          icon: Icons.delete,
        ),
      ],
    );
  }

  Widget _buildBadgesShowcase() {
    return Column(
      children: [
        // All status types
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TopicStatusBadge(status: TopicStatus.overdue),
            TopicStatusBadge(status: TopicStatus.dueToday),
          ],
        ),
        ThemeHelper.vSpaceMedium,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TopicStatusBadge(status: TopicStatus.upcoming),
            TopicStatusBadge(status: TopicStatus.completed),
          ],
        ),
        ThemeHelper.vSpaceMedium,

        // Different sizes
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TopicStatusBadge(
              status: TopicStatus.overdue,
              size: BadgeSize.small,
            ),
            TopicStatusBadge(
              status: TopicStatus.dueToday,
              size: BadgeSize.medium,
            ),
            TopicStatusBadge(
              status: TopicStatus.upcoming,
              size: BadgeSize.large,
            ),
          ],
        ),
        ThemeHelper.vSpaceMedium,

        // Without icons
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            TopicStatusBadge(
              status: TopicStatus.overdue,
              showIcon: false,
              customLabel: 'Late',
            ),
            TopicStatusBadge(
              status: TopicStatus.upcoming,
              showIcon: false,
              customLabel: 'In 3 days',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyStatesShowcase(BuildContext context) {
    return Column(
      children: [
        // Using preset
        CustomCard(
          child: SizedBox(
            height: 300,
            child: EmptyStatePresets.noTopics(
              onAddTopic: () {},
            ),
          ),
        ),
        ThemeHelper.vSpaceMedium,

        // Custom empty state
        CustomCard(
          child: SizedBox(
            height: 300,
            child: EmptyState(
              icon: Icons.search_rounded,
              title: 'No Results',
              subtitle: 'Try adjusting your search',
              buttonText: 'Clear Search',
              onButtonPressed: () {},
              iconColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeHelpersShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spacing examples
        Text('Spacing', style: AppTextStyles.titleMedium),
        ThemeHelper.vSpaceSmall,
        Container(
          padding: ThemeHelper.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: ThemeHelper.largeRadius,
          ),
          child: Text('Card with theme helper padding'),
        ),
        ThemeHelper.vSpaceMedium,

        // Status colors
        Text('Status Colors', style: AppTextStyles.titleMedium),
        ThemeHelper.vSpaceSmall,
        Row(
          children: [
            _colorBox(
              ThemeHelper.getStatusColor(TopicStatus.overdue),
              'Overdue',
            ),
            ThemeHelper.hSpaceSmall,
            _colorBox(
              ThemeHelper.getStatusColor(TopicStatus.upcoming),
              'Upcoming',
            ),
            ThemeHelper.hSpaceSmall,
            _colorBox(
              ThemeHelper.getProgressColor(0.8),
              'Progress',
            ),
          ],
        ),
        ThemeHelper.vSpaceMedium,

        // Gradients
        Text('Gradients', style: AppTextStyles.titleMedium),
        ThemeHelper.vSpaceSmall,
        Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: ThemeHelper.primaryGradient,
            borderRadius: ThemeHelper.standardRadius,
          ),
          child: Center(
            child: Text(
              'Primary Gradient',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ),
        ThemeHelper.vSpaceMedium,

        // Shadows
        Text('Shadows', style: AppTextStyles.titleMedium),
        ThemeHelper.vSpaceSmall,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: ThemeHelper.standardRadius,
                  boxShadow: ThemeHelper.standardShadow,
                ),
                child: Center(child: Text('Standard')),
              ),
            ),
            ThemeHelper.hSpaceMedium,
            Expanded(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: ThemeHelper.standardRadius,
                  boxShadow: ThemeHelper.elevatedShadow,
                ),
                child: Center(child: Text('Elevated')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorBox(Color color, String label) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: ThemeHelper.standardRadius,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
