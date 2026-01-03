# Strategic Claude Pro Plan for MemoryFlow Development

## Executive Summary

**Your Plan:** Claude Pro  
**Available:** Unlimited Claude Sonnet 4.5 + Limited Claude Opus 4.1  
**Project:** MemoryFlow Spaced Repetition App  
**Estimated Total Tokens:** 161K tokens  
**Estimated Cost with API:** ~$6.00  
**Your Cost with Pro:** $0.00 ✅

---

## Claude Model Comparison

### Claude Sonnet 4.5 (Recommended for 95% of tasks)
**Strengths:**
- ✅ Excellent at code generation
- ✅ Fast response times
- ✅ Strong architectural thinking
- ✅ Great with Flutter/Dart
- ✅ Cost-effective
- ✅ **Unlimited on Pro plan**

**Best For:**
- Widget creation
- Service class implementation
- Database schema
- UI/UX design
- Standard CRUD operations
- Debugging simple issues
- Testing code

**API Pricing:** $3 input / $15 output per 1M tokens

---

### Claude Opus 4.1 (Strategic use only)
**Strengths:**
- ✅ Deeper architectural analysis
- ✅ Complex problem solving
- ✅ Better at difficult debugging
- ✅ More thorough code review

**Best For:**
- Complex sync architecture decisions
- Difficult-to-find bugs
- Performance optimization analysis
- Major refactoring decisions

**API Pricing:** $15 input / $75 output per 1M tokens

**⚠️ Limited on Pro plan - Use strategically!**

---

## Token Usage Strategy

### Phase Distribution

| Phase | Sonnet 4.5 | Opus 4.1 | Total |
|-------|------------|----------|-------|
| Phase 1: Foundation | 55.5K | 0K | 55.5K |
| Phase 2: Core Logic | 48K | 0K | 48K |
| Phase 3: Cloud Sync | 30K | 9.5K | 39.5K |
| Phase 4: Testing | 18K | 0K | 18K |
| **TOTAL** | **151.5K** | **9.5K** | **161K** |

### Model Usage Breakdown
- **Sonnet 4.5:** 94.4% of project (FREE with Pro)
- **Opus 4.1:** 5.6% of project (1 strategic session)

---

## Development Plan with Prompts

---

## PHASE 1: Foundation (Days 1-11)

### Session 1.1: Project Setup (Day 1)
**Model:** Claude Sonnet 4.5  
**Duration:** 2-3 hours  
**Estimated Tokens:** ~15K output

#### Prompt:
```
Create a Flutter project structure for a spaced repetition app called "MemoryFlow". 

Requirements:

1. Folder structure:
   - lib/screens/
   - lib/widgets/
   - lib/models/
   - lib/services/
   - lib/utils/
   - lib/constants/

2. pubspec.yaml with these dependencies:
   - flutter_markdown: ^0.6.18
   - path_provider: ^2.1.1
   - sqflite: ^2.3.0
   - flutter_local_notifications: ^16.3.0
   - google_sign_in: ^6.2.1
   - googleapis: ^11.4.0
   - provider: ^6.1.1
   - intl: ^0.18.1
   - table_calendar: ^3.0.9
   - shared_preferences: ^2.2.2
   - uuid: ^4.2.2

3. Main.dart with:
   - Material app setup
   - Theme configuration with this color scheme:
     Primary: #6366F1 (Indigo)
     Secondary: #8B5CF6 (Purple)
     Success: #10B981 (Green)
     Warning: #F59E0B (Orange)
     Danger: #EF4444 (Red)
   - Dark mode support

4. Constants file (lib/constants/app_constants.dart) with:
   - Color definitions
   - Text styles
   - Spacing values
   - Interval stages [1, 3, 7, 14, 30] days

Show me the complete file structure and all code files.
```

**Expected Output:** ~800 lines of code  
**Deliverable:** Complete project setup

---

#### Prompt 1.2: Navigation Structure
```
Create the bottom navigation structure for MemoryFlow with 5 tabs:

1. Home/Dashboard (home screen)
2. Calendar View (calendar screen)
3. Add Topic (add topic screen - center, elevated)
4. All Topics (topics list screen)
5. Settings (settings screen)

Requirements:
- Use BottomNavigationBar
- Center button (Add) should be elevated/highlighted
- Implement PageView or IndexedStack for switching
- Add screen placeholders with title and icon
- Make it work with state management (Provider preferred)

Create:
- lib/screens/main_navigation.dart
- lib/screens/home_screen.dart (placeholder)
- lib/screens/calendar_screen.dart (placeholder)
- lib/screens/add_topic_screen.dart (placeholder)
- lib/screens/topics_list_screen.dart (placeholder)
- lib/screens/settings_screen.dart (placeholder)

Show complete implementation.
```

**Expected Output:** ~600 lines of code

---

#### Prompt 1.3: Common Widgets
```
Create reusable widgets and theme helpers:

1. lib/widgets/common/custom_card.dart
   - Styled card with shadow, padding, rounded corners
   - Props: child, onTap, color, borderColor

2. lib/widgets/common/custom_button.dart
   - Primary button (filled)
   - Secondary button (outlined)
   - Text button
   - Props: text, onPressed, loading state, icon

3. lib/widgets/common/topic_status_badge.dart
   - Shows status: Overdue (red), Due Today (orange), Upcoming (green)
   - Props: status enum, small/large size

4. lib/widgets/common/empty_state.dart
   - Shows icon, title, subtitle, action button
   - Props: icon, title, subtitle, buttonText, onButtonPressed

5. lib/utils/theme_helper.dart
   - Helper methods for consistent spacing, text styles
   - Status color methods

Show complete implementation with examples.
```

