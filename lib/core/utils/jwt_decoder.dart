import 'dart:convert';

/// JWT Token Decoder
///
/// Utility to decode JWT tokens
class JwtDecoder {
  /// Decode JWT token and return payload
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if needed
      var normalized = base64Url.normalize(payload);

      // Decode base64
      final decoded = utf8.decode(base64Url.decode(normalized));

      // Parse JSON
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  /// Get user ID from JWT token
  static String? getUserId(String token) {
    final payload = decode(token);
    return payload?['userId'] as String?;
  }
}
