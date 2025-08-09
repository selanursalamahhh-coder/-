import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  static final List<_DashboardMenu> menus = [
    _DashboardMenu('Member', Icons.people, '/member'),
    _DashboardMenu('Barang', Icons.inventory, '/barang'),
    _DashboardMenu('Vendor', Icons.store, '/vendor'),
    _DashboardMenu('Penjualan', Icons.point_of_sale, '/penjualan'),
    _DashboardMenu('Pembelian', Icons.shopping_bag, '/pembelian'),
    _DashboardMenu('Reporting', Icons.bar_chart, '/reporting'),
    _DashboardMenu('Tools', Icons.settings, '/tools'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'dendah.mart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryGreen,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: AppTheme.cream,
        child: Column(
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: menus.length,
                separatorBuilder: (context, i) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  return _DashboardMenuCard(menu: menus[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMenu {
  final String title;
  final IconData icon;
  final String route;
  const _DashboardMenu(this.title, this.icon, this.route);
}

class _DashboardMenuCard extends StatelessWidget {
  final _DashboardMenu menu;
  const _DashboardMenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, menu.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(menu.icon, size: 44, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text(
              menu.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