**Expected Output:** ~500 lines of code

**Session 1 Total:** ~15K tokens

---

### Session 1.2: Markdown Editor (Day 2-3)
**Model:** Claude Sonnet 4.5  
**Duration:** 3-4 hours  
**Estimated Tokens:** ~12K output

#### Prompt 2.1: Markdown Editor Screen
```
Create a markdown editor screen for MemoryFlow:

File: lib/screens/add_topic_screen.dart

Requirements:
1. Title TextField (single line)
2. Multi-line TextField for markdown content
3. Toolbar with buttons for:
   - Bold (**text**)
   - Italic (*text*)
   - Heading (# )
   - Bullet list (- )
   - Code block (```)
   - Insert link
4. Toggle between Edit and Preview modes
5. Preview shows rendered markdown using flutter_markdown
6. Character/word count display
7. Save button (validates title is not empty)

Include:
- State management for edit/preview toggle
- Markdown toolbar widget
- Text insertion helpers
- Form validation

Show complete implementation.
```

**Expected Output:** ~700 lines of code

---

#### Prompt 2.2: Topic Viewer
```
Create a topic viewer screen:

File: lib/screens/topic_detail_screen.dart

Requirements:
1. Display topic title (large, bold)
2. Show metadata:
   - Next review date and time
   - Current stage (e.g., "Stage 3 of 5 - 1 week")
   - Review count
   - Progress bar showing stage completion
3. Render markdown content with flutter_markdown
4. Styled code blocks, headings, lists
5. Bottom action buttons:
   - "Mark as Reviewed" (primary, full width)
   - "Reschedule" (secondary)
6. App bar with back button and menu (⋮)
7. Menu options: Edit, Delete, Reset, Share

Include:
- Topic model class
- Pass topic data to screen
- Action handlers (print statements for now)

Show complete implementation with sample data.
```

**Expected Output:** ~600 lines of code

**Session 2 Total:** ~12K tokens

---

### Session 1.3: File Storage (Day 4-5)
**Model:** Claude Sonnet 4.5  
**Duration:** 3-4 hours  
**Estimated Tokens:** ~10K output

#### Prompt 3.1: File Service
```
Create a file storage service for markdown files:

File: lib/services/file_service.dart

Requirements:
1. Get app documents directory using path_provider
2. Create "topics" folder if not exists
3. Methods:
   - saveMarkdownFile(String id, String content)
     → Saves to {id}.md
   - readMarkdownFile(String id)
     → Returns file content
   - deleteMarkdownFile(String id)
     → Deletes file
   - getAllMarkdownFiles()
     → Returns list of file IDs

4. Error handling for file operations
5. Async/await pattern
6. Singleton pattern for service

Also create:
- lib/models/topic.dart with:
  - id (String, UUID)
  - title (String)
  - filePath (String)
  - createdAt (DateTime)
  - currentStage (int, 0-4)
  - nextReviewDate (DateTime)
  - lastReviewedAt (DateTime?)
  - reviewCount (int)
  - toJson() and fromJson() methods

Show complete implementation with comments.
```

**Expected Output:** ~500 lines of code

---

#### Prompt 3.2: Topics Index Service
```
Create a service to manage topics metadata:

File: lib/services/topics_index_service.dart

Requirements:
1. Save list of topics to topics_index.json
2. Load topics list on app startup
3. Methods:
   - saveTopicsIndex(List<Topic> topics)
   - loadTopicsIndex() → Returns List<Topic>
   - addTopic(Topic topic)
   - updateTopic(Topic topic)
   - deleteTopic(String id)

4. Handle file not exists (return empty list)
5. JSON serialization/deserialization
6. Singleton pattern

Also update add_topic_screen.dart to:
- Generate UUID for new topic
- Save markdown file
- Add to topics index
- Navigate back to home

Show complete implementation.
```

**Expected Output:** ~400 lines of code

---

#### Prompt 3.3: Home Screen with Topics
```
Update the home screen to display saved topics:

File: lib/screens/home_screen.dart

Requirements:
1. Load topics on screen init
2. Display sections:
   - "Due Today" (filter by nextReviewDate == today)
   - "Upcoming This Week" (next 7 days)
   - Show count in section headers
3. Each topic card shows:
   - Title
   - Status badge (overdue/due/upcoming)
   - Next review date/time
   - Tap → Open topic viewer
4. Pull to refresh
5. Empty state: "No topics yet" with "Create Topic" button
6. Loading indicator while loading

Include:
- State management (Provider or setState)
- Date filtering logic
- Navigation to topic viewer with data

Show complete implementation.
```

**Expected Output:** ~600 lines of code

**Session 3 Total:** ~10K tokens

---

### Session 1.4: SQLite Database (Day 8-9)
**Model:** Claude Sonnet 4.5  
**Duration:** 3-4 hours  
**Estimated Tokens:** ~12K output

#### Prompt 4.1: Database Service
```
Create SQLite database service to replace JSON storage:

File: lib/services/database_service.dart

Requirements:
1. Database schema:
   CREATE TABLE topics (
     id TEXT PRIMARY KEY,
     title TEXT NOT NULL,
     file_path TEXT NOT NULL,
     created_at INTEGER NOT NULL,
     current_stage INTEGER DEFAULT 0,
     next_review_date INTEGER NOT NULL,
     last_reviewed_at INTEGER,
     review_count INTEGER DEFAULT 0,
     use_custom_schedule INTEGER DEFAULT 0,
     custom_review_datetime INTEGER,
     reminder_time TEXT
   )

