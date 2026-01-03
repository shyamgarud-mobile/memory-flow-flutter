# Release Checklist - MemoryFlow v1.0.0

## Pre-Release Testing

### Functional Testing
- [ ] **Topic Creation**
  - [ ] Create topic with markdown content
  - [ ] Edit existing topic
  - [ ] Delete topic
  - [ ] Save and load topic content

- [ ] **Spaced Repetition**
  - [ ] Mark topic as reviewed
  - [ ] Verify stage advancement
  - [ ] Check next review date calculation
  - [ ] Reset topic progress
  - [ ] Verify all 5 interval stages (1, 3, 7, 14, 30 days)

- [ ] **Calendar Features**
  - [ ] View calendar with review markers
  - [ ] Navigate between months
  - [ ] Tap date to see scheduled topics
  - [ ] Set custom review date/time
  - [ ] Remove custom schedule

- [ ] **Google Drive Backup**
  - [ ] Connect Google Drive account
  - [ ] Create manual backup
  - [ ] Restore from backup
  - [ ] Verify data integrity after restore
  - [ ] Disconnect Google Drive

- [ ] **Notifications**
  - [ ] Enable notifications
  - [ ] Receive daily reminders
  - [ ] Tap notification opens app
  - [ ] Custom notification time works
  - [ ] Disable notifications

- [ ] **Search & Filter**
  - [ ] Search topics by title
  - [ ] Filter by due/upcoming
  - [ ] Filter by favorites
  - [ ] Filter by folder

- [ ] **Folders**
  - [ ] Create folder
  - [ ] Move topic to folder
  - [ ] Delete folder
  - [ ] Nested folders work

- [ ] **Statistics**
  - [ ] View total topics
  - [ ] View review count
  - [ ] Check streak tracking
  - [ ] Verify statistics accuracy

### Platform Testing

