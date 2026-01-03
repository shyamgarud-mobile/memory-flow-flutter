# MemoryFlow - App Development Milestones

## Project Overview
**App Name:** MemoryFlow  
**Type:** Spaced Repetition Learning App  
**Platform:** Flutter (Android & iOS)  
**Storage:** Local SQLite + Google Drive Backup

---

## MILESTONE 1: Project Setup & Basic UI
**Duration:** 1-2 days  
**Status:** 🔲 Not Started

### Goals
- Flutter project initialized
- Basic navigation working
- Placeholder screens

### Tasks
- [ ] Create new Flutter project
- [ ] Set up folder structure (lib/screens, lib/models, lib/services, lib/widgets)
- [ ] Add dependencies (flutter_markdown, path_provider, sqflite, etc.)
- [ ] Create basic theme/colors
- [ ] Build navigation structure (bottom nav or drawer)
- [ ] Create placeholder screens:
  - Home/Dashboard
  - Topic List
  - Add Topic
  - Settings
  - Calendar

### Deliverable
Empty app with navigation between screens

### Dependencies
```yaml
dependencies:
  flutter_markdown: ^0.6.18
  path_provider: ^2.1.1
  sqflite: ^2.3.0
  flutter_local_notifications: ^16.3.0
  google_sign_in: ^6.2.1
  googleapis: ^11.4.0
  provider: ^6.1.1
  intl: ^0.18.1
  table_calendar: ^3.0.9
  shared_preferences: ^2.2.2
  uuid: ^4.2.2
```

---

## MILESTONE 2: Markdown Editor & Viewer
**Duration:** 2-3 days  
**Status:** 🔲 Not Started

### Goals
- User can write and view markdown
- No persistence yet (in-memory only)

### Tasks
- [ ] Create "Add Topic" screen with:
  - Title text field
  - Markdown text editor (multi-line TextField)
- [ ] Create "Topic Viewer" screen with:
  - Markdown renderer (flutter_markdown package)
  - Title display
- [ ] Add preview toggle (edit mode ↔ view mode)
- [ ] Basic markdown toolbar (bold, italic, headers)
- [ ] Navigate from editor → viewer with data

### Deliverable
Can create and view markdown topics (lost on app restart)

### Key Components
- `lib/screens/add_topic_screen.dart`
- `lib/screens/topic_detail_screen.dart`
- `lib/widgets/markdown_toolbar.dart`

---

## MILESTONE 3: Local File Storage
**Duration:** 2-3 days  
**Status:** 🔲 Not Started

### Goals
- Save markdown files to device
- Load them back on app restart

### Tasks
- [ ] Implement file service:
  - Get app documents directory (path_provider)
  - Create "topics" folder
  - Save markdown as `{uuid}.md`
- [ ] Create Topic model:
  ```dart
  class Topic {
    String id;
    String title;
    String filePath;
    DateTime createdAt;
  }
  ```
- [ ] Save topic metadata as JSON file (topics_index.json)
- [ ] Load topics on app startup
- [ ] Display topic list on home screen
- [ ] Tap topic → open viewer with file content

### Deliverable
Topics persist between app restarts, stored as markdown files

### Key Components
- `lib/services/file_service.dart`
- `lib/services/topics_index_service.dart`
- `lib/models/topic.dart`

---

## MILESTONE 4: Local Database (SQLite)
**Duration:** 2-3 days  
**Status:** 🔲 Not Started

### Goals
- Replace JSON with proper database
- Store all metadata efficiently

### Tasks
- [ ] Add sqflite package
- [ ] Create database schema:
  ```sql
  CREATE TABLE topics (
    id TEXT PRIMARY KEY,
    title TEXT,
    file_path TEXT,
    created_at INTEGER,
    current_stage INTEGER,
    next_review_date INTEGER,
    last_reviewed_at INTEGER,
    review_count INTEGER
  )
  ```
- [ ] Create DatabaseService class
- [ ] Implement CRUD operations
- [ ] Migrate from JSON to SQLite
- [ ] Add delete topic functionality

### Deliverable
Robust local storage with SQLite + markdown files

