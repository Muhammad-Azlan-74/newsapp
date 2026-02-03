import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/core/services/auth_storage_service.dart';
import 'package:newsapp/features/user/data/models/hof_user_model.dart';
import 'package:newsapp/features/user/data/models/hall_of_fame_model.dart';

/// Hall of Fame Repository
///
/// Handles all Hall of Fame related API calls
class HofRepository {
  final ApiClient _apiClient;

  HofRepository(this._apiClient);

  /// Get all Hall of Fame users
  ///
  /// Requires authentication and email verification
  Future<HofUsersResponse> getHofUsers() async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.hofUsers,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return HofUsersResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Get Hall of Fame details for a specific user
  ///
  /// Requires authentication and email verification
  Future<HallOfFameResponse> getHofDetails(String userId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.hofDetails(userId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return HallOfFameResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Like a Hall of Fame entry
  ///
  /// Requires authentication and email verification
  /// [hofUserId] - The user ID whose HOF entry to like
  Future<LikeResponse> likeHofEntry(String hofUserId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.hofLike,
        data: {'hofUserId': hofUserId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return LikeResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Unlike a Hall of Fame entry
  ///
  /// Requires authentication and email verification
  /// [hofUserId] - The user ID whose HOF entry to unlike
  Future<LikeResponse> unlikeHofEntry(String hofUserId) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.hofUnlike,
        data: {'hofUserId': hofUserId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return LikeResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Upload a picture to Hall of Fame using http package
///
/// Requires authentication and email verification
/// [filePath] - Path to the image file to upload
/// [isForSale] - Whether the image is for sale (optional, default: false)
/// [saleAmount] - Sale amount if the image is for sale (required when isForSale is true)
Future<UploadPictureResponse> uploadPicture(
  String filePath, {
  bool isForSale = false,
  double? saleAmount,
}) async {
  try {
    final token = await AuthStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    // Get file name from path
    String fileName = filePath.split('/').last;
    if (fileName.isEmpty) {
      fileName = filePath.split('\\').last; // Handle Windows paths
    }

    // Determine content type based on file extension
    String contentType = 'image/jpeg'; // Default
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'gif') {
      contentType = 'image/gif';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    }

    print('Uploading file: $fileName from path: $filePath');
    print('Is for sale: $isForSale');
    if (isForSale) {
      print('Sale amount: $saleAmount');
    }

    // Create multipart request using http package
    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.hofUploadPicture}');
    final request = http.MultipartRequest('POST', uri);

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add the image file with proper content type
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      filePath,
      filename: fileName,
      contentType: http_parser.MediaType.parse(contentType),
    );
    request.files.add(multipartFile);

    // Add sale information as form fields
    request.fields['isForSale'] = isForSale.toString();
    if (isForSale && saleAmount != null) {
      request.fields['saleAmount'] = saleAmount.toString();
    }

    print('Request URI: $uri');
    print('Request headers: ${request.headers}');
    print('Request fields: ${request.fields}');
    print('File field name: image');
    print('File name: $fileName');
    print('Content type: $contentType');

    // Send the request with timeout
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw ApiException('Upload timed out. Please try again.', null);
      },
    );
    final response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      return UploadPictureResponse.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 403) {
      throw ApiException('Email verification required', response.statusCode);
    } else if (response.statusCode == 400) {
      final errorBody = json.decode(response.body);
      final message = errorBody['message'] ?? 'Bad request';
      throw ApiException(message, response.statusCode);
    } else {
      final errorBody = json.decode(response.body);
      final message = errorBody['message'] ?? 'Server error';
      throw ServerException(message, response.statusCode);
    }
  } catch (e) {
    print('Upload error: $e');
    if (e is ApiException || e is UnauthorizedException || e is ServerException) {
      rethrow;
    }
    throw ApiException('Upload failed: ${e.toString()}', null);
  }
}

  /// Add or update caption for a Hall of Fame picture
  ///
  /// Requires authentication and email verification
  /// [imageId] - The ObjectId of the image to add caption to
  /// [caption] - The caption text to add
  Future<HallOfFameResponse> addCaption(String imageId, String caption) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.hofCaption,
        data: {
          'imageId': imageId,
          'caption': caption,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return HallOfFameResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Make an offer on a Hall of Fame picture
  ///
  /// Requires authentication and email verification
  /// [hofUserId] - The user ID who owns the Hall of Fame entry
  /// [imageId] - The ObjectId of the image to make an offer on
  /// [amount] - The offer amount
  Future<MakeOfferResponse> makeOffer({
    required String hofUserId,
    required String imageId,
    required double amount,
  }) async {
    try {
      final token = await AuthStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.hofOffer,
        data: {
          'hofUserId': hofUserId,
          'imageId': imageId,
          'amount': amount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return MakeOfferResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
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
        throw ApiException('HOF users not found', statusCode);
      } else if (statusCode == 400) {
        // Handle 400 errors (no file uploaded, only images allowed, etc.)
        throw ApiException(errorMessage, statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }
}
