/// App Constants
///
/// This file contains application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // ==================== App Info ====================
  static const String appName = 'Side Line';
  static const String appVersion = '1.0.0';

  // ==================== UI Constants ====================

  /// Background image opacity for auth screens (splash, login, signup)
  static const double authBackgroundOpacity = 0.4;

  /// Background image opacity for dashboard/marketplace
  static const double dashboardBackgroundOpacity = 1.0;

  /// Default padding
  static const double defaultPadding = 16.0;

  /// Border radius
  static const double defaultBorderRadius = 12.0;

  // ==================== Animation Durations ====================

  /// Splash screen display duration (in seconds)
  static const int splashDuration = 3;

  /// Default transition duration (in milliseconds)
  static const int transitionDuration = 300;

  // ==================== API Constants ====================
  // Add your API constants here when needed
  // static const String baseUrl = 'https://api.example.com';
}
