import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Utility class to handle authentication errors (401/403)
/// Redirects to login screen when authentication fails
class AuthErrorHandler {
  /// Handle authentication errors and redirect to login
  static void handleAuthError(BuildContext context, dynamic error) {
    final errorStr = error.toString();
    
    // Check for 401 or 403 errors
    if (errorStr.contains('401') || errorStr.contains('403') || 
        errorStr.contains('Unauthorized') || errorStr.contains('Forbidden')) {
      
      // Clear auth state
      final authProvider = context.read<AuthProvider>();
      authProvider.logout();
      
      // Navigate to login (remove all previous routes)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false, // Remove all previous routes
          );
        }
      });
    }
  }
  
  /// Check if error is an auth error
  static bool isAuthError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('401') || 
           errorStr.contains('403') || 
           errorStr.contains('Unauthorized') || 
           errorStr.contains('Forbidden');
  }
}

