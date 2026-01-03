import 'package:flutter/material.dart';
import '../widgets/analytics/circular_progress_ring.dart';
import '../widgets/analytics/review_heatmap_widget.dart';
import '../widgets/analytics/learning_velocity_gauge.dart';
import '../models/topic.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

/// Analytics Showcase Screen
///
/// Demonstrates all analytics widgets with real data from the database.
/// Shows circular progress rings, review heatmap, and learning velocity gauge.
class AnalyticsShowcaseScreen extends StatefulWidget {
  const AnalyticsShowcaseScreen({super.key});

  @override
  State<AnalyticsShowcaseScreen> createState() => _AnalyticsShowcaseScreenState();
}

class _AnalyticsShowcaseScreenState extends State<AnalyticsShowcaseScreen> {
  final DatabaseService _db = DatabaseService();
  List<Topic> _topics = [];
  Map<DateTime, int> _reviewData = {};
  double _currentVelocity = 0.0;
  VelocityTrend _velocityTrend = VelocityTrend.steady;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load topics
      final topics = await _db.getAllTopics();

      // Generate review data from topics
      final reviewData = <DateTime, int>{};
      for (var topic in topics) {
        if (topic.lastReviewedAt != null) {
          final date = DateTime(
            topic.lastReviewedAt!.year,
            topic.lastReviewedAt!.month,
            topic.lastReviewedAt!.day,
          );
          reviewData[date] = (reviewData[date] ?? 0) + topic.reviewCount;
        }
      }

      // Calculate velocity (reviews per day over last 7 days)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      int totalReviews = 0;

      reviewData.forEach((date, count) {
        if (date.isAfter(sevenDaysAgo)) {
          totalReviews += count;
        }
      });

      final velocity = totalReviews / 7.0;

      // Determine trend (simple comparison with previous week)
      final fourteenDaysAgo = now.subtract(const Duration(days: 14));
      int previousWeekReviews = 0;

      reviewData.forEach((date, count) {
        if (date.isAfter(fourteenDaysAgo) && date.isBefore(sevenDaysAgo)) {
          previousWeekReviews += count;
        }
      });

      final previousVelocity = previousWeekReviews / 7.0;
      VelocityTrend trend;
      if (velocity > previousVelocity * 1.1) {
        trend = VelocityTrend.accelerating;
      } else if (velocity < previousVelocity * 0.9) {
        trend = VelocityTrend.decelerating;
      } else {
        trend = VelocityTrend.steady;
      }

      setState(() {
        _topics = topics;
        _reviewData = reviewData;
        _currentVelocity = velocity;
        _velocityTrend = trend;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showDayDetails(DateTime date, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('MMMM d, yyyy').format(date)),
        content: Text('$count review${count == 1 ? '' : 's'} completed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showProgressDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stage Distribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (stage) {
            final count = _topics.where((t) => t.currentStage == stage).length;
            return ListTile(
              leading: CircleAvatar(
                child: Text('$stage'),
              ),
              title: Text('Stage $stage'),
              trailing: Text('$count topics'),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Widgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Circular Progress Rings
                    Text(
                      '1. Circular Progress Rings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shows topic completion stages with animated color gradients',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Example rings for different stages
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(5, (stage) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: CircularProgressRing(
                              currentStage: stage,
                              totalStages: 5,
                              size: 100,
                              onTap: _showProgressDetails,
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Section 2: Review Heatmap
                    Text(
                      '2. Review Activity Heatmap',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'GitHub-style calendar showing your review history',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _reviewData.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('No review data yet. Start reviewing topics!'),
                                ),
                              )
                            : ReviewHeatmapWidget(
                                reviewData: _reviewData,
                                daysToShow: 90,
                                onDayTap: _showDayDetails,
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // Section 3: Learning Velocity Gauge
                    Text(
                      '3. Learning Velocity Gauge',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your learning momentum with a speedometer-style gauge',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: LearningVelocityGauge(
                            currentVelocity: _currentVelocity,
                            maxVelocity: 15.0,
                            trend: _velocityTrend,
                            size: 250,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Stats Summary
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    _buildStatCard(
                      'Total Topics',
                      _topics.length.toString(),
                      Icons.topic,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildStatCard(
                      'Total Reviews',
                      _topics.fold<int>(0, (sum, t) => sum + t.reviewCount).toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildStatCard(
                      'Active Days',
                      _reviewData.length.toString(),
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildStatCard(
                      'Current Velocity',
                      '${_currentVelocity.toStringAsFixed(1)} reviews/day',
                      Icons.speed,
                      Colors.purple,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
