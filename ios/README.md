# iOS Build Setup Guide

This guide will help you set up and build the Side Line app for iOS using Xcode.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **macOS** (required for iOS development)
2. **Xcode 14.0 or later** - Download from the Mac App Store
3. **Flutter SDK** - Install from [flutter.dev](https://flutter.dev)
4. **CocoaPods** - Install via:
   ```bash
   sudo gem install cocoapods
   ```

## Initial Setup

### 1. Clone and Install Dependencies

```bash
# Navigate to project directory
cd /path/to/newsapp

# Get Flutter dependencies
flutter pub get

# Navigate to iOS directory
cd ios

# Install iOS dependencies via CocoaPods
pod install
```

**Important:** Always use `pod install` after cloning or when dependencies change.

### 2. Open Project in Xcode

```bash
# Open the workspace (NOT the .xcodeproj file)
open Runner.xcworkspace
```

**Critical:** Always open `Runner.xcworkspace`, not `Runner.xcodeproj`, as the workspace includes the CocoaPods dependencies.

## Project Configuration

### Bundle Identifier

The current bundle identifier is: `com.example.newsapp`

**For production:** You should change this to your own unique identifier:
1. In Xcode, select the Runner project in the navigator
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Change the Bundle Identifier to your own (e.g., `com.yourcompany.sideline`)

### Code Signing

1. In Xcode, select the Runner project
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Select your development team from the dropdown
5. Xcode will automatically manage provisioning profiles

### Deployment Target

The app is configured for iOS 12.0+. This is set in:
- `Podfile`: `platform :ios, '12.0'`
- Xcode project settings: IPHONEOS_DEPLOYMENT_TARGET = 12.0

## Permissions Configured

The following permissions are already configured in `Info.plist`:

- **Internet Access** - For API calls and web content
- **Camera** (NSCameraUsageDescription) - For taking photos
- **Photo Library** (NSPhotoLibraryUsageDescription) - For selecting photos
- **Photo Library Add** (NSPhotoLibraryAddUsageDescription) - For saving photos
- **Deep Links** - URL scheme: `newsapp://`

## Building the App

### Debug Build (Simulator)

1. In Xcode, select a simulator from the device dropdown (e.g., iPhone 15 Pro)
2. Press `Cmd + R` or click the Play button
3. The app will build and launch in the simulator

### Debug Build (Physical Device)

1. Connect your iPhone/iPad via USB
2. Unlock your device and trust your computer if prompted
3. Select your device from the device dropdown in Xcode
4. Press `Cmd + R` or click the Play button
5. On first run, you may need to trust the developer profile:
   - Settings → General → VPN & Device Management → Trust

### Release Build

```bash
# From project root
flutter build ios --release

# Or build archive in Xcode:
# Product → Archive
```

## Common Issues and Solutions

### Issue: "Pod install" fails

**Solution:**
```bash
# Clean CocoaPods cache
pod cache clean --all
rm -rf ios/Pods ios/Podfile.lock
pod install
```

### Issue: "GeneratedPluginRegistrant not found"

**Solution:**
```bash
# Run Flutter pub get first
flutter pub get
flutter clean
flutter pub get
```

### Issue: Build fails with "No such module 'Flutter'"

**Solution:**
1. Make sure you're opening `Runner.xcworkspace`, not `Runner.xcodeproj`
2. Run `pod install` in the ios directory
3. Clean build folder: Product → Clean Build Folder (Cmd + Shift + K)

### Issue: Signing errors

**Solution:**
1. Go to Signing & Capabilities in Xcode
2. Select your development team
3. Change Bundle Identifier if needed
4. Enable "Automatically manage signing"

### Issue: App name shows as "Runner" on device

**Solution:**
The app name is already configured as "Side Line" in `Info.plist`. If it still shows "Runner":
1. Clean the build: Product → Clean Build Folder
2. Delete the app from device/simulator
3. Rebuild and install

## Plugin Dependencies

The app uses the following Flutter plugins with iOS support:

- **dio** - HTTP client
- **app_links** - Deep linking
- **shared_preferences** - Local storage
- **path_provider** - File system access
- **webview_flutter** - WebView support
- **image_picker** - Camera and photo library
- **cached_network_image** - Image caching
- **intl_phone_field** - International phone numbers

All plugins are automatically configured via CocoaPods when you run `pod install`.

## Additional Configuration

### Changing App Icon

App icons are located in:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

To update icons:
1. Run `flutter pub run flutter_launcher_icons` from project root
2. Or manually replace icon files in the AppIcon.appiconset folder

### Deep Link Configuration

Deep links are configured for:
- Scheme: `newsapp`
- Host: `verify-email`
- Example: `newsapp://verify-email?token=xxx`

To change the scheme, update:
- `ios/Runner/Info.plist` - CFBundleURLSchemes section
- `android/app/src/main/AndroidManifest.xml` - intent-filter section

## File Structure

```
ios/
├── Podfile                      # CocoaPods dependencies
├── Podfile.lock                 # Locked dependency versions (generated)
├── Pods/                        # CocoaPods dependencies (generated)
├── Runner.xcworkspace/          # Xcode workspace (use this)
├── Runner.xcodeproj/            # Xcode project
├── Runner/
│   ├── AppDelegate.swift        # App entry point
│   ├── Info.plist               # App configuration & permissions
│   ├── Assets.xcassets/         # App icons and images
│   ├── Base.lproj/              # Storyboards
│   └── Runner-Bridging-Header.h # Objective-C bridge
└── Flutter/
    ├── Debug.xcconfig           # Debug configuration
    ├── Release.xcconfig         # Release configuration
    └── Generated.xcconfig       # Generated by Flutter
```

## Testing

### Running Tests

```bash
# From project root
flutter test

# iOS-specific integration tests (if available)
flutter drive --target=test_driver/app.dart
```

### Running in Xcode

1. Select Product → Test (Cmd + U)
2. Tests are defined in `ios/RunnerTests/`

## Deployment to App Store

1. **Prepare for release:**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode:**
   - Product → Archive
   - Wait for archive to complete
   - Xcode Organizer will open

3. **Distribute:**
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Follow the upload wizard
   - Upload to TestFlight or submit for review

4. **App Store Connect:**
   - Configure app metadata
   - Add screenshots and description
   - Submit for review

## Support

For Flutter-specific issues:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos)

For Xcode/iOS issues:
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [CocoaPods Guides](https://guides.cocoapods.org/)

## Quick Reference Commands

```bash
# Install dependencies
flutter pub get
cd ios && pod install && cd ..

# Clean and rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build for iOS
flutter build ios --release

# Run on device/simulator
flutter run

# Run in release mode
flutter run --release

# Check Flutter doctor
flutter doctor -v
```

---

**App Version:** 1.0.0+1
**Minimum iOS Version:** 12.0
**Bundle ID:** com.example.newsapp (change for production)
