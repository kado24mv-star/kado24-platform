import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final orderId = widget.transaction['id'];
    if (orderId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getOrderUrl()}/api/v1/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _orderDetails = responseData['data'];
            _isLoading = false;
          });
          return;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading order details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _orderDetails ?? widget.transaction;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order['orderNumber'] ?? 'Details'}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: _getStatusColor(order['paymentStatus']).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(order['paymentStatus']),
                            color: _getStatusColor(order['paymentStatus']),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['paymentStatus'] ?? 'PENDING',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(order['paymentStatus']),
                                  ),
                                ),
                                Text(
                                  'Order ${order['orderNumber'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Order Details
                  const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildDetailRow('Order Number', order['orderNumber'] ?? 'N/A'),
                    _buildDetailRow('Date', _formatDate(order['createdAt'])),
                    _buildDetailRow('Voucher', order['voucherTitle'] ?? 'N/A'),
                    _buildDetailRow('Customer', order['customerName'] ?? 'N/A'),
                  ]),

                  const SizedBox(height: 24),

                  // Payment Details
                  const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailCard([
                    _buildDetailRow('Subtotal', '\$${order['subtotal']?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildDetailRow('Platform Fee', '\$${order['platformFee']?.toStringAsFixed(2) ?? '0.00'}'),
                    _buildDetailRow('Your Earnings', '\$${order['merchantAmount']?.toStringAsFixed(2) ?? '0.00'}'),
                    const Divider(),
                    _buildDetailRow(
                      'Total Amount',
                      '\$${order['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                      isBold: true,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

