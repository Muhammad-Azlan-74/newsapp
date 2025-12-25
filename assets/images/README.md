# Assets Images

This folder contains all the image assets used in the NewsApp.

## Required Images

Please add the following images to this folder:

### 1. background.jpg
- **Usage**: Background image for all screens
- **Size**: Recommended 1080x1920 pixels or higher
- **Format**: JPG, PNG
- **Description**:
  - Used with 40% opacity on: Splash, Login, and Signup screens
  - Used with 100% opacity on: Marketplace/Dashboard screen

### 2. logo.png
- **Usage**: App logo displayed on splash screen
- **Size**: Recommended 512x512 pixels
- **Format**: PNG (with transparent background)
- **Description**: Your app logo/branding

### 3. news_placeholder.png (Optional)
- **Usage**: Placeholder image for news articles without images
- **Size**: Recommended 400x400 pixels
- **Format**: PNG
- **Description**: Generic news placeholder image

## How to Add Images

1. Download or create your images
2. Rename them according to the names above
3. Place them in this folder: `assets/images/`
4. Run `flutter pub get` to ensure assets are recognized
5. Restart your app

## Image Paths Reference

All image paths are centralized in:
```
lib/core/constants/app_assets.dart
```

## Note

If you don't add these images, the app will still work but will show:
- Gradient fallback for background images
- Icon fallback for missing logos
