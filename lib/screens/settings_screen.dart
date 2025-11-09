import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Settings screen - App configuration and preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Profile section
          _buildProfileCard(context),
          const SizedBox(height: AppSpacing.lg),

          // Preferences section
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Review reminders and alerts',
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Toggle dark theme',
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement theme toggle
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Learning section
          _buildSectionHeader(context, 'Learning'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.emoji_events_rounded,
                title: 'Daily Goal',
                subtitle: '${AppConfig.defaultDailyGoal} cards per day',
                onTap: () {
                  // TODO: Navigate to daily goal settings
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.timer_rounded,
                title: 'Review Intervals',
                subtitle: 'Customize spaced repetition',
                onTap: () {
                  // TODO: Navigate to interval settings
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Data section
          _buildSectionHeader(context, 'Data'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.cloud_upload_rounded,
                title: 'Backup & Sync',
                subtitle: 'Cloud backup settings',
                onTap: () {
                  // TODO: Navigate to backup settings
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.file_download_rounded,
                title: 'Export Data',
                subtitle: 'Export your learning data',
                onTap: () {
                  // TODO: Implement data export
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // About section
          _buildSectionHeader(context, 'About'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.info_rounded,
                title: 'App Version',
                subtitle: AppConfig.appVersion,
                onTap: () {
                  // TODO: Show app info
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'View privacy policy',
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              const Divider(),
              _buildSettingItem(
                context: context,
                icon: Icons.help_rounded,
                title: 'Help & Support',
                subtitle: 'Get help and send feedback',
                onTap: () {
                  // TODO: Show help
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build profile card
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'user@example.com',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                // TODO: Navigate to profile edit
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  /// Build setting card
  Widget _buildSettingCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(children: children),
      ),
    );
  }

  /// Build individual setting item
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
      onTap: onTap,
    );
  }
}
