import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../utils/phone_util.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({Key? key}) : super(key: key);

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Registration'),
        backgroundColor: const Color(0xFF4FACFE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Become a Merchant Partner',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sell digital vouchers to thousands of customers',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              
              const SizedBox(height: 32),
              
              // Business Name
              const Text('Business Name *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _businessNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Brown Coffee Phnom Penh',
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Business Type
              const Text('Business Type *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(
                  hintText: 'Select business type',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Restaurant', child: Text('Restaurant/Cafe')),
                  DropdownMenuItem(value: 'Spa', child: Text('Spa/Salon')),
                  DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
                  DropdownMenuItem(value: 'Shopping', child: Text('Shopping/Retail')),
                  DropdownMenuItem(value: 'Hotel', child: Text('Hotel/Resort')),
                  DropdownMenuItem(value: 'Other', child: Text('Other Services')),
                ],
                onChanged: (value) {
                  _businessTypeController.text = value ?? '';
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Phone Number
              const Text('Phone Number *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: '+855 12 345 678',
                  helperText: 'Format: +855 followed by 8-9 digits',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (!PhoneUtil.isValid(v!)) {
                    return 'Phone must be in format 0XXXXXXXX or +855XXXXXXXX';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email
              const Text('Email *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'business@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Business License
              const Text('Business License Number *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseController,
                decoration: InputDecoration(
                  hintText: 'BL-XXXXX',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Password
              const Text('Password *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'e.g., MyPassword123',
                  helperText: 'Min 8 chars, include uppercase, lowercase & digit',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (v) {
                  if ((v?.length ?? 0) < 8) return 'Min 8 characters required';
                  if (!RegExp(r'(?=.*[a-z])').hasMatch(v!)) return 'Must have lowercase';
                  if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) return 'Must have uppercase';
                  if (!RegExp(r'(?=.*\d)').hasMatch(v)) return 'Must have digit';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Terms
              Row(
                children: [
                  Checkbox(value: true, onChanged: (v) {}),
                  Expanded(
                    child: Text(
                      'I agree to Terms of Service and understand that my application will be reviewed by admin',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FACFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Validate and normalize phone number
      String? phone = PhoneUtil.normalize(_phoneController.text);
      if (phone == null) {
        throw Exception('Invalid phone number format. Use 0XXXXXXXX or +855XXXXXXXX');
      }
      
      // Step 2: Validate password
      String password = _passwordController.text;
      if (password.length < 8) {
        throw Exception('Password must be at least 8 characters long');
      }
      if (!RegExp(r'[a-z]').hasMatch(password)) {
        throw Exception('Password must contain at least one lowercase letter');
      }
      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        throw Exception('Password must contain at least one UPPERCASE letter');
      }
      if (!RegExp(r'\d').hasMatch(password)) {
        throw Exception('Password must contain at least one digit (0-9)');
      }

      // Step 3: Register user account
      final registerData = {
        'fullName': _businessNameController.text.trim(),
        'phoneNumber': phone,
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'password': password,
        'role': 'MERCHANT',
      };
      
      debugPrint('Registering with phone: $phone');
      
      final userResponse = await http.post(
        Uri.parse('${ApiConfig.getAuthUrl()}/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerData),
      );

      if (userResponse.statusCode != 201 && userResponse.statusCode != 200) {
        final errorData = jsonDecode(userResponse.body);
        String errorMessage = 'Registration failed';
        
        // Extract error message from API response
        if (errorData['error'] != null) {
          if (errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'];
          } else if (errorData['error']['details'] != null) {
            final details = errorData['error']['details'];
            if (details is Map<String, dynamic>) {
              errorMessage = details.values.join('\n');
            } else {
              errorMessage = details.toString();
            }
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
        
        // Special handling for 409 Conflict (user already exists)
        if (userResponse.statusCode == 409) {
          errorMessage = '$errorMessage\n\nThis phone number or email is already registered. Please try logging in instead.';
        }
        
        throw Exception(errorMessage);
      }

      // Step 3: Extract token from registration response (registration returns tokens directly)
      final userData = jsonDecode(userResponse.body);
      String? token;
      
      if (userData['data'] != null && userData['data']['accessToken'] != null) {
        token = userData['data']['accessToken'];
      } else {
        // If registration doesn't return token, try to login
        // Note: Login may fail for PENDING_VERIFICATION accounts, so we'll handle that
        try {
          final loginResponse = await http.post(
            Uri.parse('${ApiConfig.getAuthUrl()}/api/v1/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': phone,
              'password': password,
            }),
          );

          if (loginResponse.statusCode == 200) {
            final loginData = jsonDecode(loginResponse.body);
            token = loginData['data']['accessToken'];
          } else {
            // Login failed - account might be pending verification
            // But we can still try merchant registration if we have a token from registration
            final errorData = jsonDecode(loginResponse.body);
            String errorMessage = errorData['error']?['message'] ?? errorData['message'] ?? 'Login failed';
            
            if (errorMessage.contains('not active') || errorMessage.contains('PENDING')) {
              // Account is pending, but registration should have returned a token
              // If not, we'll show an error
              throw Exception('Registration successful, but account is pending approval. Please wait for admin approval before completing merchant registration.');
            } else {
              throw Exception('Login failed: $errorMessage');
            }
          }
        } catch (e) {
          // If login fails and we don't have a token from registration, throw error
          if (token == null) {
            rethrow;
          }
          // Otherwise, continue with token from registration
        }
      }
      
      if (token == null) {
        throw Exception('Failed to obtain access token. Please try again.');
      }

      // Step 4: Register as merchant
      final merchantResponse = await http.post(
        Uri.parse('${ApiConfig.getMerchantUrl()}/api/v1/merchants/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'businessName': _businessNameController.text.trim(),
          'businessType': _businessTypeController.text.trim(),
          'businessLicense': _licenseController.text.trim().isEmpty 
              ? 'LIC-${DateTime.now().millisecondsSinceEpoch}' 
              : _licenseController.text.trim(),
          'taxId': 'TAX-${DateTime.now().millisecondsSinceEpoch}',
          'phoneNumber': phone,
          'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          'description': 'Merchant registered via web app',
          'addressLine1': '123 Main Street',
          'city': 'Phnom Penh',
          'province': 'Phnom Penh',
          'bankName': 'ABA Bank',
          'bankAccountNumber': '000000000',
          'bankAccountName': _businessNameController.text.trim(),
        }),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (merchantResponse.statusCode == 201 || merchantResponse.statusCode == 200) {
          // Show success dialog and navigate to login
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: const Text('✓ Application Submitted'),
                content: const Text(
                  'Your merchant application has been successfully submitted!\n\n'
                  'Our admin team will review your application within 24-48 hours.\n\n'
                  'You can now login and will see a pending approval status.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext); // Close dialog
                      // Navigate to login page using pushReplacementNamed to ensure clean navigation
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          throw Exception('Merchant registration failed: ${merchantResponse.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}



















