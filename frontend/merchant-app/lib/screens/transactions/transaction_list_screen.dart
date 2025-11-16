import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterButton('All', true),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('Today', false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('This Week', false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterButton('This Month', false),
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10, // TODO: Load from API
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      child: const Icon(Icons.check_circle, color: Colors.green),
                    ),
                    title: const Text('Coffee Voucher \$15', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Redeemed', style: TextStyle(fontSize: 12)),
                        Text(
                          DateFormat('MMM d, h:mm a').format(DateTime.now().subtract(Duration(hours: index))),
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('\$15.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Commission: \$1.20', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                    onTap: () {
                      // Show transaction details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool active) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF4FACFE) : Colors.grey[200],
        foregroundColor: active ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}















