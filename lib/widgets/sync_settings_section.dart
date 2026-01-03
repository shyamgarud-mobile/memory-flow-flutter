import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../services/background_sync_service.dart';
import '../services/sync_queue_database.dart';

/// Sync settings section widget
class SyncSettingsSection extends StatefulWidget {
  final BackgroundSyncService syncService;

  const SyncSettingsSection({
    super.key,
    required this.syncService,
  });

  @override
  State<SyncSettingsSection> createState() => _SyncSettingsSectionState();
}

class _SyncSettingsSectionState extends State<SyncSettingsSection> {
  bool _autoSyncEnabled = true;
  bool _wifiOnly = false;
  int _syncIntervalHours = 12;
  bool _quietHoursEnabled = true;
  int _quietHoursStart = 22;
  int _quietHoursEnd = 7;
  bool _silentSync = true;
  int _reviewedCountTrigger = 5;

  SyncStatus? _syncStatus;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSyncStatus();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
      _wifiOnly = prefs.getBool('sync_wifi_only') ?? false;
      _syncIntervalHours = prefs.getInt('sync_interval_hours') ?? 12;
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? true;
      _quietHoursStart = prefs.getInt('quiet_hours_start') ?? 22;
      _quietHoursEnd = prefs.getInt('quiet_hours_end') ?? 7;
      _silentSync = prefs.getBool('silent_sync') ?? true;
      _reviewedCountTrigger = prefs.getInt('reviewed_count_trigger') ?? 5;
    });
  }

  Future<void> _loadSyncStatus() async {
    final status = await widget.syncService.getSyncStatus();
    setState(() {
      _syncStatus = status;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> _toggleAutoSync(bool value) async {
    setState(() {
      _autoSyncEnabled = value;
    });
    await _saveSetting('auto_sync_enabled', value);

    if (value) {
      await widget.syncService.registerPeriodicSync();
    } else {
      await widget.syncService.cancelPeriodicSync();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Auto-sync enabled' : 'Auto-sync disabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _performManualSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final success = await widget.syncService.performSync();

      await _loadSyncStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Sync completed successfully'
                : 'Sync completed with warnings'),
            backgroundColor: success ? AppColors.success : AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.danger,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  String _formatLastSync() {
    if (_syncStatus == null) return 'Never';
    if (_syncStatus!.lastSuccessfulSync.millisecondsSinceEpoch == 0) {
      return 'Never';
    }

    final now = DateTime.now();
    final diff = now.difference(_syncStatus!.lastSuccessfulSync);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, h:mm a').format(_syncStatus!.lastSuccessfulSync);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sync Status Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _syncStatus?.isSyncing == true
                          ? Icons.sync
                          : Icons.cloud_done_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last synced: ${_formatLastSync()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_syncStatus?.pendingChangesCount ?? 0 > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: Text(
                          '${_syncStatus!.pendingChangesCount} pending',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _performManualSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Auto-sync settings
        _buildSettingsTile(
          title: 'Auto-sync',
          subtitle: 'Automatically sync in background',
          trailing: Switch(
            value: _autoSyncEnabled,
            onChanged: _toggleAutoSync,
          ),
        ),

        if (_autoSyncEnabled) ...[
          _buildSettingsTile(
            title: 'WiFi only',
            subtitle: 'Only sync when connected to WiFi',
            trailing: Switch(
              value: _wifiOnly,
              onChanged: (value) async {
                setState(() {
                  _wifiOnly = value;
                });
                await _saveSetting('sync_wifi_only', value);
              },
            ),
          ),

          _buildSettingsTile(
            title: 'Sync interval',
            subtitle: 'Every $_syncIntervalHours hours',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showSyncIntervalDialog(),
          ),

          _buildSettingsTile(
            title: 'Quiet hours',
            subtitle: _quietHoursEnabled
                ? 'Active ${_formatHour(_quietHoursStart)} - ${_formatHour(_quietHoursEnd)}'
                : 'Disabled',
            trailing: Switch(
              value: _quietHoursEnabled,
              onChanged: (value) async {
                setState(() {
                  _quietHoursEnabled = value;
                });
                await _saveSetting('quiet_hours_enabled', value);
              },
            ),
          ),

          if (_quietHoursEnabled)
            _buildSettingsTile(
              title: 'Configure quiet hours',
              subtitle: 'Set time range for no background sync',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showQuietHoursDialog(),
            ),

          _buildSettingsTile(
            title: 'Silent sync',
            subtitle: 'No notifications for successful syncs',
            trailing: Switch(
              value: _silentSync,
              onChanged: (value) async {
                setState(() {
                  _silentSync = value;
                });
                await _saveSetting('silent_sync', value);
              },
            ),
          ),

          _buildSettingsTile(
            title: 'Auto-sync trigger',
            subtitle: 'Sync after $_reviewedCountTrigger reviews',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showReviewTriggerDialog(),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }

  Future<void> _showSyncIntervalDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Every 6 hours'),
              value: 6,
              groupValue: _syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Every 12 hours'),
              value: 12,
              groupValue: _syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Every 24 hours'),
              value: 24,
              groupValue: _syncIntervalHours,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _syncIntervalHours = result;
      });
      await _saveSetting('sync_interval_hours', result);
      await widget.syncService.registerPeriodicSync(); // Re-register with new interval
    }
  }

  Future<void> _showQuietHoursDialog() async {
    int tempStart = _quietHoursStart;
    int tempEnd = _quietHoursEnd;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Quiet Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start time'),
                trailing: Text(
                  _formatHour(tempStart),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: tempStart, minute: 0),
                  );
                  if (time != null) {
                    setDialogState(() {
                      tempStart = time.hour;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End time'),
                trailing: Text(
                  _formatHour(tempEnd),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: tempEnd, minute: 0),
                  );
                  if (time != null) {
                    setDialogState(() {
                      tempEnd = time.hour;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _quietHoursStart = tempStart;
        _quietHoursEnd = tempEnd;
      });
      await _saveSetting('quiet_hours_start', tempStart);
      await _saveSetting('quiet_hours_end', tempEnd);
    }
  }

  Future<void> _showReviewTriggerDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-sync Trigger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Automatically sync after reviewing this many topics:'),
            const SizedBox(height: AppSpacing.md),
            RadioListTile<int>(
              title: const Text('5 reviews'),
              value: 5,
              groupValue: _reviewedCountTrigger,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('10 reviews'),
              value: 10,
              groupValue: _reviewedCountTrigger,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('20 reviews'),
              value: 20,
              groupValue: _reviewedCountTrigger,
              onChanged: (value) => Navigator.pop(context, value),
            ),
            RadioListTile<int>(
              title: const Text('Never'),
              value: 999999,
              groupValue: _reviewedCountTrigger,
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _reviewedCountTrigger = result;
      });
      await _saveSetting('reviewed_count_trigger', result);
    }
  }
}
