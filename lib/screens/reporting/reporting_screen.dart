import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../db/penjualan_db.dart';
import '../../db/pembelian_db.dart';
import '../../models/penjualan.dart';
import '../../models/pembelian.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({Key? key}) : super(key: key);

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<Penjualan> _penjualans = [];
  List<Pembelian> _pembelians = [];
  DateTime? _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _penjualans = await PenjualanDB.instance.getAll();
    _pembelians = await PembelianDB.instance.getAll();
    setState(() => _loading = false);
  }

  List<T> _filterByDate<T>(List<T> data, String Function(T) getTanggal) {
    if (_selectedDate == null) return data;
    final y = _selectedDate!.year.toString().padLeft(4, '0');
    final m = _selectedDate!.month.toString().padLeft(2, '0');
    final d = _selectedDate!.day.toString().padLeft(2, '0');
    return data.where((e) => getTanggal(e).startsWith('$y-$m-$d')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reporting',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Penjualan'),
            Tab(text: 'Pembelian'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Filter tanggal:', style: GoogleFonts.poppins()),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null)
                            setState(() => _selectedDate = picked);
                        },
                        child: Text(
                          _selectedDate == null
                              ? 'Semua'
                              : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _selectedDate = null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab Penjualan
                        _buildRiwayatPenjualan(),
                        // Tab Pembelian
                        _buildRiwayatPembelian(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRiwayatPenjualan() {
    final data = _filterByDate(_penjualans, (p) => p.tanggal);
    int total = data.fold(0, (sum, p) => sum + p.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Penjualan: Rp$total',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: data.isEmpty
              ? const Center(child: Text('Tidak ada data penjualan'))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final p = data[i];
                    return Card(
                      child: ListTile(
                        title: Text('Pelanggan: ${p.namaPelanggan}'),
                        subtitle: Text(
                          'Tanggal: ${p.tanggal}\nTotal: Rp${p.total}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Detail Penjualan',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...p.items.map(
                                    (item) => ListTile(
                                      title: Text(item.namaBarang),
                                      subtitle: Text(
                                        'Qty: ${item.qty} x ${item.harga}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Total: Rp${p.total}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRiwayatPembelian() {
    final data = _filterByDate(_pembelians, (p) => p.tanggal);
    int total = data.fold(0, (sum, p) => sum + p.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Pembelian: Rp$total',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: data.isEmpty
              ? const Center(child: Text('Tidak ada data pembelian'))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final p = data[i];
                    return Card(
                      child: ListTile(
                        title: Text('Vendor: ${p.namaVendor}'),
                        subtitle: Text(
                          'Tanggal: ${p.tanggal}\nTotal: Rp${p.total}',
                        ),
                        isThreeLine: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Detail Pembelian',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...p.items.map(
                                    (item) => ListTile(
                                      title: Text(item.namaBarang),
                                      subtitle: Text(
                                        'Qty: ${item.qty} x ${item.harga}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Total: Rp${p.total}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
