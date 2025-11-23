import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/jwt_util.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    // Initialize controllers with existing user data from AuthProvider
    // Don't make API calls on init - this prevents 401 errors and redirects
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    
    // Set loading to false immediately - no API calls needed
    _isLoading = false;
  }

  // This method is no longer used - we use data from AuthProvider directly
  // Keeping it for potential future use if needed
  Future<void> _loadUserProfile() async {
    // Not used anymore - profile data comes from AuthProvider
    // This prevents unnecessary API calls and authentication errors
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    
    // Check authentication before saving
    if (authProvider.accessToken == null || authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to update your profile'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Validate token format and check for userId claim
    final token = authProvider.accessToken;
    if (token == null || token.isEmpty || !token.startsWith('eyJ')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid session. Please login again.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Check if token has userId claim
    if (!JwtUtil.hasUserId(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your session token is outdated. Please logout and login again.'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange[700],
          action: SnackBarAction(
            label: 'Logout & Login',
            textColor: Colors.white,
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ),
      );
      return;
    }
    
    // Check if token is expired
    if (JwtUtil.isExpired(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          duration: Duration(seconds: 3),
        ),
      );
      // Auto-logout on expired token
      context.read<AuthProvider>().logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final response = await ApiService().put(
        ApiConfig.userUpdate,
        {
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim().isNotEmpty 
              ? _emailController.text.trim() 
              : null,
        },
        token: authProvider.accessToken,
        baseUrlOverride: ApiConfig.userServiceUrl,
      );

      if (response['success'] && mounted) {
        // Update user in AuthProvider
        final updatedUser = response['data'];
        if (updatedUser != null) {
          // Update user data directly
          await authProvider.updateUser(updatedUser);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        final errorMsg = errorStr.toLowerCase();
        
        // Check if it's a 401 error by looking at the status code
        final is401Error = errorStr.contains('401:') || 
                         (errorMsg.contains('401') && errorMsg.contains('unauthorized'));
        
        if (is401Error) {
          // Extract the actual error message if available
          String displayMessage = 'Unable to save. Please try logging in again.';
          if (errorStr.contains(':')) {
            final parts = errorStr.split(':');
            if (parts.length > 1) {
              final actualMsg = parts.sublist(1).join(':').trim();
              if (actualMsg.isNotEmpty && 
                  !actualMsg.toLowerCase().contains('unauthorized') &&
                  !actualMsg.toLowerCase().contains('please login')) {
                displayMessage = actualMsg;
              }
            }
          }
          
          // Show a less persistent error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange[700],
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Login',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
              ),
            ),
          );
        } else {
          // For other errors, show appropriate message
          String displayMsg;
          if (errorMsg.contains('network error')) {
            displayMsg = 'Network error. Please check your connection and try again.';
          } else if (errorStr.contains(':')) {
            // Try to extract meaningful error message
            final parts = errorStr.split(':');
            if (parts.length > 1) {
              displayMsg = parts.sublist(1).join(':').trim();
              if (displayMsg.isEmpty) {
                displayMsg = 'Failed to update profile. Please try again.';
              }
            } else {
              displayMsg = 'Failed to update profile. Please try again.';
            }
          } else {
            displayMsg = 'Failed to update profile. Please try again.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMsg),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF667EEA),
                  backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                      ? Text(
                          (user?.fullName != null && user!.fullName.isNotEmpty)
                              ? user.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo upload coming soon')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: const Icon(Icons.lock, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'Phone number cannot be changed',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}





























