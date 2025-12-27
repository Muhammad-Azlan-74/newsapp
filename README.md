# Side Line

A Flutter-based mobile application for sports news and team management.

## Table of Contents
- [About](#about)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Platform Setup](#platform-setup)
- [Project Structure](#project-structure)
- [Building](#building)
- [Contributing](#contributing)

## About

Side Line is a cross-platform mobile application built with Flutter that provides sports news, team management, and interactive features for sports enthusiasts.

**Version**: 1.0.0+1
**Minimum SDK**: Flutter 3.8.1+

## Features

- 🏈 Sports team management and selection
- 📰 News feed and articles
- 🏢 Interactive office and facility navigation
- 👥 Hall of Fame and friend interactions
- 🔔 Real-time notifications with Socket.IO
- 📱 Deep linking support
- 🖼️ Image upload and management
- 📞 International phone number support
- 🌐 WebView integration
- 🎨 Glassmorphism UI design

## Requirements

### Development Environment
- **Flutter SDK**: 3.8.1 or higher
- **Dart SDK**: Included with Flutter

### For Android Development
- Android Studio or IntelliJ IDEA
- Android SDK (API 21+)
- Java JDK 11 or higher

### For iOS Development (macOS only)
- Xcode 14.0 or higher
- CocoaPods
- iOS 12.0+ for deployment

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd newsapp
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
# Run on connected device or emulator
flutter run

# Run in release mode
flutter run --release
```

## Platform Setup

### Android Setup

1. **Open in Android Studio**
   ```bash
   # Open the android folder in Android Studio
   cd android
   # Or use: studio android
   ```

2. **Configuration**
   - Bundle ID: `com.example.newsapp`
   - Min SDK: 21 (Android 5.0)
   - Target SDK: Latest
   - Compile SDK: Latest

3. **Build**
   ```bash
   flutter build apk --release
   # Or for app bundle:
   flutter build appbundle --release
   ```

4. **Permissions Configured**
   - Internet access
   - Camera
   - Read/Write external storage
   - Post notifications

### iOS Setup

**Important**: iOS development requires macOS with Xcode installed.

#### Quick Setup
```bash
# Run the automated setup script (on macOS)
chmod +x setup_ios.sh
./setup_ios.sh
```

#### Manual Setup
1. **Install CocoaPods Dependencies**
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. **Open in Xcode**
   ```bash
   cd ios
   open Runner.xcworkspace  # Important: Open .xcworkspace, not .xcodeproj
   ```

3. **Configure Code Signing**
   - Select Runner project in Xcode
   - Go to Signing & Capabilities
   - Select your development team
   - Change Bundle Identifier if needed

4. **Build and Run**
   - Select a device or simulator
   - Press Cmd+R or click the Play button

**For detailed iOS setup instructions, see**: [`ios/README.md`](ios/README.md)

**For iOS setup checklist, see**: [`ios/IOS_SETUP_CHECKLIST.md`](ios/IOS_SETUP_CHECKLIST.md)

## Project Structure

```
lib/
├── app/
│   ├── routes.dart              # App navigation routes
│   └── theme/                   # Theme configuration
├── core/
│   ├── constants/               # App constants and assets
│   ├── network/                 # API configuration
│   ├── services/                # Core services
│   └── utils/                   # Utility functions
├── features/
│   ├── auth/                    # Authentication feature
│   ├── marketplace/             # Marketplace/navigation feature
│   └── user/                    # User management feature
├── shared/
│   └── widgets/                 # Reusable widgets
└── main.dart                    # App entry point
```

## Dependencies

### Core Dependencies
- **dio** (^5.4.0) - HTTP client for API calls
- **socket_io_client** (^2.0.3+1) - Real-time notifications via WebSocket
- **app_links** (^6.3.2) - Deep linking support
- **shared_preferences** (^2.2.2) - Local storage
- **path_provider** (^2.1.1) - File system access
- **webview_flutter** (^4.4.4) - WebView integration
- **image_picker** (^1.0.4) - Camera and gallery access
- **cached_network_image** (^3.3.0) - Image caching
- **intl_phone_field** (^3.2.0) - Phone number input
- **timeago** (^3.7.0) - Time formatting for notifications

### Development Dependencies
- **flutter_test** - Testing framework
- **flutter_lints** (^5.0.0) - Linting rules
- **flutter_launcher_icons** (^0.13.1) - App icon generation

## Building

### Development Build
```bash
# Debug build (default)
flutter run

# Profile build (performance profiling)
flutter run --profile

# Release build
flutter run --release
```

### Production Build

#### Android
```bash
# APK
flutter build apk --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output location:
# - APK: build/app/outputs/flutter-apk/app-release.apk
# - Bundle: build/app/outputs/bundle/release/app-release.aab
```

#### iOS
```bash
# Build iOS app
flutter build ios --release

# Or use Xcode:
# Product → Archive → Distribute
```

## Configuration

### App Name
Current app name: **Side Line**

To change:
- `lib/core/constants/app_constants.dart` - `appName`
- `android/app/src/main/AndroidManifest.xml` - `android:label`
- `ios/Runner/Info.plist` - `CFBundleDisplayName` and `CFBundleName`

### App Icon
App icon source: `assets/images/logo.png`

To regenerate icons:
```bash
flutter pub run flutter_launcher_icons
```

### Deep Linking
URL Scheme: `newsapp://`

Examples:
- `newsapp://verify-email?token=xxx`

Configuration files:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Orientation
The app is locked to **portrait mode only** on both platforms.

### Notifications

The app includes a complete real-time notification system:

**Features:**
- Real-time notifications via Socket.IO WebSocket
- Notification history with pagination
- Mark notifications as read
- In-app notification popups
- Unread badge counter
- Auto-reconnection on network issues

**Usage:**
1. Notification bell icon appears in top-right of marketplace
2. Badge shows unread notification count
3. Tap bell to view notification history
4. Tap notification to mark as read
5. Real-time notifications appear as SnackBars

**Documentation:**
- Quick Start: [NOTIFICATIONS_QUICK_START.md](NOTIFICATIONS_QUICK_START.md)
- Full Docs: [NOTIFICATIONS_DOCUMENTATION.md](NOTIFICATIONS_DOCUMENTATION.md)
- Summary: [NOTIFICATIONS_SUMMARY.md](NOTIFICATIONS_SUMMARY.md)

**API:**
- Socket.IO: `wss://sportsapp-server.vercel.app?token=<accessToken>`
- REST API: `GET /api/notifications` and `PUT /api/notifications/:id/read`

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## Common Issues

### Issue: White screen on startup
**Solution**: Background images are precached. Ensure `assets/` folder is properly configured in `pubspec.yaml`.

### Issue: Deep links not working
**Solution**:
- Android: Verify intent-filter in AndroidManifest.xml
- iOS: Verify CFBundleURLTypes in Info.plist
- Rebuild the app after changes

### Issue: Icons not updating
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
```

### Issue: iOS build fails
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## Support

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)

### Platform-Specific
- [Android Setup Guide](https://docs.flutter.dev/get-started/install/windows#android-setup)
- [iOS Setup Guide](ios/README.md)

## Project Status

- ✅ Authentication flow implemented
- ✅ Team selection
- ✅ Marketplace navigation
- ✅ Office building interactions
- ✅ Hall of Fame feature
- ✅ Real-time notifications (Socket.IO + REST API)
- ✅ Portrait mode locked
- ✅ Deep linking configured
- ✅ App icons generated
- ⏳ Firebase/FCM (commented out, ready for future use)

## Contributing

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code: `dart format .`

### Branch Strategy
- `master` - Main development branch
- Feature branches - For new features
- Bug fix branches - For fixes

## License

[Add your license information here]

---

**App Name**: Side Line
**Current Version**: 1.0.0+1
**Platform**: iOS 12.0+, Android 5.0+
**Framework**: Flutter 3.8.1+