2. Methods:
   - initDatabase() → Initialize DB
   - insertTopic(Topic topic) → Insert new
   - updateTopic(Topic topic) → Update existing
   - deleteTopic(String id) → Delete by ID
   - getTopic(String id) → Get single topic
   - getAllTopics() → Get all topics
   - getTopicsByDateRange(DateTime start, DateTime end)
   - getDueTopics() → Where nextReviewDate <= now
   - getUpcomingTopics(int days) → Next X days

3. Singleton pattern
4. Error handling
5. Async/await
6. Update Topic model with database methods

Show complete implementation with comments.
```

**Expected Output:** ~700 lines of code

---

#### Prompt 4.2: Migrate to SQLite
```
Update the app to use SQLite instead of JSON:

1. Update lib/services/topics_index_service.dart:
   - Remove JSON logic
   - Use DatabaseService instead
   - Keep same public API for compatibility

2. Update lib/screens/add_topic_screen.dart:
   - Save to database instead of JSON
   - Keep markdown file saving

3. Update lib/screens/home_screen.dart:
   - Load from database
   - Use database queries for filtering

4. Add delete functionality:
   - Swipe to delete on topic cards
   - Confirmation dialog
   - Delete from database + markdown file

5. Update lib/screens/topic_detail_screen.dart:
   - Delete button in menu
   - Update after marking as reviewed

Show all updated files.
```

**Expected Output:** ~800 lines of code

**Session 4 Total:** ~12K tokens

---

**Phase 1 Total Tokens:** ~55.5K tokens  
**Model Used:** 100% Claude Sonnet 4.5  
**Cost with Pro:** FREE ✅

---

## PHASE 2: Core Logic (Days 12-21)

### Session 2.1: Spaced Repetition Service (Day 12-13)
**Model:** Claude Sonnet 4.5  
**Duration:** 4-5 hours  
**Estimated Tokens:** ~15K output

#### Prompt 5.1: SR Service Implementation
```
Create the spaced repetition scheduling service:

File: lib/services/spaced_repetition_service.dart

Requirements:
1. Interval stages array: [1, 3, 7, 14, 30] days
2. Methods:
   - calculateNextReviewDate(int currentStage, DateTime lastReviewed)
     → Returns DateTime for next review
     → If stage 0-4: use intervals[stage]
     → If stage >= 5: keep at 30 days
   
   - markAsReviewed(String topicId)
     → Advance to next stage
     → Calculate next review date
     → Update lastReviewedAt
     → Increment reviewCount
     → Save to database
   
   - resetTopic(String topicId)
     → Set stage to 0
     → Set next review to tomorrow
     → Reset review count to 0
   
   - getDueTopics()
     → Return topics where nextReviewDate <= now
   
   - getUpcomingTopics(int days)
     → Return topics in next X days
   
   - getOverdueTopics()
     → Return topics where nextReviewDate < today

3. Handle custom schedules:
   - If useCustomSchedule is true, respect customReviewDatetime
   - When marking reviewed, ask if should return to auto

4. Singleton pattern
5. Integration with DatabaseService

Show complete implementation with detailed comments and examples.
```

**Expected Output:** ~600 lines of code

---

#### Prompt 5.2: Update Topic Viewer
```
Enhance topic detail screen with spaced repetition:

File: lib/screens/topic_detail_screen.dart

Requirements:
1. Display current stage information:
   - "Stage 3 of 5 (1 week interval)"
   - Progress bar: ━━━━━━░░░░ 60%
   - Review count: "Reviewed 4 times"

2. "Mark as Reviewed" button:
   - Call SpacedRepetitionService.markAsReviewed()
   - Show success animation/dialog:
     ✅ "Great Job!"
     "Next review: Dec 22 (2 weeks)"
     "Stage 4 of 5"
   - Auto-dismiss after 2 seconds
   - Navigate back OR show next due topic

3. "Reschedule" button:
   - Open reschedule dialog (create separately)

4. Menu option: "Reset Progress"
   - Confirmation dialog
   - Call SpacedRepetitionService.resetTopic()

Show complete implementation including success dialog widget.
```

**Expected Output:** ~500 lines of code

---

#### Prompt 5.3: Reschedule Dialog
```
Create a reschedule dialog for topics:

File: lib/widgets/dialogs/reschedule_dialog.dart

Requirements:
1. Quick options buttons:
   - Tomorrow morning (tomorrow at 9 AM)
   - Tomorrow evening (tomorrow at 8 PM)
   - In 3 days (same time)
   - Return to auto schedule

2. Custom date/time section:
   - Date picker button
   - Time picker button
   - Shows selected: "Dec 20, 2024 at 10:00 AM"

3. Save button:
   - Update topic.useCustomSchedule = true
   - Update topic.customReviewDatetime
   - Save to database
   - Close dialog

4. Cancel button

5. Material Design styling

Also create a method in SpacedRepetitionService:
- rescheduleTopicTo(String topicId, DateTime newDateTime, bool isCustom)

Show complete implementation.
```

**Expected Output:** ~400 lines of code

---

#### Prompt 5.4: Enhanced Home Screen
```
Update home screen with better topic organization:

File: lib/screens/home_screen.dart

Requirements:
1. Stats card at top:
   - 🔥 Current streak (days)
   - 📚 Total topics
   - ✅ Reviewed today count

