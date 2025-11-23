import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getOrderUrl()}/api/v1/orders?page=0&size=50'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _transactions = responseData['data']['content'] ?? [];
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _transactions = [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() {
        _transactions = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton('All', _selectedFilter == 'All'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('Today', _selectedFilter == 'Today'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('This Week', _selectedFilter == 'This Week'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('This Month', _selectedFilter == 'This Month'),
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final isCompleted = transaction['paymentStatus'] == 'COMPLETED';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                  child: Icon(
                                    isCompleted ? Icons.check_circle : Icons.pending,
                                    color: isCompleted ? Colors.green : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  transaction['orderNumber'] ?? 'Order',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction['paymentStatus'] ?? 'Pending',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      transaction['createdAt'] != null
                                          ? DateFormat('MMM d, h:mm a').format(DateTime.parse(transaction['createdAt']))
                                          : '',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${transaction['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Fee: \$${transaction['platformFee']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionDetailScreen(transaction: transaction),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool active) {
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedFilter = label);
        // Could implement filtering here if needed
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF4FACFE) : Colors.grey[200],
        foregroundColor: active ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _applyFilter() {
    // Filter logic - reload transactions
    // In production, this would call the API with date parameters
    _loadTransactions();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: const Text('Advanced filtering options will be available in a future update. Use the time period buttons above to filter by date range.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}



















