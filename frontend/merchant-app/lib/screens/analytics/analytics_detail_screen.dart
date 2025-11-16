import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDetailScreen extends StatelessWidget {
  const AnalyticsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Analytics'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                Expanded(child: _buildPeriodButton('Today', false)),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodButton('Week', true)),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodButton('Month', false)),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodButton('Year', false)),
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
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(1, 150),
                        FlSpot(2, 120),
                        FlSpot(3, 200),
                        FlSpot(4, 180),
                        FlSpot(5, 250),
                        FlSpot(6, 280),
                      ],
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
                _buildMetricCard('Total Revenue', '\$8,456', '+23%', true),
                _buildMetricCard('Vouchers Sold', '342', '+15%', true),
                _buildMetricCard('Redemption Rate', '68%', '-2%', false),
                _buildMetricCard('Avg Order', '\$24.73', '+8%', true),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Top Vouchers
            const Text('Top Performing Vouchers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTopVoucher('Coffee Voucher', 89, 1245.00),
            _buildTopVoucher('Breakfast Combo', 56, 896.00),
            _buildTopVoucher('Lunch Special', 43, 645.00),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, bool active) {
    return ElevatedButton(
      onPressed: () {},
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
          '\$$revenue',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}















