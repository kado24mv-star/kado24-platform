import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';
import '../../utils/auth_error_handler.dart';
import 'create_voucher_screen.dart';
import 'edit_voucher_screen.dart';

class MyVouchersScreen extends StatefulWidget {
  const MyVouchersScreen({Key? key}) : super(key: key);

  @override
  State<MyVouchersScreen> createState() => _MyVouchersScreenState();
}

class _MyVouchersScreenState extends State<MyVouchersScreen> {
  List<dynamic> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;
      
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getVoucherUrl()}/api/v1/vouchers/my-vouchers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _vouchers = responseData['data']['content'] ?? [];
            _isLoading = false;
          });
          return;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Handle authentication errors - redirect to login
        if (mounted) {
          AuthErrorHandler.handleAuthError(context, Exception('${response.statusCode}:Unauthorized - Please login again'));
        }
        return;
      }
      
      setState(() {
        _vouchers = [];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading vouchers: $e');
      
      // Handle authentication errors - redirect to login
      if (AuthErrorHandler.isAuthError(e)) {
        if (mounted) {
          AuthErrorHandler.handleAuthError(context, e);
        }
        return;
      }
      
      setState(() {
        _vouchers = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vouchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateVoucherScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No vouchers yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first voucher to start selling',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVouchers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = _vouchers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
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
                                      voucher['title'] ?? 'Voucher',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(voucher['status']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      voucher['status']?.toString().toUpperCase() ?? 'ACTIVE',
                                      style: TextStyle(
                                        color: _getStatusColor(voucher['status']),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildPriceDisplay(voucher),
                              const SizedBox(height: 8),
                              Text(
                                voucher['description'] ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditVoucherScreen(voucherId: voucher['id']),
                                          ),
                                        );
                                        // Reload vouchers if voucher was updated
                                        if (result == true) {
                                          _loadVouchers();
                                        }
                                      },
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Edit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildActionButton(voucher),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateVoucherScreen()),
          );
          // Reload vouchers if a voucher was created
          if (result == true) {
            _loadVouchers();
          }
        },
        backgroundColor: const Color(0xFF4FACFE),
        label: const Text('Create Voucher', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'PAUSED':
        return Colors.orange;
      case 'DRAFT':
        return Colors.grey;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _canTogglePause(Map<String, dynamic> voucher) {
    final status = voucher['status']?.toString().toUpperCase();
    // Only allow pause/unpause for ACTIVE or PAUSED vouchers
    return status == 'ACTIVE' || status == 'PAUSED';
  }

  Widget _buildActionButton(Map<String, dynamic> voucher) {
    final status = voucher['status']?.toString().toUpperCase();
    
    if (status == 'DRAFT') {
      // Show "Publish" button for DRAFT vouchers
      return OutlinedButton.icon(
        onPressed: () => _publishVoucher(voucher),
        icon: const Icon(Icons.publish, size: 16),
        label: const Text('Publish'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
        ),
      );
    } else if (_canTogglePause(voucher)) {
      // Show "Pause" or "Resume" button for ACTIVE or PAUSED vouchers
      final isPaused = status == 'PAUSED';
      return OutlinedButton.icon(
        onPressed: () => _togglePauseVoucher(voucher),
        icon: Icon(
          isPaused ? Icons.play_arrow : Icons.pause,
          size: 16
        ),
        label: Text(isPaused ? 'Resume' : 'Pause'),
        style: OutlinedButton.styleFrom(
          foregroundColor: isPaused ? Colors.green : Colors.orange,
        ),
      );
    } else {
      // Disabled button for other statuses
      return Tooltip(
        message: 'Only DRAFT, ACTIVE, or PAUSED vouchers can be modified',
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.pause, size: 16),
          label: const Text('Pause'),
        ),
      );
    }
  }

  Future<void> _publishVoucher(Map<String, dynamic> voucher) async {
    final voucherId = voucher['id'];
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Voucher?'),
        content: const Text(
          'This voucher will become active and visible to customers. Make sure all details are correct before publishing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.getVoucherUrl()}/api/v1/vouchers/$voucherId/publish'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher published successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload vouchers to reflect the status change
        _loadVouchers();
      } else {
        String errorMessage = 'Failed to publish voucher';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = 'Failed to publish voucher (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      String errorMessage = 'Failed to publish voucher';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _togglePauseVoucher(Map<String, dynamic> voucher) async {
    final voucherId = voucher['id'];
    final currentStatus = voucher['status']?.toString().toUpperCase();
    final isPaused = currentStatus == 'PAUSED';
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPaused ? 'Resume Voucher?' : 'Pause Voucher?'),
        content: Text(
          isPaused
              ? 'This voucher will become active and visible to customers again.'
              : 'This voucher will be paused and hidden from customers. You can resume it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isPaused ? 'Resume' : 'Pause', style: const TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.getVoucherUrl()}/api/v1/vouchers/$voucherId/toggle-pause'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPaused ? 'Voucher resumed successfully' : 'Voucher paused successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload vouchers to reflect the status change
        _loadVouchers();
      } else {
        String errorMessage = 'Failed to update voucher status';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {
          // If response body is not JSON, use status code message
          errorMessage = 'Failed to update voucher status (${response.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      String errorMessage = 'Failed to update voucher status';
      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildPriceDisplay(Map<String, dynamic> voucher) {
    final denominations = voucher['denominations'];
    
    if (denominations == null || (denominations is List && denominations.isEmpty)) {
      return const Text(
        'No prices set',
        style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }
    
    if (denominations is List) {
      // Convert to list of numbers
      final prices = denominations.map((d) {
        if (d is num) return d.toDouble();
        if (d is String) return double.tryParse(d) ?? 0.0;
        return 0.0;
      }).where((p) => p > 0).toList()..sort();
      
      if (prices.isEmpty) {
        return const Text(
          'No prices set',
          style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
        );
      }
      
      if (prices.length == 1) {
        return Text(
          '\$${prices[0].toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, color: Color(0xFF4FACFE), fontWeight: FontWeight.bold),
        );
      }
      
      // Show range if multiple prices
      final min = prices.first;
      final max = prices.last;
      
      if (min == max) {
        return Text(
          '\$${min.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, color: Color(0xFF4FACFE), fontWeight: FontWeight.bold),
        );
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$${min.toStringAsFixed(2)} - \$${max.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, color: Color(0xFF4FACFE), fontWeight: FontWeight.bold),
          ),
          if (prices.length > 2) ...[
            const SizedBox(height: 4),
            Text(
              'Available: ${prices.map((p) => '\$${p.toStringAsFixed(2)}').join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      );
    }
    
    return const Text(
      'Price information unavailable',
      style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
    );
  }
}



















