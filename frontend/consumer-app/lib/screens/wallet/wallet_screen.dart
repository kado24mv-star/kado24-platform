import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'qr_display_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> activeVouchers = [];
  List<dynamic> usedVouchers = [];
  List<dynamic> expiredVouchers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await ApiService().get(
        '/api/v1/wallet',
        token: authProvider.accessToken,
        baseUrlOverride: ApiService.walletServiceUrl,
      );

      if (response['success']) {
        final vouchers = response['data']['content'] as List;
        
        setState(() {
          activeVouchers = vouchers.where((v) => v['status'] == 'ACTIVE').toList();
          usedVouchers = vouchers.where((v) => v['status'] == 'USED').toList();
          expiredVouchers = vouchers.where((v) => v['status'] == 'EXPIRED').toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Active (${activeVouchers.length})'),
            Tab(text: 'Used (${usedVouchers.length})'),
            Tab(text: 'Expired (${expiredVouchers.length})'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVoucherList(activeVouchers, 'Active'),
                _buildVoucherList(usedVouchers, 'Used'),
                _buildVoucherList(expiredVouchers, 'Expired'),
              ],
            ),
    );
  }

  Widget _buildVoucherList(List<dynamic> vouchers, String status) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No $status Vouchers',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVouchers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          final isActive = status == 'Active';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? Colors.green : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: InkWell(
              onTap: isActive
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QRDisplayScreen(
                            voucherCode: voucher['voucherCode'] ?? 'SAMPLE-CODE',
                            amount: voucher['denomination']?.toDouble() ?? 0.0,
                            merchantName: voucher['merchantName'] ?? 'Merchant',
                            validUntil: voucher['validUntil'] ?? '',
                          ),
                        ),
                      );
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            voucher['voucherTitle'] ?? 'Voucher',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voucher['merchantName'] ?? 'Merchant',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${voucher['denomination']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                        if (isActive)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QRDisplayScreen(
                                    voucherCode: voucher['voucherCode'] ?? 'SAMPLE-CODE',
                                    amount: voucher['denomination']?.toDouble() ?? 0.0,
                                    merchantName: voucher['merchantName'] ?? 'Merchant',
                                    validUntil: voucher['validUntil'] ?? '',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.qr_code, size: 20, color: Colors.white),
                            label: const Text('Use Now', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Valid until: ${voucher['validUntil'] ?? 'N/A'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}


















