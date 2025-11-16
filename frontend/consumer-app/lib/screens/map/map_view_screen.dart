import 'package:flutter/material.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Merchants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Placeholder (TODO: Integrate Google Maps)
          Container(
            height: 300,
            color: Colors.grey[300],
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'MAP VIEW',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showing merchants within 5km',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Mock pins
                const Positioned(top: 50, left: 80, child: Text('📍', style: TextStyle(fontSize: 32))),
                const Positioned(top: 120, right: 60, child: Text('📍', style: TextStyle(fontSize: 32))),
                const Positioned(bottom: 60, left: 50, child: Text('📍', style: TextStyle(fontSize: 32))),
              ],
            ),
          ),
          
          // Category Filters
          Container(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('🍽️ Food', true),
                  _buildCategoryChip('💆 Spa', false),
                  _buildCategoryChip('🎭 Entertainment', false),
                  _buildCategoryChip('🛍️ Shopping', false),
                ],
              ),
            ),
          ),
          
          // Nearby Merchants
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Near You',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildMerchantCard('Brown Coffee', '0.8 km', 'Open now', true),
                _buildMerchantCard('Amazon Coffee', '1.2 km', 'Open now', false),
                _buildMerchantCard('Costa Coffee', '2.5 km', 'Closes at 9 PM', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: active,
        selectedColor: const Color(0xFF667EEA),
        labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
        onSelected: (selected) {},
      ),
    );
  }

  Widget _buildMerchantCard(String name, String distance, String status, bool isOpen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF667EEA),
          child: Icon(Icons.store, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$distance • $status'),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            minimumSize: const Size(60, 36),
          ),
          child: const Text('View', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}















