import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/member/member_screen.dart';
import 'screens/barang/barang_screen.dart';
import 'screens/vendor/vendor_screen.dart';
import 'screens/penjualan/penjualan_screen.dart';
import 'screens/pembelian/pembelian_screen.dart';
import 'screens/reporting/reporting_screen.dart';
import 'screens/tools/tools_screen.dart';

void main() {
  runApp(const DendahMartApp());
}

class DendahMartApp extends StatelessWidget {
  const DendahMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dendah.mart',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/member': (context) => const MemberScreen(),
        '/barang': (context) => const BarangScreen(),
        '/vendor': (context) => const VendorScreen(),
        '/penjualan': (context) => const PenjualanScreen(),
        '/pembelian': (context) => const PembelianScreen(),
        '/reporting': (context) => const ReportingScreen(),
        '/tools': (context) => const ToolsScreen(),
      },
    );
  }
}