### Key Components
- `lib/services/database_service.dart`
- Database schema with indexes

---

## MILESTONE 5: Spaced Repetition Logic
**Duration:** 3-4 days  
**Status:** 🔲 Not Started

### Goals
- Calculate review dates
- Show due topics
- Track review progress

### Tasks
- [ ] Create SpacedRepetitionService:
  - `calculateNextReviewDate(currentStage)`
  - `markAsReviewed(topicId)`
  - `getDueTopics()`
  - `getUpcomingTopics()`
- [ ] Implement interval stages (1d, 3d, 7d, 14d, 30d)
- [ ] Add "Mark as Reviewed" button in viewer
- [ ] Update UI to show:
  - Next review date on each topic
  - "Due today" badge/color
  - Days until next review
- [ ] Filter topics by:
  - Due today
  - Upcoming this week
  - All topics
- [ ] Add reset/restart option for topics

### Deliverable
Full spaced repetition scheduling working locally

### Key Components
- `lib/services/spaced_repetition_service.dart`
- Review intervals: [1, 3, 7, 14, 30] days
- Progress tracking

---

## MILESTONE 5.5: Calendar & Custom Scheduling
**Duration:** 3-4 days  
**Status:** 🔲 Not Started

### Goals
- User can set custom review dates/times
- Visual calendar view of all reviews
- Override automatic spaced repetition when needed

### Tasks
- [ ] Add table_calendar package
- [ ] Update Topic model with custom schedule fields
- [ ] Add "Set Custom Review Date" option
- [ ] Create calendar view screen showing:
  - Monthly calendar
  - Dots/badges on dates with reviews
  - Color coding (overdue/today/upcoming)
- [ ] Tap on date → show topics due that day
- [ ] Custom date/time picker dialog
- [ ] Integration with spaced repetition logic
- [ ] Per-topic notification time settings

### Deliverable
Full calendar interface with custom scheduling

### Key Components
- `lib/screens/calendar_screen.dart`
- `lib/widgets/dialogs/reschedule_dialog.dart`
- `lib/widgets/pickers/custom_date_time_picker.dart`

---

## MILESTONE 6: Local Notifications
**Duration:** 2-3 days  
**Status:** 🔲 Not Started

### Goals
- Daily reminder notifications
- Tap notification → open app

### Tasks
- [ ] Add flutter_local_notifications package
- [ ] Request notification permissions
- [ ] Create NotificationService:
  - Schedule daily check (e.g., 9 AM)
  - Query due topics
  - Send notification with count
- [ ] Handle notification tap:
  - Open app to home screen
  - Show due topics first
- [ ] Add settings for:
  - Enable/disable notifications
  - Choose notification time
- [ ] Test on both Android & iOS

### Deliverable
Daily notifications remind user to review due topics

### Key Components
- `lib/services/notification_service.dart`
- Android notification channels
- iOS notification categories

---

## MILESTONE 7: UI Polish & Statistics
**Duration:** 2-3 days  
**Status:** 🔲 Not Started

### Goals
- Professional-looking UI
- Basic statistics dashboard

### Tasks
- [ ] Improve home screen:
  - Card-based topic list
  - Color coding (overdue=red, today=orange, future=green)
  - Search functionality
- [ ] Add statistics screen:
  - Total topics
  - Topics reviewed today
  - Current streak
  - Review history chart
- [ ] Add edit topic functionality
- [ ] Improve markdown editor
- [ ] Add empty states
- [ ] Loading indicators
- [ ] Error handling & user feedback

### Deliverable
Polished, production-ready local app

### Key Components
- `lib/screens/statistics_screen.dart`
- `lib/widgets/common/custom_card.dart`
- `lib/widgets/common/custom_button.dart`
- `lib/widgets/common/empty_state.dart`

---

## MILESTONE 8: Google Drive Integration
**Duration:** 4-5 days  
**Status:** 🔲 Not Started

### Goals
- Backup to Google Drive
- Restore from Google Drive

### Tasks
- [ ] Add google_sign_in & googleapis packages
- [ ] Implement GoogleDriveService:
  - Authenticate user
  - Create app folder in Drive
  - Upload file
  - Download file
  - List files