#### Android
- [ ] Test on Android 8.0 (API 26)
- [ ] Test on Android 10 (API 29)
- [ ] Test on Android 12 (API 31)
- [ ] Test on Android 14 (API 34)
- [ ] Test on small screen (< 5.5")
- [ ] Test on large screen (> 6.5")
- [ ] Test on tablet
- [ ] Verify back button navigation
- [ ] Check app permissions
- [ ] Test notification channels

#### iOS (if applicable)
- [ ] Test on iOS 13
- [ ] Test on iOS 15
- [ ] Test on iOS 17
- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPhone Pro Max (large screen)
- [ ] Test on iPad
- [ ] Verify Dark Mode support
- [ ] Check permission dialogs

### Performance Testing
- [ ] App starts in < 3 seconds
- [ ] Smooth scrolling with 100+ topics
- [ ] Smooth scrolling with 500+ topics
- [ ] Database queries complete quickly
- [ ] No frame drops during navigation
- [ ] Memory usage reasonable
- [ ] Battery drain acceptable
- [ ] Run performance test suite: `flutter test test/performance/`

### Edge Cases & Error Handling
- [ ] Works without internet connection
- [ ] Handles low storage gracefully
- [ ] Recovers from database errors
- [ ] Handles corrupted data
- [ ] Works with 0 topics
- [ ] Works with 1000+ topics
- [ ] Handles very long topic titles
- [ ] Handles very large markdown content (> 10,000 chars)
- [ ] Permission denial handled gracefully

### Security & Privacy
- [ ] Privacy policy accessible in app
- [ ] No sensitive data logged
- [ ] Secure Google Drive authentication
- [ ] Local database encrypted
- [ ] No hardcoded credentials
- [ ] Proper HTTPS for all network calls

### Accessibility
- [ ] Screen reader compatibility
- [ ] Proper content descriptions
- [ ] Sufficient touch target sizes (48dp minimum)
- [ ] Color contrast meets WCAG standards
- [ ] Text scaling works

## Code Quality

### Code Review
- [ ] Run `flutter analyze` with 0 errors
- [ ] Run `dart format .` to format code
- [ ] Remove all debug print statements
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Update code comments
- [ ] Check for TODO comments

### Testing
- [ ] All unit tests pass: `flutter test`
- [ ] Integration tests pass: `flutter test integration_test/`
- [ ] Performance tests pass
- [ ] Code coverage > 70%

### Dependencies
- [ ] All dependencies are latest stable versions
- [ ] Remove unused dependencies
- [ ] Check for security vulnerabilities
- [ ] Review licenses of all dependencies

## Documentation

- [x] README.md is complete
- [x] Privacy Policy created
- [x] Store listing prepared
- [ ] API documentation updated
- [ ] User guide/FAQ created
- [ ] Contributing guidelines added
- [ ] Changelog updated
- [ ] License file included

## Assets

### App Icon
- [x] Source icon (1024x1024)
- [x] Android icons generated (all densities)
- [ ] iOS icons generated (all sizes)
- [ ] Icon looks good on dark background
- [ ] Icon looks good on light background

### Screenshots
- [ ] Home/Topic List screen
- [ ] Topic editor screen
- [ ] Calendar view screen
- [ ] Statistics screen
- [ ] Google Drive backup screen
- [ ] All screenshots are 1080x1920 or higher
- [ ] Screenshots have captions/overlays
- [ ] Screenshots show real content (not Lorem Ipsum)

### Marketing Assets
- [ ] Feature graphic (1024x500)
- [ ] Promo video (optional)
- [ ] App description written
- [ ] Keywords researched
- [ ] Short description written

## Build Configuration

### Version
- [ ] Version number updated in `pubspec.yaml` (1.0.0+1)
- [ ] Build number incremented
- [ ] Version matches store listing

### Android Build
- [ ] Update `android/app/build.gradle`
  - [ ] `applicationId` is correct
  - [ ] `versionCode` is set
  - [ ] `versionName` is set
  - [ ] `minSdkVersion` is 21+
  - [ ] `targetSdkVersion` is latest
  - [ ] `compileSdkVersion` is latest

- [ ] Configure signing
  - [ ] Create keystore
  - [ ] Update `android/key.properties`
  - [ ] Add to `.gitignore`

- [ ] ProGuard/R8
  - [ ] Enabled in release build
  - [ ] Rules configured correctly
  - [ ] App still works after obfuscation

- [ ] Permissions in `AndroidManifest.xml`
  - [ ] Only necessary permissions included
  - [ ] Permission justifications documented
  - [ ] Request permissions at runtime

### iOS Build (if applicable)
- [ ] Update `ios/Runner/Info.plist`
  - [ ] Bundle identifier correct
  - [ ] Version and build number set
  - [ ] Required permissions with descriptions

- [ ] Configure signing in Xcode
  - [ ] Development certificate
  - [ ] Distribution certificate
  - [ ] Provisioning profiles

## Store Preparation

### Google Play Store
- [ ] Create developer account
- [ ] Accept developer agreements
- [ ] Pay registration fee ($25 one-time)
- [ ] Create app listing
- [ ] Upload screenshots
- [ ] Upload feature graphic
- [ ] Upload high-res icon (512x512)
- [ ] Set app category (Education)
- [ ] Add short description
- [ ] Add full description
- [ ] Set content rating
- [ ] Add privacy policy URL
- [ ] Configure pricing (Free)
- [ ] Select countries/regions
- [ ] Upload release APK/AAB

### Apple App Store (if applicable)
- [ ] Create Apple Developer account
- [ ] Pay annual fee ($99/year)
- [ ] Create app in App Store Connect
- [ ] Upload screenshots
- [ ] Set app category
- [ ] Add description
- [ ] Add keywords
- [ ] Set content rating
- [ ] Add privacy policy URL
- [ ] Configure pricing (Free)
- [ ] Upload build via Xcode
- [ ] Submit for review

## Legal & Compliance

- [x] Privacy policy created
- [ ] Terms of service (optional)
- [ ] GDPR compliance verified
- [ ] COPPA compliance (if applicable)
- [ ] California privacy compliance
- [ ] Open source license added (MIT/Apache)
- [ ] Third-party licenses documented
- [ ] Copyright notices included

## Release Build

### Android
```bash
# Clean build
flutter clean
flutter pub get

# Run tests
flutter test
flutter test integration_test/

# Build release
flutter build appbundle --release

# Verify build
# Location: build/app/outputs/bundle/release/app-release.aab
# Size should be < 15 MB
```

- [ ] Release AAB built successfully
- [ ] AAB signed with release key
- [ ] App bundle size acceptable
- [ ] Install and test release build on real device

### iOS
```bash
# Clean build
flutter clean
flutter pub get

# Build release
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
```

- [ ] Release IPA built successfully
- [ ] IPA signed with distribution certificate
- [ ] App size acceptable
- [ ] TestFlight build tested

## Pre-Launch

- [ ] Create support email (shyamkumar.garud@gmail.com)
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Set up analytics (optional, privacy-focused)
- [ ] Prepare social media announcements
- [ ] Create GitHub release
- [ ] Tag release in Git: `git tag v1.0.0`
- [ ] Push tags: `git push --tags`

## Launch Day

- [ ] Submit app to Google Play Store
- [ ] Submit app to Apple App Store (if applicable)
- [ ] Post announcement on GitHub
- [ ] Share on social media
- [ ] Post on relevant communities (Reddit, HN, etc.)
- [ ] Update website with download links
- [ ] Monitor crash reports
- [ ] Monitor user reviews

## Post-Launch

### Week 1
- [ ] Respond to user reviews daily
- [ ] Fix critical bugs immediately
- [ ] Monitor crash reports
- [ ] Track download numbers
- [ ] Collect user feedback

### Month 1
- [ ] Analyze usage metrics
- [ ] Prioritize feature requests
- [ ] Plan version 1.1.0
- [ ] Update documentation based on feedback
- [ ] Consider user testimonials

### Ongoing
- [ ] Regular bug fixes
- [ ] Feature updates
- [ ] Respond to user feedback
- [ ] Monitor store ratings
- [ ] Keep dependencies updated
- [ ] Security updates

## Rollback Plan

If critical issues are discovered:
1. Halt new user acquisition
2. Fix critical bug
3. Release hotfix version (1.0.1)
4. Notify users via store listing
5. Document incident
6. Update testing procedures

## Success Metrics

### Initial Goals (First Month)
- [ ] 1,000+ downloads
- [ ] 4.0+ star rating
- [ ] < 1% crash rate
- [ ] Positive user reviews
- [ ] Active GitHub community

### Long-term Goals (6 Months)
- [ ] 10,000+ downloads
- [ ] 4.5+ star rating
- [ ] < 0.5% crash rate
- [ ] Featured in store category
- [ ] Community contributions to open source

---

## Notes

- Keep this checklist updated for future releases
- Document any issues encountered
- Update based on lessons learned
- Share with contributors

---

**Release Version:** 1.0.0
**Target Date:** [Set your target date]
**Status:** In Progress

**Last Updated:** November 29, 2025
