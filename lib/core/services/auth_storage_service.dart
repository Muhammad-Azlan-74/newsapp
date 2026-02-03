import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Auth Storage Service
///
/// Manages storage and retrieval of authentication data
class AuthStorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_data';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyHasLoggedInBefore = 'has_logged_in_before';
  static const String _keySelectedTeam = 'selected_team';
  static const String _keyFcmToken = 'fcm_token';

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Get saved authentication token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Save remember me preference
  static Future<void> saveRememberMe(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  /// Get remember me preference
  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Check if user is logged in (has token)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all authentication data (logout)
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyFcmToken);
  }

  /// Save complete auth response (token + user data)
  static Future<void> saveAuthResponse({
    required String token,
    required Map<String, dynamic> userData,
    required bool rememberMe,
  }) async {
    await saveToken(token);
    await saveUserData(userData);
    await saveRememberMe(rememberMe);
  }

  /// Check if user has logged in before
  static Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasLoggedInBefore) ?? false;
  }

  /// Mark that user has logged in
  static Future<void> markLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasLoggedInBefore, true);
  }

  /// Save selected team
  static Future<void> saveSelectedTeam(String team) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedTeam, team);
  }

  /// Get selected team
  static Future<String?> getSelectedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedTeam);
  }

  /// Save FCM token
  static Future<void> saveFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFcmToken, fcmToken);
  }

  /// Get FCM token
  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFcmToken);
  }

  /// Remove FCM token
  static Future<void> removeFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFcmToken);
  }

  /// Get user's display name
  static Future<String?> getUserName() async {
    final userData = await getUserData();
    if (userData != null) {
      // Try various name fields, then fall back to email
      return userData['fullName'] as String? ??
          userData['displayName'] as String? ??
          userData['username'] as String? ??
          userData['name'] as String? ??
          userData['email'] as String?;
    }
    return null;
  }
}
