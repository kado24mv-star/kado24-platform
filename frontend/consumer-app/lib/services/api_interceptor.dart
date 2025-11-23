import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Global error handler for API responses
/// Redirects to login on 401/403 errors
class ApiInterceptor {
  static void handleAuthError(BuildContext? context, dynamic error) {
    final errorStr = error.toString();
    
    // Check for 401 or 403 errors
    if (errorStr.contains('401') || errorStr.contains('403') || 
        errorStr.contains('Unauthorized') || errorStr.contains('Forbidden')) {
      
      // Clear auth state
      if (context != null) {
        final authProvider = context.read<AuthProvider>();
        authProvider.logout();
        
        // Navigate to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false, // Remove all previous routes
          );
        });
      }
    }
  }
}