2. Three sections with counts:
   - 🔴 OVERDUE (count) - Red, sorted by most overdue first
   - 🟠 DUE TODAY (count) - Orange, sorted by time
   - 🟢 UPCOMING (count) - Green, show next 5, "View All" button

3. Each topic card shows:
   - Status icon/color
   - Title (bold)
   - Due/overdue information:
     * "2 hours overdue"
     * "Due in 1 hour"
     * "Tomorrow at 9 AM"
   - Stage indicator: "Stage 3 • 📝"

4. Long press actions:
   - Mark as reviewed
   - Reschedule
   - Open

5. Pull to refresh
6. Empty state for "All caught up! 🎉"

Show complete implementation with all widgets.
```

**Expected Output:** ~800 lines of code

**Session 5 Total:** ~15K tokens

---

### Session 2.2: Calendar & Custom Scheduling (Day 15-16)
**Model:** Claude Sonnet 4.5  
**Duration:** 4-5 hours  
**Estimated Tokens:** ~14K output

#### Prompt 6.1: Calendar View
```
Create a calendar view screen:

File: lib/screens/calendar_screen.dart

Requirements:
1. Use table_calendar package
2. Month view showing current month
3. Mark dates with reviews:
   - Red dot: Has overdue reviews
   - Orange dot: Has reviews today
   - Green dot: Has upcoming reviews
   - Blue checkmark: All completed

4. Bottom section showing selected date's topics:
   - Initially shows today's topics
   - Updates when tapping date
   - Header: "Dec 15, 2024 - 3 reviews"
   - List of topics for that date
   - Each with checkbox to mark reviewed
   - Tap topic → Open viewer

5. Navigation: < December 2024 >
6. Legend showing color meanings
7. Load all topics and map to dates efficiently

Show complete implementation with date filtering logic.
```

**Expected Output:** ~700 lines of code

---

#### Prompt 6.2: Date/Time Pickers
```
Create custom date and time picker screens:

File: lib/widgets/pickers/custom_date_time_picker.dart

Requirements:
1. DateTimePicker widget that shows:
   - Selected date and time
   - Two buttons: "Change Date" and "Change Time"
   - Nice Material Design styling

2. Uses Flutter's showDatePicker and showTimePicker
3. Returns DateTime when selected
4. Props:
   - initialDateTime
   - onDateTimeSelected(DateTime)
   - minimumDate (default: today)
   - label

Also update reschedule_dialog.dart to use this picker.

Show complete implementation with examples.
```

**Expected Output:** ~300 lines of code

---

#### Prompt 6.3: Schedule Settings in Add Topic
```
Update add topic screen with scheduling options:

File: lib/screens/add_topic_screen.dart

Requirements:
1. Add "Schedule" section with two options:
   - ⚡ Auto (starts tomorrow) - Default selected
   - 📅 Custom Date/Time

2. When "Auto" selected:
   - Show: "First review: Tomorrow at 9:00 AM"
   - Uses default notification time from settings

3. When "Custom" selected:
   - Show DateTimePicker widget
   - User chooses specific date/time

4. Add "Reminder Time" section:
   - Show current reminder time
   - Button to change
   - Uses TimePicker

5. When saving:
   - If auto: calculate first review (tomorrow)
   - If custom: use selected datetime
   - Save markdown file
   - Insert into database with schedule info

Show complete implementation.
```

**Expected Output:** ~400 lines of code

**Session 6 Total:** ~14K tokens

---

### Session 2.3: Notifications & UI Polish (Day 17-21)
**Model:** Claude Sonnet 4.5  
**Duration:** 4-5 hours  
**Estimated Tokens:** ~13K output

#### Prompt 7.1: Notification Service
```
Create notification service:

File: lib/services/notification_service.dart

Requirements:
1. Initialize flutter_local_notifications
2. Request permissions (Android 13+, iOS)
3. Methods:
   - scheduleDailyReminder(TimeOfDay time)
     → Schedule daily at specific time
     → Check for due topics
     → Send notification with count

   - scheduleTopicReminder(String topicId, DateTime dateTime)
     → Schedule notification for specific topic
     
   - cancelTopicReminder(String topicId)
   
   - handleNotificationTap(String? payload)
     → Open app to specific topic or home

4. Notification content:
   Title: "📚 MemoryFlow"
   Body: "3 topics due today"
   Action buttons:
     - "Review Now"
     - "Snooze 1h"

5. Android notification channel setup
6. iOS notification categories
7. Background notification handling

Show complete implementation for both platforms with detailed comments.
```

**Expected Output:** ~700 lines of code

---

#### Prompt 7.2: Settings Screen
```
Create complete settings screen:

File: lib/screens/settings_screen.dart

Requirements:
1. NOTIFICATIONS section:
   - Daily Reminder toggle
   - Reminder Time selector (shows time picker)
   - Evening Reminder toggle
   - Overdue Alerts toggle
   - Quiet Hours (from/to time)

2. CLOUD BACKUP section (placeholder for now):
   - "Google Drive: Not Connected"
   - "Connect" button (shows coming soon)
   - Auto Backup toggle (disabled)
   - Last Backup: "Never"
   - [Backup Now] button (disabled)

3. REVIEW SETTINGS section:
   - Show interval stages: "1d, 3d, 7d, 14d, 30d"
   - [Customize Intervals] button (shows dialog with warning)

4. APPEARANCE section:
   - Theme: Light/Dark/System
   - Font Size: Small/Medium/Large

