import 'package:flutter/material.dart';
import '../scanner/qr_scanner_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.qr_code_scanner,
              title: 'Scan QR',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.card_giftcard,
              title: 'My Vouchers',
              color: Colors.purple,
              onTap: () {
                // TODO: Navigate to vouchers
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.receipt_long,
              title: 'Transactions',
              color: Colors.green,
              onTap: () {
                // TODO: Navigate to transactions
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Payouts',
              color: Colors.orange,
              onTap: () {
                // TODO: Navigate to payouts
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



















