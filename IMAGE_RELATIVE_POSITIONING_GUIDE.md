# Image-Relative Positioning System

## Overview

This system allows you to position containers **relative to a background image**, not the screen. This ensures that overlays stay locked to specific areas of the image (like buildings) regardless of screen size or aspect ratio changes.

## The Problem with Screen-Relative Positioning

When using standard Flutter layout (padding, margins, percentages), containers are positioned relative to the **screen**:

```dart
// ❌ Screen-relative (breaks on different aspect ratios)
Positioned(
  left: MediaQuery.of(context).size.width * 0.2,  // 20% from screen left
  top: MediaQuery.of(context).size.height * 0.3,  // 30% from screen top
  child: Container(...),
)
```

**Problems:**
- Different screen aspect ratios cause drift
- Background image scales/crops differently on each device
- Containers don't stay aligned with image features

## The Solution: Image-Relative Coordinates

Use **normalized coordinates (0.0 to 1.0)** relative to the **image itself**:

```dart
// ✅ Image-relative (stays locked to image)
BuildingOverlay(
  left: 0.2,    // 20% from image's left edge
  top: 0.3,     // 30% from image's top edge
  width: 0.25,  // 25% of image width
  height: 0.4,  // 40% of image height
)
```

## How It Works

1. **Image Aspect Ratio Locked**: The background image maintains its original aspect ratio using `BoxFit.contain`
2. **Coordinate Transformation**: Normalized coordinates (0.0-1.0) are converted to actual screen pixels
3. **Automatic Scaling**: As screen size changes, overlays scale and move with the image
4. **No Drift**: Overlays stay perfectly aligned with image features

## Usage

### 1. Create Building Overlays

Define each overlay using normalized coordinates:

```dart
final overlays = [
  BuildingOverlay(
    left: 0.1,      // 10% from left edge
    top: 0.2,       // 20% from top edge
    width: 0.25,    // 25% of image width
    height: 0.4,    // 40% of image height
    label: 'Building 1',
    color: Colors.white.withOpacity(0.7),
    borderColor: Colors.blue,
    borderWidth: 3.0,
  ),
  // Add more overlays...
];
```

### 2. Use ImageRelativeBackground Widget

```dart
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 1.0,
  overlays: overlays,
  debugMode: false,  // Set to true to see debug borders
  child: YourContent(),
)
```

### 3. Finding the Right Coordinates

To determine correct coordinates for your buildings:

#### Method 1: Trial and Error
1. Set `debugMode: true` to see red borders
2. Adjust coordinates and hot reload
3. Check alignment with background features

#### Method 2: Image Editor
1. Open your background image in an image editor
2. Note the image dimensions (e.g., 1920x1080)
3. Measure building positions in pixels
4. Convert to normalized coordinates:
   - `left = buildingX / imageWidth`
   - `top = buildingY / imageHeight`
   - `width = buildingWidth / imageWidth`
   - `height = buildingHeight / imageHeight`

#### Example Calculation:
```
Image: 1920x1080 pixels
Building: starts at (384, 216), size 480x432

Normalized coordinates:
left   = 384 / 1920  = 0.2
top    = 216 / 1080  = 0.2
width  = 480 / 1920  = 0.25
height = 432 / 1080  = 0.4
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/shared/widgets/building_overlay.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageRelativeBackground(
        imagePath: AppAssets.backgroundImage,
        opacity: 0.8,
        overlays: [
          BuildingOverlay(
            left: 0.15,
            top: 0.25,
            width: 0.2,
            height: 0.3,
            label: 'North Building',
            color: Colors.white.withOpacity(0.7),
          ),
          BuildingOverlay(
            left: 0.45,
            top: 0.2,
            width: 0.15,
            height: 0.4,
            label: 'Tower',
            color: Colors.white.withOpacity(0.7),
          ),
        ],
        child: SafeArea(
          child: YourUIContent(),
        ),
      ),
    );
  }
}
```

## Custom Overlay Widgets

You can provide custom widgets instead of the default white container:

```dart
BuildingOverlay(
  left: 0.2,
  top: 0.3,
  width: 0.25,
  height: 0.4,
  customWidget: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Icon(Icons.location_on, size: 48),
    ),
  ),
)
```

## Testing on Different Screen Sizes

To verify your overlays work correctly:

1. **Run on multiple devices**: Phone, tablet, different aspect ratios
2. **Rotate device**: Portrait ↔ Landscape
3. **Resize window**: If running on desktop/web
4. **Check alignment**: Overlays should stay on the same image features

## Coordinate System Reference

```
Image Coordinate System (normalized 0.0 to 1.0)

(0,0)                    (0.5,0)                    (1,0)
  ┌──────────────────────┬──────────────────────────┐
  │                      │                          │
  │                      │                          │
  │                      │                          │
(0,0.5)                (0.5,0.5)                 (1,0.5)
  │                      │                          │
  │                      │                          │
  │                      │                          │
  └──────────────────────┴──────────────────────────┘
(0,1)                   (0.5,1)                    (1,1)
```

## Files Created

1. **`lib/shared/widgets/building_overlay.dart`**
   - Model class for overlay definitions
   - Properties: position, size, styling

2. **`lib/shared/widgets/image_relative_background.dart`**
   - Main widget for image-relative positioning
   - Handles coordinate transformation
   - Manages image loading and rendering

3. **`lib/features/marketplace/presentation/pages/building_overlay_demo_screen.dart`**
   - Example implementation
   - Shows 4 sample building overlays

## Migration from BackgroundWidget

### Old (Screen-Relative):
```dart
BackgroundWidget(
  opacity: 0.4,
  child: Container(
    padding: EdgeInsets.all(20),
    child: MyForm(),
  ),
)
```

### New (Image-Relative):
```dart
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 0.4,
  overlays: [
    BuildingOverlay(...),
  ],
  child: Container(
    padding: EdgeInsets.all(20),
    child: MyForm(),
  ),
)
```

## Tips

- **Start with debugMode: true** to visualize overlay positions
- **Use consistent opacity** (0.7 works well for white overlays)
- **Add borders** during development to see exact boundaries
- **Test landscape mode** - aspect ratio changes are most visible here
- **Keep coordinates simple** - round to 2 decimal places for easier tweaking

## Common Issues

### Overlays not visible
- Check opacity values (0.0 is fully transparent)
- Verify coordinates are within 0.0-1.0 range
- Enable `debugMode: true` to see red borders

### Overlays don't align with buildings
- Verify you're using normalized coordinates, not pixel values
- Double-check image dimensions when calculating coordinates
- Use image editor to measure exact positions

### Overlays drift on rotation
- This shouldn't happen with this system
- If it does, verify you're using `ImageRelativeBackground`, not `BackgroundWidget`
- Check that coordinates are relative to image, not screen

## Demo Screen

Run the demo screen to see the system in action:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BuildingOverlayDemoScreen(),
  ),
);
```

The demo shows 4 sample overlays. Rotate your device or resize the window to see how they stay locked to the background image.
