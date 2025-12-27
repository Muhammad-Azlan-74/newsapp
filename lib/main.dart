// Commented out Firebase - uncomment when needed
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newsapp/app/theme/app_theme.dart';
import 'package:newsapp/app/routes.dart';
import 'package:newsapp/core/constants/app_constants.dart';
import 'package:newsapp/core/constants/app_assets.dart';
// import 'package:newsapp/core/services/fcm_service.dart';
// import 'package:newsapp/core/services/local_notification_service.dart';

/// Background message handler - Commented out for now
/// Must be a top-level function to handle messages when app is in background/terminated
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('Background message received: ${message.messageId}');
//   debugPrint('Title: ${message.notification?.title}');
//   debugPrint('Body: ${message.notification?.body}');
//   debugPrint('Data: ${message.data}');
// }

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Commented out Firebase initialization - uncomment when needed
  // try {
  //   // Initialize Firebase
  //   await Firebase.initializeApp();
  //   debugPrint('Firebase initialized successfully');
  //
  //   // Register background message handler
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  //   // Initialize local notifications
  //   await LocalNotificationService().initialize();
  //   debugPrint('Local notifications initialized');
  //
  //   // Initialize FCM service
  //   await FCMService().initialize();
  //   debugPrint('FCM service initialized');
  // } catch (e) {
  //   debugPrint('Error initializing app: $e');
  // }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Commented out Firebase notification check - uncomment when needed
    // _checkInitialNotification();
  }

  /// Check if app was opened from a notification (terminated state) - Commented out
  // Future<void> _checkInitialNotification() async {
  //   try {
  //     final message = await FCMService().getInitialMessage();
  //     if (message != null) {
  //       debugPrint('App opened from notification: ${message.messageId}');
  //       // Handle navigation based on notification data
  //       // You can navigate to the appropriate screen here
  //     }
  //   } catch (e) {
  //     debugPrint('Error checking initial notification: $e');
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache background image to prevent white flash
    precacheImage(AssetImage(AppAssets.backgroundImage), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
