import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class DisputeListScreen extends StatefulWidget {
  const DisputeListScreen({Key? key}) : super(key: key);

  @override
  State<DisputeListScreen> createState() => _DisputeListScreenState();
}

class _DisputeListScreenState extends State<DisputeListScreen> {
  List<dynamic> _disputes = [];
  List<dynamic> _resolvedDisputes = [];
  bool _isLoading = true;
  String _selectedTab = 'Active';

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      // Get merchant redemptions and filter for disputes
      final response = await http.get(
        Uri.parse('${ApiConfig.getRedemptionUrl()}/api/v1/redemptions/my-redemptions?page=0&size=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final allRedemptions = responseData['data']['content'] ?? [];
          
          // Filter for disputed redemptions
          final disputes = allRedemptions.where((r) => 
            r['status']?.toString().toUpperCase() == 'DISPUTED' ||
            r['status']?.toString().toUpperCase() == 'PENDING'
          ).toList();
          
          final resolved = allRedemptions.where((r) => 
            r['status']?.toString().toUpperCase() != 'DISPUTED' &&
            r['status']?.toString().toUpperCase() != 'PENDING'
          ).toList();

          setState(() {
            _disputes = disputes;
            _resolvedDisputes = resolved;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _disputes = [];
        _resolvedDisputes = [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading disputes: $e');
      setState(() {
        _disputes = [];
        _resolvedDisputes = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDisputes = _selectedTab == 'Active' ? _disputes : _resolvedDisputes;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Active (${_disputes.length})',
                    _selectedTab == 'Active',
                    () => setState(() => _selectedTab = 'Active'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    'Resolved (${_resolvedDisputes.length})',
                    _selectedTab == 'Resolved',
                    () => setState(() => _selectedTab = 'Resolved'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentDisputes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gavel, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_selectedTab.toLowerCase()} disputes',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDisputes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: currentDisputes.length,
                          itemBuilder: (context, index) {
                            final dispute = currentDisputes[index];
                            return _buildDisputeCard(dispute);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF4FACFE) : Colors.grey[200],
        foregroundColor: active ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildDisputeCard(Map<String, dynamic> dispute) {
    final status = dispute['status']?.toString().toUpperCase() ?? 'PENDING';
    final isUrgent = status == 'DISPUTED';
    final statusColor = isUrgent ? Colors.red : Colors.orange;
    
    String disputeId = dispute['id']?.toString() ?? 'N/A';
    String issue = dispute['notes'] ?? 'No description';
    String voucherTitle = dispute['voucherTitle'] ?? 'Voucher';
    String amount = '\$${dispute['amount']?.toStringAsFixed(2) ?? '0.00'}';
    
    String dateStr = 'Recently';
    if (dispute['createdAt'] != null) {
      try {
        final date = DateTime.parse(dispute['createdAt']);
        dateStr = DateFormat('MMM d, yyyy').format(date);
      } catch (e) {
        dateStr = 'Recently';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: statusColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dispute #$disputeId', style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(issue, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Voucher: $voucherTitle ($amount)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Filed: $dateStr', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement dispute response
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Dispute response feature coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FACFE)),
                child: const Text('Respond Now', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
