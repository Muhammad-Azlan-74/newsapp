# Quick Start - iOS Development

## 🚀 5-Minute iOS Setup

### Prerequisites (macOS only)
```bash
# 1. Install Xcode from Mac App Store
# 2. Install CocoaPods
sudo gem install cocoapods
```

### Setup Commands
```bash
# Clone and navigate
git clone <your-repo>
cd newsapp

# Install Flutter dependencies
flutter pub get

# Install iOS dependencies
cd ios
pod install
cd ..

# Open in Xcode
cd ios && open Runner.xcworkspace
```

### In Xcode
1. Select your team in **Signing & Capabilities**
2. Select device/simulator from dropdown
3. Press **Cmd+R** to build and run

## 📋 Pre-Flight Checklist

- [ ] Running on macOS
- [ ] Xcode 14.0+ installed
- [ ] CocoaPods installed (`pod --version`)
- [ ] Flutter installed (`flutter doctor`)
- [ ] Ran `flutter pub get`
- [ ] Ran `cd ios && pod install`
- [ ] Opening `Runner.xcworkspace` (NOT .xcodeproj)
- [ ] Code signing team selected in Xcode

## 🎯 What's Already Configured

| Item | Status | Location |
|------|--------|----------|
| Podfile | ✅ Ready | `ios/Podfile` |
| App Name | ✅ "Side Line" | `ios/Runner/Info.plist` |
| App Icons | ✅ Generated | `ios/Runner/Assets.xcassets/` |
| Permissions | ✅ Camera, Photos | `ios/Runner/Info.plist` |
| Deep Links | ✅ newsapp:// | `ios/Runner/Info.plist` |
| Orientation | ✅ Portrait only | `ios/Runner/Info.plist` |
| Min iOS | ✅ 12.0 | `ios/Podfile` |

## 🔧 Common Commands

```bash
# Clean and rebuild
flutter clean
cd ios && pod install && cd ..
flutter run

# Build release
flutter build ios --release

# Run Flutter doctor
flutter doctor -v

# Update pods
cd ios && pod update && cd ..
```

## 📱 Build for Device

### Debug Build
```bash
flutter run -d <device-id>
# Or press Cmd+R in Xcode
```

### Release Build
```bash
# Option 1: Flutter CLI
flutter build ios --release

# Option 2: Xcode
# Product → Archive → Distribute
```

## ⚠️ Important Notes

1. **Always** open `Runner.xcworkspace`, never `Runner.xcodeproj`
2. **Run** `pod install` after cloning or updating dependencies
3. **iOS development** requires macOS - cannot build iOS on Windows
4. **Bundle ID**: Change `com.example.newsapp` for production

## 🆘 Quick Fixes

### Build Fails
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Icons Not Showing
```bash
flutter clean
flutter pub run flutter_launcher_icons
flutter run
```

### Certificate/Signing Issues
1. Xcode → Preferences → Accounts → Add Apple ID
2. Project → Signing & Capabilities → Select Team
3. Enable "Automatically manage signing"

## 📚 Documentation

- **Full Guide**: [`ios/README.md`](ios/README.md)
- **Checklist**: [`ios/IOS_SETUP_CHECKLIST.md`](ios/IOS_SETUP_CHECKLIST.md)
- **Summary**: [`IOS_SETUP_SUMMARY.md`](IOS_SETUP_SUMMARY.md)
- **Main README**: [`README.md`](README.md)

## ✅ Success Indicators

You'll know it's working when:
- ✓ Xcode builds without errors
- ✓ App runs on simulator/device
- ✓ App name shows as "Side Line"
- ✓ App icon displays correctly
- ✓ Camera/photo permissions prompt when needed

---

**Ready to build?** Run `./setup_ios.sh` for automated setup!