5. ABOUT section:
   - Version: 1.0.0
   - [Privacy Policy] button
   - [Help & Support] button

6. Save settings to shared_preferences
7. Apply settings immediately (theme, notifications)

Show complete implementation with settings model class.
```

**Expected Output:** ~800 lines of code

---

#### Prompt 7.3: Statistics Dashboard
```
Create statistics/progress screen:

File: lib/screens/statistics_screen.dart

Requirements:
1. Overview section:
   - 🔥 Current Streak (calculate from reviews)
   - 🏆 Longest Streak
   - ✅ Total Reviews
   - 📚 Total Topics

2. This Week chart:
   - Bar chart showing reviews per day (M-S)
   - Use simple CustomPaint or packages
   - Show review counts

3. By Stage distribution:
   - Horizontal bar chart
   - Stage 1 (1d): █ 2 topics
   - Stage 2 (3d): ███ 5 topics
   - Stage 3 (1w): █████ 8 topics
   - Stage 4 (2w): ███ 5 topics
   - Stage 5 (1m): █ 4 topics

4. Achievements section:
   - List of achievements with checkmarks
   - 🌟 First Week ✓
   - 🔥 10 Day Streak ✓
   - 📚 25 Topics 🔒 (locked)
   - 💯 100 Reviews ✓

5. Calculate streak logic:
   - Check reviews table for consecutive days
   - Store in shared_preferences for performance

Show complete implementation with calculation methods.
```

**Expected Output:** ~700 lines of code

**Session 7 Total:** ~13K tokens

---

**Phase 2 Total Tokens:** ~48K tokens  
**Model Used:** 100% Claude Sonnet 4.5  
**Cost with Pro:** FREE ✅

---

## PHASE 3: Cloud Integration (Days 22-30)

### Session 3.1: Sync Architecture Planning (Day 22)
**Model:** 🌟 **Claude Opus 4.1** 🌟  
**Duration:** 1-2 hours  
**Estimated Tokens:** ~8K output

#### Strategic Prompt for Opus:
```
I'm building a Flutter spaced repetition app that needs cloud sync via Google Drive. I need your expert architectural guidance.

CONTEXT:
- Local-first app with SQLite + markdown files
- User's personal Google Drive for storage
- Multi-device sync required
- Offline-first approach

DATABASE SCHEMA:
CREATE TABLE topics (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  file_path TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  current_stage INTEGER DEFAULT 0,
  next_review_date INTEGER NOT NULL,
  last_reviewed_at INTEGER,
  review_count INTEGER DEFAULT 0,
  use_custom_schedule INTEGER DEFAULT 0,
  custom_review_datetime INTEGER,
  reminder_time TEXT,
  last_modified INTEGER NOT NULL
)

REQUIREMENTS:
1. Sync strategy for handling:
   - New device setup (initial download)
   - Ongoing bidirectional sync
   - Offline changes on multiple devices
   - Conflict resolution when same topic edited on Device A and B offline

2. What to sync:
   - SQLite database (or just changes?)
   - Markdown files
   - App settings

3. Performance considerations:
   - Don't sync on every change
   - Minimize API calls
   - Handle large numbers of topics (100+)

QUESTIONS:
1. Should I sync the entire database or track changes per-row?
2. Best conflict resolution strategy for my use case?
3. How to handle file deletions across devices?
4. Optimal sync frequency?
5. Should I use operational transformation, CRDTs, or simpler timestamp-based merging?

Please provide:
- Detailed architectural recommendation
- Sync algorithm pseudocode
- Conflict resolution strategy with examples
- Data structure for tracking changes
- Edge cases to handle

Be thorough - I want to implement this correctly the first time.
```

**Expected Output:** ~800 lines of detailed architectural analysis

**Why Opus:** This is a complex architectural decision requiring deep analysis of trade-offs, edge cases, and system design. Worth using your limited Opus quota.

**Session 8A Total:** ~9.5K tokens (including input)

---

### Session 3.2: Google Drive Implementation (Day 22-25)
**Model:** Claude Sonnet 4.5 (back to Sonnet)  
**Duration:** 4-5 hours  
**Estimated Tokens:** ~16K output

#### Prompt 8B.1: Google Drive Service
```
Based on the sync architecture we discussed with Claude Opus, create Google Drive integration service:

File: lib/services/google_drive_service.dart

[PASTE RELEVANT ARCHITECTURE FROM OPUS RESPONSE]

Implementation needed:
1. Authentication:
   - Use google_sign_in package
   - Request Drive scope
   - Handle sign-in flow
   - Store credentials securely

2. Drive Operations:
   - createAppFolder() → Create "MemoryFlow" folder
   - uploadFile(File file, String fileName)
   - downloadFile(String fileId) → Returns File
   - listFiles(String folderQuery) → Returns list
   - deleteFile(String fileId)
   - updateFile(String fileId, File file)

3. Backup Methods:
   - backupDatabase() → Upload SQLite file
   - backupAllMarkdownFiles() → Upload all .md files
   - createFullBackup() → Zip everything, upload with timestamp
   
4. Restore Methods:
   - listAvailableBackups() → Show timestamped backups
   - restoreFromBackup(String backupId) → Download and restore
   
5. Change Tracking:
   - getLastSyncTimestamp()
   - setLastSyncTimestamp(DateTime)
   - Store in shared_preferences

6. Error handling for:
   - No internet
   - Auth failures
   - API quota limits
   - File not found

