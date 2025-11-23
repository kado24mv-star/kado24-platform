import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  // Register
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authRegister}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'email': email,
          'password': password,
          'role': 'CONSUMER',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Parse error response to extract message
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          final error = errorBody['error'];
          errorMessage = error != null 
              ? (error['message'] ?? error.toString())
              : (errorBody['message'] ?? 'Registration failed');
        } catch (e) {
          errorMessage = 'Registration failed. Please check your information and try again.';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Re-throw if it's already our formatted exception
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      // Wrap network errors
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authLogin}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Parse error response to extract message
      String errorMessage;
      try {
        final errorBody = jsonDecode(response.body);
        
        // Backend returns: { "success": false, "error": { "code": "...", "message": "..." } }
        final error = errorBody['error'];
        errorMessage = error != null 
            ? (error['message'] ?? error.toString())
            : (errorBody['message'] ?? response.body);
      } catch (e) {
        // If parsing fails, try to extract from raw body as string
        final bodyStr = response.body.toString();
        // Try to find error message in JSON string
        final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(bodyStr);
        errorMessage = match != null ? match.group(1)! : 'Login failed';
      }
      
      // Handle 404 specifically (user not found)
      if (response.statusCode == 404) {
        if (errorMessage.contains('not found') || errorMessage.contains('User not found')) {
          errorMessage = 'User not found. Please register first or check your credentials.';
        }
      }
      
      // Create exception with the error message so it can be checked for OTP_VERIFICATION_REQUIRED
      throw Exception(errorMessage);
    }
  }

  // Send OTP (calls mock OTP service)
  Future<Map<String, dynamic>> sendOTP(String phoneNumber, String purpose) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authSendOtp}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'purpose': purpose, // REGISTRATION, LOGIN, PASSWORD_RESET
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // In dev mode, backend returns OTP code
      return data;
    } else {
      throw Exception('Send OTP failed');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode, {String? purpose}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authVerifyOtp}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        if (purpose != null) 'purpose': purpose,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('OTP verification failed');
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String identifier) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authForgotPassword}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    if (response.statusCode != 200) {
      throw Exception('Forgot password failed');
    }
  }

  // Reset Password
  Future<void> resetPassword(String phoneNumber, String otpCode, String newPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authResetPassword}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Password reset failed');
    }
  }

  // Logout
  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authLogout}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authRefresh}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Token refresh failed');
    }
  }
}























