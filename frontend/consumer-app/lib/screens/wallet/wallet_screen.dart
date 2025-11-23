import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/jwt_util.dart';
import '../../utils/auth_error_handler.dart';
import 'qr_display_screen.dart';

class WalletScreen extends StatefulWidget {
  final bool showAppBar;
  
  const WalletScreen({Key? key, this.showAppBar = true}) : super(key: key);

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
      
      // Check if user is authenticated and has a valid token
      if (!authProvider.isAuthenticated || authProvider.accessToken == null || authProvider.accessToken!.isEmpty) {
        debugPrint('Wallet: User not authenticated or token missing');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      
      // Check if token is expired before making the request
      if (JwtUtil.isExpired(authProvider.accessToken!)) {
        debugPrint('Wallet: Token is expired, redirecting to login');
        await authProvider.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      
      // Debug: Log token details before making request
      final token = authProvider.accessToken!;
      final tokenPreview = token.length > 30 ? '${token.substring(0, 30)}...' : token;
      final payload = JwtUtil.decodePayload(token);
      debugPrint('Wallet: Making request with token: $tokenPreview');
      debugPrint('Wallet: Token payload - userId: ${payload?['userId']}, exp: ${payload?['exp']}');
      debugPrint('Wallet: Token payload keys: ${payload?.keys.toList()}');
      debugPrint('Wallet: Token has "key" claim: ${payload?.containsKey('key')}');
      debugPrint('Wallet: Token isExpired check: ${JwtUtil.isExpired(token)}');
      debugPrint('Wallet: Request URL: ${ApiService.walletServiceUrl}/api/v1/wallet');
      
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
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      // Handle authentication errors (401/403) - redirect to login
      if (AuthErrorHandler.isAuthError(e)) {
        debugPrint('Wallet: Auth error detected, redirecting to login');
        AuthErrorHandler.handleAuthError(context, e);
        return;
      }
      
      // Log other errors
      debugPrint('Error loading vouchers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      indicatorColor: widget.showAppBar ? Colors.white : const Color(0xFF667EEA),
      labelColor: widget.showAppBar ? Colors.white : Colors.white,
      unselectedLabelColor: widget.showAppBar ? Colors.white70 : Colors.white70,
      tabs: [
        Tab(text: 'Active (${activeVouchers.length})'),
        Tab(text: 'Used (${usedVouchers.length})'),
        Tab(text: 'Expired (${expiredVouchers.length})'),
      ],
    );

    final bodyContent = isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildVoucherList(activeVouchers, 'Active'),
              _buildVoucherList(usedVouchers, 'Used'),
              _buildVoucherList(expiredVouchers, 'Expired'),
            ],
          );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Wallet'),
          bottom: tabBar,
        ),
        body: bodyContent,
      );
    } else {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF667EEA),
            child: tabBar,
          ),
          Expanded(child: bodyContent),
        ],
      );
    }
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
































