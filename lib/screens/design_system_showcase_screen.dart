import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import '../widgets/branded/memory_flow_card.dart';
import '../widgets/branded/memory_flow_stat_widget.dart';
import '../widgets/branded/memory_flow_button.dart';

/// Design System Showcase Screen
///
/// Demonstrates all MemoryFlow branded components with examples.
/// Reference for developers to maintain consistency.
class DesignSystemShowcaseScreen extends StatelessWidget {
  const DesignSystemShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoryFlow Design System'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: MemoryFlowDesign.paddingMedium,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand Colors
            Text('Brand Colors', style: MemoryFlowDesign.heading1(context)),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            _buildColorsSection(context),

            const SizedBox(height: MemoryFlowDesign.spaceXLarge),
            const Divider(),
            const SizedBox(height: MemoryFlowDesign.spaceXLarge),

            // Typography
            Text('Typography', style: MemoryFlowDesign.heading1(context)),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            _buildTypographySection(context),

            const SizedBox(height: MemoryFlowDesign.spaceXLarge),
            const Divider(),
            const SizedBox(height: MemoryFlowDesign.spaceXLarge),

            // Cards
            Text('Cards', style: MemoryFlowDesign.heading1(context)),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            _buildCardsSection(context),

            const SizedBox(height: MemoryFlowDesign.spaceXLarge),
            const Divider(),
            const SizedBox(height: MemoryFlowDesign.spaceXLarge),

            // Stats
            Text('Stat Widgets', style: MemoryFlowDesign.heading1(context)),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            _buildStatsSection(context),

            const SizedBox(height: MemoryFlowDesign.spaceXLarge),
            const Divider(),
            const SizedBox(height: MemoryFlowDesign.spaceXLarge),

            // Buttons
            Text('Buttons', style: MemoryFlowDesign.heading1(context)),
            const SizedBox(height: MemoryFlowDesign.spaceMedium),
            _buildButtonsSection(context),

            const SizedBox(height: MemoryFlowDesign.spaceXXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsSection(BuildContext context) {
    return Wrap(
      spacing: MemoryFlowDesign.spaceSmall,
      runSpacing: MemoryFlowDesign.spaceSmall,
      children: [
        _colorBox('Primary Blue', MemoryFlowDesign.primaryBlue),
        _colorBox('Accent Orange', MemoryFlowDesign.accentOrange),
        _colorBox('Success Green', MemoryFlowDesign.successGreen),
        _colorBox('Warning Amber', MemoryFlowDesign.warningAmber),
        _colorBox('Error Red', MemoryFlowDesign.errorRed),
        _colorBox('Info Blue', MemoryFlowDesign.infoBlue),
      ],
    );
  }

  Widget _colorBox(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: MemoryFlowDesign.radiusSmall,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display', style: MemoryFlowDesign.display(context)),
        const SizedBox(height: 8),
        Text('Heading 1', style: MemoryFlowDesign.heading1(context)),
        const SizedBox(height: 8),
        Text('Heading 2', style: MemoryFlowDesign.heading2(context)),
        const SizedBox(height: 8),
        Text('Heading 3', style: MemoryFlowDesign.heading3(context)),
        const SizedBox(height: 8),
        Text('Body Large', style: MemoryFlowDesign.bodyLarge(context)),
        const SizedBox(height: 8),
        Text('Body', style: MemoryFlowDesign.body(context)),
        const SizedBox(height: 8),
        Text('Caption', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        Text('LABEL', style: MemoryFlowDesign.label(context)),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return Column(
      children: [
        // Standard Card
        MemoryFlowCard(
          title: 'Standard Card',
          subtitle: 'Default card style',
          icon: Icons.info,
          onTap: () {},
          child: const Text('This is a standard card with icon and title.'),
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Elevated Card
        MemoryFlowCard(
          title: 'Elevated Card',
          icon: Icons.arrow_upward,
          variant: MemoryFlowCardVariant.elevated,
          child: const Text('This card has more shadow elevation.'),
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Gradient Card
        MemoryFlowCard(
          title: 'Gradient Card',
          icon: Icons.gradient,
          iconColor: Colors.white,
          variant: MemoryFlowCardVariant.gradient,
          child: const Text(
            'Beautiful gradient background.',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Outlined Card
        MemoryFlowCard(
          title: 'Outlined Card',
          icon: Icons.border_all,
          variant: MemoryFlowCardVariant.outlined,
          child: const Text('Card with border outline.'),
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Info Card
        const MemoryFlowInfoCard(
          title: 'Info Card',
          message: 'Colored left border for important messages.',
          icon: Icons.info_outline,
          color: Color(0xFF3B82F6),
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Compact Card
        MemoryFlowCompactCard(
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              const Text('Compact card with minimal padding'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      children: [
        // Standard Stats
        Row(
          children: [
            Expanded(
              child: MemoryFlowStatWidget(
                icon: Icons.local_fire_department,
                value: '42',
                label: 'Day Streak',
                color: MemoryFlowDesign.warningAmber,
              ),
            ),
            const SizedBox(width: MemoryFlowDesign.spaceMedium),
            Expanded(
              child: MemoryFlowStatWidget(
                icon: Icons.check_circle,
                value: '156',
                label: 'Reviews',
                color: MemoryFlowDesign.successGreen,
                showTrend: true,
                trendValue: 12.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Compact Stats
        MemoryFlowStatWidget(
          icon: Icons.library_books,
          value: '28',
          label: 'Total Topics',
          color: MemoryFlowDesign.primaryBlue,
          compact: true,
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Progress Stat
        MemoryFlowProgressStat(
          label: 'Learning Progress',
          value: '75%',
          progress: 0.75,
          icon: Icons.trending_up,
          color: MemoryFlowDesign.successGreen,
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        // Metric Card
        MemoryFlowMetricCard(
          metric: 'Reviews This Week',
          value: '42',
          subtitle: '+12% from last week',
          icon: Icons.analytics,
          color: MemoryFlowDesign.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Primary', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowButton.primary(
          label: 'Start Review',
          icon: Icons.play_arrow,
          onPressed: () {},
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Secondary', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowButton.secondary(
          label: 'View Details',
          icon: Icons.visibility,
          onPressed: () {},
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Success', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowButton.success(
          label: 'Complete',
          icon: Icons.check,
          onPressed: () {},
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Danger', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowButton.danger(
          label: 'Delete',
          icon: Icons.delete,
          onPressed: () {},
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Outlined', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowOutlinedButton(
          label: 'Cancel',
          icon: Icons.close,
          onPressed: () {},
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Loading State', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        MemoryFlowButton.primary(
          label: 'Processing',
          isLoading: true,
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Button Sizes', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            MemoryFlowButton.primary(
              label: 'Small',
              size: MemoryFlowButtonSize.small,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            MemoryFlowButton.primary(
              label: 'Medium',
              size: MemoryFlowButtonSize.medium,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            MemoryFlowButton.primary(
              label: 'Large',
              size: MemoryFlowButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: MemoryFlowDesign.spaceMedium),

        Text('Icon Buttons', style: MemoryFlowDesign.caption(context)),
        const SizedBox(height: 8),
        Row(
          children: [
            MemoryFlowIconButton(
              icon: Icons.favorite,
              color: MemoryFlowDesign.errorRed,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            MemoryFlowIconButton(
              icon: Icons.share,
              color: MemoryFlowDesign.primaryBlue,
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            MemoryFlowIconButton(
              icon: Icons.bookmark,
              color: MemoryFlowDesign.warningAmber,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
