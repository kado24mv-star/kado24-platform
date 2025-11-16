import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class WalletService {
  // Get My Wallet Vouchers
  Future<Map<String, dynamic>> getWalletVouchers(String token, {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.walletServiceUrl}${ApiConfig.walletList}?page=$page&size=$size'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load wallet');
    }
  }

  // Get Voucher Detail
  Future<Map<String, dynamic>> getVoucherDetail(String token, int voucherId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.walletServiceUrl}${ApiConfig.walletDetail}/$voucherId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load voucher details');
    }
  }

  // Gift Voucher
  Future<void> giftVoucher({
    required String token,
    required int voucherId,
    required String recipientPhone,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.walletServiceUrl}/api/v1/wallet/$voucherId/gift'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'recipientPhone': recipientPhone,
        'giftMessage': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gift failed');
    }
  }
}















