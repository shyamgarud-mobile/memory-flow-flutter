# App Icon Setup Guide

## Current Status

✅ App icon is configured and ready for production

## Icon Files

### Source Icon
- **Location:** `assets/images/app_icon.png`
- **Size:** 1024x1024 (recommended for all platforms)

### Android Icons
Icons are automatically generated in all required densities:
- `mipmap-mdpi/` - 48x48
- `mipmap-hdpi/` - 72x72
- `mipmap-xhdpi/` - 96x96
- `mipmap-xxhdpi/` - 144x144
- `mipmap-xxxhdpi/` - 192x192
- `mipmap-anydpi-v26/` - Adaptive icon XML

### iOS Icons
Will be generated when building for iOS platform.

## Generating Icons

Icons are configured using `flutter_launcher_icons` package.

### Configuration
Located in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/app_icon.png"
```

### Generate Icons Command
```bash
flutter pub run flutter_launcher_icons
```

## Updating the Icon

1. Replace `assets/images/app_icon.png` with your new 1024x1024 icon
2. Run the icon generation command:
   ```bash
   flutter pub run flutter_launcher_icons
   ```
3. Rebuild the app

## Icon Design Guidelines

### Best Practices
- **Size:** 1024x1024 pixels minimum
- **Format:** PNG with transparency
- **Safe Zone:** Keep important content within the center 80%
- **Colors:** High contrast, recognizable at small sizes
- **Simplicity:** Avoid fine details that won't be visible

### Platform-Specific Guidelines

#### Android
- Supports adaptive icons (foreground + background)
- Icon should work on various background colors
- Follow Material Design icon guidelines
- Test on different Android launcher themes

#### iOS
- No transparency on final icon (background will be added)
- Rounded corners applied automatically
- Follow Apple Human Interface Guidelines

## Testing Icons

### Android
```bash
flutter run
```
Check the app icon in:
- App drawer
- Home screen
- Recent apps
- Settings

### iOS
```bash
flutter run -d ios
```
Check the app icon in:
- Home screen
- App Library
- Settings
- Spotlight search

## Troubleshooting

### Icons not updating
1. Clean the project:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Regenerate icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```
3. Rebuild the app

### Wrong colors on adaptive icon
- Adjust `adaptive_icon_background` color in `pubspec.yaml`
- Ensure foreground has proper transparency

### Icons appear blurry
- Use higher resolution source image (1024x1024 or larger)
- Ensure PNG is not compressed too much

## Resources

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS App Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

## Icon Sizes Reference

### Android
| Density | Size | DPI |
|---------|------|-----|
| mdpi | 48x48 | 160 |
| hdpi | 72x72 | 240 |
| xhdpi | 96x96 | 320 |
| xxhdpi | 144x144 | 480 |
| xxxhdpi | 192x192 | 640 |

### iOS
| Device | Size |
|--------|------|
| iPhone | 180x180 |
| iPad Pro | 167x167 |
| iPad | 152x152 |
| App Store | 1024x1024 |

## Next Steps

For production release:
1. Verify icon appears correctly on all supported devices
2. Test adaptive icon on different launcher backgrounds
3. Ensure icon meets Play Store and App Store guidelines
4. Include icon in app store listing screenshots
