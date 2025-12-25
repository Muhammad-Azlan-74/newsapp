# Building Overlay Quick Start Guide

## 🎯 Coordinates Determined for marketplace.jpeg

I've analyzed your marketplace.jpeg image and identified **8 buildings** with precise coordinates:

| # | Building Name | Location | Coordinates |
|---|--------------|----------|-------------|
| 1 | **Colorful Tower** | Left side - tall multicolored building | `(0.08, 0.02)` - `15% × 55%` |
| 2 | **Gray Building** | Behind colorful tower | `(0.02, 0.25)` - `12% × 25%` |
| 3 | **BAR Building** | Bottom left corner | `(0.02, 0.48)` - `10% × 12%` |
| 4 | **Stadium** | Center background | `(0.30, 0.25)` - `40% × 25%` |
| 5 | **Hall Game** | Right side - beige classical building | `(0.58, 0.15)` - `38% × 45%` |
| 6 | **Brown House** | Small building center-right | `(0.45, 0.32)` - `10% × 18%` |
| 7 | **Sport Squad Shop** | Shop with striped awning | `(0.40, 0.48)` - `12% × 10%` |
| 8 | **News Kiosk** | Yellow/red kiosk in foreground | `(0.43, 0.68)` - `18% × 20%` |

## 🚀 Quick Usage

### Option 1: Use Predefined Coordinates (Recommended)

```dart
import 'package:newsapp/core/constants/building_coordinates.dart';
import 'package:newsapp/shared/widgets/image_relative_background.dart';
import 'package:newsapp/core/constants/app_assets.dart';

// Show all buildings with default styling
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 1.0,
  overlays: BuildingCoordinates.getAllWithStyling(
    opacity: 0.75,
    showBorders: true,
  ),
  child: YourContent(),
)

// Or select specific buildings
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 1.0,
  overlays: BuildingCoordinates.selectBuildings([0, 3, 4])
    .map((building) => building.copyWith(
      color: Colors.white.withOpacity(0.8),
    ))
    .toList(),
  child: YourContent(),
)

// Or individual buildings
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 1.0,
  overlays: [
    BuildingCoordinates.stadium.copyWith(
      color: Colors.red.withOpacity(0.3),
      label: 'Click to view matches',
    ),
  ],
  child: YourContent(),
)
```

### Option 2: Define Custom Coordinates

```dart
BuildingOverlay(
  left: 0.2,     // 20% from left
  top: 0.3,      // 30% from top
  width: 0.25,   // 25% of image width
  height: 0.4,   // 40% of image height
  color: Colors.white.withOpacity(0.7),
  label: 'My Building',
)
```

## 🧪 Test the Implementation

Run the demo screen to see all 8 buildings highlighted:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BuildingOverlayDemoScreen(),
  ),
);
```

Or add to your router:

```dart
// In your routes
'/building-demo': (context) => BuildingOverlayDemoScreen(),
```

## 📐 Visual Reference

```
┌─────────────────────────────────────────────────┐
│        [2]                                      │
│   [1]  Gray                         [5]         │
│  Color  Bld                      Hall Game      │
│  Tower         [4]                Building      │
│   │          Stadium                  │         │
│   │         ╔═════╗             [6]   │         │
│  [3]        ║     ║            Brown  │         │
│  BAR   [7]  ║     ║            House  │         │
│       Sport ╚═════╝                   │         │
│       Squad                           │         │
│                                                 │
│              [8]                                │
│           News Kiosk                            │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 🎨 Customization Examples

### Example 1: Interactive Stadium
```dart
BuildingCoordinates.stadium.copyWith(
  color: Colors.red.withOpacity(0.5),
  borderColor: Colors.red.shade900,
  borderWidth: 4.0,
  customWidget: GestureDetector(
    onTap: () => Navigator.push(...),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(Icons.stadium, size: 48, color: Colors.white),
      ),
    ),
  ),
)
```

### Example 2: Highlight Multiple Buildings
```dart
overlays: [
  BuildingCoordinates.colorfulTower,
  BuildingCoordinates.hallGameBuilding,
  BuildingCoordinates.stadium,
].map((building) => building.copyWith(
  color: Colors.white.withOpacity(0.8),
  borderColor: Colors.blue,
  borderWidth: 3.0,
)).toList(),
```

### Example 3: Custom Color Per Building
```dart
overlays: [
  BuildingCoordinates.barBuilding.copyWith(
    color: Colors.brown.withOpacity(0.6),
    label: '🍺 BAR',
  ),
  BuildingCoordinates.sportSquadShop.copyWith(
    color: Colors.blue.withOpacity(0.6),
    label: '⚽ SHOP',
  ),
  BuildingCoordinates.newsKiosk.copyWith(
    color: Colors.yellow.withOpacity(0.6),
    label: '📰 NEWS',
  ),
],
```

## 🔧 Fine-Tuning Coordinates

If overlays don't align perfectly:

1. **Enable debug mode** to see exact boundaries:
   ```dart
   ImageRelativeBackground(
     debugMode: true,  // Shows red borders
     ...
   )
   ```

2. **Adjust coordinates** in `building_coordinates.dart`

3. **Hot reload** to see changes instantly

4. **Test on different devices** to ensure consistency

## 📱 Integration Examples

### Replace BackgroundWidget
```dart
// Old
BackgroundWidget(
  opacity: 0.4,
  child: MyContent(),
)

// New with building overlays
ImageRelativeBackground(
  imagePath: AppAssets.backgroundImage,
  opacity: 0.4,
  overlays: BuildingCoordinates.getAllWithStyling(opacity: 0.7),
  child: MyContent(),
)
```

### Use in Marketplace Screen
```dart
class MarketplaceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageRelativeBackground(
        imagePath: AppAssets.backgroundImage,
        opacity: 1.0,
        overlays: [
          BuildingCoordinates.stadium.copyWith(
            customWidget: _buildStadiumCard(),
          ),
          BuildingCoordinates.barBuilding.copyWith(
            customWidget: _buildBarCard(),
          ),
        ],
        child: SafeArea(child: YourDashboard()),
      ),
    );
  }
}
```

## ✅ Next Steps

1. ✅ Run the demo: `BuildingOverlayDemoScreen()`
2. ✅ Review coordinates in: `lib/core/constants/building_coordinates.dart`
3. ✅ Test on different screen sizes (phone, tablet, landscape)
4. ✅ Customize colors and borders for your use case
5. ✅ Integrate into your actual screens

## 📚 Related Files

- **Model**: `lib/shared/widgets/building_overlay.dart`
- **Widget**: `lib/shared/widgets/image_relative_background.dart`
- **Coordinates**: `lib/core/constants/building_coordinates.dart`
- **Demo**: `lib/features/marketplace/presentation/pages/building_overlay_demo_screen.dart`
- **Full Guide**: `IMAGE_RELATIVE_POSITIONING_GUIDE.md`
