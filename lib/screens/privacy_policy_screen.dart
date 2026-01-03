import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_constants.dart';
import '../widgets/common/figma_app_bar.dart';

/// Privacy Policy screen - Display app privacy policy
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String privacyPolicyContent = '''
# Privacy Policy for MemoryFlow

**Last Updated:** January 3, 2026

---

## Introduction

Welcome to MemoryFlow! We are committed to protecting your privacy and ensuring you have a positive experience using our application.

By using MemoryFlow, you agree to the collection and use of information in accordance with this policy.

---

## 1. Information We Collect

### 1.1 Information You Provide Directly

- **Learning Topics and Content**: Text content, notes, and study materials
- **Tags and Categories**: Organizational labels you assign
- **Review History**: Records of your review progress
- **User Preferences**: App settings and customizations

### 1.2 Automatically Collected Information

- **Review Statistics**: Study patterns and progress data
- **Timestamps**: Creation and review dates

### 1.3 Third-Party Services (Optional)

If you enable Google Drive backup:

- **Google Account Information**: Email address for authentication
- **Google Drive Access**: Limited access to create backup files

---

## 2. How We Use Your Information

### 2.1 Core Functionality
- **Spaced Repetition**: Calculate optimal review intervals
- **Progress Tracking**: Display learning statistics
- **Personalization**: Apply your preferred settings

### 2.2 Notifications
- **Review Reminders**: Send notifications when topics are due
- **Daily Reminders**: Notify based on your settings

### 2.3 Backup and Sync (Optional)
- **Data Backup**: Create backups to your Google Drive
- **Data Recovery**: Restore content across devices

---

## 3. Data Storage and Security

### 3.1 Local Storage

MemoryFlow is a **privacy-first, offline-first application**:

- **Local Database**: All data stored locally on your device
- **No Cloud Servers**: We don't store data on our servers
- **Offline Functionality**: Works completely offline

### 3.2 Google Drive Storage (Optional)

- **Your Google Drive**: Backups stored in YOUR account
- **User Control**: You control all backup files
- **No Access to Other Files**: We only access our backup files

### 3.3 Security Measures

- **Local Encryption**: Protected by device security
- **Secure Authentication**: OAuth 2.0 for Google Drive
- **No Data Transmission**: Content never sent to third parties

---

## 4. Data Sharing and Disclosure

### 4.1 No Third-Party Sharing

We **do not sell, trade, rent, or share** your information with third parties for marketing purposes.

### 4.2 Google Services

If you enable Google Drive backup, Google's privacy policy applies to data in your Drive.

---

## 5. Your Rights and Choices

### 5.1 Data Access and Control

- **View Your Data**: Access all data in the app
- **Edit Your Data**: Modify or delete any content
- **Export Your Data**: Back up to Google Drive
- **Delete Your Data**: Clear all app data

### 5.2 Notification Controls

- **Enable/Disable**: Turn notifications on or off
- **Customize Timing**: Set preferred reminder times
- **Quiet Hours**: Prevent notifications during specific times

### 5.3 Google Drive Integration

- **Connect/Disconnect**: Enable or disable at any time
- **Revoke Access**: Disconnect through app settings
- **Delete Backups**: Remove files from your Drive

---

## 6. Children's Privacy

MemoryFlow is suitable for users of all ages. We do not knowingly collect personal information from children under 13 without parental consent.

---

## 7. Changes to This Privacy Policy

We will notify you of any changes by posting the new Privacy Policy in the app and updating the "Last Updated" date.

---

## 8. Data Retention

- **Local Data**: Remains until you delete it or uninstall
- **Backup Data**: Remains in your Google Drive until you delete it

---

## 9. Analytics and Crash Reporting

**Current Status**: MemoryFlow does **not** use any analytics or crash reporting services.

---

## 10. Contact Us

If you have questions or concerns:

**Email**: support@memoryflow.app
**App Version**: ${AppConfig.appVersion}

---

## Summary of Key Points

✅ **Your data stays on your device** - We don't store on our servers
✅ **No tracking or analytics** - We don't track or sell your data
✅ **Optional cloud backup** - You control Google Drive backup
✅ **Full data control** - View, edit, export, and delete all data
✅ **Offline-first** - Works completely offline
✅ **Minimal permissions** - Only essential permissions requested

---

## Your Consent

By using MemoryFlow, you consent to this Privacy Policy and agree to its terms.

---

*Last updated: January 3, 2026*
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FigmaAppBar(
        title: 'Privacy Policy',
        showBackButton: true,
      ),
      body: Markdown(
        data: privacyPolicyContent,
        selectable: true,
        padding: const EdgeInsets.all(AppSpacing.md),
        styleSheet: MarkdownStyleSheet(
          h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
          h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
          h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          p: Theme.of(context).textTheme.bodyMedium,
          listBullet: Theme.of(context).textTheme.bodyMedium,
          code: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                backgroundColor: AppColors.gray100,
              ),
          blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
          strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
