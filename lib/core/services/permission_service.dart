import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Permission Service
///
/// Handles requesting all necessary permissions on app startup
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request all necessary permissions for the app
  Future<void> requestAllPermissions() async {
    try {
      debugPrint('Requesting app permissions...');

      // Request camera permission
      await _requestPermission(Permission.camera, 'Camera');

      // Request photo/storage permissions based on platform and Android version
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), use photos permission
        // For older versions, use storage permission
        final androidInfo = await _getAndroidSdkVersion();
        if (androidInfo >= 33) {
          await _requestPermission(Permission.photos, 'Photos');
        } else {
          await _requestPermission(Permission.storage, 'Storage');
        }
      } else if (Platform.isIOS) {
        await _requestPermission(Permission.photos, 'Photos');
      }

      // Request notification permission (Android 13+ and iOS)
      await _requestPermission(Permission.notification, 'Notification');

      debugPrint('All permissions requested');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  /// Helper method to request a single permission
  Future<PermissionStatus> _requestPermission(Permission permission, String name) async {
    try {
      final status = await permission.request();
      debugPrint('Permission $name: $status');
      return status;
    } catch (e) {
      debugPrint('Error requesting $name permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    try {
      if (Platform.isAndroid) {
        // Default to API 33 if we can't determine
        return 33;
      }
      return 0;
    } catch (e) {
      return 33;
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraGranted() async {
    try {
      return await Permission.camera.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check if photos/gallery permission is granted
  Future<bool> isPhotosGranted() async {
    try {
      if (Platform.isAndroid) {
        final photos = await Permission.photos.isGranted;
        final storage = await Permission.storage.isGranted;
        return photos || storage;
      }
      return await Permission.photos.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStorageGranted() async {
    try {
      return await Permission.storage.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationGranted() async {
    try {
      return await Permission.notification.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Request photos/gallery permission
  Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted && Platform.isAndroid) {
        // Fallback to storage permission for older Android versions
        final storageStatus = await Permission.storage.request();
        return storageStatus.isGranted;
      }
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Open app settings if permission is permanently denied
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
