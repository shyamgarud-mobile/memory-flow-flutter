/// Utility class for form validation
class Validators {
  /// Validate that a string is not empty
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Use required validator for this
    }
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > max) {
      return '${fieldName ?? 'This field'} must not exceed $max characters';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate that a number is within range
  static String? numberRange(
    String? value, {
    int? min,
    int? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'This field'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'This field'} must not exceed $max';
    }

    return null;
  }

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  /// Validate flashcard content (not empty and reasonable length)
  static String? flashcardContent(String? value, {String? side}) {
    final sideLabel = side ?? 'Content';

    final requiredError = required(value, fieldName: sideLabel);
    if (requiredError != null) return requiredError;

    final minError = minLength(value, 1, fieldName: sideLabel);
    if (minError != null) return minError;

    final maxError = maxLength(value, 1000, fieldName: sideLabel);
    if (maxError != null) return maxError;

    return null;
  }

  /// Validate deck name
  static String? deckName(String? value) {
    final requiredError = required(value, fieldName: 'Deck name');
    if (requiredError != null) return requiredError;

    final minError = minLength(value, 1, fieldName: 'Deck name');
    if (minError != null) return minError;

    final maxError = maxLength(value, 50, fieldName: 'Deck name');
    if (maxError != null) return maxError;

    return null;
  }
}
