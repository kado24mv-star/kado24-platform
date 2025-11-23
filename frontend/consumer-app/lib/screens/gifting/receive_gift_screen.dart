import 'package:flutter/material.dart';

class ReceiveGiftScreen extends StatelessWidget {
  final Map<String, dynamic> gift;

  const ReceiveGiftScreen({Key? key, required this.gift}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard, size: 80, color: Color(0xFF667EEA)),
                      const SizedBox(height: 24),
                      const Text(
                        'You Got a Gift!',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          children: [
                            Text(
                              gift['merchantName'] ?? 'Merchant',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${gift['amount'] ?? '0.00'}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF667EEA)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'From: ${gift['senderPhone'] ?? 'Anonymous'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            if (gift['message'] != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                '"${gift['message']}"',
                                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Accept gift
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gift added to your wallet!')),
                            );
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Accept & Add to Wallet', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Decline Gift'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


































