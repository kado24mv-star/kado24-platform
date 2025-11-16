import 'package:http/http.dart' as http;
import 'dart:convert';

class MerchantApiService {
  // All requests through API Gateway (APISIX)
  static const String apiGatewayUrl = 'http://localhost:9080';
  
  static const String authServiceUrl = apiGatewayUrl;
  static const String merchantServiceUrl = apiGatewayUrl;
  static const String voucherServiceUrl = apiGatewayUrl;
  static const String redemptionServiceUrl = apiGatewayUrl;
  static const String payoutServiceUrl = apiGatewayUrl;

  // Register Merchant
  Future<Map<String, dynamic>> registerMerchant({
    required String token,
    required Map<String, dynamic> businessData,
  }) async {
    final response = await http.post(
      Uri.parse('$merchantServiceUrl/api/v1/merchants/register'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(businessData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Merchant registration failed');
  }

  // Create Voucher
  Future<Map<String, dynamic>> createVoucher({
    required String token,
    required Map<String, dynamic> voucherData,
  }) async {
    final response = await http.post(
      Uri.parse('$voucherServiceUrl/api/v1/vouchers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(voucherData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Voucher creation failed');
  }

  // Redeem Voucher (QR Scanner)
  Future<Map<String, dynamic>> redeemVoucher({
    required String token,
    required String voucherCode,
    required double amount,
    String? location,
  }) async {
    final response = await http.post(
      Uri.parse('$redemptionServiceUrl/api/v1/redemptions/redeem'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'voucherCode': voucherCode,
        'amount': amount,
        'location': location,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Redemption failed');
  }

  // Get My Vouchers
  Future<Map<String, dynamic>> getMyVouchers(String token) async {
    final response = await http.get(
      Uri.parse('$voucherServiceUrl/api/v1/vouchers/my-vouchers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load vouchers');
  }

  // Get Payouts
  Future<Map<String, dynamic>> getPayouts(String token) async {
    final response = await http.get(
      Uri.parse('$payoutServiceUrl/api/v1/payouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load payouts');
  }
}

