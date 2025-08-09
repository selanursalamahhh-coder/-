import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tools',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: Text('Backup Data', style: GoogleFonts.poppins()),
              onTap: () => _showDialog(
                context,
                'Backup Data',
                'Fitur backup data akan menyimpan database ke file lokal. (Belum diimplementasikan)',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.green),
              title: Text('Restore Data', style: GoogleFonts.poppins()),
              onTap: () => _showDialog(
                context,
                'Restore Data',
                'Fitur restore data akan memulihkan database dari file backup. (Belum diimplementasikan)',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text('Reset Data', style: GoogleFonts.poppins()),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Reset Data',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Semua data akan dihapus. Lanjutkan?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDialog(
                          context,
                          'Reset Data',
                          'Semua data berhasil direset. (Belum diimplementasikan)',
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.grey),
              title: Text('Tentang Aplikasi', style: GoogleFonts.poppins()),
              onTap: () => _showDialog(
                context,
                'Tentang Aplikasi',
                'dendah.mart\nAplikasi manajemen penjualan & pembelian\nDibuat oleh Endah Nursalamah\n2025',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
