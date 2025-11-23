import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Wait for auth initialization
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if authenticated
        if (!authProvider.isAuthenticated) {
          // Redirect to login after frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Validate user role - only MERCHANT role can access merchant app
        final userData = authProvider.userData;
        final userRole = userData?['role'] as String?;
        
        if (userRole != 'MERCHANT') {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await authProvider.logout();
            if (context.mounted) {
              // Show popup dialog for 10 seconds
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 28),
                        SizedBox(width: 8),
                        Text('Access Denied'),
                      ],
                    ),
                    content: const Text(
                      'This app is for merchants only. Please use the consumer app to access your account.',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
              
              // Auto-close dialog after 10 seconds and redirect to login
              Future.delayed(const Duration(seconds: 10), () {
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              });
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated and has MERCHANT role, show the protected screen
        return child;
      },
    );
  }
}

