import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/tv_studio_news_model.dart';

/// TV Studio News Repository
///
/// Handles all TV Studio news-related API calls
class TvStudioNewsRepository {
  final ApiClient _apiClient;

  TvStudioNewsRepository(this._apiClient);

  /// Get TV Studio news with pagination
  Future<TvStudioNewsResponse> getTvStudioNews({
    int page = 1,
    int limit = 10,
    String? teamId,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (teamId != null && teamId.isNotEmpty) {
        queryParams['teamId'] = teamId;
      }

      // Make the API call
      final response = await _apiClient.dio.get(
        ApiEndpoints.tvStudioNews,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return TvStudioNewsResponse.fromJson(response.data as Map<String, dynamic>);
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
