import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/rumor_model.dart';

/// Rumor Repository
///
/// Handles all rumor-related API calls
class RumorRepository {
  final ApiClient _apiClient;

  RumorRepository(this._apiClient);

  /// Get the latest rumor
  Future<RumorResponse> getRumor({
    String? teamId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      // Build query parameters
      final queryParams = <String, dynamic>{};

      if (teamId != null && teamId.isNotEmpty) {
        queryParams['teamId'] = teamId;
      }

      // Make the API call
      final response = await _apiClient.dio.get(
        ApiEndpoints.rumors,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return RumorResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Handle Dio errors
  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data['message'] ?? 'An error occurred';

      switch (statusCode) {
        case 401:
          throw UnauthorizedException(message);
        case 403:
          throw ForbiddenException(message);
        case 404:
          throw NotFoundException(message);
        case 500:
          throw ServerException(message, statusCode!);
        default:
          throw ApiException(message, statusCode);
      }
    } else {
      throw NetworkException();
    }
  }
}
