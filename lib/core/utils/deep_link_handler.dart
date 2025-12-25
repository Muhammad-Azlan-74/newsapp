import 'dart:async';
import 'package:app_links/app_links.dart';

/// Deep Link Handler
///
/// Manages deep link initialization and handling for email verification
class DeepLinkHandler {
  static final _appLinks = AppLinks();
  static StreamSubscription? _subscription;

  /// Initialize deep link handling
  ///
  /// Handles both initial link (when app is opened via link)
  /// and incoming links (when app is already running)
  static Future<void> initialize(Function(Uri) onLinkReceived) async {
    // Handle initial link if app was opened via deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        onLinkReceived(initialUri);
      }
    } catch (e) {
      // Handle error silently
      print('Error getting initial URI: $e');
    }

    // Listen for links while app is running
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        onLinkReceived(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// Dispose the stream subscription
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Parse query parameters from URI
  static Map<String, String> parseQueryParameters(Uri uri) {
    return uri.queryParameters;
  }
}
