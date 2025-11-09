import '../constants/app_constants.dart';
import '../models/flashcard.dart';

/// Service for managing spaced repetition algorithm
class SpacedRepetitionService {
  /// Calculate the next review date based on performance
  static DateTime calculateNextReviewDate({
    required Flashcard card,
    required CardDifficulty difficulty,
  }) {
    int newStage = card.repetitionStage;

    switch (difficulty) {
      case CardDifficulty.again:
        // Reset to beginning
        newStage = 0;
        break;
      case CardDifficulty.hard:
        // Stay at same stage or go back one
        newStage = card.repetitionStage > 0 ? card.repetitionStage - 1 : 0;
        break;
      case CardDifficulty.good:
        // Move to next stage
        newStage = card.repetitionStage + 1;
        if (newStage >= SpacedRepetitionIntervals.intervals.length) {
          newStage = SpacedRepetitionIntervals.intervals.length - 1;
        }
        break;
      case CardDifficulty.easy:
        // Skip ahead one stage
        newStage = card.repetitionStage + 2;
        if (newStage >= SpacedRepetitionIntervals.intervals.length) {
          newStage = SpacedRepetitionIntervals.intervals.length - 1;
        }
        break;
    }

    return SpacedRepetitionIntervals.calculateNextReviewDate(newStage);
  }

  /// Update flashcard after review
  static Flashcard updateCardAfterReview({
    required Flashcard card,
    required CardDifficulty difficulty,
  }) {
    final now = DateTime.now();
    final nextReviewDate = calculateNextReviewDate(
      card: card,
      difficulty: difficulty,
    );

    int newStage = card.repetitionStage;
    switch (difficulty) {
      case CardDifficulty.again:
        newStage = 0;
        break;
      case CardDifficulty.hard:
        newStage = card.repetitionStage > 0 ? card.repetitionStage - 1 : 0;
        break;
      case CardDifficulty.good:
        newStage = card.repetitionStage + 1;
        if (newStage >= SpacedRepetitionIntervals.intervals.length) {
          newStage = SpacedRepetitionIntervals.intervals.length - 1;
        }
        break;
      case CardDifficulty.easy:
        newStage = card.repetitionStage + 2;
        if (newStage >= SpacedRepetitionIntervals.intervals.length) {
          newStage = SpacedRepetitionIntervals.intervals.length - 1;
        }
        break;
    }

    final isCorrect = difficulty == CardDifficulty.good ||
                      difficulty == CardDifficulty.easy;

    return card.copyWith(
      repetitionStage: newStage,
      lastReviewDate: now,
      nextReviewDate: nextReviewDate,
      totalReviews: card.totalReviews + 1,
      correctReviews: isCorrect ? card.correctReviews + 1 : card.correctReviews,
      updatedAt: now,
    );
  }

  /// Get interval description for UI display
  static String getIntervalDescription(int stage) {
    if (stage < 0 || stage >= SpacedRepetitionIntervals.intervals.length) {
      return 'Unknown';
    }

    final days = SpacedRepetitionIntervals.intervals[stage];
    if (days == 1) return '1 day';
    if (days < 7) return '$days days';
    if (days == 7) return '1 week';
    if (days < 30) return '${(days / 7).round()} weeks';
    return '${(days / 30).round()} month${days >= 60 ? 's' : ''}';
  }

  /// Calculate estimated time until mastery
  static Duration estimateTimeToMastery(Flashcard card) {
    final currentStage = card.repetitionStage;
    final maxStage = SpacedRepetitionIntervals.intervals.length - 1;

    int totalDays = 0;
    for (int i = currentStage; i < maxStage; i++) {
      totalDays += SpacedRepetitionIntervals.intervals[i];
    }

    return Duration(days: totalDays);
  }

  /// Get cards that should be reviewed today
  static List<Flashcard> getCardsForToday(List<Flashcard> allCards) {
    final now = DateTime.now();
    return allCards.where((card) {
      if (card.nextReviewDate == null) return true;
      final reviewDate = card.nextReviewDate!;
      return reviewDate.year == now.year &&
             reviewDate.month == now.month &&
             reviewDate.day == now.day;
    }).toList();
  }

  /// Calculate retention rate for a set of cards
  static double calculateRetentionRate(List<Flashcard> cards) {
    if (cards.isEmpty) return 0.0;

    final totalReviews = cards.fold<int>(
      0,
      (sum, card) => sum + card.totalReviews,
    );

    if (totalReviews == 0) return 0.0;

    final totalCorrect = cards.fold<int>(
      0,
      (sum, card) => sum + card.correctReviews,
    );

    return (totalCorrect / totalReviews) * 100;
  }

  /// Get card difficulty recommendation based on performance
  static CardDifficulty recommendDifficulty(Flashcard card) {
    final successRate = card.successRate;

    if (successRate >= 90) return CardDifficulty.easy;
    if (successRate >= 70) return CardDifficulty.good;
    if (successRate >= 50) return CardDifficulty.hard;
    return CardDifficulty.again;
  }
}
