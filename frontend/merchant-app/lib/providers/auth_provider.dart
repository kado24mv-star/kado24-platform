import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userData;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userData => _userData;
  bool get isInitialized => _isInitialized;

  // Initialize auth state from storage
  Future<void> initAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      _userData = jsonDecode(userDataString);
    }
    _isAuthenticated = _accessToken != null && _accessToken!.isNotEmpty;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.getAuthUrl()}/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          _accessToken = responseData['data']['accessToken'];
          _refreshToken = responseData['data']['refreshToken'];
          _userData = responseData['data']['user'];
          _isAuthenticated = true;
          
          // Save to persistent storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', _accessToken!);
          await prefs.setString('refreshToken', _refreshToken ?? '');
          await prefs.setString('userData', jsonEncode(_userData));
          
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _accessToken = null;
    _refreshToken = null;
    _userData = null;
    
    // Clear from persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userData');
    
    notifyListeners();
  }
}























