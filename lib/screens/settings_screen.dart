import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/topic.dart';
import '../services/notification_service.dart';
import '../services/google_drive_service.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_helper.dart';
import '../widgets/common/figma_app_bar.dart';
import '../widgets/common/figma_button.dart';
import '../widgets/common/figma_card.dart';
import '../widgets/common/figma_dialog.dart';
import 'google_drive_connect_screen.dart';
import 'analytics_showcase_screen.dart';
import 'gamification_showcase_screen.dart';
import 'design_system_showcase_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/dialogs/restore_backup_dialog.dart';
import '../services/test_data_generator.dart';

/// Settings screen - App configuration and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final GoogleDriveService _driveService = GoogleDriveService();
  final DatabaseService _databaseService = DatabaseService();
  late AppSettings _settings;
  bool _isLoading = true;
  bool _isBackingUp = false;
  String? _connectedEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeDriveService();
  }

  /// Initialize Google Drive service
  Future<void> _initializeDriveService() async {
    await _driveService.initialize();
    final signedIn = await _driveService.isSignedIn();
    if (signedIn) {
      setState(() {
        _connectedEmail = _driveService.userEmail;
      });
    }
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

    // Update ThemeProvider for immediate visual feedback
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

      // Update theme mode if changed
      if (_settings.themeMode != newSettings.themeMode) {
        await themeProvider.setThemeMode(newSettings.themeMode);
      }

      // Update font size if changed
      if (_settings.fontSize != newSettings.fontSize) {
        await themeProvider.setFontSize(newSettings.fontSize);
      }

      // Update color scheme if changed
      if (_settings.colorScheme != newSettings.colorScheme) {
        await themeProvider.setColorScheme(newSettings.colorScheme);
      }
    }
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

  /// Generate test data (1000 topics)
  Future<void> _generateTestData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Test Data'),
        content: const Text(
          'This will create 1000 interview question topics across 5 folders:\n\n'
          '• Laravel (200 topics)\n'
          '• ReactJS (200 topics)\n'
          '• Flutter (200 topics)\n'
          '• Python (200 topics)\n'
          '• AI/ML (200 topics)\n\n'
          'This may take a few minutes. Continue?',
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          FigmaButton(
            text: 'Generate',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FigmaLoadingDialog(
        message: 'Generating 1000 test topics...',
        subtitle: 'This may take a few minutes.',
      ),
    );

    try {
      final generator = TestDataGenerator();
      await generator.generateAllTopics();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Successfully created 1000 test topics!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating test data: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
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
          FigmaTextButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
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

  /// Show color scheme picker
  void _showColorSchemePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color Scheme'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppColorScheme.values.map((scheme) {
              final schemeData = AppColorSchemes.getScheme(scheme);
              return _buildColorSchemeOption(scheme, schemeData);
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Build color scheme option with preview
  Widget _buildColorSchemeOption(AppColorScheme scheme, ColorSchemeData data) {
    final isSelected = _settings.colorScheme == scheme;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _updateSettings(_settings.copyWith(colorScheme: scheme));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${data.name}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? data.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          children: [
            // Color preview circles
            Row(
              children: [
                _buildColorCircle(data.primary),
                const SizedBox(width: 4),
                _buildColorCircle(data.secondary),
                const SizedBox(width: 4),
                _buildColorCircle(data.accent),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Name
            Expanded(
              child: Text(
                data.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: data.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build color preview circle
  Widget _buildColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gray300,
          width: 0.5,
        ),
      ),
    );
  }

  /// Handle Google Drive connection
  Future<void> _handleGoogleDriveConnect() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const GoogleDriveConnectScreen(),
      ),
    );

    if (result == true) {
      // Refresh connection status to get the latest sign-in state
      await _driveService.refreshConnectionStatus();
      setState(() {
        _connectedEmail = _driveService.userEmail;
      });
      await _updateSettings(_settings.copyWith(googleDriveConnected: true));
    }
  }

  /// Handle Google Drive disconnect
  Future<void> _handleGoogleDriveDisconnect() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Google Drive'),
        content: const Text(
          'Are you sure you want to disconnect from Google Drive? '
          'Your backups will remain in your Drive, but you won\'t be able to '
          'create new backups or restore from existing ones until you reconnect.',
        ),
        actions: [
          FigmaTextButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
          ),
          FigmaTextButton(
            text: 'Disconnect',
            onPressed: () => Navigator.pop(context, true),
            color: AppColors.error,
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _driveService.signOut();
      setState(() {
        _connectedEmail = null;
      });
      await _updateSettings(_settings.copyWith(googleDriveConnected: false));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disconnected from Google Drive'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  /// Handle backup now
  Future<void> _handleBackupNow() async {
    setState(() {
      _isBackingUp = true;
    });

    try {
      // Get all data from database
      final topics = await _databaseService.getAllTopics();

      // Create backup data - convert topics to maps manually
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'topics': topics.map((t) => {
          'id': t.id,
          'title': t.title,
          'filePath': t.filePath,
          'createdAt': t.createdAt.toIso8601String(),
          'currentStage': t.currentStage,
          'nextReviewDate': t.nextReviewDate.toIso8601String(),
          'lastReviewedAt': t.lastReviewedAt?.toIso8601String(),
          'reviewCount': t.reviewCount,
          'tags': t.tags,
          'isFavorite': t.isFavorite,
          'useCustomSchedule': t.useCustomSchedule,
          'customReviewDatetime': t.customReviewDatetime?.toIso8601String(),
        }).toList(),
      };

      // Upload to Google Drive
      final success = await _driveService.backup(backupData);

      if (mounted) {
        if (success) {
          await _updateSettings(_settings.copyWith(lastBackupTime: DateTime.now()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup completed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during backup: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  /// Handle restore from backup
  Future<void> _handleRestoreBackup() async {
    await showDialog(
      context: context,
      builder: (context) => RestoreBackupDialog(
        driveService: _driveService,
        onRestore: _restoreData,
      ),
    );
  }

  /// Restore data from backup
  Future<void> _restoreData(Map<String, dynamic> data) async {
    try {
      // Get all topics first to delete them
      final existingTopics = await _databaseService.getAllTopics();

      // Delete all existing topics
      for (var topic in existingTopics) {
        await _databaseService.deleteTopic(topic.id);
      }

      // Restore topics
      final topicsData = data['topics'] as List<dynamic>?;
      if (topicsData != null) {
        for (var topicMap in topicsData) {
          // Convert map to Topic
          final topic = Topic(
            id: topicMap['id'] as String,
            title: topicMap['title'] as String,
            filePath: topicMap['filePath'] as String,
            createdAt: DateTime.parse(topicMap['createdAt'] as String),
            currentStage: topicMap['currentStage'] as int,
            nextReviewDate: DateTime.parse(topicMap['nextReviewDate'] as String),
            lastReviewedAt: topicMap['lastReviewedAt'] != null
                ? DateTime.parse(topicMap['lastReviewedAt'] as String)
                : null,
            reviewCount: topicMap['reviewCount'] as int? ?? 0,
            tags: (topicMap['tags'] as List<dynamic>?)?.cast<String>() ?? [],
            isFavorite: topicMap['isFavorite'] as bool? ?? false,
            useCustomSchedule: topicMap['useCustomSchedule'] as bool? ?? false,
            customReviewDatetime: topicMap['customReviewDatetime'] != null
                ? DateTime.parse(topicMap['customReviewDatetime'] as String)
                : null,
          );

          await _databaseService.insertTopic(topic);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully. Please restart the app.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Toggle auto backup
  Future<void> _toggleAutoBackup(bool value) async {
    await _updateSettings(_settings.copyWith(autoBackupEnabled: value));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Auto backup enabled' : 'Auto backup disabled',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const FigmaAppBar(
        title: 'Settings',
        showBackButton: false, // Main navigation screen
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
                subtitle: _connectedEmail != null
                    ? 'Connected as: $_connectedEmail'
                    : 'Not Connected',
                trailing: FigmaTextButton(
                  text: _connectedEmail != null ? 'Disconnect' : 'Connect',
                  onPressed: _connectedEmail != null
                      ? _handleGoogleDriveDisconnect
                      : _handleGoogleDriveConnect,
                ),
              ),
              if (_connectedEmail != null) ...[
                const Divider(height: 1),
                _buildSettingItem(
                  context: context,
                  icon: Icons.backup_rounded,
                  title: 'Auto Backup',
                  subtitle: 'Backup automatically',
                  trailing: Switch(
                    value: _settings.autoBackupEnabled,
                    onChanged: _toggleAutoBackup,
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
                  child: Column(
                    children: [
                      FigmaButton(
                        text: _isBackingUp ? 'Backing up...' : 'Backup Now',
                        icon: _isBackingUp ? null : Icons.backup,
                        onPressed: _isBackingUp ? null : _handleBackupNow,
                        isLoading: _isBackingUp,
                        fullWidth: true,
                      ),
                      ThemeHelper.vSpaceSmall,
                      FigmaOutlinedButton(
                        text: 'Restore from Backup',
                        icon: Icons.restore,
                        onPressed: _handleRestoreBackup,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ],
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
              const Divider(height: 1),
              _buildSettingItem(
                context: context,
                icon: Icons.color_lens_rounded,
                title: 'Color Scheme',
                subtitle: AppColorSchemes.getScheme(_settings.colorScheme).name,
                onTap: _showColorSchemePicker,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
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
    return FigmaCard(
      padding: EdgeInsets.zero,
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
