import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/voucher.dart';

class VoucherService {
  // Get All Vouchers
  Future<List<Voucher>> getVouchers({int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.voucherServiceUrl}${ApiConfig.vouchersList}?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final vouchersList = data['data']['content'] as List;
        return vouchersList.map((v) => Voucher.fromJson(v)).toList();
      }
    }
    throw Exception('Failed to load vouchers');
  }

  // Search Vouchers
  Future<List<Voucher>> searchVouchers(String query, {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.voucherServiceUrl}${ApiConfig.vouchersSearch}?query=$query&page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final vouchersList = data['data']['content'] as List;
        return vouchersList.map((v) => Voucher.fromJson(v)).toList();
      }
    }
    throw Exception('Search failed');
  }

  // Get Categories
  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.voucherServiceUrl}${ApiConfig.vouchersCategories}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'] as List;
      }
    }
    throw Exception('Failed to load categories');
  }

  // Get Voucher Detail
  Future<Voucher> getVoucherDetail(String slugOrId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.voucherServiceUrl}${ApiConfig.vouchersDetail}/$slugOrId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return Voucher.fromJson(data['data']);
      }
    }
    throw Exception('Failed to load voucher');
  }

  // Get Vouchers by Category
  Future<List<Voucher>> getVouchersByCategory(int categoryId, {int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.voucherServiceUrl}/api/v1/vouchers/category/$categoryId?page=$page&size=$size'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final vouchersList = data['data']['content'] as List;
        return vouchersList.map((v) => Voucher.fromJson(v)).toList();
      }
    }
    throw Exception('Failed to load vouchers');
  }
}















