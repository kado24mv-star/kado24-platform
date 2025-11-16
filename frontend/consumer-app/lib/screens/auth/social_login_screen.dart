import 'package:flutter/material.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_giftcard, size: 100, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    'Kado24',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cambodia Digital Vouchers',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 64),
                  
                  // Facebook Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _loginWithFacebook(context),
                      icon: const Text('f', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      label: const Text('Continue with Facebook', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _loginWithGoogle(context),
                      icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      label: const Text('Continue with Google', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Or',
                    style: TextStyle(color: Colors.white70),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email/Phone Login
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: const Text('Sign in with Email/Phone', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithFacebook(BuildContext context) {
    // TODO: Integrate Facebook SDK
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook login - Coming soon!')),
    );
  }

  void _loginWithGoogle(BuildContext context) {
    // TODO: Integrate Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google login - Coming soon!')),
    );
  }
}















