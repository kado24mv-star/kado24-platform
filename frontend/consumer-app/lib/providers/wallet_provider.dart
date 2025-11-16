import 'package:flutter/foundation.dart';
import '../services/wallet_service.dart';

class WalletProvider with ChangeNotifier {
  final WalletService _walletService = WalletService();
  
  List<dynamic> _vouchers = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWalletVouchers(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _walletService.getWalletVouchers(token);
      if (response['success']) {
        _vouchers = response['data']['content'] as List;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> giftVoucher({
    required String token,
    required int voucherId,
    required String recipientPhone,
    String? message,
  }) async {
    try {
      await _walletService.giftVoucher(
        token: token,
        voucherId: voucherId,
        recipientPhone: recipientPhone,
        message: message,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}















