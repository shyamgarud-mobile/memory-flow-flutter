import 'package:uuid/uuid.dart';

/// Topic model for memory flow items
///
/// Represents a learning topic with spaced repetition tracking.
/// The markdown content is stored in a separate file referenced by filePath.
class Topic {
  /// Unique identifier (UUID)
  final String id;

  /// Topic title
  final String title;

  /// Path to the markdown file containing topic content
  final String filePath;

  /// Date when topic was created
  final DateTime createdAt;

  /// Current stage in spaced repetition (0-4)
  /// - 0: New (review immediately)
  /// - 1: Stage 1 (review in 1 day)
  /// - 2: Stage 2 (review in 3 days)
  /// - 3: Stage 3 (review in 1 week)
  /// - 4: Stage 4 (review in 2 weeks)
  final int currentStage;

  /// Next scheduled review date
  final DateTime nextReviewDate;

  /// Date when topic was last reviewed (null if never reviewed)
  final DateTime? lastReviewedAt;

  /// Total number of times this topic has been reviewed
  final int reviewCount;

  /// Tags associated with the topic (for organization)
  final List<String> tags;

  /// Whether the topic is marked as favorite
  final bool isFavorite;

  /// Whether using custom schedule instead of automatic spaced repetition
  final bool useCustomSchedule;

  /// Custom review datetime (only used if useCustomSchedule is true)
  final DateTime? customReviewDatetime;

  /// UUID generator instance
  static const _uuid = Uuid();

  const Topic({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.currentStage,
    required this.nextReviewDate,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.tags = const [],
    this.isFavorite = false,
    this.useCustomSchedule = false,
    this.customReviewDatetime,
  });

  /// Create a new topic with a generated UUID
  ///
  /// Parameters:
  ///   - title: Topic title
  ///   - filePath: Path to markdown file
  ///   - tags: Optional tags for organization
  ///   - isFavorite: Whether to mark as favorite
  factory Topic.create({
    required String title,
    required String filePath,
    List<String> tags = const [],
    bool isFavorite = false,
  }) {
    final now = DateTime.now();
    return Topic(
      id: _uuid.v4(),
      title: title,
      filePath: filePath,
      createdAt: now,
      currentStage: 0,
      nextReviewDate: now, // New topics are due immediately
      lastReviewedAt: null,
      reviewCount: 0,
      tags: tags,
      isFavorite: isFavorite,
    );
  }

  /// Get stage description for display
  String get stageDescription {
    switch (currentStage) {
      case 0:
        return 'New';
      case 1:
        return '1 day';
      case 2:
        return '3 days';
      case 3:
        return '1 week';
      case 4:
        return '2 weeks';
      default:
        return 'Stage $currentStage';
    }
  }

  /// Get total number of stages
  int get totalStages => 5;

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    return currentStage / totalStages;
  }

  /// Check if review is overdue
  bool get isOverdue {
    return DateTime.now().isAfter(nextReviewDate);
  }

  /// Check if review is due today
  bool get isDueToday {
    final now = DateTime.now();
    return nextReviewDate.year == now.year &&
        nextReviewDate.month == now.month &&
        nextReviewDate.day == now.day;
  }

  /// Get days until next review (negative if overdue)
  int get daysUntilReview {
    final now = DateTime.now();
    final difference = nextReviewDate.difference(now);
    return difference.inDays;
  }

  /// Calculate next review date based on current stage
  DateTime _calculateNextReviewDate() {
    final now = DateTime.now();
    switch (currentStage) {
      case 0:
        return now; // Review immediately
      case 1:
        return now.add(const Duration(days: 1));
      case 2:
        return now.add(const Duration(days: 3));
      case 3:
        return now.add(const Duration(days: 7));
      case 4:
        return now.add(const Duration(days: 14));
      default:
        // For stages beyond 4, use exponential backoff
        final days = 14 * (currentStage - 3);
        return now.add(Duration(days: days));
    }
  }

  /// Mark topic as reviewed and advance to next stage
  ///
  /// Returns a new Topic instance with updated review information
  Topic markAsReviewed() {
    final now = DateTime.now();
    final newStage = currentStage < 4 ? currentStage + 1 : 4;

    return copyWith(
      currentStage: newStage,
      lastReviewedAt: now,
      nextReviewDate: _calculateNextReviewDate(),
      reviewCount: reviewCount + 1,
    );
  }

  /// Reset review progress to stage 0
  Topic resetProgress() {
    return copyWith(
      currentStage: 0,
      nextReviewDate: DateTime.now(),
      reviewCount: 0,
      lastReviewedAt: null,
    );
  }

  /// Reschedule review to a specific date
  Topic reschedule(DateTime newDate) {
    return copyWith(nextReviewDate: newDate);
  }

  /// Create a copy with updated fields
  Topic copyWith({
    String? id,
    String? title,
    String? filePath,
    DateTime? createdAt,
    int? currentStage,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    int? reviewCount,
    List<String>? tags,
    bool? isFavorite,
    bool? useCustomSchedule,
    DateTime? customReviewDatetime,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      currentStage: currentStage ?? this.currentStage,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      useCustomSchedule: useCustomSchedule ?? this.useCustomSchedule,
      customReviewDatetime: customReviewDatetime ?? this.customReviewDatetime,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'currentStage': currentStage,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewCount': reviewCount,
      'tags': tags,
      'isFavorite': isFavorite,
      'useCustomSchedule': useCustomSchedule,
      'customReviewDatetime': customReviewDatetime?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      currentStage: json['currentStage'] as int,
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      reviewCount: json['reviewCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      useCustomSchedule: json['useCustomSchedule'] as bool? ?? false,
      customReviewDatetime: json['customReviewDatetime'] != null
          ? DateTime.parse(json['customReviewDatetime'] as String)
          : null,
    );
  }

  /// Create sample topic for testing (without actual file)
  static Topic sample({String? customFilePath}) {
    final id = _uuid.v4();
    return Topic(
      id: id,
      title: 'Flutter State Management',
      filePath: customFilePath ?? 'topics/$id.md',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      currentStage: 3,
      nextReviewDate: DateTime.now().add(const Duration(days: 2)),
      lastReviewedAt: DateTime.now().subtract(const Duration(days: 7)),
      reviewCount: 8,
      tags: ['Flutter', 'State Management', 'Development'],
      isFavorite: true,
    );
  }

  /// Sample markdown content for testing
  static String get sampleContent => '''# Flutter State Management

## Overview
Flutter provides several approaches to manage state in your applications.

### Popular Solutions
- **Provider**: Simple and efficient dependency injection
- **Riverpod**: More flexible, compile-safe version of Provider
- **Bloc**: Business Logic Component pattern
- **GetX**: All-in-one solution

## Code Example

\`\`\`dart
class CounterProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
\`\`\`

## Best Practices

1. **Keep state minimal** - Only store what's necessary
2. **Use immutable data** - Prevents unexpected mutations
3. **Separate business logic** - Keep widgets simple

> "State management is about managing complexity, not adding to it."

### When to Use What?

- Small apps: `setState()`
- Medium apps: Provider
- Large apps: Bloc or Riverpod

## Resources

- [Official Docs](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- Provider package
- Riverpod documentation
''';

  @override
  String toString() {
    return 'Topic(id: $id, title: $title, stage: $currentStage/$totalStages, '
        'reviewCount: $reviewCount, nextReview: $nextReviewDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