Show complete implementation with detailed error handling.
```

**Expected Output:** ~900 lines of code

---

#### Prompt 8B.2: Sync Service
```
Create the synchronization service:

File: lib/services/sync_service.dart

Based on our architecture from Claude Opus, implement:

1. Sync Strategy:
   [PASTE THE SPECIFIC STRATEGY OPUS RECOMMENDED]

2. Methods:
   - performFullSync() → Complete sync (initial setup)
   - performIncrementalSync() → Sync only changes
   - detectConflicts() → Find conflicting changes
   - resolveConflicts(List<Conflict> conflicts) → Apply resolution strategy
   
3. Change Detection:
   - Track local changes since last sync
   - Use last_modified column in database
   - Compare with cloud versions

4. Conflict Resolution:
   [IMPLEMENT THE SPECIFIC STRATEGY OPUS RECOMMENDED]

5. Sync UI State:
   - SyncStatus enum (idle, syncing, error, success)
   - Progress tracking
   - Expose as stream for UI

6. Background Sync:
   - Schedule periodic sync (every 6-12 hours)
   - Sync on app resume
   - Sync after significant changes

7. Error Recovery:
   - Retry logic for transient failures
   - Queue failed syncs
   - Alert user of permanent failures

Show complete implementation matching our architectural plan.
```

**Expected Output:** ~1000 lines of code

---

#### Prompt 8B.3: Google Sign-In UI
```
Create Google Drive connection flow:

1. File: lib/screens/google_drive_connect_screen.dart
   Requirements:
   - Beautiful onboarding UI explaining benefits
   - "We'll create a folder: MemoryFlow"
   - "Your data stays private"
   - [Sign in with Google] button
   - Skip option

2. Update settings_screen.dart:
   - Show connection status
   - "Connected as: user@gmail.com"
   - [Disconnect] button
   - [Backup Now] button
   - [Restore from Backup] button
   - Auto Backup toggle
   - Last synced: timestamp

3. File: lib/widgets/dialogs/restore_backup_dialog.dart
   - List available backups with dates
   - Show backup size
   - Warning: "This will replace all local data"
   - Confirmation step

Show complete implementation with Google sign-in flow.
```

**Expected Output:** ~700 lines of code

**Session 8B Total:** ~16K tokens

---

### Session 3.3: Automatic Sync (Day 29-30)
**Model:** Claude Sonnet 4.5  
**Duration:** 3-4 hours  
**Estimated Tokens:** ~10K output

#### Prompt 9.1: Background Sync
```
Implement automatic background synchronization:

File: lib/services/background_sync_service.dart

Requirements:
1. Use workmanager package for background tasks
2. Register periodic task:
   - Every 6-12 hours
   - Only when on WiFi (optional setting)
   - Not during quiet hours

3. Sync triggers:
   - App opened (after 1 hour since last sync)
   - App resumed from background
   - After marking 5+ topics as reviewed
   - Manual trigger from settings

4. Sync queue:
   - Queue changes when offline
   - Persist queue to database
   - Process when back online
   - Retry failed items

5. Sync status notifications:
   - Silent background sync
   - Only notify on errors or conflicts
   - "Sync completed" (optional, in settings)

6. Battery optimization:
   - Don't sync if battery < 15%
   - Respect system battery saver mode
   - Efficient change detection

Show complete implementation for Android and iOS.
```

**Expected Output:** ~600 lines of code

---

#### Prompt 9.2: Sync Status UI
```
Create sync status indicators throughout the app:

1. File: lib/widgets/sync/sync_status_indicator.dart
   - Small widget showing sync status
   - Icons: ✓ synced, ⟳ syncing, ⚠ error, ☁️ offline
   - Last synced time
   - Tap to open sync details

2. Add to app bar in main screens
3. Show sync progress during active sync

4. File: lib/widgets/dialogs/sync_details_dialog.dart
   - Sync history (last 10 syncs)
   - Current status
   - Pending changes count
   - [Sync Now] button
   - [View Conflicts] button (if any)

5. File: lib/screens/conflict_resolution_screen.dart
   - Show conflicts side-by-side:
     Local version | Cloud version
   - Options:
     - Keep local
     - Keep cloud
     - Merge (if possible)
   - Apply to all similar conflicts

Show complete implementation.
```

**Expected Output:** ~700 lines of code

---

#### Prompt 9.3: Final Integration
```
Integrate all sync components with the main app:

1. Update main.dart:
   - Initialize GoogleDriveService
   - Initialize SyncService
   - Register background tasks
   - Check for pending syncs on startup

2. Update database operations:
   - Mark rows as modified (set last_modified timestamp)
   - Trigger sync after X changes
   - Don't trigger sync on sync-initiated changes

3. Handle edge cases:
   - User signs out: Keep local data, clear sync state
   - User deletes app folder: Offer to restore or ignore
   - User has multiple devices: Show device list (optional)

4. Add first-time sync flow:
   - After Google sign-in
   - Check if cloud has data
   - If yes: Offer to restore or merge
   - If no: Upload current data

5. Testing helper:
   - Settings option to "Clear sync state"
   - "Force sync now"
   - "View sync logs"

Show all updated files and integration points.
```

**Expected Output:** ~600 lines of code

**Session 9 Total:** ~10K tokens

---

**Phase 3 Total Tokens:** ~39.5K tokens  
**Model Used:** Opus 4.1 (9.5K) + Sonnet 4.5 (30K)  
**Cost with Pro:** FREE ✅

---

## PHASE 4: Testing & Release (Days 31-35)

### Session 4.1: Testing & Release (Day 33-35)
**Model:** Claude Sonnet 4.5  
**Duration:** 6-8 hours  
**Estimated Tokens:** ~15K output

#### Prompt 10.1: Unit Tests
```
Create comprehensive unit tests:

