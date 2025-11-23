import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final double amount;
  final String voucherTitle;

  const PaymentSuccessScreen({
    Key? key,
    required this.orderNumber,
    required this.amount,
    required this.voucherTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green[600],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Your voucher is now in your wallet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              // Order Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Order Number', orderNumber),
                    const SizedBox(height: 12),
                    _buildDetailRow('Amount Paid', '\$${amount.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Voucher', voucherTitle),
                    const SizedBox(height: 12),
                    _buildDetailRow('Status', 'Completed', valueColor: Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to wallet
                    Navigator.popUntil(context, (route) => route.isFirst);
                    // TODO: Navigate to wallet tab
                  },
                  icon: const Icon(Icons.wallet, color: Colors.white),
                  label: const Text(
                    'View My Wallet',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement gifting
                  },
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Gift This Voucher', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF667EEA),
                    side: const BorderSide(color: Color(0xFF667EEA), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}





































