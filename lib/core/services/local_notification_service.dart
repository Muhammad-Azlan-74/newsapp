import 'package:flutter/foundation.dart';
// Commented out Firebase - uncomment when needed
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local Notification Service - Commented out for now
///
/// Handles displaying local notifications using flutter_local_notifications
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  // Commented out Firebase - uncomment when needed
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications - Commented out
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('Local Notification Service is disabled - uncomment Firebase code to enable');

    // Commented out Firebase - uncomment when needed
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );
    //
    // const initializationSettings = InitializationSettings(
    //   android: androidSettings,
    //   iOS: iosSettings,
    // );
    //
    // await _flutterLocalNotificationsPlugin.initialize(
    //   initializationSettings,
    //   onDidReceiveNotificationResponse: _onNotificationTapped,
    // );
    //
    // // Create notification channel for Android
    // await _createNotificationChannel();
    //
    // _initialized = true;
    // debugPrint('Local Notification Service initialized');
  }

  /// Create Android notification channel - Commented out
  // Future<void> _createNotificationChannel() async {
  //   const androidChannel = AndroidNotificationChannel(
  //     'sports_news_channel',
  //     'Sports News',
  //     description: 'Notifications for sports news and updates',
  //     importance: Importance.high,
  //     enableVibration: true,
  //     playSound: true,
  //   );
  //
  //   await _flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(androidChannel);
  //
  //   debugPrint('Notification channel created');
  // }

  /// Show a notification - Commented out
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('Local Notification Service is disabled');
    // Commented out Firebase - uncomment when needed
    // if (!_initialized) {
    //   await initialize();
    // }
    //
    // const androidDetails = AndroidNotificationDetails(
    //   'sports_news_channel',
    //   'Sports News',
    //   channelDescription: 'Notifications for sports news and updates',
    //   importance: Importance.high,
    //   priority: Priority.high,
    //   showWhen: true,
    //   enableVibration: true,
    //   playSound: true,
    // );
    //
    // const iosDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );
    //
    // const notificationDetails = NotificationDetails(
    //   android: androidDetails,
    //   iOS: iosDetails,
    // );
    //
    // await _flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   notificationDetails,
    //   payload: payload,
    // );
    //
    // debugPrint('Notification shown: $title');
  }

  /// Show a notification with custom icon and color - Commented out
  Future<void> showStyledNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? largeIcon,
    String? bigPicture,
  }) async {
    debugPrint('Local Notification Service is disabled');
    // Commented out Firebase - uncomment when needed
    // if (!_initialized) {
    //   await initialize();
    // }
    //
    // final androidDetails = AndroidNotificationDetails(
    //   'sports_news_channel',
    //   'Sports News',
    //   channelDescription: 'Notifications for sports news and updates',
    //   importance: Importance.high,
    //   priority: Priority.high,
    //   showWhen: true,
    //   enableVibration: true,
    //   playSound: true,
    //   styleInformation: bigPicture != null
    //       ? BigPictureStyleInformation(
    //           FilePathAndroidBitmap(bigPicture),
    //           largeIcon: largeIcon != null
    //               ? FilePathAndroidBitmap(largeIcon)
    //               : null,
    //         )
    //       : largeIcon != null
    //           ? BigPictureStyleInformation(
    //               FilePathAndroidBitmap(largeIcon),
    //             )
    //           : null,
    // );
    //
    // const iosDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );
    //
    // final notificationDetails = NotificationDetails(
    //   android: androidDetails,
    //   iOS: iosDetails,
    // );
    //
    // await _flutterLocalNotificationsPlugin.show(
    //   id,
    //   title,
    //   body,
    //   notificationDetails,
    //   payload: payload,
    // );
  }

  /// Cancel a notification - Commented out
  Future<void> cancelNotification(int id) async {
    debugPrint('Local Notification Service is disabled');
    // Commented out Firebase - uncomment when needed
    // await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications - Commented out
  Future<void> cancelAllNotifications() async {
    debugPrint('Local Notification Service is disabled');
    // Commented out Firebase - uncomment when needed
    // await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Get active notifications - Commented out
  Future<List<dynamic>> getActiveNotifications() async {
    debugPrint('Local Notification Service is disabled');
    return [];
    // Commented out Firebase - uncomment when needed
    // final activeNotifications = await _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.getActiveNotifications();
    //
    // return activeNotifications ?? [];
  }

  /// Handle notification tap - Commented out
  // void _onNotificationTapped(NotificationResponse response) {
  //   debugPrint('Notification tapped with payload: ${response.payload}');
  //   // You can handle navigation here or emit an event
  //   // For now, we'll just log it
  //   // In the future, you can use a NavigationService or event bus
  // }

  /// Request notification permissions (iOS) - Commented out
  Future<bool?> requestPermissions() async {
    debugPrint('Local Notification Service is disabled');
    return null;
    // Commented out Firebase - uncomment when needed
    // return await _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         IOSFlutterLocalNotificationsPlugin>()
    //     ?.requestPermissions(
    //       alert: true,
    //       badge: true,
    //       sound: true,
    //     );
  }
}