File: test/services/spaced_repetition_service_test.dart

Test cases:
1. calculateNextReviewDate:
   - Stage 0 → +1 day
   - Stage 4 → +30 days
   - Stage >= 5 → +30 days
   - Custom schedule ignored when useCustomSchedule = false

2. markAsReviewed:
   - Advances stage correctly
   - Updates timestamps
   - Increments review count
   - Saves to database

3. Edge cases:
   - Very old reviews (months overdue)
   - Topics at max stage
   - Invalid topic IDs

Also create tests for:
- test/services/database_service_test.dart
- test/services/sync_service_test.dart
- test/utils/date_helper_test.dart

Use mockito for database mocking.
Show complete test implementation.
```

**Expected Output:** ~800 lines of code

---

#### Prompt 10.2: Integration Tests
```
Create integration tests for critical user flows:

File: integration_test/app_test.dart

Test flows:
1. Create Topic Flow:
   - Open app
   - Tap add button
   - Enter title and content
   - Save
   - Verify appears on home screen

2. Review Topic Flow:
   - Create topic
   - Wait until due
   - Open topic
   - Mark as reviewed
   - Verify stage advanced
   - Verify next review date updated

3. Calendar Flow:
   - Create topics with different dates
   - Open calendar
   - Verify dates marked correctly
   - Tap date
   - Verify correct topics shown

4. Settings Flow:
   - Change notification time
   - Toggle auto-backup
   - Verify saved

5. Sync Flow (mock Google Drive):
   - Create topics
   - Trigger sync
   - Verify uploaded
   - Clear local data
   - Restore from backup
   - Verify restored correctly

Show complete integration tests.
```

**Expected Output:** ~600 lines of code

---

#### Prompt 10.3: Performance Optimization
```
Optimize app performance:

1. Database queries:
   - Add indexes on frequently queried columns
   - Use transactions for batch operations
   - Implement connection pooling

2. List rendering:
   - Use ListView.builder for large lists
   - Implement pagination (load 20 at a time)
   - Cache rendered markdown

3. File operations:
   - Read markdown files lazily (only when viewing)
   - Implement file caching
   - Compress large markdown files

4. Sync optimization:
   - Only sync changed files
   - Use batch uploads
   - Implement delta sync

5. App startup:
   - Lazy load services
   - Show splash while loading
   - Load topics asynchronously

Show all optimization implementations and before/after benchmarks.
```

**Expected Output:** ~500 lines of code

---

#### Prompt 10.4: Release Preparation
```
Prepare app for release:

1. Update pubspec.yaml:
   - Version: 1.0.0
   - Description
   - All dependencies with specific versions

2. Create app icon:
   - Suggest design concept for icon
   - Use flutter_launcher_icons package
   - Generate for Android and iOS

3. Create splash screen:
   - Branded splash
   - Use flutter_native_splash package

4. Update app metadata:
   - android/app/src/main/AndroidManifest.xml:
     * App name
     * Permissions
     * Backup rules
   - ios/Runner/Info.plist:
     * Display name
     * Permissions descriptions

5. Privacy policy:
   - Template for privacy policy
   - What data collected
   - How data used
   - User rights

6. Store listings:
   - Title: "MemoryFlow - Spaced Repetition"
   - Short description (80 chars)
   - Full description (4000 chars)
   - Keywords
   - Screenshots suggestions

Show all files and content.
```

**Expected Output:** ~400 lines + documents

---

#### Prompt 10.5: Build & Deploy
```
Guide me through building and releasing:

1. Android (Play Store):
   - Generate keystore
   - Configure signing in gradle
   - Build release APK/AAB
   - Commands to run

2. iOS (App Store):
   - Configure signing in Xcode
   - Set up provisioning profiles
   - Build archive
   - Upload to TestFlight
   - Commands to run

3. Pre-release checklist:
   - [ ] All tests passing
   - [ ] No console errors
   - [ ] Tested on real devices
   - [ ] Privacy policy published
   - [ ] Store assets ready
   - [ ] Version numbers correct

4. Post-release:
   - Monitor crash reports
   - Respond to reviews
   - Plan for updates

Provide step-by-step instructions and all necessary configurations.
```

**Expected Output:** ~300 lines of instructions

**Session 10 Total:** ~15K tokens

---

**Phase 4 Total Tokens:** ~18K tokens  
**Model Used:** 100% Claude Sonnet 4.5  
**Cost with Pro:** FREE ✅

---

## Complete Token Summary

### By Phase
```
Phase 1 (Foundation):      55.5K tokens
Phase 2 (Core Logic):      48.0K tokens
Phase 3 (Cloud Sync):      39.5K tokens
Phase 4 (Testing):         18.0K tokens
──────────────────────────────────────
TOTAL:                     161.0K tokens
```

### By Model
```
Claude Sonnet 4.5:  151.5K tokens (94.4%)
Claude Opus 4.1:      9.5K tokens ( 5.6%)
──────────────────────────────────────
TOTAL:              161.0K tokens
```

### Cost Analysis
```
IF USING API (without Pro):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sonnet 4.5 Input:   ~18K × $3/M   = $0.05
Sonnet 4.5 Output: ~143K × $15/M  = $2.15
Opus 4.1 Input:    ~1.5K × $15/M  = $0.02
Opus 4.1 Output:     ~8K × $75/M  = $0.60
──────────────────────────────────────
TOTAL API COST:                  ~$2.82

