import 'package:flutter/material.dart';

class GiftVoucherScreen extends StatefulWidget {
  final Map<String, dynamic> voucher;
  
  const GiftVoucherScreen({Key? key, required this.voucher}) : super(key: key);

  @override
  State<GiftVoucherScreen> createState() => _GiftVoucherScreenState();
}

class _GiftVoucherScreenState extends State<GiftVoucherScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sendNow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send as Gift'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                          '\$${widget.voucher['amount'] ?? '0.00'}',
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
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '+855 12 345 678',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
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
                    onPressed: () => setState(() => _sendNow = false),
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
                onPressed: _sendGift,
                icon: const Icon(Icons.card_giftcard, color: Colors.white),
                label: const Text('Send Gift 🎁', style: TextStyle(fontSize: 16, color: Colors.white)),
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
    );
  }

  void _sendGift() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient phone number')),
      );
      return;
    }
    
    // TODO: Call wallet-service to gift voucher
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎁 Gift Sent!'),
        content: Text(
          'Your gift has been sent to ${_phoneController.text}\n\n'
          'They will receive an SMS notification with the voucher.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}















