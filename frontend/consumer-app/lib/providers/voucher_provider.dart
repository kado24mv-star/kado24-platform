import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voucher_service.dart';
import '../models/voucher.dart';
import '../utils/auth_error_handler.dart';
import '../providers/auth_provider.dart';

class VoucherProvider with ChangeNotifier {
  final VoucherService _voucherService = VoucherService();
  
  List<Voucher> _vouchers = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;

  List<Voucher> get vouchers => _vouchers;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadVouchers({int page = 0, int size = 20, BuildContext? context}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vouchers = await _voucherService.getVouchers(page: page, size: size);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle auth errors - redirect to login
      if (context != null && AuthErrorHandler.isAuthError(e)) {
        AuthErrorHandler.handleAuthError(context, e);
        return;
      }
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories({BuildContext? context}) async {
    try {
      _categories = await _voucherService.getCategories();
      notifyListeners();
    } catch (e) {
      // Handle auth errors - redirect to login
      if (context != null && AuthErrorHandler.isAuthError(e)) {
        AuthErrorHandler.handleAuthError(context, e);
        return;
      }
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchVouchers(String query, {BuildContext? context}) async {
    _isLoading = true;
    _selectedCategoryId = null; // Clear category filter when searching
    notifyListeners();

    try {
      _vouchers = await _voucherService.searchVouchers(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle auth errors - redirect to login
      if (context != null && AuthErrorHandler.isAuthError(e)) {
        AuthErrorHandler.handleAuthError(context, e);
        return;
      }
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategory(int categoryId, {BuildContext? context}) async {
    _isLoading = true;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      _vouchers = await _voucherService.getVouchersByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Handle auth errors - redirect to login
      if (context != null && AuthErrorHandler.isAuthError(e)) {
        AuthErrorHandler.handleAuthError(context, e);
        return;
      }
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCategoryFilter({BuildContext? context}) async {
    _selectedCategoryId = null;
    await loadVouchers(context: context);
  }
}





