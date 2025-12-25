/// API Endpoints
///
/// Centralized constants for all API endpoints
class ApiEndpoints {
  // Base URL for the sports app backend
  static const String baseUrl = 'https://sportsapp-server.vercel.app';

  // Authentication endpoints (with /api/auth prefix)
  static const String register = '/api/auth/register';
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyResetOtp = '/api/auth/verify-reset-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String me = '/api/auth/me';
}
