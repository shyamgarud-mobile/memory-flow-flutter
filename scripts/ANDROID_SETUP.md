# Android Google Sign-In Setup - Fix ApiException: 10

## Problem
Error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)`

This error means Google doesn't recognize your app. You need to register your app's SHA-1 fingerprint.

## Quick Fix (5 minutes)

### Step 1: Get Your SHA-1 Fingerprint

Run this command to get your debug certificate SHA-1:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copy the SHA-1 fingerprint** - it looks like:
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

### Step 2: Add SHA-1 to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your **MemoryFlow** project
3. Go to **APIs & Services** > **Credentials**
4. Find your Android OAuth client (or create a new one):
   - Click **"Create Credentials"** > **"OAuth client ID"**
   - Select **"Android"**
   - Name: **MemoryFlow Android**
   - Package name: `com.example.memory_flow`
   - Paste your SHA-1 fingerprint
   - Click **"Create"**

### Step 3: Wait & Restart

1. **Wait 5 minutes** for Google to propagate the changes
2. **Kill the app** completely
3. **Rerun the app:**
   ```bash
   flutter run -d <your-device-id>
   ```

### Step 4: Test Sign-In

1. Open the app
2. Go to **Settings**
3. Tap **"Connect"** under Google Drive
4. Sign in with your Google account
5. Grant permissions
6. Done! ✅

## If Still Not Working

### Verify Package Name

Check your package name matches in [android/app/build.gradle](android/app/build.gradle):

```gradle
defaultConfig {
    applicationId "com.example.memory_flow"  // Must match Google Console
    ...
}
```

### Get Release SHA-1 (For Production)

If you're building a release version, you also need the release SHA-1:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias
```

### Enable Google Drive API

Make sure you've enabled the API:
1. Go to **APIs & Services** > **Library**
2. Search: **"Google Drive API"**
3. Click **"Enable"**

### Add Test User

If your OAuth consent screen is in testing mode:
1. Go to **APIs & Services** > **OAuth consent screen**
2. Scroll to **Test users**
3. Add your Google account email
4. Save

## Common Errors

| Error Code | Meaning | Solution |
|------------|---------|----------|
| 10 | App not registered | Add SHA-1 fingerprint |
| 12500 | Google Play Services outdated | Update Play Services |
| 7 | Network error | Check internet connection |

## Troubleshooting Commands

**Check if keytool is installed:**
```bash
keytool -help
```

**List all keystores:**
```bash
ls -la ~/.android/
```

**View app logs:**
```bash
flutter logs
```

**Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter run
```

## Production Notes

⚠️ **For production release:**
1. Generate a release keystore
2. Get the release SHA-1
3. Add it to Google Console
4. Update signing config in `android/app/build.gradle`

## Next Steps After Setup

Once Google Sign-In works:
- ✅ Test backup functionality
- ✅ Test restore functionality
- ✅ Enable auto-backup
- ✅ Verify data persistence

---

**Need Help?**
- Check Flutter logs: `flutter logs`
- View detailed error: Enable verbose logging
- Google Sign-In docs: https://pub.dev/packages/google_sign_in
