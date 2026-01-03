# MemoryFlow - Project Timeline

## Executive Summary

**Total Duration:** 35 days (~5 weeks)  
**Fast Track Option:** 14 days (2 weeks) for MVP  
**Team Size:** 1 developer  
**Development Approach:** Agile, milestone-based

---

## Timeline Overview

| Phase | Duration | Cumulative | Focus |
|-------|----------|------------|-------|
| Phase 1: Foundation | 8-11 days | Day 11 | Setup, UI, Storage |
| Phase 2: Core Logic | 7-10 days | Day 21 | Spaced Repetition, Calendar |
| Phase 3: Cloud Sync | 7-9 days | Day 30 | Google Drive Integration |
| Phase 4: Polish & Release | 3-5 days | Day 35 | Testing, Release |

---

## Detailed Week-by-Week Breakdown

---

## WEEK 1: Foundation Setup
**Days 1-7** | **Milestones 1-3**

### Monday (Day 1-2): Project Setup
**Time:** 6-8 hours  
**Milestone:** 1 - Project Setup & Basic UI

#### Morning (4 hours)
- [ ] Create Flutter project structure
- [ ] Set up folders (screens, widgets, models, services)
- [ ] Add all dependencies to pubspec.yaml
- [ ] Configure theme and colors
- [ ] Create constants file

#### Afternoon (4 hours)
- [ ] Build bottom navigation structure
- [ ] Create placeholder screens (5 screens)
- [ ] Test navigation flow
- [ ] Commit to git

**Deliverable:** Working app skeleton with navigation

---

### Tuesday-Wednesday (Day 2-3): Markdown Editor
**Time:** 10-12 hours  
**Milestone:** 2 - Markdown Editor & Viewer

#### Tuesday Morning (4 hours)
- [ ] Create Add Topic screen
- [ ] Title input field
- [ ] Multi-line markdown text editor
- [ ] Basic styling

#### Tuesday Afternoon (4 hours)
- [ ] Create markdown toolbar widget
- [ ] Implement text insertion helpers
- [ ] Bold, Italic, Heading, List buttons
- [ ] Code block insertion

#### Wednesday Morning (4 hours)
- [ ] Create Topic Viewer screen
- [ ] Integrate flutter_markdown renderer
- [ ] Toggle Edit/Preview mode
- [ ] Test with sample markdown

**Deliverable:** Functional markdown editor with preview

---

### Thursday-Friday (Day 4-5): File Storage
**Time:** 8-10 hours  
**Milestone:** 3 - Local File Storage

#### Thursday Morning (3 hours)
- [ ] Create FileService class
- [ ] Implement path_provider integration
- [ ] Create topics folder
- [ ] Save/read markdown files

#### Thursday Afternoon (3 hours)
- [ ] Create Topic model
- [ ] Implement JSON serialization
- [ ] Create TopicsIndexService
- [ ] Save topics metadata

#### Friday Morning (3 hours)
- [ ] Update Add Topic to save files
- [ ] Update Home Screen to load topics
- [ ] Display topics list
- [ ] Navigate to viewer with data

#### Friday Afternoon (2 hours)
- [ ] Test save/load cycle
- [ ] Test app restart persistence
- [ ] Bug fixes
- [ ] Code cleanup

**Deliverable:** Topics persist between app restarts

---

## WEEK 2: Database & Logic Foundation
**Days 8-14** | **Milestones 4-5**

### Monday (Day 8-9): SQLite Database
**Time:** 8-10 hours  
**Milestone:** 4 - Local Database

#### Monday Morning (4 hours)
- [ ] Create DatabaseService class
- [ ] Define database schema
- [ ] Implement database initialization
- [ ] Create tables with indexes

#### Monday Afternoon (4 hours)
- [ ] Implement CRUD operations
  - insertTopic()
  - updateTopic()
  - deleteTopic()
  - getTopic()
  - getAllTopics()
- [ ] Add query methods for filtering

#### Tuesday Morning (2 hours)
- [ ] Migrate from JSON to SQLite
- [ ] Test database operations
- [ ] Update all screens to use database

**Deliverable:** Full SQLite integration

---

### Tuesday-Thursday (Day 9-11): Spaced Repetition
**Time:** 12-15 hours  
**Milestone:** 5 - Spaced Repetition Logic

#### Tuesday Afternoon (4 hours)
- [ ] Create SpacedRepetitionService
- [ ] Implement calculateNextReviewDate()
- [ ] Define interval stages [1, 3, 7, 14, 30]
- [ ] Implement stage advancement logic

