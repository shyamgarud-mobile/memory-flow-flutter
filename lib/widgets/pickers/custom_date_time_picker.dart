import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../utils/theme_helper.dart';

/// Custom date and time picker widget
///
/// Combines date and time selection with a clean Material Design interface.
/// Shows selected datetime and provides buttons to change date and time separately.
///
/// **Example:**
/// ```dart
/// CustomDateTimePicker(
///   initialDateTime: DateTime.now().add(Duration(days: 1)),
///   onDateTimeSelected: (dateTime) {
///     print('Selected: $dateTime');
///   },
///   label: 'Review Date',
/// )
/// ```
class CustomDateTimePicker extends StatefulWidget {
  /// Initial date and time to display
  final DateTime? initialDateTime;

  /// Callback when date/time is selected
  final Function(DateTime dateTime) onDateTimeSelected;

  /// Minimum selectable date (defaults to today)
  final DateTime? minimumDate;

  /// Maximum selectable date (defaults to 1 year from now)
  final DateTime? maximumDate;

  /// Label to display above the picker
  final String? label;

  /// Whether to show the label
  final bool showLabel;

  /// Custom decoration for the container
  final BoxDecoration? decoration;

  const CustomDateTimePicker({
    super.key,
    this.initialDateTime,
    required this.onDateTimeSelected,
    this.minimumDate,
    this.maximumDate,
    this.label,
    this.showLabel = true,
    this.decoration,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
  }

  @override
  void didUpdateWidget(CustomDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime && widget.initialDateTime != null) {
      final initial = widget.initialDateTime!;
      setState(() {
        _selectedDate = DateTime(initial.year, initial.month, initial.day);
        _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
      });
    }
  }

  /// Get the combined DateTime from selected date and time
  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  /// Format the combined datetime for display
  String get _formattedDateTime {
    return DateFormat('MMM d, y \'at\' h:mm a').format(_combinedDateTime);
  }

  /// Format just the date
  String get _formattedDate {
    return DateFormat('MMM d, y').format(_selectedDate);
  }

  /// Format just the time
  String get _formattedTime {
    return _selectedTime.format(context);
  }

  /// Handle date picker
  Future<void> _handleDatePick() async {
    final now = DateTime.now();
    final minimumDate = widget.minimumDate ?? now;
    final maximumDate = widget.maximumDate ?? now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(minimumDate) ? minimumDate : _selectedDate,
      firstDate: minimumDate,
      lastDate: maximumDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateTimeSelected(_combinedDateTime);
    }
  }

  /// Handle time picker
  Future<void> _handleTimePick() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.white,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      widget.onDateTimeSelected(_combinedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.showLabel && widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          ThemeHelper.vSpaceMedium,
        ],

        // Selected datetime display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: widget.decoration ??
              BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: ThemeHelper.standardRadius,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  ThemeHelper.hSpaceSmall,
                  Text(
                    'Selected Date & Time',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formattedDateTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
        ThemeHelper.vSpaceMedium,

        // Date and time picker buttons
        Row(
          children: [
            // Date picker button
            Expanded(
              child: _buildPickerButton(
                icon: Icons.calendar_today,
                label: 'Change Date',
                value: _formattedDate,
                onPressed: _handleDatePick,
              ),
            ),
            ThemeHelper.hSpaceSmall,
            // Time picker button
            Expanded(
              child: _buildPickerButton(
                icon: Icons.access_time,
                label: 'Change Time',
                value: _formattedTime,
                onPressed: _handleTimePick,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a picker button (date or time)
  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 4,
        ),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.5),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ThemeHelper.standardRadius,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Compact version of CustomDateTimePicker
///
/// Shows date and time in a single row with inline picker buttons.
///
/// **Example:**
/// ```dart
/// CompactDateTimePicker(
///   initialDateTime: DateTime.now(),
///   onDateTimeSelected: (dateTime) {
///     print('Selected: $dateTime');
///   },
/// )
/// ```
class CompactDateTimePicker extends StatefulWidget {
  /// Initial date and time to display
  final DateTime? initialDateTime;

  /// Callback when date/time is selected
  final Function(DateTime dateTime) onDateTimeSelected;

  /// Minimum selectable date (defaults to today)
  final DateTime? minimumDate;

  /// Maximum selectable date (defaults to 1 year from now)
  final DateTime? maximumDate;

  const CompactDateTimePicker({
    super.key,
    this.initialDateTime,
    required this.onDateTimeSelected,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  State<CompactDateTimePicker> createState() => _CompactDateTimePickerState();
}

class _CompactDateTimePickerState extends State<CompactDateTimePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
  }

  /// Get the combined DateTime from selected date and time
  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  /// Handle date picker
  Future<void> _handleDatePick() async {
    final now = DateTime.now();
    final minimumDate = widget.minimumDate ?? now;
    final maximumDate = widget.maximumDate ?? now.add(const Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(minimumDate) ? minimumDate : _selectedDate,
      firstDate: minimumDate,
      lastDate: maximumDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateTimeSelected(_combinedDateTime);
    }
  }

  /// Handle time picker
  Future<void> _handleTimePick() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      widget.onDateTimeSelected(_combinedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleDatePick,
            icon: Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              DateFormat('MMM d, y').format(_selectedDate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              side: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
        ThemeHelper.hSpaceSmall,
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _handleTimePick,
            icon: Icon(
              Icons.access_time,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              _selectedTime.format(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              side: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
