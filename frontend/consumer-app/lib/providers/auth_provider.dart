import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../utils/jwt_util.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _accessToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isRefreshing = false; // Prevent multiple simultaneous refresh attempts
  DateTime? _lastRefreshAttempt; // Track last refresh attempt to prevent rapid retries

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    // Prevent multiple simultaneous calls
    if (_isRefreshing) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    final userJson = prefs.getString('user');
    
    debugPrint('🔍 Loading stored auth - Token exists: ${_accessToken != null}, User exists: ${userJson != null}');
    
    if (_accessToken != null && userJson != null) {
      try {
        // Validate token has userId claim - this prevents "missing user key" errors
        if (!JwtUtil.hasUserId(_accessToken!)) {
          await _clearAuth(prefs);
          return;
        }
        
        // Check if token is expired (with buffer to prevent false positives on quick refreshes)
        if (JwtUtil.isExpired(_accessToken!)) {
          // Try to refresh token if we have a refresh token
          final refreshToken = prefs.getString('refreshToken');
          if (refreshToken != null && refreshToken.isNotEmpty) {
            // Prevent rapid refresh attempts (wait at least 10 seconds between attempts)
            final now = DateTime.now();
            if (_lastRefreshAttempt != null && 
                now.difference(_lastRefreshAttempt!).inSeconds < 10) {
              // Too soon since last refresh attempt, use existing token if still valid
              // This prevents rapid refresh loops on quick page refreshes
              if (!JwtUtil.isExpired(_accessToken!, buffer: const Duration(minutes: 10))) {
                _user = User.fromJson(jsonDecode(userJson));
                _isAuthenticated = true;
                notifyListeners();
                return;
              }
            }
            
            _isRefreshing = true;
            _lastRefreshAttempt = now;
            
            try {
              // Attempt to refresh - if it fails, then logout
              final authService = AuthService();
              final refreshResponse = await authService.refreshToken(refreshToken);
              if (refreshResponse['success'] == true && refreshResponse['data'] != null) {
                _accessToken = refreshResponse['data']['accessToken'];
                await prefs.setString('accessToken', _accessToken!);
                if (refreshResponse['data']['refreshToken'] != null) {
                  await prefs.setString('refreshToken', refreshResponse['data']['refreshToken']);
                }
                _user = User.fromJson(jsonDecode(userJson));
                _isAuthenticated = true;
                _isRefreshing = false;
                notifyListeners();
                return;
              }
            } catch (e) {
              // Refresh failed - but don't clear auth immediately on network errors
              // Only clear if token is truly expired (more than 10 minutes past expiration)
              if (JwtUtil.isExpired(_accessToken!, buffer: const Duration(minutes: 10))) {
                await _clearAuth(prefs);
              } else {
                // Token still valid, use it even though refresh failed
                _user = User.fromJson(jsonDecode(userJson));
                _isAuthenticated = true;
              }
              _isRefreshing = false;
              notifyListeners();
              return;
            } finally {
              _isRefreshing = false;
            }
          }
          
          // No refresh token or refresh failed - only clear if truly expired
          if (JwtUtil.isExpired(_accessToken!, buffer: const Duration(minutes: 10))) {
            await _clearAuth(prefs);
          } else {
            // Token still valid, use it
            _user = User.fromJson(jsonDecode(userJson));
            _isAuthenticated = true;
            notifyListeners();
          }
          return;
        }
        
        // Token is valid - load user and set authenticated
        _user = User.fromJson(jsonDecode(userJson));
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        // If parsing fails, clear invalid data
        await _clearAuth(prefs);
      }
    }
  }
  
  Future<void> _clearAuth(SharedPreferences prefs) async {
    await prefs.remove('user');
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    _accessToken = null;
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
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
        // Registration may not return tokens if OTP verification is required
        final data = response['data'];
        if (data['accessToken'] != null) {
          // User is already activated (shouldn't happen for consumers now)
          _accessToken = data['accessToken'];
          _user = User.fromJson(data['user']);
          _isAuthenticated = true;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', _accessToken!);
          await prefs.setString('refreshToken', data['refreshToken']);
        } else {
          // OTP verification required - just store user info temporarily
          _user = User.fromJson(data['user']);
          _isAuthenticated = false; // Not authenticated until OTP is verified
        }

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
        // Verify response structure
        assert(response['data'] != null, 'Login response missing data');
        assert(response['data']['accessToken'] != null, 'Login response missing accessToken');
        assert(response['data']['user'] != null, 'Login response missing user');
        
        _accessToken = response['data']['accessToken'];
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;

        // Store tokens and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', _accessToken!);
        if (response['data']['refreshToken'] != null) {
          await prefs.setString('refreshToken', response['data']['refreshToken']);
        }
        // Store user JSON for persistence
        await prefs.setString('user', jsonEncode(response['data']['user']));
        
        // Verify storage
        final storedToken = prefs.getString('accessToken');
        final storedUser = prefs.getString('user');
        assert(storedToken == _accessToken, 'Token not stored correctly');
        assert(storedUser != null, 'User data not stored correctly');
        
        debugPrint('✅ Login successful - Token stored: ${_accessToken?.substring(0, 20)}...');
        debugPrint('✅ User stored: ${_user?.fullName} (${_user?.phoneNumber})');

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

  Future<void> loginWithOTP(Map<String, dynamic> tokenResponse) async {
    if (tokenResponse['success'] == true && tokenResponse['data'] != null) {
      _accessToken = tokenResponse['data']['accessToken'];
      _user = User.fromJson(tokenResponse['data']['user']);
      _isAuthenticated = true;

      // Store tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', _accessToken!);
      if (tokenResponse['data']['refreshToken'] != null) {
        await prefs.setString('refreshToken', tokenResponse['data']['refreshToken']);
      }
      await prefs.setString('user', jsonEncode(tokenResponse['data']['user']));

      notifyListeners();
    }
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    if (userData.isNotEmpty) {
      _user = User.fromJson(userData);
      
      // Store updated user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(userData));
      
      notifyListeners();
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





