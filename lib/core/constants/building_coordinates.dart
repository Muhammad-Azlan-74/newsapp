import 'package:newsapp/shared/widgets/building_overlay.dart';
import 'package:flutter/material.dart';

/// Predefined building overlay coordinates for marketplace.jpeg
///
/// All coordinates are normalized (0.0 to 1.0) and mapped to
/// specific buildings in the marketplace background image.
class BuildingCoordinates {
  /// 1. Colorful Tower - Tall multicolored glass building on left side
  static BuildingOverlay get colorfulTower => const BuildingOverlay(
        left: 0.08,
        top: 0.02,
        width: 0.15,
        height: 0.55,
        label: 'Colorful Tower',
        borderRadius: 8.0,
      );

  /// 2. Gray Building - Traditional building behind the colorful tower
  static BuildingOverlay get grayBuilding => const BuildingOverlay(
        left: 0.02,
        top: 0.25,
        width: 0.12,
        height: 0.25,
        label: 'Gray Building',
        borderRadius: 8.0,
      );

  /// 3. BAR Building - Dark building with BAR signage (bottom left)
  static BuildingOverlay get barBuilding => const BuildingOverlay(
        left: 0.02,
        top: 0.48,
        width: 0.10,
        height: 0.12,
        label: 'BAR',
        borderRadius: 8.0,
      );

  /// 4. Stadium - Large sports stadium in center background
  static BuildingOverlay get stadium => const BuildingOverlay(
        left: 0.30,
        top: 0.25,
        width: 0.40,
        height: 0.25,
        label: 'Stadium',
        borderRadius: 12.0,
      );

  /// 5. Hall Game - Large beige classical building with columns (right side)
  static BuildingOverlay get hallGameBuilding => const BuildingOverlay(
        left: 0.58,
        top: 0.15,
        width: 0.38,
        height: 0.45,
        label: 'Hall Game',
        borderRadius: 10.0,
      );

  /// 6. Brown Building - Small brown residential building (center-right)
  static BuildingOverlay get brownHouse => const BuildingOverlay(
        left: 0.45,
        top: 0.32,
        width: 0.10,
        height: 0.18,
        label: 'Brown House',
        borderRadius: 6.0,
      );

  /// 7. Sport Squad Shop - Small shop with striped awning
  static BuildingOverlay get sportSquadShop => const BuildingOverlay(
        left: 0.40,
        top: 0.48,
        width: 0.12,
        height: 0.10,
        label: 'Sport Squad',
        borderRadius: 6.0,
      );

  /// 8. News Kiosk - Yellow and red kiosk in foreground plaza
  static BuildingOverlay get newsKiosk => const BuildingOverlay(
        left: 0.43,
        top: 0.68,
        width: 0.18,
        height: 0.20,
        label: 'News Kiosk',
        borderRadius: 8.0,
      );

  /// Get all buildings as a list
  static List<BuildingOverlay> get allBuildings => [
        colorfulTower,
        grayBuilding,
        barBuilding,
        stadium,
        hallGameBuilding,
        brownHouse,
        sportSquadShop,
        newsKiosk,
      ];

  /// Get all buildings with custom styling (white containers with colored borders)
  static List<BuildingOverlay> getAllWithStyling({
    double opacity = 0.75,
    bool showBorders = true,
  }) {
    return [
      colorfulTower.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.purple : null,
        borderWidth: 3.0,
      ),
      grayBuilding.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.grey : null,
        borderWidth: 3.0,
      ),
      barBuilding.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.brown : null,
        borderWidth: 3.0,
      ),
      stadium.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.red : null,
        borderWidth: 3.0,
      ),
      hallGameBuilding.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.orange : null,
        borderWidth: 3.0,
      ),
      brownHouse.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.brown.shade700 : null,
        borderWidth: 2.5,
      ),
      sportSquadShop.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.blue : null,
        borderWidth: 2.5,
      ),
      newsKiosk.copyWith(
        color: Colors.white.withOpacity(opacity),
        borderColor: showBorders ? Colors.yellow.shade700 : null,
        borderWidth: 3.0,
      ),
    ];
  }

  /// Get specific buildings by selecting indices
  ///
  /// Example:
  /// ```dart
  /// BuildingCoordinates.selectBuildings([0, 3, 4])
  /// // Returns: colorfulTower, stadium, hallGameBuilding
  /// ```
  static List<BuildingOverlay> selectBuildings(List<int> indices) {
    final all = allBuildings;
    return indices
        .where((i) => i >= 0 && i < all.length)
        .map((i) => all[i])
        .toList();
  }
}
