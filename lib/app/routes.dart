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
