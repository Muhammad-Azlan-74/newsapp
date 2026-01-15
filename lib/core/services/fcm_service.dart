// Commented out Firebase - uncomment when needed
// import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// import 'package:newsapp/core/network/api_client.dart';
// import 'package:newsapp/core/services/auth_storage_service.dart';
// import 'package:newsapp/features/user/data/repositories/notification_repository.dart';
// import 'local_notification_service.dart';

/// FCM Service - Commented out for now
///
/// Handles Firebase Cloud Messaging setup, token management, and message handling
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  // Commented out Firebase - uncomment when needed
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final LocalNotificationService _localNotificationService =
  //     LocalNotificationService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize FCM and request permissions - Commented out
  Future<void> initialize() async {
    debugPrint('FCM Service is disabled - uncomment Firebase code to enable');
    // Commented out Firebase - uncomment when needed
    // try {
    //   // Request notification permissions
    //   await requestPermission();
    //
    //   // Get FCM token
    //   await getToken();
    //
    //   // Setup message listeners
    //   _setupMessageListeners();
    //
    //   debugPrint('FCM Service initialized successfully');
    // } catch (e) {
    //   debugPrint('Error initializing FCM: $e');
    // }
  }

  /// Request notification permissions - Commented out
  // Future<NotificationSettings> requestPermission() async {
  //   final settings = await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //
  //   debugPrint('Notification permission status: ${settings.authorizationStatus}');
  //   return settings;
  // }

  /// Get FCM token and register with backend - Commented out
  Future<String?> getToken() async {
    debugPrint('FCM Service is disabled');
    return null;
    // Commented out Firebase - uncomment when needed
    // try {
    //   _fcmToken = await _firebaseMessaging.getToken();
    //   debugPrint('FCM Token: $_fcmToken');
    //
    //   if (_fcmToken != null) {
    //     // Save token locally
    //     await AuthStorageService.saveFcmToken(_fcmToken!);
    //
    //     // Register token with backend
    //     await _registerTokenWithBackend(_fcmToken!);
    //   }
    //
    //   return _fcmToken;
    // } catch (e) {
    //   debugPrint('Error getting FCM token: $e');
    //   return null;
    // }
  }

  /// Register FCM token with backend - Commented out
  // Future<void> _registerTokenWithBackend(String token) async {
  //   try {
  //     final authToken = await AuthStorageService.getToken();
  //     if (authToken == null) {
  //       debugPrint('No auth token, skipping FCM registration');
  //       return;
  //     }
  //
  //     final repository = NotificationRepository(ApiClient());
  //     await repository.registerFcmToken(
  //       fcmToken: token,
  //       deviceId: await _getDeviceId(),
  //       platform: Platform.isAndroid ? 'android' : 'ios',
  //     );
  //
  //     debugPrint('FCM token registered with backend');
  //   } catch (e) {
  //     debugPrint('Error registering FCM token with backend: $e');
  //   }
  // }

  /// Remove FCM token from backend (on logout) - Commented out
  Future<void> removeToken() async {
    debugPrint('FCM Service is disabled');
    // Commented out Firebase - uncomment when needed
    // try {
    //   final token = await AuthStorageService.getFcmToken();
    //   if (token != null) {
    //     final repository = NotificationRepository(ApiClient());
    //     await repository.removeFcmToken(token);
    //     debugPrint('FCM token removed from backend');
    //   }
    //
    //   await _firebaseMessaging.deleteToken();
    //   await AuthStorageService.removeFcmToken();
    //   _fcmToken = null;
    // } catch (e) {
    //   debugPrint('Error removing FCM token: $e');
    // }
  }

  /// Setup message listeners for different app states - Commented out
  // void _setupMessageListeners() {
  //   // Handle foreground messages
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     debugPrint('Foreground message received: ${message.messageId}');
  //     _handleForegroundMessage(message);
  //   });
  //
  //   // Handle notification tap when app is in background
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     debugPrint('Notification tapped (background): ${message.messageId}');
  //     _handleNotificationTap(message);
  //   });
  //
  //   // Handle token refresh
  //   _firebaseMessaging.onTokenRefresh.listen((String newToken) {
  //     debugPrint('FCM token refreshed: $newToken');
  //     _fcmToken = newToken;
  //     AuthStorageService.saveFcmToken(newToken);
  //     _registerTokenWithBackend(newToken);
  //   });
  // }

  /// Handle foreground messages (when app is open) - Commented out
  // void _handleForegroundMessage(RemoteMessage message) {
  //   debugPrint('Notification Title: ${message.notification?.title}');
  //   debugPrint('Notification Body: ${message.notification?.body}');
  //   debugPrint('Notification Data: ${message.data}');
  //
  //   // Show local notification
  //   _localNotificationService.showNotification(
  //     id: message.hashCode,
  //     title: message.notification?.title ?? 'New Notification',
  //     body: message.notification?.body ?? '',
  //     payload: message.data.toString(),
  //   );
  // }

  /// Handle notification tap - Commented out
  // void _handleNotificationTap(RemoteMessage message) {
  //   debugPrint('Notification tapped with data: ${message.data}');
  //   // Navigation will be handled by the notification navigator
  //   // You can emit an event or use a navigation service here
  // }

  /// Check if app was opened from a notification (terminated state) - Commented out
  Future<dynamic> getInitialMessage() async {
    debugPrint('FCM Service is disabled');
    return null;
    // Commented out Firebase - uncomment when needed
    // final message = await _firebaseMessaging.getInitialMessage();
    // if (message != null) {
    //   debugPrint('App opened from notification (terminated): ${message.messageId}');
    //   _handleNotificationTap(message);
    // }
    // return message;
  }

  /// Get device ID (simplified - you might want to use device_info_plus package) - Commented out
  // Future<String> _getDeviceId() async {
  //   // For now, use FCM token as device ID
  //   // In production, use device_info_plus package to get actual device ID
  //   return _fcmToken ?? 'unknown_device';
  // }

  /// Subscribe to topic - Commented out
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('FCM Service is disabled');
    // Commented out Firebase - uncomment when needed
    // try {
    //   await _firebaseMessaging.subscribeToTopic(topic);
    //   debugPrint('Subscribed to topic: $topic');
    // } catch (e) {
    //   debugPrint('Error subscribing to topic: $e');
    // }
  }

  /// Unsubscribe from topic - Commented out
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('FCM Service is disabled');
    // Commented out Firebase - uncomment when needed
    // try {
    //   await _firebaseMessaging.unsubscribeFromTopic(topic);
    //   debugPrint('Unsubscribed from topic: $topic');
    // } catch (e) {
    //   debugPrint('Error unsubscribing from topic: $e');
    // }
  }
}
