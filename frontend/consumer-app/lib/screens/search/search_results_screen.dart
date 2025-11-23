import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../widgets/voucher_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  
  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  String _sortBy = 'Popular';
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VoucherProvider>().searchVouchers(widget.query, context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: "${widget.query}"'),
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Sort/Filter Bar
              Container(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Sort: $_sortBy', () => _showSortOptions()),
                      const SizedBox(width: 8),
                      _buildFilterChip('Price', () {}),
                      const SizedBox(width: 8),
                      _buildFilterChip('Distance', () {}),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rating', () {}),
                    ],
                  ),
                ),
              ),
              
              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Found ${provider.vouchers.length} vouchers',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ),
              
              // Results List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.vouchers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text('No vouchers found'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.vouchers.length,
                            itemBuilder: (context, index) {
                              final voucher = provider.vouchers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.card_giftcard),
                                  ),
                                  title: Text(voucher.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.amber),
                                          Text(' ${voucher.rating?.toStringAsFixed(1) ?? 'N/A'}'),
                                          Text(' (${voucher.totalReviews ?? 0})'),
                                        ],
                                      ),
                                      if (voucher.denominations.isNotEmpty)
                                        Text('\$${voucher.denominations.first.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/voucher-detail',
                                      arguments: voucher,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF667EEA)),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Most Popular'),
              leading: Radio(value: 'Popular', groupValue: _sortBy, onChanged: (v) => _updateSort(v as String)),
            ),
            ListTile(
              title: const Text('Price: Low to High'),
              leading: Radio(value: 'Price Low', groupValue: _sortBy, onChanged: (v) => _updateSort(v as String)),
            ),
            ListTile(
              title: const Text('Price: High to Low'),
              leading: Radio(value: 'Price High', groupValue: _sortBy, onChanged: (v) => _updateSort(v as String)),
            ),
            ListTile(
              title: const Text('Highest Rated'),
              leading: Radio(value: 'Rating', groupValue: _sortBy, onChanged: (v) => _updateSort(v as String)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSort(String sort) {
    setState(() => _sortBy = sort);
    Navigator.pop(context);
  }

}





















