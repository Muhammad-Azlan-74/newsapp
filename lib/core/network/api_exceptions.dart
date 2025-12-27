/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException ($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

/// Network Exception (No internet connection)
class NetworkException extends ApiException {
  NetworkException() : super('No internet connection');
}

/// Server Exception (5xx errors)
class ServerException extends ApiException {
  ServerException(String message, int statusCode)
      : super(message, statusCode);
}

/// Validation Exception (4xx errors)
class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 400);
}

/// Unauthorized Exception (401 errors)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message])
      : super(message ?? 'Unauthorized. Please login again.', 401);
}

/// Forbidden Exception (403 errors)
class ForbiddenException extends ApiException {
  ForbiddenException([String? message])
      : super(message ?? 'Access forbidden.', 403);
}

/// Not Found Exception (404 errors)
class NotFoundException extends ApiException {
  NotFoundException([String? message])
      : super(message ?? 'Resource not found.', 404);
}
