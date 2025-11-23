import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Use API Gateway for all services
  static const String baseUrl = ApiConfig.apiGatewayUrl;
  static const String voucherServiceUrl = ApiConfig.voucherServiceUrl;
  static const String userServiceUrl = ApiConfig.userServiceUrl;
  static const String orderServiceUrl = ApiConfig.orderServiceUrl;
  static const String walletServiceUrl = ApiConfig.walletServiceUrl;

  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, {
    String? token,
    String? baseUrlOverride,
  }) async {
    try {
      final url = baseUrlOverride ?? baseUrl;
      final response = await http.post(
        Uri.parse('$url$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 401/403 - redirect to login
        try {
          final error = jsonDecode(response.body);
          final errorMsg = error['message'] ?? error['error'] ?? 'Unauthorized';
          throw Exception('${response.statusCode}:$errorMsg');
        } catch (_) {
          throw Exception('${response.statusCode}:Unauthorized - Please login again');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Request failed');
      }
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        rethrow; // Let caller handle auth errors
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    String? baseUrlOverride,
  }) async {
    try {
      final url = baseUrlOverride ?? baseUrl;
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        // Debug: Log request details
        debugPrint('API Request: GET $url$endpoint');
        debugPrint('API Headers: Authorization: Bearer ${token.length > 30 ? "${token.substring(0, 30)}..." : token}');
      } else {
        debugPrint('API Request: GET $url$endpoint (NO TOKEN)');
      }
      
      final response = await http.get(
        Uri.parse('$url$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 401 Unauthorized or 403 Forbidden - redirect to login
        final errorBody = response.body;
        if (errorBody.isNotEmpty) {
          try {
            final error = jsonDecode(errorBody);
            final errorMsg = error['message'] ?? error['error'] ?? 'Unauthorized';
            throw Exception('${response.statusCode}:$errorMsg');
          } catch (_) {
            throw Exception('${response.statusCode}:Unauthorized - Please login again');
          }
        }
        throw Exception('${response.statusCode}:Unauthorized - Please login again');
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Request failed with status ${response.statusCode}');
        } catch (_) {
          throw Exception('Request failed with status ${response.statusCode}');
        }
      }
    } catch (e) {
      if (e.toString().contains('401') || e.toString().contains('403')) {
        rethrow; // Let caller handle auth errors
      }
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
    String? baseUrlOverride,
  }) async {
    try {
      final url = baseUrlOverride ?? baseUrl;
      final response = await http.put(
        Uri.parse('$url$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response for better error messages
        try {
          final errorBody = jsonDecode(response.body);
          final errorMsg = errorBody['error']?['message'] ?? 
                          errorBody['message'] ?? 
                          'Request failed';
          
          if (response.statusCode == 401) {
            throw Exception('401:$errorMsg');
          } else {
            throw Exception('${response.statusCode}:$errorMsg');
          }
        } catch (e) {
          // If parsing fails, throw with status code
          if (e.toString().contains('401')) {
            rethrow;
          }
          if (response.statusCode == 401) {
            throw Exception('401:Unauthorized - Please login again');
          } else {
            throw Exception('${response.statusCode}:Request failed');
          }
        }
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('401')) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }
}

































