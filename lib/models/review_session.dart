import 'package:uuid/uuid.dart';

/// Represents a review session
class ReviewSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int cardsReviewed;
  final int correctCount;
  final int incorrectCount;
  final Duration? totalDuration;
  final Map<String, dynamic>? metadata;

  ReviewSession({
    String? id,
    DateTime? startTime,
    this.endTime,
    this.cardsReviewed = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.totalDuration,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now();

  /// Check if session is active
  bool get isActive => endTime == null;

  /// Calculate accuracy percentage
  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return (correctCount / cardsReviewed) * 100;
  }

  /// Copy with method for immutability
  ReviewSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? cardsReviewed,
    int? correctCount,
    int? incorrectCount,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
  }) {
    return ReviewSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      totalDuration: totalDuration ?? this.totalDuration,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'cards_reviewed': cardsReviewed,
      'correct_count': correctCount,
      'incorrect_count': incorrectCount,
      'total_duration': totalDuration?.inSeconds,
      'metadata': metadata != null ? metadata.toString() : null,
    };
  }

  /// Create from JSON
  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    return ReviewSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      cardsReviewed: json['cards_reviewed'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      incorrectCount: json['incorrect_count'] as int? ?? 0,
      totalDuration: json['total_duration'] != null
          ? Duration(seconds: json['total_duration'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ReviewSession(id: $id, cards: $cardsReviewed, accuracy: ${accuracy.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReviewSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
