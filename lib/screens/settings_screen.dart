import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../services/notification_service.dart';
import '../utils/theme_helper.dart';

/// Settings screen - App configuration and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  late AppSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = <String, dynamic>{};

    // Load all settings
    prefs.getKeys().forEach((key) {
      final value = prefs.get(key);
      settingsMap[key] = value;
    });

    setState(() {
      _settings = settingsMap.isEmpty
          ? const AppSettings()
          : AppSettings.fromMap(settingsMap);
      _isLoading = false;
    });
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = _settings.toMap();

    for (var entry in settingsMap.entries) {
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is String) {
        await prefs.setString(entry.key, value);
      }
    }
  }

  /// Update settings and save
  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });
    await _saveSettings();
  }

  /// Toggle daily reminder
  Future<void> _toggleDailyReminder(bool value) async {
    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permissions denied'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }
      await _notificationService.scheduleDailyReminder(_settings.dailyReminderTime);
    }

    await _updateSettings(_settings.copyWith(dailyReminderEnabled: value));
  }

  /// Change daily reminder time
  Future<void> _changeDailyReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _settings.dailyReminderTime,
    );

    if (pickedTime != null) {
      await _updateSettings(_settings.copyWith(dailyReminderTime: pickedTime));

      if (_settings.dailyReminderEnabled) {
        await _notificationService.scheduleDailyReminder(pickedTime);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Daily reminder set for ${pickedTime.format(context)}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  /// Change evening reminder time
  Future<void> _changeEveningReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _settings.eveningReminderTime,
    );

    if (pickedTime != null) {
      await _updateSettings(_settings.copyWith(eveningReminderTime: pickedTime));
    }
  }

  /// Change quiet hours start time
  Future<void> _changeQuietHoursStart() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _settings.quietHoursStart,
    );

    if (pickedTime != null) {
      await _updateSettings(_settings.copyWith(quietHoursStart: pickedTime));
    }
  }

  /// Change quiet hours end time
  Future<void> _changeQuietHoursEnd() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _settings.quietHoursEnd,
    );

    if (pickedTime != null) {
      await _updateSettings(_settings.copyWith(quietHoursEnd: pickedTime));
    }
  }

  /// Show customize intervals dialog
  void _showCustomizeIntervalsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize Intervals'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 48,
            ),
            ThemeHelper.vSpaceMedium,
            Text(
              'Changing spaced repetition intervals may affect your learning efficiency.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ThemeHelper.vSpaceMedium,
            Text(
              'Current intervals: ${_settings.intervalStages.join(', ')} days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ThemeHelper.vSpaceMedium,
            Text(
              'This feature will be available in a future update.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show theme mode picker
  void _showThemeModePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: _settings.themeMode,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(themeMode: value));
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: _settings.themeMode,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(themeMode: value));
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: _settings.themeMode,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(themeMode: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show font size picker
  void _showFontSizePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Small'),
              value: 'small',
              groupValue: _settings.fontSize,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontSize: value));
              },
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              value: 'medium',
              groupValue: _settings.fontSize,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontSize: value));
              },
            ),
            RadioListTile<String>(
              title: const Text('Large'),
              value: 'large',
              groupValue: _settings.fontSize,
              onChanged: (value) {
                Navigator.pop(context);
                _updateSettings(_settings.copyWith(fontSize: value));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // NOTIFICATIONS Section
          _buildSectionHeader(context, 'NOTIFICATIONS'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.notifications_active_rounded,
                title: 'Daily Reminder',
                subtitle: _settings.dailyReminderEnabled
                    ? 'Enabled at ${_settings.dailyReminderTime.format(context)}'
                    : 'Disabled',
                trailing: Switch(
                  value: _settings.dailyReminderEnabled,
                  onChanged: _toggleDailyReminder,
                ),
              ),
              if (_settings.dailyReminderEnabled) ...[
                const Divider(height: 1),
                _buildSettingItem(
                  context: context,
                  icon: Icons.access_time_rounded,
                  title: 'Reminder Time',
                  subtitle: _settings.dailyReminderTime.format(context),
                  onTap: _changeDailyReminderTime,
                ),
              ],
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.nights_stay_rounded,
                title: 'Evening Reminder',
                subtitle: _settings.eveningReminderEnabled
                    ? 'Enabled at ${_settings.eveningReminderTime.format(context)}'
                    : 'Disabled',
                trailing: Switch(
                  value: _settings.eveningReminderEnabled,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(eveningReminderEnabled: value),
                  ),
                ),
              ),
              if (_settings.eveningReminderEnabled) ...[
                const Divider(height: 1),
                _buildSettingItem(
                  context: context,
                  icon: Icons.access_time_rounded,
                  title: 'Evening Time',
                  subtitle: _settings.eveningReminderTime.format(context),
                  onTap: _changeEveningReminderTime,
                ),
              ],
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.warning_rounded,
                title: 'Overdue Alerts',
                subtitle: _settings.overdueAlertsEnabled
                    ? 'Get notified for overdue topics'
                    : 'Disabled',
                trailing: Switch(
                  value: _settings.overdueAlertsEnabled,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(overdueAlertsEnabled: value),
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.bedtime_rounded,
                title: 'Quiet Hours',
                subtitle: _settings.quietHoursEnabled
                    ? '${_settings.quietHoursStart.format(context)} - ${_settings.quietHoursEnd.format(context)}'
                    : 'Disabled',
                trailing: Switch(
                  value: _settings.quietHoursEnabled,
                  onChanged: (value) => _updateSettings(
                    _settings.copyWith(quietHoursEnabled: value),
                  ),
                ),
              ),
              if (_settings.quietHoursEnabled) ...[
                const Divider(height: 1),
                _buildSettingItem(
                  context: context,
                  icon: Icons.schedule_rounded,
                  title: 'Quiet Hours Period',
                  subtitle: '${_settings.quietHoursStart.format(context)} to ${_settings.quietHoursEnd.format(context)}',
                  onTap: () async {
                    await _changeQuietHoursStart();
                    await _changeQuietHoursEnd();
                  },
                ),
              ],
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // CLOUD BACKUP Section
          _buildSectionHeader(context, 'CLOUD BACKUP'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.cloud_rounded,
                title: 'Google Drive',
                subtitle: _settings.googleDriveConnected
                    ? 'Connected'
                    : 'Not Connected',
                trailing: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cloud backup coming soon!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Text(
                    _settings.googleDriveConnected ? 'Disconnect' : 'Connect',
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.backup_rounded,
                title: 'Auto Backup',
                subtitle: 'Backup automatically',
                trailing: Switch(
                  value: _settings.autoBackupEnabled,
                  onChanged: null, // Disabled
                ),
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.history_rounded,
                title: 'Last Backup',
                subtitle: _settings.lastBackupTime != null
                    ? DateFormat('MMM d, y \'at\' h:mm a').format(_settings.lastBackupTime!)
                    : 'Never',
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ElevatedButton.icon(
                  onPressed: null, // Disabled
                  icon: const Icon(Icons.backup),
                  label: const Text('Backup Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // REVIEW SETTINGS Section
          _buildSectionHeader(context, 'REVIEW SETTINGS'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.timeline_rounded,
                title: 'Interval Stages',
                subtitle: '${_settings.intervalStages.join(', ')} days',
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: OutlinedButton.icon(
                  onPressed: _showCustomizeIntervalsDialog,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Customize Intervals'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // APPEARANCE Section
          _buildSectionHeader(context, 'APPEARANCE'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.palette_rounded,
                title: 'Theme',
                subtitle: _settings.themeMode == ThemeMode.light
                    ? 'Light'
                    : _settings.themeMode == ThemeMode.dark
                        ? 'Dark'
                        : 'System',
                onTap: _showThemeModePicker,
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.text_fields_rounded,
                title: 'Font Size',
                subtitle: _settings.fontSize[0].toUpperCase() + _settings.fontSize.substring(1),
                onTap: _showFontSizePicker,
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,

          // ABOUT Section
          _buildSectionHeader(context, 'ABOUT'),
          _buildSettingCard(
            context: context,
            children: [
              _buildSettingItem(
                context: context,
                icon: Icons.info_rounded,
                title: 'Version',
                subtitle: AppConfig.appVersion,
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon!'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.help_rounded,
                title: 'Help & Support',
                subtitle: 'Get help and send feedback',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & Support coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
          ThemeHelper.vSpaceLarge,
        ],
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
              letterSpacing: 0.5,
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
      child: Column(children: children),
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
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                )
              : null),
      onTap: onTap,
    );
  }
}
