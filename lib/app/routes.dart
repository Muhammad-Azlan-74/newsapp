import 'package:flutter/material.dart';
import 'package:newsapp/features/auth/presentation/pages/splash_screen.dart';
import 'package:newsapp/features/auth/presentation/pages/login_screen.dart';
import 'package:newsapp/features/auth/presentation/pages/signup_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/marketplace_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/left_zone_detail_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/center_hub_detail_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/right_top_zone_detail_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/right_bottom_zone_detail_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/bottom_right_action_detail_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/doctors_office_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/hr_office_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/janitor_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/studio_tv_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/personal_office_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/sportsbook_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/rumour_garage_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/conference_room_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/man_cave_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/news_stand_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/hof_friends_screen.dart';
import 'package:newsapp/features/marketplace/presentation/pages/personal_hof_screen.dart';
import 'package:newsapp/features/notifications/presentation/pages/notifications_screen.dart';

/// App Routes
///
/// Centralized route management for the application
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String marketplace = '/marketplace';

  // Marketplace detail routes
  static const String leftZoneDetail = '/marketplace/left-zone';
  static const String centerHubDetail = '/marketplace/center-hub';
  static const String rightTopZoneDetail = '/marketplace/right-top-zone';
  static const String rightBottomZoneDetail = '/marketplace/right-bottom-zone';
  static const String bottomRightActionDetail = '/marketplace/bottom-right-action';
  static const String doctorsOffice = '/marketplace/doctors-office';
  static const String hrOffice = '/marketplace/hr-office';
  static const String janitorOffice = '/marketplace/janitor-office';
  static const String studioTv = '/marketplace/studio-tv';
  static const String personalOffice = '/marketplace/personal-office';
  static const String sportsbook = '/marketplace/sportsbook';
  static const String rumourGarage = '/marketplace/rumour-garage';
  static const String conferenceRoom = '/marketplace/conference-room';
  static const String manCave = '/marketplace/man-cave';
  static const String newsStand = '/marketplace/news-stand';
  static const String hofFriends = '/marketplace/hof-friends';
  static const String personalHof = '/marketplace/personal-hof';
  static const String notifications = '/notifications';

  /// Generate routes for the app
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());

      case leftZoneDetail:
        return MaterialPageRoute(builder: (_) => const LeftZoneDetailScreen());

      case centerHubDetail:
        return MaterialPageRoute(builder: (_) => const CenterHubDetailScreen());

      case rightTopZoneDetail:
        return MaterialPageRoute(builder: (_) => const RightTopZoneDetailScreen());

      case rightBottomZoneDetail:
        return MaterialPageRoute(builder: (_) => const RightBottomZoneDetailScreen());

      case bottomRightActionDetail:
        return MaterialPageRoute(builder: (_) => const BottomRightActionDetailScreen());

      case doctorsOffice:
        return MaterialPageRoute(builder: (_) => const DoctorsOfficeScreen());

      case hrOffice:
        return MaterialPageRoute(builder: (_) => const HrOfficeScreen());

      case janitorOffice:
        return MaterialPageRoute(builder: (_) => const JanitorScreen());

      case studioTv:
        return MaterialPageRoute(builder: (_) => const StudioTvScreen());

      case personalOffice:
        return MaterialPageRoute(builder: (_) => const PersonalOfficeScreen());

      case sportsbook:
        return MaterialPageRoute(builder: (_) => const SportsbookScreen());

      case rumourGarage:
        return MaterialPageRoute(builder: (_) => const RumourGarageScreen());

      case conferenceRoom:
        return MaterialPageRoute(builder: (_) => const ConferenceRoomScreen());

      case manCave:
        return MaterialPageRoute(builder: (_) => const ManCaveScreen());

      case newsStand:
        return MaterialPageRoute(builder: (_) => const NewsStandScreen());

      case hofFriends:
        return MaterialPageRoute(builder: (_) => const HofFriendsScreen());

      case personalHof:
        return MaterialPageRoute(builder: (_) => const PersonalHofScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
