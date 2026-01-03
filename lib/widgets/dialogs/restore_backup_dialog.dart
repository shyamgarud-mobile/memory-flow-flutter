import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../services/google_drive_service.dart';
import '../../utils/theme_helper.dart';

/// Dialog for selecting and restoring from a backup
class RestoreBackupDialog extends StatefulWidget {
  final GoogleDriveService driveService;
  final Function(Map<String, dynamic>) onRestore;

  const RestoreBackupDialog({
    super.key,
    required this.driveService,
    required this.onRestore,
  });

  @override
  State<RestoreBackupDialog> createState() => _RestoreBackupDialogState();
}

class _RestoreBackupDialogState extends State<RestoreBackupDialog> {
  bool _isLoading = true;
  bool _isRestoring = false;
  List<BackupMetadata> _backups = [];
  BackupMetadata? _selectedBackup;
  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  /// Load available backups
  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final backups = await widget.driveService.listBackups();
      if (mounted) {
        setState(() {
          _backups = backups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading backups: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handle backup selection
  void _selectBackup(BackupMetadata backup) {
    setState(() {
      _selectedBackup = backup;
      _showConfirmation = true;
    });
  }

  /// Handle restore confirmation
  Future<void> _confirmRestore() async {
    if (_selectedBackup == null) return;

    setState(() {
      _isRestoring = true;
    });

    try {
      final data = await widget.driveService.restore(_selectedBackup!.id);

      if (data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to restore backup'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        widget.onRestore(data);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup restored successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  /// Cancel restore
  void _cancelRestore() {
    setState(() {
      _showConfirmation = false;
      _selectedBackup = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppBorderRadius.lg),
                  topRight: Radius.circular(AppBorderRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restore_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  ThemeHelper.hSpaceMedium,
                  Expanded(
                    child: Text(
                      _showConfirmation ? 'Confirm Restore' : 'Restore from Backup',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isRestoring ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _showConfirmation
                      ? _buildConfirmationView()
                      : _buildBackupList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build backup list view
  Widget _buildBackupList() {
    if (_backups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: AppColors.textSecondaryLight.withOpacity(0.5),
              ),
              ThemeHelper.vSpaceMedium,
              Text(
                'No backups found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              ThemeHelper.vSpaceSmall,
              Text(
                'Create your first backup to get started',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _backups.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final backup = _backups[index];
        return _buildBackupItem(backup);
      },
    );
  }

  /// Build individual backup item
  Widget _buildBackupItem(BackupMetadata backup) {
    final dateFormat = DateFormat('MMM d, y \'at\' h:mm a');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: const Icon(
          Icons.backup_rounded,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        dateFormat.format(backup.createdAt),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeHelper.vSpaceSmall,
          Text(
            'Size: ${backup.sizeFormatted}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (backup.description.isNotEmpty) ...[
            ThemeHelper.vSpaceSmall,
            Text(
              backup.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _selectBackup(backup),
    );
  }

  /// Build confirmation view
  Widget _buildConfirmationView() {
    if (_selectedBackup == null) return const SizedBox.shrink();

    final dateFormat = DateFormat('MMM d, y \'at\' h:mm a');

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 48,
            ),
          ),
          ThemeHelper.vSpaceLarge,

          // Warning message
          Text(
            'This will replace all local data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
            textAlign: TextAlign.center,
          ),
          ThemeHelper.vSpaceMedium,

          Text(
            'All your current topics and progress will be permanently replaced with the backup data.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          ThemeHelper.vSpaceLarge,

          // Backup details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: AppColors.gray200,
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  'Backup Date',
                  dateFormat.format(_selectedBackup!.createdAt),
                ),
                ThemeHelper.vSpaceSmall,
                _buildDetailRow(
                  context,
                  'Backup Size',
                  _selectedBackup!.sizeFormatted,
                ),
              ],
            ),
          ),
          ThemeHelper.vSpaceLarge,

          // Buttons
          if (_isRestoring)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _confirmRestore,
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore Backup'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
                ThemeHelper.vSpaceMedium,
                OutlinedButton(
                  onPressed: _cancelRestore,
                  child: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
