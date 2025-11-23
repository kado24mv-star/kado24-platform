import 'package:flutter/foundation.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<dynamic> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> createOrder({
    required String token,
    required int voucherId,
    required double denomination,
    required int quantity,
    String? customerNotes,
  }) async {
    try {
      final response = await _orderService.createOrder(
        token: token,
        voucherId: voucherId,
        denomination: denomination,
        quantity: quantity,
        customerNotes: customerNotes,
      );
      return response;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _orderService.getMyOrders(token);
      if (response['success']) {
        _orders = response['data']['content'] as List;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}


































