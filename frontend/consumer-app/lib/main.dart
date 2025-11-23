import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/voucher_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/social_login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/support/help_center_screen.dart';
import 'screens/debug/token_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Kado24App());
}

class Kado24App extends StatelessWidget {
  const Kado24App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        title: 'Kado24 Cambodia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: const Color(0xFF667EEA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667EEA),
            secondary: const Color(0xFF764BA2),
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/social-login': (context) => const SocialLoginScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpCenterScreen(),
        },
        onGenerateRoute: (settings) {
          // Handle debug routes
          if (settings.name == '/debug/tokens') {
            return MaterialPageRoute(
              builder: (context) => const TokenVerificationScreen(),
            );
          }
          // Default to home if route not found
          return MaterialPageRoute(
            builder: (context) => const SplashScreen(),
          );
        },
      ),
    );
  }
}
