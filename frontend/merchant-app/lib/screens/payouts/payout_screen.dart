import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayoutScreen extends StatelessWidget {
  const PayoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts'),
      ),
      body: SingleChildScrollView(
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
                  const Text(
                    '\$1,234.50',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Scheduled: Friday, Nov 15, 2025',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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

            _buildPayoutCard(
              'Week of Nov 1-7, 2025',
              '\$2,145.80',
              'Completed',
              'Nov 8, 2025',
              Colors.green,
            ),
            _buildPayoutCard(
              'Week of Oct 25-31, 2025',
              '\$1,987.50',
              'Completed',
              'Nov 1, 2025',
              Colors.green,
            ),
            _buildPayoutCard(
              'Week of Oct 18-24, 2025',
              '\$2,301.25',
              'Completed',
              'Oct 25, 2025',
              Colors.green,
            ),
            _buildPayoutCard(
              'Week of Oct 11-17, 2025',
              '\$1,876.90',
              'Completed',
              'Oct 18, 2025',
              Colors.green,
            ),

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
}


















