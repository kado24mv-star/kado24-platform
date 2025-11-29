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
        // Registration failed - show error popup and stop execution
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
        
        // Throw exception to be caught by catch block - this will show error popup and stop execution
        throw Exception(errorMessage);
      }

      // Step 3: User registration successful - show OTP verification popup
      // Only reach here if registration was successful (200 or 201)
      final userData = jsonDecode(userResponse.body);
      
      // After successful registration, OTP verification is typically required
      // Show OTP popup dialog immediately
      if (mounted) {
        setState(() => _isLoading = false);
        _showOTPVerificationDialog(phone);
        return; // Exit early, OTP dialog will handle merchant registration after verification
      }
      
      // Note: The OTP dialog will handle merchant registration after OTP verification
      // The code below is a fallback in case OTP dialog doesn't handle it
      // But typically, we show OTP dialog and return early, so this won't execute
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show error as popup dialog instead of SnackBar
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registration Failed',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: If this phone number is already registered, please try logging in instead.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (e.toString().contains('already registered') || 
                  e.toString().contains('Phone number'))
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4FACFE),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    }
  }

  void _showOTPVerificationDialog(String phoneNumber) {
    final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
    final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
    int resendTimer = 45;
    bool isVerifying = false;

    void startResendTimer() {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && resendTimer > 0) {
          resendTimer--;
          return true;
        }
        return false;
      });
    }

    startResendTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.phone_android, color: Color(0xFF4FACFE), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verify Phone Number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter the 6-digit code sent to',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4FACFE),
                  ),
                ),
                const SizedBox(height: 24),
                // OTP Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      height: 55,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4FACFE),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                          if (index == 5 && value.isNotEmpty) {
                            _verifyOTPInDialog(
                              dialogContext,
                              otpControllers.map((c) => c.text).join(),
                              phoneNumber,
                            );
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive code? ", 
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    if (resendTimer > 0)
                      Text('Resend (${resendTimer}s)', 
                        style: TextStyle(color: Colors.grey[400], fontSize: 12))
                    else
                      InkWell(
                        onTap: () {
                          _resendOTP(phoneNumber);
                          setDialogState(() {
                            resendTimer = 45;
                            startResendTimer();
                          });
                        },
                        child: const Text(
                          'Resend',
                          style: TextStyle(
                            color: Color(0xFF4FACFE),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Skip for now'),
            ),
            ElevatedButton(
              onPressed: isVerifying
                  ? null
                  : () {
                      final otp = otpControllers.map((c) => c.text).join();
                      if (otp.length == 6) {
                        _verifyOTPInDialog(dialogContext, otp, phoneNumber);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FACFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOTPInDialog(
    BuildContext dialogContext,
    String otp,
    String phoneNumber,
  ) async {
    try {
      // Call OTP verification API
      final response = await http.post(
        Uri.parse('${ApiConfig.getAuthUrl()}/api/v1/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otpCode': otp,  // Fixed: changed from 'otp' to 'otpCode'
          'purpose': 'REGISTRATION',  // Added purpose for registration
        }),
      );

      if (response.statusCode == 200) {
        // OTP verified successfully - tokens are included in response
        final responseData = jsonDecode(response.body);
        final token = responseData['data']['accessToken'];
        
        if (mounted) {
          Navigator.of(dialogContext).pop();
          // Continue with merchant registration using tokens from verify-otp
          _continueMerchantRegistrationAfterOTP(phoneNumber, token);
        }
      } else {
        // OTP verification failed
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Invalid OTP. Please try again.';
        
        if (errorData['error'] != null && errorData['error']['message'] != null) {
          errorMessage = errorData['error']['message'];
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _continueMerchantRegistrationAfterOTP(String phoneNumber, String token) async {
    // After OTP verification, continue with merchant registration
    // Token is already provided from verify-otp response, no need to login again
    setState(() => _isLoading = true);
    
    try {
      // Continue with merchant registration using token from verify-otp
      await _registerMerchant(token, phoneNumber);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to continue registration: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _registerMerchant(String token, String phoneNumber) async {
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
        'phoneNumber': phoneNumber,
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
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
        // Show success dialog
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
                    Navigator.pop(dialogContext);
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
  }

  Future<void> _resendOTP(String phoneNumber) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.getAuthUrl()}/api/v1/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'purpose': 'REGISTRATION',
        }),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString()}'),
            backgroundColor: Colors.red,
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



















