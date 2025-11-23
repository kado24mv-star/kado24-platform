import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _recentTransactions = [];
  List<Map<String, dynamic>> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
    _loadRecentTransactions();
    _loadChartData();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getMerchantUrl()}/api/v1/merchants/my-statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _stats = responseData['data'];
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _stats = {};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      setState(() {
        _stats = {};
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentTransactions() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.getOrderUrl()}/api/v1/orders?page=0&size=5'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _recentTransactions = responseData['data']['content'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading recent transactions: $e');
    }
  }

  Future<void> _loadChartData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) return;

      // Get last 7 days of orders for chart
      final response = await http.get(
        Uri.parse('${ApiConfig.getOrderUrl()}/api/v1/orders?page=0&size=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final orders = responseData['data']['content'] ?? [];
          
          // Group by date and calculate daily revenue
          Map<String, double> dailyRevenue = {};
          final now = DateTime.now();
          
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            dailyRevenue[dateKey] = 0.0;
          }
          
          for (var order in orders) {
            if (order['createdAt'] != null && order['totalAmount'] != null) {
              try {
                final orderDate = DateTime.parse(order['createdAt']);
                final dateKey = '${orderDate.year}-${orderDate.month.toString().padLeft(2, '0')}-${orderDate.day.toString().padLeft(2, '0')}';
                if (dailyRevenue.containsKey(dateKey)) {
                  final amount = (order['totalAmount'] is num) 
                      ? order['totalAmount'].toDouble() 
                      : double.tryParse(order['totalAmount'].toString()) ?? 0.0;
                  dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0.0) + amount;
                }
              } catch (e) {
                debugPrint('Error parsing order date: $e');
              }
            }
          }
          
          setState(() {
            _chartData = dailyRevenue.entries.map((e) {
              final date = DateTime.parse(e.key);
              return {
                'day': date.day,
                'revenue': e.value,
              };
            }).toList()..sort((a, b) => (a['day'] as num).compareTo(b['day'] as num));
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading chart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Revenue',
                          '\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Vouchers Sold',
                          '${_stats['totalVouchersSold'] ?? 0}',
                          Icons.card_giftcard,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Rating',
                          '${(_stats['rating'] ?? 0.0).toStringAsFixed(1)} ★',
                          Icons.star,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Reviews',
                          '${_stats['totalReviews'] ?? 0}',
                          Icons.reviews,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Sales Chart
            const Text(
              'Sales Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _chartData.isEmpty
                          ? [
                              const FlSpot(0, 0),
                              const FlSpot(1, 0),
                              const FlSpot(2, 0),
                              const FlSpot(3, 0),
                              const FlSpot(4, 0),
                              const FlSpot(5, 0),
                              const FlSpot(6, 0),
                            ]
                          : _chartData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value['revenue'] ?? 0.0);
                            }).toList(),
                      isCurved: true,
                      color: const Color(0xFF4FACFE),
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactions');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _recentTransactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No recent transactions',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: _recentTransactions.take(3).map((transaction) {
                      final status = transaction['paymentStatus'] ?? 'PENDING';
                      final isCompleted = status == 'COMPLETED';
                      final amount = transaction['totalAmount']?.toStringAsFixed(2) ?? '0.00';
                      final createdAt = transaction['createdAt'];
                      String timeAgo = 'Recently';
                      
                      if (createdAt != null) {
                        try {
                          final date = DateTime.parse(createdAt);
                          final now = DateTime.now();
                          final diff = now.difference(date);
                          if (diff.inHours < 1) {
                            timeAgo = '${diff.inMinutes} minutes ago';
                          } else if (diff.inHours < 24) {
                            timeAgo = '${diff.inHours} hours ago';
                          } else {
                            timeAgo = '${diff.inDays} days ago';
                          }
                        } catch (e) {
                          timeAgo = 'Recently';
                        }
                      }
                      
                      return _buildTransactionCard(
                        transaction['orderNumber'] ?? 'Order',
                        isCompleted ? 'Completed' : status,
                        timeAgo,
                        '\$$amount',
                        isCompleted ? Colors.green : Colors.blue,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    String title,
    String status,
    String time,
    String amount,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            status == 'Redeemed' ? Icons.check : Icons.shopping_bag,
            color: statusColor,
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$status • $time'),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}