#### Wednesday Morning (4 hours)
- [ ] Implement markAsReviewed()
- [ ] Update database with new dates
- [ ] Implement getDueTopics()
- [ ] Implement getUpcomingTopics()

#### Wednesday Afternoon (3 hours)
- [ ] Update Topic Viewer screen
- [ ] Add "Mark as Reviewed" button
- [ ] Show stage progress
- [ ] Display next review date

#### Thursday Morning (4 hours)
- [ ] Create Reschedule Dialog
- [ ] Implement quick reschedule options
- [ ] Add custom date/time picker
- [ ] Integrate with SpacedRepetitionService

#### Thursday Afternoon (3 hours)
- [ ] Update Home Screen with filtering
- [ ] Show "Due Today" section
- [ ] Show "Upcoming" section
- [ ] Add color coding (red/orange/green)

**Deliverable:** Full spaced repetition system working

---

### Friday (Day 12-14): Testing & Refinement
**Time:** 6-8 hours

#### Friday Morning (3 hours)
- [ ] Test entire flow: create → review → reschedule
- [ ] Test edge cases (very overdue, future dates)
- [ ] Test stage advancement
- [ ] Bug fixes

#### Friday Afternoon (3 hours)
- [ ] Code refactoring
- [ ] Add error handling
- [ ] Performance optimization
- [ ] Documentation
- [ ] End of Week 2 demo

**Deliverable:** Stable core functionality

---

## WEEK 3: Calendar & Scheduling
**Days 15-21** | **Milestones 5.5-6**

### Monday-Tuesday (Day 15-16): Calendar View
**Time:** 10-12 hours  
**Milestone:** 5.5 - Calendar & Custom Scheduling

#### Monday Morning (4 hours)
- [ ] Add table_calendar package
- [ ] Create Calendar Screen
- [ ] Implement month view
- [ ] Add date navigation

#### Monday Afternoon (4 hours)
- [ ] Implement date marking logic
- [ ] Add color-coded dots (overdue/today/upcoming)
- [ ] Load topics for calendar display
- [ ] Optimize date queries

#### Tuesday Morning (3 hours)
- [ ] Implement date selection
- [ ] Show topics for selected date
- [ ] Create bottom sheet with topic list
- [ ] Add tap to view functionality

#### Tuesday Afternoon (3 hours)
- [ ] Create CustomDateTimePicker widget
- [ ] Update database schema for custom schedules
- [ ] Integrate custom scheduling
- [ ] Test calendar functionality

**Deliverable:** Full calendar view with custom scheduling

---

### Wednesday-Thursday (Day 17-18): Notifications
**Time:** 8-10 hours  
**Milestone:** 6 - Local Notifications

#### Wednesday Morning (4 hours)
- [ ] Add flutter_local_notifications
- [ ] Create NotificationService
- [ ] Implement Android notification channel
- [ ] Implement iOS notification setup

#### Wednesday Afternoon (3 hours)
- [ ] Request notification permissions
- [ ] Implement daily reminder scheduling
- [ ] Query due topics for notification
- [ ] Format notification content

#### Thursday Morning (3 hours)
- [ ] Implement notification tap handling
- [ ] Navigate to correct screen on tap
- [ ] Add notification action buttons
- [ ] Test on Android device

#### Thursday Afternoon (2 hours)
- [ ] Test on iOS device
- [ ] Add notification settings screen
- [ ] Allow time customization
- [ ] Bug fixes

**Deliverable:** Working notification system

---

### Friday (Day 19-21): UI Polish
**Time:** 8-10 hours  
**Milestone:** 7 - UI Polish & Statistics

#### Friday Morning (4 hours)
- [ ] Create Statistics Screen
- [ ] Calculate streak logic
- [ ] Show review counts
- [ ] Add simple charts

#### Friday Afternoon (4 hours)
- [ ] Improve home screen UI
- [ ] Add search functionality
- [ ] Create empty states
- [ ] Add loading indicators

#### Weekend (Optional, Day 20-21)
- [ ] Additional polish
- [ ] Icon improvements
- [ ] Animation additions
- [ ] User testing with friends

**Deliverable:** Polished, feature-complete local app

---

## WEEK 4: Cloud Integration - Part 1
**Days 22-28** | **Milestone 8**

### Monday (Day 22): Architecture Planning
**Time:** 2-3 hours  
**Use:** Claude Opus 4.1

