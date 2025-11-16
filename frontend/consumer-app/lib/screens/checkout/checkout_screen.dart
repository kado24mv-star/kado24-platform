import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/voucher.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Voucher voucher;
  final double selectedAmount;

  const CheckoutScreen({
    Key? key,
    required this.voucher,
    required this.selectedAmount,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int quantity = 1;
  String? selectedPaymentMethod;

  final List<Map<String, dynamic>> paymentMethods = [
    {'id': 'ABA', 'name': 'ABA PayWay', 'icon': '💳', 'color': Color(0xFF0066CC)},
    {'id': 'WING', 'name': 'Wing Money', 'icon': '💸', 'color': Color(0xFFFF6B00)},
    {'id': 'PIPAY', 'name': 'Pi Pay', 'icon': '📱', 'color': Color(0xFF6C63FF)},
    {'id': 'KHQR', 'name': 'KHQR', 'icon': '📲', 'color': Color(0xFF00AA13)},
  ];

  double get subtotal => widget.selectedAmount * quantity;
  double get platformFee => subtotal * 0.08;
  double get total => subtotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.voucher.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.voucher.merchantName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setState(() => quantity--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: quantity < 10
                                ? () => setState(() => quantity++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Price Breakdown
                  _buildPriceRow('Amount', '\$${widget.selectedAmount.toStringAsFixed(2)} × $quantity'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ...paymentMethods.map((method) {
              final isSelected = selectedPaymentMethod == method['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = method['id'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? method['color'] : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(method['icon'], style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          method['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: method['color']),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 100), // Space for button
          ],
        ),
      ),

      // Proceed to Payment Button
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: selectedPaymentMethod != null ? _proceedToPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pay \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToPayment() async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // Create order
      final orderResponse = await ApiService().post(
        '/api/v1/orders',
        {
          'voucherId': widget.voucher.id,
          'denomination': widget.selectedAmount,
          'quantity': quantity,
        },
        token: authProvider.accessToken,
        baseUrlOverride: ApiService.orderServiceUrl,
      );

      if (orderResponse['success'] && mounted) {
        final orderData = orderResponse['data'];
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              orderId: orderData['id'],
              orderNumber: orderData['orderNumber'],
              amount: total,
              paymentMethod: selectedPaymentMethod!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    }
  }
}


















