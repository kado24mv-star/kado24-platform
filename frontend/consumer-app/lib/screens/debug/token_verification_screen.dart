import 'package:flutter/material.dart';
import '../../utils/token_verifier.dart';

/// Debug screen to verify token storage
class TokenVerificationScreen extends StatefulWidget {
  const TokenVerificationScreen({Key? key}) : super(key: key);

  @override
  State<TokenVerificationScreen> createState() => _TokenVerificationScreenState();
}

class _TokenVerificationScreenState extends State<TokenVerificationScreen> {
  Map<String, dynamic>? _verificationResults;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verifyTokens();
  }

  Future<void> _verifyTokens() async {
    setState(() {
      _isLoading = true;
    });

    final results = await TokenVerifier.verifyTokenStorage();
    
    setState(() {
      _verificationResults = results;
      _isLoading = false;
    });
    
    // Also print to console
    await TokenVerifier.printVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _verifyTokens,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _verificationResults == null
              ? const Center(child: Text('No verification results'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('Access Token', _verificationResults!['accessToken']),
                      const SizedBox(height: 16),
                      _buildSection('Refresh Token', _verificationResults!['refreshToken']),
                      const SizedBox(height: 16),
                      _buildSection('User Data', _verificationResults!['user']),
                      const SizedBox(height: 16),
                      _buildOverallStatus(_verificationResults!['overall']),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...data.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: _getValueColor(entry.key, entry.value),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatus(Map<String, dynamic> overall) {
    final isAuthenticated = overall['isAuthenticated'] == true;
    
    return Card(
      color: isAuthenticated ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAuthenticated ? Icons.check_circle : Icons.error,
                  color: isAuthenticated ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Overall Status',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAuthenticated 
                  ? '✅ User is authenticated and tokens are valid'
                  : '❌ User is not authenticated or tokens are invalid',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isAuthenticated ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            ...overall.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        entry.value == true ? Icons.check : Icons.close,
                        size: 16,
                        color: entry.value == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(entry.key),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getValueColor(String key, dynamic value) {
    if (key == 'exists' || key == 'isValid' || key == 'hasUserId') {
      return value == true ? Colors.green : Colors.red;
    }
    if (key == 'isExpired') {
      return value == true ? Colors.red : Colors.green;
    }
    return Colors.black87;
  }
}

