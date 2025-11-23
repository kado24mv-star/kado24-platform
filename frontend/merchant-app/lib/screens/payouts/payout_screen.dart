import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({Key? key}) : super(key: key);

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  List<dynamic> _payouts = [];
  bool _isLoading = true;
  double _nextPayoutAmount = 0.0;
  String _nextPayoutDate = '';

  @override
  void initState() {
    super.initState();
    _loadPayouts();
  }

  Future<void> _loadPayouts() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getPayoutUrl()}/api/v1/payouts?page=0&size=20'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _payouts = responseData['data']['content'] ?? [];
            // Calculate next payout from pending payouts
            final pending = _payouts.where((p) => p['status'] == 'PENDING').toList();
            if (pending.isNotEmpty) {
              _nextPayoutAmount = pending.fold(0.0, (sum, p) {
                double amount = 0.0;
                if (p['amount'] != null) {
                  if (p['amount'] is num) {
                    amount = p['amount'].toDouble();
                  } else if (p['amount'] is String) {
                    amount = double.tryParse(p['amount']) ?? 0.0;
                  }
                }
                return sum + amount;
              });
              _nextPayoutDate = 'Next payout scheduled';
            }
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _payouts = [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading payouts: $e');
      setState(() {
        _payouts = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPayouts,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next Payout
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next Payout',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_nextPayoutAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Colors.white70, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _nextPayoutDate.isEmpty ? 'No pending payouts' : _nextPayoutDate,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payout History
                    const Text(
                      'Payout History',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    if (_payouts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.account_balance_wallet, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No payouts yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._payouts.map((payout) {
                        // Build period string from periodStart and periodEnd
                        String period = 'Payout #${payout['id']}';
                        if (payout['periodStart'] != null && payout['periodEnd'] != null) {
                          try {
                            final start = DateFormat('MMM d').format(DateTime.parse(payout['periodStart']));
                            final end = DateFormat('MMM d, y').format(DateTime.parse(payout['periodEnd']));
                            period = '$start - $end';
                          } catch (e) {
                            period = 'Payout #${payout['id']}';
                          }
                        }
                        
                        // Handle amount - convert to double if it's a string or number
                        double amount = 0.0;
                        if (payout['amount'] != null) {
                          if (payout['amount'] is num) {
                            amount = payout['amount'].toDouble();
                          } else if (payout['amount'] is String) {
                            amount = double.tryParse(payout['amount']) ?? 0.0;
                          }
                        }
                        
                        return _buildPayoutCard(
                          period,
                          '\$${amount.toStringAsFixed(2)}',
                          payout['status'] ?? 'Pending',
                          payout['paidAt'] != null 
                              ? DateFormat('MMM d, y').format(DateTime.parse(payout['paidAt']))
                              : 'Pending',
                          _getPayoutStatusColor(payout['status']),
                        );
                      }).toList(),

                    const SizedBox(height: 24),

                    // Bank Account Info
                    const Text(
                      'Bank Account',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBankDetailRow('Bank', 'ABA Bank'),
                          _buildBankDetailRow('Account Number', '**** **** 1234'),
                          _buildBankDetailRow('Account Name', 'Brown Coffee Shop'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPayoutCard(
    String period,
    String amount,
    String status,
    String date,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  period,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid on $date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FACFE),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getPayoutStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
      case 'PAID':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}






















