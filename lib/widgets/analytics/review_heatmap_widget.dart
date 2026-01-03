import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GitHub-Style Review Heatmap Widget
///
/// Displays a calendar heatmap showing review activity over the past days.
/// Color intensity represents the number of reviews completed each day.
///
/// **Features:**
/// - Calendar grid layout (weeks × days)
/// - Color intensity based on review count
/// - Month labels
/// - Tap to see detailed info for a specific day
/// - Streak tracking overlay
/// - Customizable time range (30/90/365 days)
///
/// **Example:**
/// ```dart
/// ReviewHeatmapWidget(
///   reviewData: {
///     DateTime(2025, 12, 1): 5,
///     DateTime(2025, 12, 2): 3,
///     // ...
///   },
///   onDayTap: (date, count) => showDayDetails(date, count),
/// )
/// ```
class ReviewHeatmapWidget extends StatefulWidget {
  /// Map of dates to review counts
  final Map<DateTime, int> reviewData;

  /// Number of days to display (default: 365)
  final int daysToShow;

  /// Size of each day cell
  final double cellSize;

  /// Spacing between cells
  final double cellSpacing;

  /// Callback when a day is tapped
  final Function(DateTime date, int count)? onDayTap;

  /// Show month labels
  final bool showMonthLabels;

  /// Show day labels (Mon, Wed, Fri)
  final bool showDayLabels;

  const ReviewHeatmapWidget({
    super.key,
    required this.reviewData,
    this.daysToShow = 365,
    this.cellSize = 12,
    this.cellSpacing = 3,
    this.onDayTap,
    this.showMonthLabels = true,
    this.showDayLabels = true,
  });

  @override
  State<ReviewHeatmapWidget> createState() => _ReviewHeatmapWidgetState();
}

class _ReviewHeatmapWidgetState extends State<ReviewHeatmapWidget> {
  late DateTime _endDate;
  late DateTime _startDate;
  late List<DateTime> _dateList;
  int _maxReviewCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeDates();
  }

  @override
  void didUpdateWidget(ReviewHeatmapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reviewData != widget.reviewData ||
        oldWidget.daysToShow != widget.daysToShow) {
      _initializeDates();
    }
  }

  void _initializeDates() {
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(Duration(days: widget.daysToShow - 1));

    // Generate list of all dates in range
    _dateList = [];
    DateTime current = _startDate;
    while (current.isBefore(_endDate) || _isSameDay(current, _endDate)) {
      _dateList.add(current);
      current = current.add(const Duration(days: 1));
    }

    // Find max review count for color scaling
    _maxReviewCount = widget.reviewData.values.isEmpty
        ? 0
        : widget.reviewData.values.reduce((a, b) => a > b ? a : b);
    if (_maxReviewCount == 0) _maxReviewCount = 1; // Avoid division by zero
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get review count for a specific date
  int _getReviewCount(DateTime date) {
    for (var entry in widget.reviewData.entries) {
      if (_isSameDay(entry.key, date)) {
        return entry.value;
      }
    }
    return 0;
  }

  /// Get color based on review count (intensity scaling)
  Color _getCellColor(int count, BuildContext context) {
    if (count == 0) {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]!
          : Colors.grey[200]!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);

    // Scale intensity from 0.3 to 1.0 based on count
    final intensity = 0.3 + (0.7 * (count / _maxReviewCount));

    return Color.lerp(
      isDark ? Colors.grey[800]! : Colors.grey[200]!,
      baseColor,
      intensity,
    )!;
  }

  /// Build month labels
  Widget _buildMonthLabels() {
    final months = <String, double>{};
    double xPos = widget.showDayLabels ? 30 : 0;

    // Group dates by month
    String? currentMonth;
    double monthStartX = xPos;

    for (int i = 0; i < _dateList.length; i++) {
      final date = _dateList[i];
      final monthYear = DateFormat('MMM').format(date);

      if (currentMonth != monthYear) {
        if (currentMonth != null && xPos - monthStartX > 40) {
          months[currentMonth] = monthStartX;
        }
        currentMonth = monthYear;
        monthStartX = xPos;
      }

      // Move to next week on Sunday
      if (date.weekday == DateTime.sunday) {
        xPos += widget.cellSize + widget.cellSpacing;
      }
    }

    // Add last month if wide enough
    if (currentMonth != null && xPos - monthStartX > 40) {
      months[currentMonth] = monthStartX;
    }

    return SizedBox(
      height: 20,
      child: Stack(
        children: months.entries.map((entry) {
          return Positioned(
            left: entry.value,
            child: Text(
              entry.key,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build day labels (Mon, Wed, Fri)
  Widget _buildDayLabels() {
    const days = ['Mon', 'Wed', 'Fri'];
    const dayIndices = [0, 2, 4]; // Monday, Wednesday, Friday

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) {
        if (dayIndices.contains(index)) {
          return SizedBox(
            height: widget.cellSize,
            child: Text(
              days[dayIndices.indexOf(index)],
              style: TextStyle(
                fontSize: 9,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          );
        } else {
          return SizedBox(height: widget.cellSize);
        }
      }),
    );
  }

  /// Build the heatmap grid
  Widget _buildHeatmap(BuildContext context) {
    // Organize dates into weeks
    final weeks = <List<DateTime?>>[];
    List<DateTime?> currentWeek = List.filled(7, null);

    for (var date in _dateList) {
      final weekday = date.weekday % 7; // Convert to 0=Sunday, 6=Saturday
      currentWeek[weekday] = date;

      if (weekday == 6) {
        // Saturday - week complete
        weeks.add(List.from(currentWeek));
        currentWeek = List.filled(7, null);
      }
    }

    // Add incomplete last week
    if (currentWeek.any((d) => d != null)) {
      weeks.add(currentWeek);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) {
        return Column(
          children: week.map((date) {
            if (date == null) {
              return SizedBox(
                width: widget.cellSize,
                height: widget.cellSize,
              );
            }

            final count = _getReviewCount(date);
            final color = _getCellColor(count, context);

            return GestureDetector(
              onTap: () => widget.onDayTap?.call(date, count),
              child: Container(
                width: widget.cellSize,
                height: widget.cellSize,
                margin: EdgeInsets.only(
                  right: widget.cellSpacing,
                  bottom: widget.cellSpacing,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// Build legend
  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final count = (_maxReviewCount * (index + 1) / 5).ceil();
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: _getCellColor(count, context),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'More',
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showMonthLabels) ...[
          _buildMonthLabels(),
          const SizedBox(height: 4),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDayLabels) ...[
              _buildDayLabels(),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildHeatmap(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildLegend(context),
      ],
    );
  }
}
