import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'guards/auth_guard.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/scanner/qr_scanner_screen.dart';
import 'screens/vouchers/my_vouchers_screen.dart';
import 'screens/vouchers/create_voucher_screen.dart';
import 'screens/sales/sales_dashboard_screen.dart';
import 'screens/payouts/payout_screen.dart';
import 'screens/status/pending_approval_screen.dart';
import 'screens/profile/business_profile_screen.dart';
import 'screens/transactions/transaction_list_screen.dart';

void main() {
  runApp(const Kado24MerchantApp());
}

class Kado24MerchantApp extends StatelessWidget {
  const Kado24MerchantApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Kado24 Merchant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF4FACFE),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4FACFE),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const AuthGuard(child: DashboardScreen()),
          '/pending-approval': (context) => const AuthGuard(child: PendingApprovalScreen()),
          '/qr-scanner': (context) => const AuthGuard(child: QRScannerScreen()),
          '/my-vouchers': (context) => const AuthGuard(child: MyVouchersScreen()),
          '/create-voucher': (context) => const AuthGuard(child: CreateVoucherScreen()),
          '/sales': (context) => const AuthGuard(child: SalesDashboardScreen()),
          '/payouts': (context) => const AuthGuard(child: PayoutScreen()),
          '/profile': (context) => const AuthGuard(child: BusinessProfileScreen()),
          '/transactions': (context) => const AuthGuard(child: TransactionListScreen()),
        },
      ),
    );
  }
}
