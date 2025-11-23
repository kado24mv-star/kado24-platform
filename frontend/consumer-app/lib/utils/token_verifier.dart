import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'jwt_util.dart';

/// Utility class to verify token storage and retrieval
class TokenVerifier {
  /// Verify that tokens are stored correctly in SharedPreferences
  static Future<Map<String, dynamic>> verifyTokenStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final results = <String, dynamic>{};
    
    // Check access token
    final accessToken = prefs.getString('accessToken');
    results['accessToken'] = {
      'exists': accessToken != null,
      'length': accessToken?.length ?? 0,
      'isValid': accessToken != null && accessToken.isNotEmpty,
      'hasUserId': accessToken != null ? JwtUtil.hasUserId(accessToken) : false,
      'isExpired': accessToken != null ? JwtUtil.isExpired(accessToken) : true,
      'preview': accessToken != null && accessToken.length > 20 
          ? '${accessToken.substring(0, 20)}...' 
          : accessToken,
    };
    
    // Check refresh token
    final refreshToken = prefs.getString('refreshToken');
    results['refreshToken'] = {
      'exists': refreshToken != null,
      'length': refreshToken?.length ?? 0,
      'isValid': refreshToken != null && refreshToken.isNotEmpty,
      'preview': refreshToken != null && refreshToken.length > 20 
          ? '${refreshToken.substring(0, 20)}...' 
          : refreshToken,
    };
    
    // Check user data
    final userJson = prefs.getString('user');
    results['user'] = {
      'exists': userJson != null,
      'isValid': userJson != null,
    };
    
    if (userJson != null) {
      try {
        final user = jsonDecode(userJson);
        results['user']['data'] = {
          'id': user['id'],
          'fullName': user['fullName'],
          'phoneNumber': user['phoneNumber'],
          'email': user['email'],
          'role': user['role'],
        };
      } catch (e) {
        results['user']['parseError'] = e.toString();
      }
    }
    
    // Overall status
    results['overall'] = {
      'hasAccessToken': accessToken != null && accessToken.isNotEmpty,
      'hasRefreshToken': refreshToken != null && refreshToken.isNotEmpty,
      'hasUser': userJson != null,
      'isAuthenticated': accessToken != null && 
                        accessToken.isNotEmpty && 
                        userJson != null &&
                        !JwtUtil.isExpired(accessToken),
    };
    
    return results;
  }
  
  /// Print verification results in a readable format
  static Future<void> printVerification() async {
    final results = await verifyTokenStorage();
    
    print('\n=== Token Storage Verification ===');
    print('\nAccess Token:');
    print('  Exists: ${results['accessToken']['exists']}');
    print('  Length: ${results['accessToken']['length']}');
    print('  Valid: ${results['accessToken']['isValid']}');
    print('  Has User ID: ${results['accessToken']['hasUserId']}');
    print('  Expired: ${results['accessToken']['isExpired']}');
    print('  Preview: ${results['accessToken']['preview']}');
    
    print('\nRefresh Token:');
    print('  Exists: ${results['refreshToken']['exists']}');
    print('  Length: ${results['refreshToken']['length']}');
    print('  Valid: ${results['refreshToken']['isValid']}');
    print('  Preview: ${results['refreshToken']['preview']}');
    
    print('\nUser Data:');
    print('  Exists: ${results['user']['exists']}');
    if (results['user']['data'] != null) {
      final user = results['user']['data'];
      print('  ID: ${user['id']}');
      print('  Name: ${user['fullName']}');
      print('  Phone: ${user['phoneNumber']}');
      print('  Email: ${user['email']}');
      print('  Role: ${user['role']}');
    }
    
    print('\nOverall Status:');
    print('  Has Access Token: ${results['overall']['hasAccessToken']}');
    print('  Has Refresh Token: ${results['overall']['hasRefreshToken']}');
    print('  Has User: ${results['overall']['hasUser']}');
    print('  Is Authenticated: ${results['overall']['isAuthenticated']}');
    print('\n===================================\n');
  }
  
  /// Verify login response structure
  static Map<String, dynamic> verifyLoginResponse(Map<String, dynamic> response) {
    final results = <String, dynamic>{};
    
    results['hasSuccess'] = response.containsKey('success');
    results['success'] = response['success'] ?? false;
    
    if (response.containsKey('data')) {
      final data = response['data'];
      results['hasData'] = true;
      results['hasAccessToken'] = data.containsKey('accessToken') && 
                                  data['accessToken'] != null && 
                                  data['accessToken'].toString().isNotEmpty;
      results['hasRefreshToken'] = data.containsKey('refreshToken') && 
                                   data['refreshToken'] != null && 
                                   data['refreshToken'].toString().isNotEmpty;
      results['hasUser'] = data.containsKey('user') && data['user'] != null;
      
      if (results['hasAccessToken']) {
        final token = data['accessToken'].toString();
        results['accessToken'] = {
          'length': token.length,
          'hasUserId': JwtUtil.hasUserId(token),
          'isExpired': JwtUtil.isExpired(token),
        };
      }
      
      if (results['hasUser']) {
        final user = data['user'];
        results['user'] = {
          'hasId': user.containsKey('id'),
          'hasFullName': user.containsKey('fullName'),
          'hasPhoneNumber': user.containsKey('phoneNumber'),
          'hasEmail': user.containsKey('email'),
          'hasRole': user.containsKey('role'),
        };
      }
    } else {
      results['hasData'] = false;
    }
    
    results['isValid'] = results['success'] == true && 
                        results['hasData'] == true && 
                        results['hasAccessToken'] == true && 
                        results['hasUser'] == true;
    
    return results;
  }
}

