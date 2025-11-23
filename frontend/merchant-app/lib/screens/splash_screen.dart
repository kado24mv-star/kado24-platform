import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize auth state from storage
    await authProvider.initAuth();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Navigate based on auth state and role
      if (authProvider.isAuthenticated) {
        // Check user role - only MERCHANT role can access merchant app
        final userData = authProvider.userData;
        final userRole = userData?['role'] as String?;
        
        if (userRole != 'MERCHANT') {
          // Logout and redirect to login if not a merchant
          await authProvider.logout();
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Kado24',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Merchant App',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}























