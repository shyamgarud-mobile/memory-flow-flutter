# Google Drive OAuth Setup Guide

This guide will help you set up Google Drive integration for the MemoryFlow app.

## Prerequisites
- A Google account
- Access to Google Cloud Console

## Step-by-Step Setup

### 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click "New Project"
4. Enter project name: **MemoryFlow**
5. Click "Create"

### 2. Enable Google Drive API

1. In the left sidebar, go to **APIs & Services** > **Library**
2. Search for **"Google Drive API"**
3. Click on it
4. Click **"Enable"**

### 3. Configure OAuth Consent Screen

1. Go to **APIs & Services** > **OAuth consent screen**
2. For **User Type**:
   - If you see both **Internal** and **External**: Choose **External** (for personal Google accounts)
   - If you only see **External**: Proceed with it (this is normal for personal accounts)
   - Note: **Internal** is only available for Google Workspace organizations
3. Click **"Create"** or **"Continue"**
4. Fill in the **App information**:
   - **App name:** MemoryFlow
   - **User support email:** Your email
   - **Developer contact information:** Your email
5. Click **"Save and Continue"**
6. On **"Scopes"** page:
   - Click **"Add or Remove Scopes"**
   - Search for and select: `https://www.googleapis.com/auth/drive.file`
   - Click **"Update"**
   - Click **"Save and Continue"**
7. On **"Test users"** page (IMPORTANT!):
   - Click **"Add Users"**
   - Add your Google email address
   - Click **"Save"**
   - Click **"Save and Continue"**
8. Review the summary and click **"Back to Dashboard"**

### 4. Create OAuth 2.0 Credentials

#### For Android (Required):

1. Go to **APIs & Services** > **Credentials**
2. Click **"Create Credentials"** > **"OAuth client ID"**
3. Select **"Android"**
4. Name: **MemoryFlow Android**
5. Package name: `com.garud.shyamkumar.memoryflow`
6. Get SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the SHA-1 fingerprint (it will look like: `47:8B:AF:5D:38:1B:99:17:C7:AA:A1:F3:0E:50:26:55:42:BD:C1:18`)
7. Paste the SHA-1 into the form
8. Click **"Create"**
9. ✅ **Done!** No need to copy any Client ID - Android uses the package name + SHA-1 for authentication

#### For Web (Optional - only if testing in Chrome):

1. Click **"Create Credentials"** > **"OAuth client ID"**
2. Select **"Web application"**
3. Name: **MemoryFlow Web**
4. Under **"Authorized JavaScript origins"**, add:
   - `http://localhost`
   - `http://localhost:8080`
5. Under **"Authorized redirect URIs"**, add:
   - `http://localhost`
6. Click **"Create"**
7. Copy the **Client ID** and add it to `lib/services/google_drive_service.dart` in the `GoogleSignIn` constructor

### 5. No Code Changes Required!

For Android, the app is already configured correctly:
- Package name: `com.garud.shyamkumar.memoryflow` ✅
- OAuth authentication happens automatically via Google Play Services ✅

For Web/iOS (if needed later), you would need to add the `clientId` parameter to the `GoogleSignIn` constructor in [lib/services/google_drive_service.dart](lib/services/google_drive_service.dart).

### 6. Test the Integration

#### On Web (Chrome):
```bash
flutter run -d chrome
```

#### On Android:
```bash
./scripts/connect_device.sh
flutter run -d <device-id>
```

### 7. Using the App

1. Open the app
2. Go to **Settings**
3. Scroll to **Cloud Backup** section
4. Click **"Connect"**
5. Sign in with your Google account
6. Grant permissions when prompted
7. You're all set!

## Features Available

Once connected:
- ✅ **Backup Now** - Manual backup to Google Drive
- ✅ **Auto Backup** - Automatic backups (toggle on/off)
- ✅ **Restore from Backup** - View and restore from previous backups
- ✅ **Connection Status** - See which Google account is connected
- ✅ **Last Backup Time** - Track when data was last backed up

## Troubleshooting

### "Sign-in failed" error
- Make sure you've added your email to test users in OAuth consent screen
- Check that the Client ID is correctly copied
- Verify JavaScript origins and redirect URIs are correct

### "Access blocked" error
- Your app needs to be verified by Google (only for production)
- For testing, make sure you're using a test user account

### Web sign-in not working
- Clear browser cache
- Make sure you're using `http://localhost` (not `127.0.0.1`)
- Check browser console for errors

### Android sign-in not working
- Verify SHA-1 fingerprint is correct
- Package name must match exactly
- Rebuild the app after adding credentials

## Security Notes

⚠️ **Important:**
- Never commit your Client ID to public repositories if it's for production
- For open-source projects, use environment variables
- Add `.env` files to `.gitignore`
- Consider using Firebase instead for easier setup

## Next Steps

After setup is complete:
1. Test backup functionality
2. Test restore functionality
3. Enable auto-backup
4. Consider implementing encryption for sensitive data

## Support

If you encounter issues:
1. Check the [Google Sign-In Flutter docs](https://pub.dev/packages/google_sign_in)
2. Review [Google Drive API documentation](https://developers.google.com/drive/api/guides/about-sdk)
3. Check Flutter logs: `flutter logs`

---

**Created for MemoryFlow** - A spaced repetition learning app with cloud backup
