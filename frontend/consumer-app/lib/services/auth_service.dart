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
      throw Exception('Registration failed: ${response.body}');
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
      throw Exception('Login failed: ${response.body}');
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
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.authServiceUrl}${ApiConfig.authVerifyOtp}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
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















