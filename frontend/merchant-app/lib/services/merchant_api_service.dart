import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class MerchantApiService {
  // Use configuration from ApiConfig
  static String get authServiceUrl => ApiConfig.getAuthUrl();
  static String get merchantServiceUrl => ApiConfig.getMerchantUrl();
  static String get voucherServiceUrl => ApiConfig.getVoucherUrl();
  static String get redemptionServiceUrl => ApiConfig.getRedemptionUrl();
  static String get payoutServiceUrl => ApiConfig.getPayoutUrl();

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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('${response.statusCode}:Unauthorized - Please login again');
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('${response.statusCode}:Unauthorized - Please login again');
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('${response.statusCode}:Unauthorized - Please login again');
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('${response.statusCode}:Unauthorized - Please login again');
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('${response.statusCode}:Unauthorized - Please login again');
    }
    throw Exception('Failed to load payouts');
  }
}

