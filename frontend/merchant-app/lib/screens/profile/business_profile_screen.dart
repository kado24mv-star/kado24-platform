import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _merchantProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.getMerchantUrl()}/api/v1/merchants/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            _merchantProfile = responseData['data'];
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _merchantProfile = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
      setState(() {
        _merchantProfile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile screen when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile editing feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _merchantProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No merchant profile found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please complete merchant registration',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                            ),
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.store, size: 50, color: Color(0xFF4FACFE)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _merchantProfile!['businessName'] ?? 'Business',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_merchantProfile!['verificationStatus']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _merchantProfile!['verificationStatus']?.toString().toUpperCase() ?? 'PENDING',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Business Info
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Business Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildInfoCard('Business Type', _merchantProfile!['businessType'] ?? 'N/A'),
                              _buildInfoCard('Phone', _merchantProfile!['phoneNumber'] ?? 'N/A'),
                              _buildInfoCard('Email', _merchantProfile!['email'] ?? 'N/A'),
                              _buildInfoCard('Address', '${_merchantProfile!['address'] ?? ''}, ${_merchantProfile!['city'] ?? ''}'),
                              _buildInfoCard('Tax ID', _merchantProfile!['taxId'] ?? 'N/A'),
                              
                              const SizedBox(height: 24),
                              const Text('Bank Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildInfoCard('Bank', _merchantProfile!['bankName'] ?? 'N/A'),
                              _buildInfoCard('Account Number', _merchantProfile!['bankAccountNumber'] ?? 'N/A'),
                              _buildInfoCard('Account Name', _merchantProfile!['bankAccountName'] ?? 'N/A'),
                  
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit Profile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}



















