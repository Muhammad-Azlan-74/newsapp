import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/medical_news_model.dart';

/// Medical News Repository
///
/// Handles all medical news-related API calls
class MedicalNewsRepository {
  final ApiClient _apiClient;

  MedicalNewsRepository(this._apiClient);

  /// Get medical news with pagination
  Future<MedicalNewsResponse> getMedicalNews({
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
        ApiEndpoints.medicalNews,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return MedicalNewsResponse.fromJson(response.data as Map<String, dynamic>);
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
