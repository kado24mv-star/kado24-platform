import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/wallet_service.dart';
import 'gift_sent_screen.dart';

class GiftVoucherScreen extends StatefulWidget {
  final Map<String, dynamic> voucher;
  
  const GiftVoucherScreen({Key? key, required this.voucher}) : super(key: key);

  @override
  State<GiftVoucherScreen> createState() => _GiftVoucherScreenState();
}

class _GiftVoucherScreenState extends State<GiftVoucherScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sendNow = true;
  bool _isSending = false;
  final WalletService _walletService = WalletService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send as Gift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voucher Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF667EEA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, size: 48, color: Color(0xFF667EEA)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.voucher['title'] ?? 'Voucher',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${widget.voucher['denomination']?.toStringAsFixed(2) ?? widget.voucher['amount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 20, color: Color(0xFF667EEA)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recipient Phone
              const Text("Recipient's Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '+855 12 345 678',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Personal Message
              const Text('Personal Message (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Happy Birthday! Enjoy your coffee! 🎉',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Schedule Delivery
              const Text('Schedule Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _sendNow = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _sendNow ? const Color(0xFF667EEA) : Colors.grey[300],
                        foregroundColor: _sendNow ? Colors.white : Colors.black,
                      ),
                      child: const Text('Send Now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement scheduling
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scheduled delivery coming soon')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: !_sendNow ? const Color(0xFF667EEA) : Colors.grey,
                        side: BorderSide(color: !_sendNow ? const Color(0xFF667EEA) : Colors.grey),
                      ),
                      child: const Text('Schedule'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Send Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendGift,
                  icon: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.card_giftcard, color: Colors.white),
                  label: Text(
                    _isSending ? 'Sending...' : 'Send Gift 🎁',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendGift() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('Not authenticated');
      }

      await _walletService.giftVoucher(
        token: token,
        voucherId: widget.voucher['id'] ?? widget.voucher['voucherId'],
        recipientPhone: _phoneController.text,
        message: _messageController.text.isEmpty ? null : _messageController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GiftSentScreen(
              recipientPhone: _phoneController.text,
              voucherTitle: widget.voucher['title'] ?? 'Voucher',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
