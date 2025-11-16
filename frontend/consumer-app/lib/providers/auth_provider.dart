import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _accessToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    final userJson = prefs.getString('user');
    
    if (_accessToken != null && userJson != null) {
      _isAuthenticated = true;
      // TODO: Parse user from JSON
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );

      if (response['success']) {
        _accessToken = response['data']['accessToken'];
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;

        // Store in local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);
        await prefs.setString('refreshToken', response['data']['refreshToken']);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(identifier, password);

      if (response['success']) {
        _accessToken = response['data']['accessToken'];
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;

        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);
        await prefs.setString('refreshToken', response['data']['refreshToken']);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await _authService.logout(_accessToken!);
      } catch (e) {
        // Continue with logout even if API fails
      }
    }

    _user = null;
    _accessToken = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}





