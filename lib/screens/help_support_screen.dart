import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/design_system.dart';
import '../widgets/common/figma_app_bar.dart';
import '../widgets/common/figma_card.dart';
import '../utils/theme_helper.dart';

/// Help & Support screen - Information about spaced repetition
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FigmaAppBar(
        title: 'Help & Support',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Hero section
          _buildHeroSection(context),
          ThemeHelper.vSpaceLarge,

          // What is Spaced Repetition?
          _buildSectionCard(
            context,
            icon: Icons.psychology_rounded,
            iconColor: MemoryFlowDesign.primaryBlue,
            title: 'What is Spaced Repetition?',
            content: [
              _buildParagraph(
                context,
                'Spaced repetition is a learning technique that helps optimize long-term memory '
                'retention by reviewing information at increasing time intervals.',
              ),
              ThemeHelper.vSpaceMedium,
              _buildParagraph(
                context,
                'Instead of cramming or reviewing material at random, this scientifically-backed '
                'method schedules reviews just as you\'re about to forget something, reinforcing '
                'it in your memory at the optimal moment.',
              ),
              ThemeHelper.vSpaceMedium,
              _buildInfoBox(
                context,
                icon: Icons.lightbulb_outline_rounded,
                text: 'This approach is based on the psychological spacing effect, where '
                    'information is better retained when learning sessions are spread out over '
                    'time rather than massed together.',
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // Who invented Spaced Repetition?
          _buildSectionCard(
            context,
            icon: Icons.history_edu_rounded,
            iconColor: MemoryFlowDesign.accentOrange,
            title: 'Who Invented Spaced Repetition?',
            content: [
              _buildParagraph(
                context,
                'The concept is based on pioneering research by:',
              ),
              ThemeHelper.vSpaceSmall,
              _buildBulletPoint(
                context,
                title: 'Hermann Ebbinghaus (1880s)',
                description: 'German psychologist who discovered the "forgetting curve," '
                    'showing how memory retention declines over time without reinforcement.',
              ),
              ThemeHelper.vSpaceSmall,
              _buildBulletPoint(
                context,
                title: 'Modern Applications',
                description: 'Later researchers expanded on his work to develop practical '
                    'spaced repetition algorithms. The modern application in learning software '
                    'was popularized by systems like SuperMemo (created by Piotr Woźniak in the 1980s).',
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // How does this app use Spaced Repetition?
          _buildSectionCard(
            context,
            icon: Icons.auto_awesome_rounded,
            iconColor: MemoryFlowDesign.successGreen,
            title: 'How Does MemoryFlow Use Spaced Repetition?',
            content: [
              _buildParagraph(
                context,
                'MemoryFlow implements a 5-stage spaced repetition system with predefined intervals:',
              ),
              ThemeHelper.vSpaceMedium,

              // Review Schedule
              _buildSubsectionHeader(context, 'Review Schedule'),
              ThemeHelper.vSpaceSmall,
              _buildStageItem(context, 0, 'Stage 0 (New)', '1 day', 'Initial learning phase with rapid reinforcement'),
              _buildStageItem(context, 1, 'Stage 1', '3 days', 'Short-term memory consolidation'),
              _buildStageItem(context, 2, 'Stage 2', '7 days', 'Weekly checkpoint'),
              _buildStageItem(context, 3, 'Stage 3', '14 days', 'Bi-weekly review'),
              _buildStageItem(context, 4, 'Stage 4+', '30 days', 'Long-term maintenance (continues monthly)'),

              ThemeHelper.vSpaceMedium,

              // How It Works
              _buildSubsectionHeader(context, 'How It Works'),
              ThemeHelper.vSpaceSmall,
              _buildNumberedStep(context, 1, 'When you add a new topic, it starts at Stage 0'),
              _buildNumberedStep(context, 2, 'After each successful review, the topic advances to the next stage'),
              _buildNumberedStep(context, 3, 'The interval between reviews increases progressively'),
              _buildNumberedStep(context, 4, 'The app schedules automatic notifications to remind you when topics are due'),
              _buildNumberedStep(context, 5, 'You can track due/overdue topics on your calendar and home screen'),

              ThemeHelper.vSpaceMedium,

              // Key Features
              _buildSubsectionHeader(context, 'Key Features'),
              ThemeHelper.vSpaceSmall,
              _buildFeatureChip(context, Icons.schedule_rounded, 'Automatic scheduling based on the algorithm'),
              _buildFeatureChip(context, Icons.edit_calendar_rounded, 'Option for custom review schedules'),
              _buildFeatureChip(context, Icons.analytics_rounded, 'Progress tracking showing total review count'),
              _buildFeatureChip(context, Icons.calendar_month_rounded, 'Calendar integration to visualize schedule'),
              _buildFeatureChip(context, Icons.notifications_rounded, 'Notifications to keep you on track'),

              ThemeHelper.vSpaceMedium,

              // The Science Behind It
              _buildInfoBox(
                context,
                icon: Icons.science_rounded,
                text: 'The app\'s intervals are designed to reinforce learning just before you\'re '
                    'likely to forget, maximizing retention while minimizing unnecessary repetition. '
                    'This makes learning more efficient compared to traditional review methods.',
                color: MemoryFlowDesign.infoBlue,
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // Contact Support Section
          _buildContactSection(context),

          ThemeHelper.vSpaceLarge,
        ],
      ),
    );
  }

  /// Build hero section at the top
  Widget _buildHeroSection(BuildContext context) {
    return FigmaCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: MemoryFlowDesign.primaryGradient,
              borderRadius: MemoryFlowDesign.radiusMedium,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: MemoryFlowDesign.iconXXLarge,
                  color: Colors.white,
                ),
                ThemeHelper.vSpaceSmall,
                Text(
                  'Welcome to MemoryFlow',
                  style: MemoryFlowDesign.heading2(context, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                ThemeHelper.vSpaceSmall,
                Text(
                  'Learn smarter with science-backed spaced repetition',
                  style: MemoryFlowDesign.body(context, color: Colors.white.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a section card
  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> content,
  }) {
    return FigmaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              ThemeHelper.hSpaceMedium,
              Expanded(
                child: Text(
                  title,
                  style: MemoryFlowDesign.heading2(context),
                ),
              ),
            ],
          ),
          ThemeHelper.vSpaceMedium,
          const Divider(height: 1),
          ThemeHelper.vSpaceMedium,
          ...content,
        ],
      ),
    );
  }

  /// Build a paragraph
  Widget _buildParagraph(BuildContext context, String text) {
    return Text(
      text,
      style: MemoryFlowDesign.body(context),
    );
  }

  /// Build a subsection header
  Widget _buildSubsectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: MemoryFlowDesign.heading3(context, color: MemoryFlowDesign.primaryBlue),
    );
  }

  /// Build a bullet point
  Widget _buildBulletPoint(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: MemoryFlowDesign.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MemoryFlowDesign.body(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: MemoryFlowDesign.body(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a numbered step
  Widget _buildNumberedStep(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: MemoryFlowDesign.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: MemoryFlowDesign.caption(context, color: Colors.white).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: MemoryFlowDesign.body(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a stage item with color coding
  Widget _buildStageItem(
    BuildContext context,
    int stage,
    String title,
    String interval,
    String description,
  ) {
    final stageColor = MemoryFlowDesign.getStageColor(stage);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: stageColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: stageColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stageColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Text(
              interval,
              style: MemoryFlowDesign.caption(context, color: Colors.white).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MemoryFlowDesign.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: MemoryFlowDesign.caption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build an info box
  Widget _buildInfoBox(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? color,
  }) {
    final boxColor = color ?? MemoryFlowDesign.successGreen;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: boxColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: boxColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: boxColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: MemoryFlowDesign.body(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a feature chip
  Widget _buildFeatureChip(BuildContext context, IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: MemoryFlowDesign.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: MemoryFlowDesign.body(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build contact support section
  Widget _buildContactSection(BuildContext context) {
    return FigmaCard(
      child: Column(
        children: [
          Icon(
            Icons.email_rounded,
            size: MemoryFlowDesign.iconXLarge,
            color: MemoryFlowDesign.primaryBlue,
          ),
          ThemeHelper.vSpaceSmall,
          Text(
            'Need More Help?',
            style: MemoryFlowDesign.heading3(context),
            textAlign: TextAlign.center,
          ),
          ThemeHelper.vSpaceSmall,
          Text(
            'If you have questions or feedback, feel free to reach out to us.',
            style: MemoryFlowDesign.body(context),
            textAlign: TextAlign.center,
          ),
          ThemeHelper.vSpaceMedium,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: MemoryFlowDesign.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: MemoryFlowDesign.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'support@memoryflow.app',
                  style: MemoryFlowDesign.body(context).copyWith(
                    color: MemoryFlowDesign.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