- [ ] Create backup functionality:
  - Zip SQLite database + all markdown files
  - Upload to Drive with timestamp
  - Keep last 5 backups
- [ ] Create restore functionality:
  - List available backups
  - Download selected backup
  - Extract and restore local data
- [ ] Add settings screen options:
  - "Connect Google Drive"
  - "Backup now"
  - "Restore from backup"
  - "Auto-backup" toggle

### Deliverable
Manual backup/restore to Google Drive working

### Key Components
- `lib/services/google_drive_service.dart`
- `lib/screens/google_drive_connect_screen.dart`
- `lib/widgets/dialogs/restore_backup_dialog.dart`

---

## MILESTONE 9: Automatic Cloud Sync
**Duration:** 3-4 days  
**Status:** 🔲 Not Started

### Goals
- Automatic background sync
- Multi-device support

### Tasks
- [ ] Implement sync strategy:
  - Track local changes
  - Check for changes periodically
  - Upload only changed files
- [ ] Add conflict resolution:
  - Compare timestamps
  - Last-write-wins or user choice
- [ ] Background sync service:
  - Sync on app open
  - Sync every 6-12 hours
  - Sync after major changes
- [ ] Add sync status indicator:
  - Last synced time
  - Sync in progress
  - Sync errors
- [ ] Handle offline gracefully:
  - Queue changes
  - Sync when back online

### Deliverable
Seamless multi-device sync via Google Drive

### Key Components
- `lib/services/sync_service.dart`
- `lib/services/background_sync_service.dart`
- `lib/widgets/sync/sync_status_indicator.dart`

---

## MILESTONE 10: Testing & Release
**Duration:** 3-5 days  
**Status:** 🔲 Not Started

### Goals
- Bug-free, stable app
- Published to stores

### Tasks
- [ ] Comprehensive testing:
  - All features on Android
  - All features on iOS
  - Edge cases
- [ ] Performance optimization:
  - Large markdown files
  - Many topics (100+)
  - Fast app startup
- [ ] Add onboarding tutorial
- [ ] Create app icon & splash screen
- [ ] Write privacy policy
- [ ] Prepare store listings:
  - Screenshots
  - Description
  - Keywords
- [ ] Build release APK/IPA
- [ ] Submit to Play Store & App Store

### Deliverable
Published app available for download

### Key Components
- `test/` directory with unit tests
- `integration_test/` directory
- App store assets
- Privacy policy document

---

## Optional Future Enhancements

### Phase 2 Features
- [ ] Tags/Categories - Organize topics
- [ ] Rich formatting - Images in markdown
- [ ] Shared topics - Share with friends
- [ ] Web version - Access from browser
- [ ] Import/Export - CSV, Anki decks
- [ ] Advanced statistics - Retention curves, heatmaps
- [ ] Themes - Dark mode, custom colors
- [ ] Widgets - Show due count on home screen
- [ ] iCloud support - For iOS users
- [ ] Voice notes - Record audio with topics
- [ ] AI suggestions - Generate flashcards from text

---

## Progress Tracking

### Completion Status
- ⬜ Not Started
- 🟡 In Progress
- ✅ Completed
- ⚠️ Blocked

### Current Sprint
**Sprint:** N/A  
**Focus:** Project Planning  
**Next Milestone:** Milestone 1 - Project Setup

---

## Notes & Decisions

### Architecture Decisions
1. **Local-first approach**: App works fully offline, cloud is backup/sync
2. **SQLite for metadata**: Fast queries, reliable
3. **Markdown files**: Human-readable, portable
4. **Google Drive**: Free storage for users, no server costs

### Technology Choices
- **State Management**: Provider (simple, official)
- **Database**: SQLite (mature, reliable)
- **Cloud**: Google Drive API (ubiquitous, free tier)
- **Notifications**: flutter_local_notifications (best support)

### Design Principles
- Mobile-first design
- Offline-first functionality
- Privacy-focused (user owns data)
- Simple, intuitive UX
- Fast performance

---

*Last Updated: November 8, 2025*
