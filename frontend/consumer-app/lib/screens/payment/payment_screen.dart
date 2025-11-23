import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../payment/payment_success_screen.dart';
import '../../config/api_config.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/jwt_util.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final double amount;
  final String paymentMethod;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.orderNumber,
    required this.amount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;
  bool isCompletingPayment = false;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _initiatePayment();
  }

  Future<void> _initiatePayment() async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Use mock payment service through API Gateway
      // Ensure we use the gateway URL (port 9080) and include payment method
      final method = widget.paymentMethod.toUpperCase();
      final paymentUrl = 'http://localhost:9080/api/mock/payment/page?amount=${widget.amount}&orderId=${widget.orderNumber}&method=$method';
      
      // Open payment in browser (for web) or WebView (for mobile)
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      // Wait a moment for payment window to open
      await Future.delayed(const Duration(seconds: 1));
      
      // Show a button for user to manually complete payment after they finish in the payment window
      // The payment completion will be triggered when user clicks "I've Completed Payment" button
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: $e')),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _completePayment() async {
    setState(() {
      isCompletingPayment = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;
      
      print('Payment: Starting payment completion...');
      print('Payment: Token exists: ${token != null && token.isNotEmpty}');
      
      if (token == null || token.isEmpty) {
        print('Payment: Token is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not authenticated. Please log in again.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // Check if token has userId claim (required for payment)
      // If token is missing userId, user needs to log out and log back in
      print('Payment: Checking for userId in token...');
      final userId = JwtUtil.getUserId(token);
      print('Payment: userId from token: $userId');
      
      if (userId == null) {
        print('Payment: userId is null - token missing userId claim');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session token is outdated and missing user information. Please log out and log back in to continue.'),
              duration: Duration(seconds: 6),
              backgroundColor: Colors.red,
            ),
          );
          // Wait a moment then navigate back
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context);
          }
        }
        return;
      }
      
      print('Payment: Token validated - userId: $userId, proceeding with payment...');

      // Complete payment through order service
      print('Payment: Calling completePayment API...');
      print('Payment: orderId=${widget.orderId}, amount=${widget.amount}, method=${widget.paymentMethod}');
      
      final response = await _orderService.completePayment(
        token: token,
        orderId: widget.orderId,
        amount: widget.amount,
        paymentMethod: widget.paymentMethod,
      );

      print('Payment: API response received: ${response.toString()}');
      
      if (mounted && response['success'] == true) {
        print('Payment: Payment completed successfully, navigating to success screen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              orderNumber: widget.orderNumber,
              amount: widget.amount,
              voucherTitle: 'Voucher', // TODO: Pass actual voucher title
            ),
          ),
        );
      } else {
        final errorMsg = response['message'] ?? response['error'] ?? 'Payment completion failed';
        print('Payment: Payment failed - $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to complete payment';
        if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = 'Authentication failed. Please log in again.';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Payment endpoint not found. Please try again.';
        } else {
          errorMessage = 'Payment error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        isCompletingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                strokeWidth: 4,
              ),
              const SizedBox(height: 32),
              Text(
                isCompletingPayment ? 'Completing Payment...' : 'Processing Payment',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Amount: \$${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Method: ${widget.paymentMethod}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Order: ${widget.orderNumber}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please complete payment in the opened window, then click the button below',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (!isCompletingPayment)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _completePayment,
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text(
                      'I\'ve Completed Payment',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27ae60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




































