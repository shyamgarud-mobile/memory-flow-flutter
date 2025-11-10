import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/topic.dart';
import '../services/topics_index_service.dart';
import '../services/spaced_repetition_service.dart';
import '../utils/theme_helper.dart';
import 'topic_detail_screen.dart';

/// Calendar screen showing review schedule
///
/// Displays a monthly calendar with review dates marked by status.
/// Shows topics for selected date with ability to mark as reviewed.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TopicsIndexService _topicsService = TopicsIndexService();
  final SpacedRepetitionService _spacedRepService = SpacedRepetitionService();

  // Calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Data
  List<Topic> _allTopics = [];
  Map<DateTime, List<Topic>> _topicsByDate = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  /// Load all topics and organize by review date
  Future<void> _loadTopics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final topics = await _topicsService.loadTopicsIndex();

      // Group topics by review date (normalized to start of day)
      final Map<DateTime, List<Topic>> topicsByDate = {};

      for (final topic in topics) {
        final dateKey = _normalizeDate(topic.nextReviewDate);

        if (topicsByDate.containsKey(dateKey)) {
          topicsByDate[dateKey]!.add(topic);
        } else {
          topicsByDate[dateKey] = [topic];
        }
      }

      setState(() {
        _allTopics = topics;
        _topicsByDate = topicsByDate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading topics: $e');
    }
  }

  /// Normalize datetime to start of day for date comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get topics for a specific date
  List<Topic> _getTopicsForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return _topicsByDate[normalizedDate] ?? [];
  }

  /// Get review status for a date
  DateReviewStatus _getDateStatus(DateTime date) {
    final topics = _getTopicsForDate(date);
    if (topics.isEmpty) return DateReviewStatus.none;

    final now = DateTime.now();
    final today = _normalizeDate(now);
    final normalizedDate = _normalizeDate(date);

    // Check if any topics are overdue (date is before today)
    if (normalizedDate.isBefore(today)) {
      return DateReviewStatus.overdue;
    }

    // Check if date is today
    if (normalizedDate.isAtSameMomentAs(today)) {
      return DateReviewStatus.today;
    }

    // Future dates have upcoming reviews
    return DateReviewStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Calendar'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar
                _buildCalendar(),

                // Legend
                _buildLegend(),

                ThemeHelper.divider,

                // Selected date topics
                Expanded(
                  child: _buildTopicsList(),
                ),
              ],
            ),
    );
  }

  /// Build the calendar widget
  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white,
        boxShadow: ThemeHelper.standardShadow,
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,

        // Styling
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),

          // Selected day
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),

          // Default days
          defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
          weekendTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.danger.withOpacity(0.7),
              ),

          // Outside days
          outsideDaysVisible: false,

          // Markers
          markersMaxCount: 1,
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),

        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          weekendStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.danger.withOpacity(0.7),
              ),
        ),

        // Callbacks
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },

        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },

        // Custom builders
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            return _buildDateMarker(date);
          },
        ),
      ),
    );
  }

  /// Build marker for a date based on review status
  Widget? _buildDateMarker(DateTime date) {
    final status = _getDateStatus(date);

    if (status == DateReviewStatus.none) return null;

    Color markerColor;
    IconData? iconData;

    switch (status) {
      case DateReviewStatus.overdue:
        markerColor = AppColors.danger;
        iconData = Icons.circle;
        break;
      case DateReviewStatus.today:
        markerColor = AppColors.warning;
        iconData = Icons.circle;
        break;
      case DateReviewStatus.upcoming:
        markerColor = AppColors.success;
        iconData = Icons.circle;
        break;
      case DateReviewStatus.none:
        return null;
    }

    return Positioned(
      bottom: 4,
      child: Icon(
        iconData,
        size: 6,
        color: markerColor,
      ),
    );
  }

  /// Build legend showing color meanings
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(
            color: AppColors.danger,
            label: 'Overdue',
          ),
          _buildLegendItem(
            color: AppColors.warning,
            label: 'Today',
          ),
          _buildLegendItem(
            color: AppColors.success,
            label: 'Upcoming',
          ),
        ],
      ),
    );
  }

  /// Build a single legend item
  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 8,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Build the list of topics for selected date
  Widget _buildTopicsList() {
    final topics = _getTopicsForDate(_selectedDay);
    final formattedDate = DateFormat('MMM d, y').format(_selectedDay);

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.backgroundDark
          : AppColors.gray50,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.white,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.gray700
                      : AppColors.gray300,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: AppColors.primary,
                  size: 20,
                ),
                ThemeHelper.hSpaceSmall,
                Expanded(
                  child: Text(
                    '$formattedDate - ${topics.length} ${topics.length == 1 ? 'review' : 'reviews'}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Topics list
          Expanded(
            child: topics.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: topics.length,
                    separatorBuilder: (context, index) => ThemeHelper.vSpaceSmall,
                    itemBuilder: (context, index) {
                      return _buildTopicCard(topics[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no topics for selected date
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
          ),
          ThemeHelper.vSpaceMedium,
          Text(
            'No reviews scheduled',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          ThemeHelper.vSpaceSmall,
          Text(
            'Select another date to see reviews',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Build a topic card
  Widget _buildTopicCard(Topic topic) {
    final isOverdue = topic.nextReviewDate.isBefore(DateTime.now());
    final stageDescription = _spacedRepService.getStageDescription(topic.currentStage);

    return InkWell(
      onTap: () => _handleTopicTap(topic),
      borderRadius: ThemeHelper.standardRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          borderRadius: ThemeHelper.standardRadius,
          border: Border.all(
            color: isOverdue
                ? AppColors.danger.withOpacity(0.3)
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.gray700
                    : AppColors.gray300,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: false,
              onChanged: (value) {
                if (value == true) {
                  _handleMarkAsReviewed(topic);
                }
              },
              activeColor: AppColors.success,
            ),

            ThemeHelper.hSpaceSmall,

            // Topic info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    topic.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Metadata
                  Row(
                    children: [
                      // Stage
                      Icon(
                        Icons.layers,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stage ${topic.currentStage + 1} ($stageDescription)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      const SizedBox(width: 12),

                      // Review count
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${topic.reviewCount}x',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      if (isOverdue) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.warning,
                          size: 14,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Overdue',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle topic tap - navigate to detail screen
  Future<void> _handleTopicTap(Topic topic) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicDetailScreen(topic: topic),
      ),
    );

    // Reload if topic was updated
    if (result == true) {
      _loadTopics();
    }
  }

  /// Handle marking topic as reviewed
  Future<void> _handleMarkAsReviewed(Topic topic) async {
    try {
      await _spacedRepService.markAsReviewed(topic.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${topic.title} marked as reviewed!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reload topics
      _loadTopics();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as reviewed: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// Review status for a date
enum DateReviewStatus {
  none,
  overdue,
  today,
  upcoming,
}
