import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../config/api_config.dart';
import '../../providers/auth_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Voucher QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _handleQRCode(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          
          // Scan area overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black54,
              child: const Text(
                'Point camera at customer QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQRCode(String code) async {
    setState(() {
      isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('No authentication token');
      }

      // Call redemption service to redeem voucher
      final response = await http.post(
        Uri.parse('${ApiConfig.getRedemptionUrl()}/api/v1/redemptions/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'voucherCode': code,
          'amount': 0, // Amount will be determined by voucher
          'location': 'Mobile App',
        }),
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final redemptionData = responseData['data'];
          
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('Redemption Successful'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Voucher: ${redemptionData['voucherTitle'] ?? code}'),
                  const SizedBox(height: 8),
                  Text('Amount: \$${redemptionData['amount']?.toStringAsFixed(2) ?? '0.00'}', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4FACFE)),
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: User ${redemptionData['userId'] ?? 'N/A'}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => isProcessing = false);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Redemption failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}























