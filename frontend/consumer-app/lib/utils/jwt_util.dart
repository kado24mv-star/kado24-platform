import 'dart:convert';

/// Utility class for JWT token operations
class JwtUtil {
  /// Decode JWT token payload (without verification)
  /// Returns null if token is invalid
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Decode the payload (second part)
      String payload = parts[1];
      
      // Add padding if needed for base64
      final remainder = payload.length % 4;
      if (remainder > 0) {
        payload += '=' * (4 - remainder);
      }
      
      // Replace URL-safe base64 characters
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      
      final decoded = utf8.decode(base64.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if token has userId claim
  static bool hasUserId(String token) {
    final payload = decodePayload(token);
    if (payload == null) {
      return false;
    }
    
    return payload.containsKey('userId') && payload['userId'] != null;
  }
  
  /// Get userId from token
  static int? getUserId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;
    
    final userId = payload['userId'];
    if (userId is int) return userId;
    if (userId is String) return int.tryParse(userId);
    return null;
  }
  
  /// Check if token is expired (basic check without verification)
  /// Returns true only if token is expired by more than buffer time (5 minutes)
  /// This prevents false positives on quick refreshes
  static bool isExpired(String token, {Duration buffer = const Duration(minutes: 5)}) {
    final payload = decodePayload(token);
    if (payload == null) return true;
    
    final exp = payload['exp'];
    if (exp == null) return false; // No expiration claim
    
    if (exp is int) {
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      // Only consider expired if past expiration + buffer time
      // This prevents redirects on quick refreshes when token is about to expire
      return now.isAfter(expirationDate.add(buffer));
    }
    
    return false;
  }
  
  /// Check if token will expire soon (within buffer time)
  static bool willExpireSoon(String token, {Duration buffer = const Duration(minutes: 5)}) {
    final payload = decodePayload(token);
    if (payload == null) return true;
    
    final exp = payload['exp'];
    if (exp == null) return false;
    
    if (exp is int) {
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      // Check if token expires within buffer time
      return expirationDate.isBefore(now.add(buffer));
    }
    
    return false;
  }
}

