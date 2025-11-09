# MemoryFlow

A beautiful spaced repetition app built with Flutter for effective learning and memory retention.

## Features

- Spaced repetition algorithm with 5 interval stages (1, 3, 7, 14, 30 days)
- Organize flashcards into decks
- Track your learning progress with statistics
- Calendar view to see review schedule
- Local notifications for review reminders
- Dark mode support
- Google Drive sync (coming soon)

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart          # App-wide constants and configurations
├── models/
│   ├── flashcard.dart               # Flashcard data model
│   ├── deck.dart                    # Deck data model
│   └── review_session.dart          # Review session data model
├── screens/
│   └── home_screen.dart             # Main home screen with navigation
├── services/
│   ├── database_service.dart        # SQLite database operations
│   ├── spaced_repetition_service.dart  # Spaced repetition algorithm
│   └── notification_service.dart    # Local notifications
├── utils/
│   ├── date_formatter.dart          # Date formatting utilities
│   └── validators.dart              # Form validation utilities
├── widgets/
│   ├── flashcard_widget.dart        # Flashcard display with flip animation
│   ├── deck_card.dart               # Deck card widget
│   └── difficulty_button.dart       # Difficulty selection button
└── main.dart                        # App entry point
```

## Color Scheme

- **Primary**: #6366F1 (Indigo)
- **Secondary**: #8B5CF6 (Purple)
- **Success**: #10B981 (Green)
- **Warning**: #F59E0B (Orange)
- **Danger**: #EF4444 (Red)

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- **flutter_markdown**: Markdown rendering support
- **path_provider**: Access to file system directories
- **sqflite**: SQLite database for local storage
- **flutter_local_notifications**: Local push notifications
- **google_sign_in**: Google authentication
- **googleapis**: Google API integration
- **provider**: State management
- **intl**: Internationalization and date formatting
- **table_calendar**: Calendar widget
- **shared_preferences**: Key-value storage
- **uuid**: Unique ID generation

## Spaced Repetition Intervals

The app uses the following interval stages:

1. **Stage 0**: 1 day
2. **Stage 1**: 3 days
3. **Stage 2**: 7 days
4. **Stage 3**: 14 days
5. **Stage 4**: 30 days

Cards progress through stages based on your difficulty rating:
- **Again**: Reset to Stage 0
- **Hard**: Go back one stage
- **Good**: Advance to next stage
- **Easy**: Skip ahead one stage

## License

This project is private and not licensed for public use.
# memory-flow-flutter
