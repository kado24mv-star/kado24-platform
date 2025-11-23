import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '🔍 Search for help...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Popular Topics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            _buildHelpTopic(
              context,
              '📱',
              'How to redeem vouchers?',
              'Step-by-step guide',
            ),
            _buildHelpTopic(
              context,
              '💳',
              'Payment issues',
              'Troubleshooting payments',
            ),
            _buildHelpTopic(
              context,
              '🎁',
              'Gifting vouchers',
              'How to send gifts',
            ),
            _buildHelpTopic(
              context,
              '🔄',
              'Refund policy',
              'Returns and refunds',
            ),
            _buildHelpTopic(
              context,
              '❓',
              'General FAQ',
              'Common questions',
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open live chat
                },
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text('Chat with Support', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Open ticket form
                },
                icon: const Icon(Icons.email),
                label: const Text('Submit a Ticket'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF667EEA),
                  side: const BorderSide(color: Color(0xFF667EEA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTopic(BuildContext context, String emoji, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Show help article
        },
      ),
    );
  }
}


































