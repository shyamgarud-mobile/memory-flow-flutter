import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/topic.dart';
import '../../services/spaced_repetition_service.dart';
import '../../utils/theme_helper.dart';
import '../common/custom_button.dart';
import '../pickers/custom_date_time_picker.dart';

/// Dialog for rescheduling topic review dates
///
/// Provides quick options and custom date/time selection for rescheduling.
/// Supports both custom scheduling and returning to automatic scheduling.
class RescheduleDialog extends StatefulWidget {
  /// Topic to reschedule
  final Topic topic;

  /// Callback when topic is successfully rescheduled
  final Function(Topic updatedTopic) onRescheduled;

  const RescheduleDialog({
    super.key,
    required this.topic,
    required this.onRescheduled,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();

  /// Show the reschedule dialog
  static Future<void> show({
    required BuildContext context,
    required Topic topic,
    required Function(Topic updatedTopic) onRescheduled,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RescheduleDialog(
        topic: topic,
        onRescheduled: onRescheduled,
      ),
    );
  }
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();

  DateTime? _customDateTime;
  bool _isLoading = false;
  String? _selectedQuickOption;

  @override
  void initState() {
    super.initState();
    // Initialize with current review date if custom schedule is active
    if (widget.topic.useCustomSchedule && widget.topic.customReviewDatetime != null) {
      _customDateTime = widget.topic.customReviewDatetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppColors.primary,
            size: 24,
          ),
          ThemeHelper.hSpaceSmall,
          const Text('Reschedule Review'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic title
              Text(
                widget.topic.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ThemeHelper.vSpaceSmall,
              Text(
                'Current: ${DateFormat('MMM d, y \'at\' h:mm a').format(widget.topic.nextReviewDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
              ThemeHelper.vSpaceLarge,

              // Quick options section
              Text(
                'Quick Options',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              ThemeHelper.vSpaceMedium,

              // Quick option buttons
              _buildQuickOptionButton(
                label: 'Tomorrow Morning',
                description: '9:00 AM',
                icon: Icons.wb_sunny,
                optionKey: 'tomorrow_morning',
                datetime: _getTomorrowMorning(),
              ),
              ThemeHelper.vSpaceSmall,

              _buildQuickOptionButton(
                label: 'Tomorrow Evening',
                description: '8:00 PM',
                icon: Icons.nights_stay,
                optionKey: 'tomorrow_evening',
                datetime: _getTomorrowEvening(),
              ),
              ThemeHelper.vSpaceSmall,

              _buildQuickOptionButton(
                label: 'In 3 Days',
                description: DateFormat('MMM d \'at\' h:mm a').format(_getIn3Days()),
                icon: Icons.calendar_today,
                optionKey: 'in_3_days',
                datetime: _getIn3Days(),
              ),
              ThemeHelper.vSpaceSmall,

              _buildQuickOptionButton(
                label: 'Return to Auto Schedule',
                description: 'Use spaced repetition intervals',
                icon: Icons.autorenew,
                optionKey: 'auto',
                datetime: null, // Special case for auto
                isAutoOption: true,
              ),
              ThemeHelper.vSpaceLarge,

              // Custom date/time picker
              CustomDateTimePicker(
                initialDateTime: _customDateTime,
                onDateTimeSelected: (dateTime) {
                  setState(() {
                    _customDateTime = dateTime;
                    _selectedQuickOption = null; // Clear quick option when custom is selected
                  });
                },
                label: 'Custom Date & Time',
                minimumDate: DateTime.now(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button
        CustomButton.text(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),

        // Save button
        CustomButton.primary(
          text: _isLoading ? 'Saving...' : 'Save',
          icon: _isLoading ? null : Icons.check,
          onPressed: _canSave && !_isLoading ? _handleSave : null,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  /// Build a quick option button
  Widget _buildQuickOptionButton({
    required String label,
    required String description,
    required IconData icon,
    required String optionKey,
    required DateTime? datetime,
    bool isAutoOption = false,
  }) {
    final isSelected = _selectedQuickOption == optionKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedQuickOption = optionKey;
          if (!isAutoOption && datetime != null) {
            _customDateTime = datetime;
          } else {
            _customDateTime = null;
          }
        });
      },
      borderRadius: ThemeHelper.standardRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: ThemeHelper.standardRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.gray700
                    : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : Theme.of(context).brightness == Brightness.dark
                        ? AppColors.gray800
                        : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            ThemeHelper.hSpaceMedium,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primary : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Check if save button should be enabled
  bool get _canSave {
    // Auto schedule option is always valid
    if (_selectedQuickOption == 'auto') return true;

    // For custom schedule, need valid datetime
    return _customDateTime != null;
  }

  /// Handle save button
  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Topic updatedTopic;

      if (_selectedQuickOption == 'auto') {
        // Return to automatic scheduling
        updatedTopic = await _spacedRepService.removeCustomSchedule(
          widget.topic.id,
          recalculate: true,
        );
      } else {
        // Set custom schedule
        final datetime = _customDateTime;
        if (datetime == null) {
          throw Exception('Please select date and time');
        }

        updatedTopic = await _spacedRepService.rescheduleTopicTo(
          widget.topic.id,
          datetime,
          isCustom: true,
        );
      }

      if (!mounted) return;

      // Notify parent and close dialog
      widget.onRescheduled(updatedTopic);
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedQuickOption == 'auto'
                ? 'Returned to automatic scheduling'
                : 'Review rescheduled to ${DateFormat('MMM d, y \'at\' h:mm a').format(_customDateTime!)}',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Get tomorrow morning datetime
  DateTime _getTomorrowMorning() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
  }

  /// Get tomorrow evening datetime
  DateTime _getTomorrowEvening() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20, 0);
  }

  /// Get in 3 days datetime (same time as now)
  DateTime _getIn3Days() {
    final now = DateTime.now();
    final in3Days = now.add(const Duration(days: 3));
    return DateTime(in3Days.year, in3Days.month, in3Days.day, now.hour, now.minute);
  }
}