WITH CLAUDE PRO PLAN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sonnet 4.5:        UNLIMITED ✅
Opus 4.1:          Within limits ✅
──────────────────────────────────────
YOUR COST:                      $0.00 ✅

YOU SAVE: 100%! 🎉
```

---

## Best Practices for Claude Pro

### 1. Session Management
- **Work in 2-4 hour focused sessions**
- One feature per session
- Test immediately after code generation
- Keep context window clean
- Start new chat for major phase transitions

### 2. Prompt Strategy
✅ **DO:**
- Be specific about requirements
- Provide context (schema, existing code)
- Ask for complete implementations
- Request comments and examples
- Iterate if output isn't perfect

❌ **DON'T:**
- Write vague prompts
- Assume Claude knows your codebase
- Ask for partial implementations
- Skip error handling requirements

### 3. Model Selection
**Use Sonnet 4.5 for:**
- All code generation (95% of work)
- Widget creation
- Service implementation
- Standard features
- Debugging simple issues

**Use Opus 4.1 only for:**
- Complex architectural decisions
- Sync conflict strategies
- Performance optimization analysis
- Very difficult debugging

### 4. Context Management
- Reference previous code when needed
- Don't let context get too large (>100K tokens)
- Save important architectural decisions externally
- Use comments in code for future reference

### 5. Testing Strategy
- Generate code
- Test immediately
- Fix bugs with follow-up prompts
- Don't accumulate untested code

---

## Recommended Workflow

### Daily Development Cycle

**Morning (9 AM - 12 PM)**
```
1. Review today's milestone goals
2. Open Claude Pro
3. Start with first prompt from schedule
4. Generate code
5. Copy to your IDE
6. Test functionality
7. If issues: follow-up prompt
8. Commit to git
```

**Afternoon (1 PM - 5 PM)**
```
1. Continue with next prompts
2. Integration testing
3. Bug fixes with Claude
4. Documentation
5. End-of-day commit
6. Update milestone progress
```

### Prompt Template
```
[Clear title of what you're building]

Context:
- [What exists already]
- [Relevant code/schema]

Requirements:
1. [Specific requirement 1]
2. [Specific requirement 2]
...

Implementation details:
- [Technology choices]
- [Design patterns]
- [Edge cases to handle]

Show:
- Complete implementation
- Error handling
- Comments
- Examples

File: [exact file path]
```

---

## Emergency Strategies

### If You Hit Opus Limits
1. Wait 24 hours for reset
2. Use Sonnet 4.5 for implementation
3. Simplify sync strategy temporarily
4. Continue with other milestones

### If Stuck on Complex Issue
1. Break problem into smaller pieces
2. Ask Sonnet first
3. Only use Opus if truly necessary
4. Search documentation/forums first

### If Running Behind Schedule
**Focus on MVP first:**
- Skip calendar view
- Skip cloud sync
- Launch with local-only
- Add features in v1.1

---

## Success Metrics

### Development Velocity
- ✅ 1-2 screens per day
- ✅ 1 major feature per 2-3 days
- ✅ Full milestone per week

### Code Quality
- ✅ All generated code compiles
- ✅ No critical bugs
- ✅ Follows Flutter best practices
- ✅ Well-commented

### Claude Usage
- ✅ Sonnet: Unlimited (use liberally)
- ✅ Opus: <10K tokens (1-2 sessions)
- ✅ Total project: ~161K tokens
- ✅ Cost: $0 with Pro

---

## Quick Reference

### When to Use Which Model

| Task | Use Sonnet | Use Opus |
|------|------------|----------|
| Create widget | ✅ | ❌ |
| Write service | ✅ | ❌ |
| Design database | ✅ | ❌ |
| Implement feature | ✅ | ❌ |
| Fix simple bug | ✅ | ❌ |
| Design sync strategy | ❌ | ✅ |
| Complex architecture | ❌ | ✅ |
| Performance analysis | ❌ | ✅ |
| Difficult debugging | ❌ | ✅ |

### Estimated Time Per Session
- Setup & Navigation: 2-3 hours
- Markdown Editor: 3-4 hours
- File Storage: 3-4 hours
- Database: 3-4 hours
- Spaced Repetition: 4-5 hours
- Calendar: 4-5 hours
- Notifications: 3-4 hours
- Cloud Sync Planning: 1-2 hours (Opus)
- Cloud Implementation: 4-5 hours
- Auto Sync: 3-4 hours
- Testing: 6-8 hours

---

## Your Next Steps

### Right Now:
```
1. Save these markdown files to your project
2. Open Claude.ai
3. Copy the first prompt (Session 1.1)
4. Paste and send
5. Start coding!
```

### This Week:
- Complete Phase 1 (Foundation)
- Set up git repository
- Test on real device
- Track progress in milestones doc

### This Month:
- Complete all 4 phases
- Submit to app stores
- Get first users
- Celebrate! 🎉

---

**You're ready to build MemoryFlow!** 🚀

With Claude Pro's unlimited Sonnet access and strategic Opus usage, you have everything you need to create a professional spaced repetition app at zero additional cost.

**Total Project Value:** ~$6 of API usage  
**Your Cost with Pro:** $0  
**Time to Build:** ~5 weeks  
**Result:** Published app on iOS & Android

Let's build this! 💪

---

*Strategic Plan created: November 8, 2025*  
*Last updated: November 8, 2025*
