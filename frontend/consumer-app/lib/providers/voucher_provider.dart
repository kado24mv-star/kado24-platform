import 'package:flutter/foundation.dart';
import '../services/voucher_service.dart';
import '../models/voucher.dart';

class VoucherProvider with ChangeNotifier {
  final VoucherService _voucherService = VoucherService();
  
  List<Voucher> _vouchers = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Voucher> get vouchers => _vouchers;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVouchers({int page = 0, int size = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vouchers = await _voucherService.getVouchers(page: page, size: size);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _voucherService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchVouchers(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vouchers = await _voucherService.searchVouchers(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}





