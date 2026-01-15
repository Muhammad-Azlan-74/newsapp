#!/bin/bash

# iOS Setup Script for Side Line App
# This script sets up the iOS development environment and installs all dependencies

set -e  # Exit on error

echo "========================================="
echo "Side Line iOS Setup Script"
echo "========================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must be run on macOS for iOS development"
    exit 1
fi

# Check if Flutter is installed
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed"
    echo "   Please install Flutter from: https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi
echo "✅ Flutter is installed"
flutter --version
echo ""

# Check if CocoaPods is installed
echo "📦 Checking CocoaPods installation..."
if ! command -v pod &> /dev/null; then
    echo "⚠️  CocoaPods is not installed"
    echo "   Installing CocoaPods..."
    sudo gem install cocoapods
    echo "✅ CocoaPods installed"
else
    echo "✅ CocoaPods is installed"
    pod --version
fi
echo ""

# Check if Xcode is installed
echo "🔨 Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi
echo "✅ Xcode is installed"
xcodebuild -version
echo ""

# Install Flutter dependencies
echo "📦 Installing Flutter dependencies..."
flutter pub get
echo "✅ Flutter dependencies installed"
echo ""

# Install iOS CocoaPods dependencies
echo "📦 Installing iOS CocoaPods dependencies..."
cd ios
pod install
cd ..
echo "✅ iOS dependencies installed"
echo ""

# Run Flutter doctor
echo "🔍 Running Flutter doctor..."
flutter doctor -v
echo ""

# Generate app icons (if needed)
echo "🎨 Checking app icons..."
if [ -f "assets/images/logo.png" ]; then
    echo "   Generating app icons from logo.png..."
    flutter pub run flutter_launcher_icons || echo "⚠️  Icon generation skipped (package may need to be added)"
else
    echo "⚠️  Warning: logo.png not found in assets/images/"
fi
echo ""

# Summary
echo "========================================="
echo "✅ iOS Setup Complete!"
echo "========================================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Open Xcode:"
echo "   cd ios"
echo "   open Runner.xcworkspace"
echo ""
echo "2. Configure Code Signing:"
echo "   - Select Runner project in Xcode"
echo "   - Go to Signing & Capabilities"
echo "   - Select your development team"
echo "   - Change Bundle ID if needed: com.example.newsapp"
echo ""
echo "3. Build and Run:"
echo "   - Select a device or simulator"
echo "   - Press Cmd+R or click Play"
echo ""
echo "📖 For more information, see: ios/README.md"
echo ""
echo "========================================="
