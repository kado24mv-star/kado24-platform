import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({Key? key}) : super(key: key);

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _merchantProfile;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      // Load merchant profile
      final merchantResponse = await http.get(
        Uri.parse('${ApiConfig.getMerchantUrl()}/api/v1/merchants/my-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (merchantResponse.statusCode == 200) {
        final merchantData = jsonDecode(merchantResponse.body);
        if (merchantData['success'] == true && merchantData['data'] != null) {
          setState(() {
            _merchantProfile = merchantData['data'];
          });
        }
      }

      setState(() {
        _userData = authProvider.userData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading team data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTeamData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Team Management',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Currently showing business owner. Staff member management will be available in a future update.',
                                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_merchantProfile != null || _userData != null)
                    _buildMemberCard(
                      _userData?['fullName'] ?? _merchantProfile?['businessName'] ?? 'Business Owner',
                      'Owner',
                      _userData?['phoneNumber'] ?? _merchantProfile?['phoneNumber'] ?? 'N/A',
                      _userData?['email'] ?? _merchantProfile?['email'],
                      true,
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: const Color(0xFF4FACFE),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildMemberCard(String name, String role, String phone, String? email, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4FACFE),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$role • $phone'),
            if (email != null && email.isNotEmpty)
              Text(email, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options menu
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit'),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement edit
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Call'),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement call
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Team Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Staff member management is coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'In the future, you will be able to add staff members who can help process redemptions and manage your business.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
