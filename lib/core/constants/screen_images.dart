import 'package:newsapp/core/constants/app_assets.dart';
import 'package:newsapp/app/routes.dart';

/// Screen Images Mapping
///
/// Maps routes to their background images for preloading
class ScreenImages {
  static const Map<String, String> routeImages = {
    AppRoutes.newsStand: AppAssets.backgroundImage,
    AppRoutes.sportsbook: AppAssets.sportsbook,
    AppRoutes.doctorsOffice: AppAssets.doctorOffice,
    AppRoutes.personalOffice: AppAssets.personalOffice,
    AppRoutes.studioTv: AppAssets.studioTv,
    AppRoutes.rightBottomZoneDetail: AppAssets.mainOffice,
    AppRoutes.rumourGarage: AppAssets.garage,
    AppRoutes.janitorOffice: AppAssets.janitorOffice,
    AppRoutes.hrOffice: AppAssets.hrOffice,
    AppRoutes.conferenceRoom: AppAssets.conferenceRoom,
    AppRoutes.manCave: AppAssets.manCave,
    AppRoutes.centerHubDetail: 'assets/images/training_ground.png',
    AppRoutes.leftZoneDetail: 'assets/images/social_bar.png',
    AppRoutes.rightTopZoneDetail: 'assets/images/hof_hallway.png',
    AppRoutes.hofFriends: 'assets/images/hof_hallway.png',
  };

  /// Get the image path for a given route
  static String? getImageForRoute(String route) {
    return routeImages[route];
  }
}
