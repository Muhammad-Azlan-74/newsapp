import 'package:dio/dio.dart';
import 'package:newsapp/core/network/api_client.dart';
import 'package:newsapp/core/network/api_endpoints.dart';
import 'package:newsapp/core/network/api_exceptions.dart';
import 'package:newsapp/features/auth/data/models/register_request.dart';
import 'package:newsapp/features/auth/data/models/login_request.dart';
import 'package:newsapp/features/auth/data/models/auth_response.dart';

/// Auth Repository
///
/// Handles all authentication-related API calls
class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Register a new user
  ///
  /// Sends user data and selected team to backend
  /// Backend automatically sends verification OTP to email
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Verify email with OTP code
  ///
  /// Verifies the 6-digit OTP sent to user's email during registration
  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.verifyEmail,
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Resend verification OTP
  ///
  /// Sends a new OTP to the user's email
  Future<void> resendVerificationOtp(String email) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.resendVerification,
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Login user with email and password
  ///
  /// Returns auth response with token and user data
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e);
      // This line won't be reached due to throw in _handleDioError
      rethrow;
    }
  }

  /// Request password reset
  ///
  /// Sends OTP to user's email for password reset
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Verify password reset OTP
  ///
  /// Verifies OTP and returns reset token
  Future<String> verifyResetOtp(String email, String otp) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.verifyResetOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return data['resetToken'] as String;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Reset password with reset token
  ///
  /// Uses the reset token from OTP verification
  Future<void> resetPassword(String resetToken, String newPassword) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $resetToken',
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
      } else if (statusCode != null && statusCode >= 500) {
        throw ServerException(errorMessage, statusCode);
      }
    }

    throw ApiException(errorMessage, statusCode);
  }
}