#### Morning (2 hours)
- [ ] Design sync architecture with Claude Opus
- [ ] Define conflict resolution strategy
- [ ] Plan data structures for sync
- [ ] Document edge cases

**Deliverable:** Comprehensive sync architecture document

---

### Monday-Tuesday (Day 22-23): Google Drive Setup
**Time:** 8-10 hours

#### Monday Afternoon (4 hours)
- [ ] Add google_sign_in package
- [ ] Add googleapis package
- [ ] Create GoogleDriveService skeleton
- [ ] Implement authentication flow

#### Tuesday Morning (4 hours)
- [ ] Create app folder in Drive
- [ ] Implement file upload
- [ ] Implement file download
- [ ] Implement file listing

#### Tuesday Afternoon (3 hours)
- [ ] Test upload/download cycle
- [ ] Handle authentication errors
- [ ] Add token refresh logic

**Deliverable:** Basic Google Drive integration

---

### Wednesday-Thursday (Day 24-25): Backup System
**Time:** 10-12 hours

#### Wednesday Morning (4 hours)
- [ ] Create backup functionality
- [ ] Zip database + markdown files
- [ ] Upload to Google Drive
- [ ] Add timestamp to backups

#### Wednesday Afternoon (4 hours)
- [ ] Create restore functionality
- [ ] List available backups
- [ ] Download and extract backup
- [ ] Restore to local storage

#### Thursday Morning (3 hours)
- [ ] Create Google Drive Connect screen
- [ ] Add onboarding UI
- [ ] Implement sign-in flow
- [ ] Handle sign-in errors

#### Thursday Afternoon (3 hours)
- [ ] Update Settings screen
- [ ] Add "Backup Now" button
- [ ] Add "Restore from Backup" dialog
- [ ] Add connection status display

**Deliverable:** Manual backup/restore working

---

### Friday (Day 26-28): Testing & Polish
**Time:** 6-8 hours

#### Friday Morning (3 hours)
- [ ] Test backup on Android
- [ ] Test backup on iOS
- [ ] Test restore flow
- [ ] Test error scenarios

#### Friday Afternoon (3 hours)
- [ ] Bug fixes
- [ ] UI improvements
- [ ] Add loading indicators
- [ ] Documentation

**Deliverable:** Stable backup/restore system

---

## WEEK 5: Cloud Sync & Release
**Days 29-35** | **Milestones 9-10**

### Monday-Tuesday (Day 29-30): Auto Sync
**Time:** 10-12 hours  
**Milestone:** 9 - Automatic Cloud Sync

#### Monday Morning (4 hours)
- [ ] Create SyncService
- [ ] Implement change tracking
- [ ] Detect local modifications
- [ ] Queue sync operations

#### Monday Afternoon (4 hours)
- [ ] Implement sync algorithm
- [ ] Upload only changed files
- [ ] Download cloud changes
- [ ] Merge changes locally

#### Tuesday Morning (3 hours)
- [ ] Implement conflict detection
- [ ] Implement conflict resolution
- [ ] Test merge scenarios
- [ ] Handle deletion conflicts

#### Tuesday Afternoon (3 hours)
- [ ] Create BackgroundSyncService
- [ ] Schedule periodic sync
- [ ] Sync on app open/resume
- [ ] Handle offline queue

**Deliverable:** Automatic background sync

---

### Wednesday (Day 31-32): Sync UI
**Time:** 6-8 hours

#### Wednesday Morning (3 hours)
- [ ] Create SyncStatusIndicator widget
- [ ] Show sync status in app bar
- [ ] Display last synced time
- [ ] Add sync progress indicator

#### Wednesday Afternoon (3 hours)
- [ ] Create SyncDetailsDialog
- [ ] Show sync history
- [ ] Add manual sync button
- [ ] Create ConflictResolutionScreen

**Deliverable:** Complete sync UI

---

### Thursday (Day 33): Testing & Bug Fixes
**Time:** 6-8 hours  
**Milestone:** 10 - Testing & Release (Part 1)

#### Thursday Morning (4 hours)
- [ ] Write unit tests
- [ ] Test SpacedRepetitionService
- [ ] Test DatabaseService
- [ ] Test SyncService

#### Thursday Afternoon (4 hours)
- [ ] Write integration tests
- [ ] Test critical user flows
- [ ] Test on multiple devices
- [ ] Fix discovered bugs

**Deliverable:** Comprehensive test suite

---

