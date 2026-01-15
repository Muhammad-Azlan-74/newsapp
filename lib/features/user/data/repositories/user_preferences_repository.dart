import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/user_preferences_model.dart';
import 'package:newsapp/features/user/data/models/favorite_teams_response.dart';

/// User Preferences Repository
///
/// Handles all user preferences-related API calls
class UserPreferencesRepository {
  final ApiClient _apiClient;

  UserPreferencesRepository(this._apiClient);

  /// Get all user preferences (favorite teams, news levels, notifications)
  ///
  /// Requires authentication and email verification
  Future<UserPreferences> getUserPreferences() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.userPreferences,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return UserPreferences.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get user's favorite teams only
  ///
  /// Requires authentication and email verification
  Future<FavoriteTeamsResponse> getFavoriteTeams() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.favoriteTeams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return FavoriteTeamsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Update user's favorite teams
  ///
  /// Requires authentication (email verification not required)
  Future<void> updateFavoriteTeams(List<String> teamIds) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      await _apiClient.dio.patch(
        ApiEndpoints.favoriteTeams,
        data: {
          'favoriteTeams': teamIds,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException();
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NetworkException();
    }

    // Extract error message from response
    String errorMessage = 'An error occurred';
    int? statusCode;

    if (e.response != null) {
      statusCode = e.response!.statusCode;

      // Try to extract message from response
      if (e.response!.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final data = e.response!.data as Map<String, dynamic>;
          errorMessage = data['message'] as String? ??
              data['error'] as String? ??
              errorMessage;
        } else if (e.response!.data is String) {
          errorMessage = e.response!.data as String;
        }
      }

      // Handle specific status codes
      if (statusCode == 401) {
        throw UnauthorizedException();
      } else if (statusCode == 403) {
        throw ApiException('Email verification required', statusCode);
      } else if (statusCode == 404) {
        throw ApiException('Preferences not found', statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }
}
