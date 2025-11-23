import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class AnalyticsDetailScreen extends StatefulWidget {
  const AnalyticsDetailScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsDetailScreen> createState() => _AnalyticsDetailScreenState();
}

class _AnalyticsDetailScreenState extends State<AnalyticsDetailScreen> {
  String _selectedPeriod = 'Week';
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _chartData = [];
  List<dynamic> _topVouchers = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      // Load merchant statistics
      final statsResponse = await http.get(
        Uri.parse('${ApiConfig.getMerchantUrl()}/api/v1/merchants/my-statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (statsResponse.statusCode == 200) {
        final statsData = jsonDecode(statsResponse.body);
        if (statsData['success'] == true && statsData['data'] != null) {
          setState(() {
            _stats = statsData['data'];
          });
        }
      }

      // Load orders for chart and top vouchers
      final ordersResponse = await http.get(
        Uri.parse('${ApiConfig.getOrderUrl()}/api/v1/orders?page=0&size=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (ordersResponse.statusCode == 200) {
        final ordersData = jsonDecode(ordersResponse.body);
        if (ordersData['success'] == true && ordersData['data'] != null) {
          final orders = ordersData['data']['content'] ?? [];
          _processChartData(orders);
          _processTopVouchers(orders);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() => _isLoading = false);
    }
  }

  void _processChartData(List<dynamic> orders) {
    Map<String, double> dailyRevenue = {};
    final now = DateTime.now();
    int daysToShow = 7; // Default to week
    
    if (_selectedPeriod == 'Today') daysToShow = 1;
    else if (_selectedPeriod == 'Month') daysToShow = 30;
    else if (_selectedPeriod == 'Year') daysToShow = 365;
    
    for (int i = daysToShow - 1; i >= 0; i--) {
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
      }).toList()..sort((a, b) => a['day'].compareTo(b['day']));
    });
  }

  void _processTopVouchers(List<dynamic> orders) {
    Map<String, Map<String, dynamic>> voucherStats = {};
    
    for (var order in orders) {
      final voucherTitle = order['voucherTitle'] ?? 'Unknown Voucher';
      final amount = (order['totalAmount'] is num) 
          ? order['totalAmount'].toDouble() 
          : double.tryParse(order['totalAmount'].toString()) ?? 0.0;
      
      if (!voucherStats.containsKey(voucherTitle)) {
        voucherStats[voucherTitle] = {
          'name': voucherTitle,
          'sales': 0,
          'revenue': 0.0,
        };
      }
      
      voucherStats[voucherTitle]!['sales'] = (voucherStats[voucherTitle]!['sales'] as int) + 1;
      voucherStats[voucherTitle]!['revenue'] = (voucherStats[voucherTitle]!['revenue'] as double) + amount;
    }
    
    setState(() {
      _topVouchers = voucherStats.values.toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export analytics data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  Row(
                    children: [
                      Expanded(child: _buildPeriodButton('Today', _selectedPeriod == 'Today')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPeriodButton('Week', _selectedPeriod == 'Week')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPeriodButton('Month', _selectedPeriod == 'Month')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildPeriodButton('Year', _selectedPeriod == 'Year')),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Revenue Chart
                  const Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartData.isEmpty
                                ? [const FlSpot(0, 0)]
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
                  
                  // Metrics Grid
                  const Text('Key Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMetricCard(
                        'Total Revenue',
                        '\$${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                        '+23%',
                        true,
                      ),
                      _buildMetricCard(
                        'Vouchers Sold',
                        '${_stats['totalVouchersSold'] ?? 0}',
                        '+15%',
                        true,
                      ),
                      _buildMetricCard(
                        'Rating',
                        '${(_stats['rating'] ?? 0.0).toStringAsFixed(1)} ★',
                        '-2%',
                        false,
                      ),
                      _buildMetricCard(
                        'Avg Order',
                        '\$${((_stats['totalRevenue'] ?? 0.0) / ((_stats['totalVouchersSold'] ?? 1).toDouble())).toStringAsFixed(2)}',
                        '+8%',
                        true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Top Vouchers
                  const Text('Top Performing Vouchers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _topVouchers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No voucher sales data available',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Column(
                          children: _topVouchers.take(3).map((voucher) {
                            return _buildTopVoucher(
                              voucher['name'] ?? 'Voucher',
                              voucher['sales'] ?? 0,
                              voucher['revenue'] ?? 0.0,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodButton(String label, bool active) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = label;
        });
        _loadAnalytics();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF4FACFE) : Colors.grey[200],
        foregroundColor: active ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildMetricCard(String label, String value, String change, bool positive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(
            change,
            style: TextStyle(
              fontSize: 12,
              color: positive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopVoucher(String name, int sales, double revenue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4FACFE).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.card_giftcard, color: Color(0xFF4FACFE)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$sales sales'),
        trailing: Text(
          '\$${revenue.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