### Friday (Day 34-35): Release Preparation
**Time:** 8-10 hours  
**Milestone:** 10 - Testing & Release (Part 2)

#### Friday Morning (4 hours)
- [ ] Create app icon
- [ ] Create splash screen
- [ ] Update app metadata
- [ ] Write privacy policy

#### Friday Afternoon (4 hours)
- [ ] Prepare store listings
- [ ] Take screenshots
- [ ] Write descriptions
- [ ] Build release APK/AAB

#### Weekend (Optional, Day 35)
- [ ] Build iOS archive
- [ ] Submit to Play Store
- [ ] Submit to App Store
- [ ] Monitor initial feedback

**Deliverable:** App submitted to stores! 🎉

---

## Fast Track MVP (2 Weeks)

For faster initial launch, focus on core features only:

### Week 1: Core Features
- Days 1-2: Setup + Navigation
- Days 3-4: Markdown Editor
- Days 5-7: Local Storage + Database

### Week 2: Essential Logic
- Days 8-10: Spaced Repetition
- Days 11-12: Notifications
- Days 13-14: Testing + Polish

**Deliverable:** Local-only app with core functionality

**Then add later:**
- Calendar view (Week 3)
- Cloud sync (Week 4-5)
- Advanced features (ongoing)

---

## Critical Path

### Must-Have for Launch
1. ✅ Project Setup
2. ✅ Markdown Editor
3. ✅ Local Storage (SQLite)
4. ✅ Spaced Repetition Logic
5. ✅ Notifications
6. ✅ Basic UI Polish

### Nice-to-Have for v1.0
7. 📅 Calendar View
8. ☁️ Google Drive Backup

### Can Launch Without
9. 🔄 Auto Sync (add in v1.1)
10. 📊 Advanced Statistics (add in v1.2)

---

## Risk Management

### High Risk Items
| Risk | Impact | Mitigation |
|------|--------|------------|
| Notification permissions denied | High | Clear onboarding, graceful degradation |
| Google Drive API quota limits | Medium | Implement rate limiting, caching |
| Sync conflicts | Medium | Clear conflict resolution UI |
| Platform-specific bugs | High | Test on real devices early |

### Time Buffers
- Add 20% buffer for unexpected issues
- Reserve Day 34-35 for critical fixes
- Plan for post-launch bug fixes

---

## Daily Schedule Template

### Typical Development Day (8 hours)

**Morning Session (4 hours)**
- 9:00 AM - 9:30 AM: Review plan, setup
- 9:30 AM - 12:30 PM: Focused coding
- 12:30 PM - 1:30 PM: Lunch break

**Afternoon Session (4 hours)**
- 1:30 PM - 5:00 PM: Coding + testing
- 5:00 PM - 5:30 PM: Git commit, documentation

**Evening (Optional, 2 hours)**
- Testing on real devices
- Bug fixes
- Code review

---

## Progress Tracking

### Daily Checklist
- [ ] Morning standup (review goals)
- [ ] Code implementation
- [ ] Unit testing
- [ ] Git commit with descriptive message
- [ ] Update milestone progress
- [ ] Document blockers

### Weekly Review
- [ ] Demo working features
- [ ] Review completed milestones
- [ ] Adjust timeline if needed
- [ ] Plan next week's focus

---

## Key Milestones & Demos

### End of Week 1
**Demo:** Create topic, view in list, persist data

### End of Week 2
**Demo:** Full review cycle with spaced repetition

### End of Week 3
**Demo:** Calendar view, notifications working

### End of Week 4
**Demo:** Google Drive backup and restore

### End of Week 5
**Demo:** Complete app ready for stores!

---

## Resource Allocation

### Development Tools
- Flutter SDK
- Android Studio / VS Code
- Xcode (for iOS)
- Git for version control
- Claude Pro for AI assistance

### Testing Devices
- Android phone (physical)
- iOS phone (physical)
- Android emulator
- iOS simulator
- Various screen sizes

### External Services
- Google Drive API (free tier)
- Play Store Developer Account ($25 one-time)
- Apple Developer Program ($99/year)

---

## Success Metrics

### Launch Goals
- ✅ App published on both stores
- ✅ All core features working
- ✅ No critical bugs
- ✅ Privacy policy compliant
- ✅ 5-star UX on test group

### Post-Launch (Week 6+)
- 100 downloads in first month
- 4+ star average rating
- <1% crash rate
- User feedback implementation
- v1.1 planning

---

*Timeline created: November 8, 2025*  
*Last updated: November 8, 2025*
