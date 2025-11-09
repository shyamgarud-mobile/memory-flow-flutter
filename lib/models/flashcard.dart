import 'package:uuid/uuid.dart';

/// Represents a flashcard in the spaced repetition system
class Flashcard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final int repetitionStage;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
  final int totalReviews;
  final int correctReviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final Map<String, dynamic>? metadata;

  Flashcard({
    String? id,
    required this.deckId,
    required this.front,
    required this.back,
    this.repetitionStage = 0,
    this.lastReviewDate,
    this.nextReviewDate,
    this.totalReviews = 0,
    this.correctReviews = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isArchived = false,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate success rate as a percentage
  double get successRate {
    if (totalReviews == 0) return 0.0;
    return (correctReviews / totalReviews) * 100;
  }

  /// Check if the card is due for review
  bool get isDue {
    if (nextReviewDate == null) return true;
    return DateTime.now().isAfter(nextReviewDate!);
  }

  /// Copy with method for immutability
  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    int? repetitionStage,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    int? totalReviews,
    int? correctReviews,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    Map<String, dynamic>? metadata,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      repetitionStage: repetitionStage ?? this.repetitionStage,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      totalReviews: totalReviews ?? this.totalReviews,
      correctReviews: correctReviews ?? this.correctReviews,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deck_id': deckId,
      'front': front,
      'back': back,
      'repetition_stage': repetitionStage,
      'last_review_date': lastReviewDate?.toIso8601String(),
      'next_review_date': nextReviewDate?.toIso8601String(),
      'total_reviews': totalReviews,
      'correct_reviews': correctReviews,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
      'metadata': metadata != null ? metadata.toString() : null,
    };
  }

  /// Create from JSON
  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      repetitionStage: json['repetition_stage'] as int? ?? 0,
      lastReviewDate: json['last_review_date'] != null
          ? DateTime.parse(json['last_review_date'] as String)
          : null,
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.parse(json['next_review_date'] as String)
          : null,
      totalReviews: json['total_reviews'] as int? ?? 0,
      correctReviews: json['correct_reviews'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isArchived: (json['is_archived'] as int?) == 1,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Flashcard(id: $id, front: ${front.substring(0, front.length > 20 ? 20 : front.length)}..., stage: $repetitionStage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Flashcard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
