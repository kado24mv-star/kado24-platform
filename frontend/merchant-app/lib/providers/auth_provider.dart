import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _accessToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;

  Future<bool> login(String phone, String password) async {
    // TODO: Implement login with auth-service
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _accessToken = null;
    notifyListeners();
  }
}



















