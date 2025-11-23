import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class OrderService {
  // Create Order
  Future<Map<String, dynamic>> createOrder({
    required String token,
    required int voucherId,
    required double denomination,
    required int quantity,
    String? customerNotes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.orderServiceUrl}${ApiConfig.ordersCreate}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'voucherId': voucherId,
        'denomination': denomination,
        'quantity': quantity,
        'customerNotes': customerNotes,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Order creation failed: ${response.body}');
    }
  }

  // Get My Orders
  Future<Map<String, dynamic>> getMyOrders(String token, {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.orderServiceUrl}${ApiConfig.ordersList}?page=$page&size=$size'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Get Order Details
  Future<Map<String, dynamic>> getOrderDetail(String token, int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.orderServiceUrl}${ApiConfig.ordersDetail}/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load order details');
    }
  }

  // Cancel Order
  Future<void> cancelOrder(String token, int orderId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.orderServiceUrl}/api/v1/orders/$orderId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Order cancellation failed');
    }
  }

  // Complete Payment
  Future<Map<String, dynamic>> completePayment({
    required String token,
    required int orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.orderServiceUrl}/api/v1/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      }),
    );

    print('OrderService: Payment completion response status: ${response.statusCode}');
    print('OrderService: Response body: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('OrderService: Payment completion successful: ${responseData.toString()}');
      return responseData;
    } else {
      final errorBody = response.body;
      print('OrderService: Payment completion failed with status ${response.statusCode}: $errorBody');
      throw Exception('Payment completion failed: $errorBody');
    }
  }
}

































