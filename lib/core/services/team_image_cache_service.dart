import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsapp/features/user/data/models/team_model.dart';

/// Team Image Cache Service
///
/// Handles downloading and caching team images locally
class TeamImageCacheService {
  static const String _keyPrefix = 'team_image_';

  /// Download and cache all images for a team
  ///
  /// Returns true if successful, false otherwise
  static Future<bool> cacheTeamImages(Team team) async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final teamDir = Directory('${directory.path}/team_images/${team.code}');

      // Create team directory if it doesn't exist
      if (!await teamDir.exists()) {
        await teamDir.create(recursive: true);
      }

      // Download and save each image type
      final imagePaths = <String, String>{};

      // Download anchor image
      if (team.images.anchor.isNotEmpty) {
        final anchorPath = await _downloadImage(
          dio,
          team.images.anchor,
          '${teamDir.path}/anchor.png',
        );
        if (anchorPath != null) {
          imagePaths['anchor'] = anchorPath;
        }
      }

      // Download doctor image
      if (team.images.doctor.isNotEmpty) {
        final doctorPath = await _downloadImage(
          dio,
          team.images.doctor,
          '${teamDir.path}/doctor.png',
        );
        if (doctorPath != null) {
          imagePaths['doctor'] = doctorPath;
        }
      }

      // Download newspaper image
      if (team.images.newspaper.isNotEmpty) {
        final newspaperPath = await _downloadImage(
          dio,
          team.images.newspaper,
          '${teamDir.path}/newspaper.png',
        );
        if (newspaperPath != null) {
          imagePaths['newspaper'] = newspaperPath;
        }
      }

      // Download main logo image
      if (team.images.main.isNotEmpty) {
        final mainPath = await _downloadImage(
          dio,
          team.images.main,
          '${teamDir.path}/main.png',
        );
        if (mainPath != null) {
          imagePaths['main'] = mainPath;
        }
      }

      // Save paths to shared preferences
      await _saveImagePaths(team.code, imagePaths);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Download a single image from URL and save to local path
  static Future<String?> _downloadImage(
    Dio dio,
    String url,
    String savePath,
  ) async {
    try {
      // Skip if file already exists
      final file = File(savePath);
      if (await file.exists()) {
        return savePath;
      }

      // Download the image
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      // Save to file
      await file.writeAsBytes(response.data as List<int>);
      return savePath;
    } catch (e) {
      return null;
    }
  }

  /// Save image paths to shared preferences
  static Future<void> _saveImagePaths(
    String teamCode,
    Map<String, String> imagePaths,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in imagePaths.entries) {
      final key = '$_keyPrefix${teamCode}_${entry.key}';
      await prefs.setString(key, entry.value);
    }
  }

  /// Get cached image path for a specific team and image type
  ///
  /// Returns null if not cached
  static Future<String?> getCachedImagePath(
    String teamCode,
    String imageType,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${teamCode}_$imageType';
    return prefs.getString(key);
  }

  /// Check if team images are cached
  static Future<bool> areImagesCached(String teamCode) async {
    final prefs = await SharedPreferences.getInstance();
    final anchorKey = '$_keyPrefix${teamCode}_anchor';
    return prefs.containsKey(anchorKey);
  }

  /// Clear all cached team images
  static Future<void> clearCache() async {
    try {
      // Remove files
      final directory = await getApplicationDocumentsDirectory();
      final teamImagesDir = Directory('${directory.path}/team_images');
      if (await teamImagesDir.exists()) {
        await teamImagesDir.delete(recursive: true);
      }

      // Remove from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  /// Get all cached image paths for a team
  static Future<Map<String, String>> getCachedTeamImages(
    String teamCode,
  ) async {
    final imagePaths = <String, String>{};
    final imageTypes = ['anchor', 'doctor', 'newspaper', 'main'];

    for (final type in imageTypes) {
      final path = await getCachedImagePath(teamCode, type);
      if (path != null) {
        imagePaths[type] = path;
      }
    }

    return imagePaths;
  }
}
