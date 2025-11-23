import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class PaymentService {
  // Initialize payment with mock payment service
  Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.mockPaymentServiceUrl}${ApiConfig.mockPaymentInit}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'orderId': orderId,
        'amount': amount,
        'method': paymentMethod, // ABA, WING, PIPAY, KHQR
        'currency': 'USD',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment initiation failed');
    }
  }

  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.mockPaymentServiceUrl}/api/mock/payment/status/$paymentId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment status check failed');
    }
  }

  // Process payment (mock)
  Future<Map<String, dynamic>> processPayment(String paymentId, bool success) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.mockPaymentServiceUrl}${ApiConfig.mockPaymentProcess}?id=$paymentId&success=$success'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment processing failed');
    }
  }

  // For real payment gateways (future implementation):
  
  // ABA PayWay
  Future<Map<String, dynamic>> initiateABAPayment(String orderId, double amount) async {
    // TODO: Integrate with actual ABA PayWay API
    // For now, use mock service
    return initiatePayment(orderId: orderId, amount: amount, paymentMethod: 'ABA');
  }

  // Wing Money
  Future<Map<String, dynamic>> initiateWingPayment(String orderId, double amount) async {
    // TODO: Integrate with Wing API
    return initiatePayment(orderId: orderId, amount: amount, paymentMethod: 'WING');
  }

  // Pi Pay
  Future<Map<String, dynamic>> initiatePiPayPayment(String orderId, double amount) async {
    // TODO: Integrate with Pi Pay API
    return initiatePayment(orderId: orderId, amount: amount, paymentMethod: 'PIPAY');
  }

  // KHQR
  Future<Map<String, dynamic>> initiateKHQRPayment(String orderId, double amount) async {
    // TODO: Integrate with KHQR
    return initiatePayment(orderId: orderId, amount: amount, paymentMethod: 'KHQR');
  }
}


































