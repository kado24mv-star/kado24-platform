import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Saved Payment Methods',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentCard(
            '🏦',
            'ABA PayWay',
            '**** 1234',
            true,
          ),
          _buildPaymentCard(
            '🦅',
            'Wing Money',
            '+855 ** *** 678',
            false,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add New Payment Method'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String emoji, String name, String detail, bool isDefault) {
    return Card(
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 32)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(detail),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}


































