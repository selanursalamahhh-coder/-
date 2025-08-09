import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ...existing code...
import '../../db/pembelian_db.dart';
import '../../models/pembelian.dart';
import '../../db/barang_db.dart';
import '../../models/barang.dart';
import '../../db/member_db.dart';
import '../../db/vendor_db.dart';
import '../../models/vendor.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class PembelianScreen extends StatefulWidget {
  const PembelianScreen({Key? key}) : super(key: key);

  @override
  State<PembelianScreen> createState() => _PembelianScreenState();
}

class _PembelianScreenState extends State<PembelianScreen> {
  List<Pembelian> _pembelians = [];
  String _search = '';
  bool _loading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadPembelians();
  }

  Future<void> _loadPembelians() async {
    setState(() => _loading = true);
    try {
      final data = await PembelianDB.instance.getAll(query: _search);
      setState(() {
        _pembelians = data;
        _loading = false;
      });
    } catch (e) {
      if (e.toString().contains('no such table')) {
        try {
          await MemberDB.instance.close();
        } catch (_) {}
        try {
          await BarangDB.instance.close();
        } catch (_) {}
        final dbPath = await getDatabasesPath();
        final path = p.join(dbPath, 'dendahmart.db');
        await deleteDatabase(path);
        try {
          final data = await PembelianDB.instance.getAll(query: _search);
          setState(() {
            _pembelians = data;
            _loading = false;
          });
        } catch (e2) {
          setState(() {
            _errorMsg = 'Gagal inisialisasi database: ' + e2.toString();
            _loading = false;
          });
        }
      } else {
        setState(() {
          _errorMsg = e.toString();
          _loading = false;
        });
      }
    }
    // ...existing code...
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _loadPembelians();
  }

  void _showForm({Pembelian? pembelian}) async {
    final formKey = GlobalKey<FormState>();
    String? selectedVendorName = pembelian?.namaVendor;
    String metodePembayaran = pembelian?.metodePembayaran ?? 'Tunai';
    final items = pembelian?.items ?? <PembelianItem>[];
    final List<PembelianItem> tempItems = List.from(items);
    int total = pembelian?.total ?? 0;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            pembelian == null ? 'Pembelian Baru' : 'Edit Pembelian',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<List<Vendor>>(
                    future: VendorDB.instance.getAll(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      final vendors = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedVendorName,
                        items: vendors
                            .map(
                              (v) => DropdownMenuItem(
                                value: v.nama,
                                child: Text(v.nama),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setStateDialog(() => selectedVendorName = v),
                        decoration: const InputDecoration(labelText: 'Vendor'),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Vendor wajib dipilih'
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: metodePembayaran,
                    items: ['Tunai', 'Non-Tunai']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setStateDialog(() => metodePembayaran = v ?? 'Tunai'),
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Error: ' + _errorMsg!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah Barang'),
                    onPressed: () async {
                      final barangList = await BarangDB.instance.getAll();
                      Barang? selectedBarang;
                      final qtyController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (barangDialogContext) => AlertDialog(
                          title: const Text('Pilih Barang'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonFormField<Barang>(
                                items: barangList
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b.nama),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (b) => selectedBarang = b,
                                decoration: const InputDecoration(
                                  labelText: 'Barang',
                                ),
                              ),
                              TextFormField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(barangDialogContext),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedBarang != null &&
                                    int.tryParse(qtyController.text) != null) {
                                  int qty = int.parse(qtyController.text);
                                  if (qty <= 0) {
                                    setStateDialog(() {
                                      _errorMsg = 'Qty harus lebih dari 0';
                                    });
                                    return;
                                  }
                                  setStateDialog(() {
                                    _errorMsg = null;
                                    tempItems.add(
                                      PembelianItem(
                                        barangId: selectedBarang!.id!,
                                        namaBarang: selectedBarang!.nama,
                                        qty: qty,
                                        harga: selectedBarang!.harga,
                                      ),
                                    );
                                    total = tempItems.fold(
                                      0,
                                      (sum, item) =>
                                          sum + (item.qty * item.harga),
                                    );
                                  });
                                  Navigator.pop(barangDialogContext);
                                }
                              },
                              child: const Text('Tambah'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ...tempItems.map(
                    (item) => ListTile(
                      title: Text(item.namaBarang),
                      subtitle: Text('Qty: ${item.qty} x ${item.harga}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setStateDialog(() {
                            tempItems.remove(item);
                            total = tempItems.fold(
                              0,
                              (sum, i) => sum + (i.qty * i.harga),
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: Rp$total',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (formKey.currentState!.validate() &&
                      tempItems.isNotEmpty) {
                    final now = DateTime.now();
                    final tanggal =
                        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                    final newPembelian = Pembelian(
                      id: pembelian?.id,
                      tanggal: tanggal,
                      namaVendor: selectedVendorName!,
                      metodePembayaran: metodePembayaran,
                      items: tempItems,
                      total: total,
                    );
                    if (pembelian == null) {
                      await PembelianDB.instance.insert(newPembelian);
                    } else {
                      await PembelianDB.instance.update(newPembelian);
                    }
                    if (mounted) Navigator.pop(dialogContext);
                    _loadPembelians();
                  }
                } catch (e) {
                  setStateDialog(() {
                    _errorMsg = e.toString();
                  });
                }
              },
              child: Text(pembelian == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePembelian(int id) async {
    await PembelianDB.instance.delete(id);
    _loadPembelians();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pembelian',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari Nama Vendor',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onChanged: _onSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _pembelians.isEmpty
                  ? const Center(child: Text('Belum ada transaksi pembelian'))
                  : ListView.builder(
                      itemCount: _pembelians.length,
                      itemBuilder: (context, i) {
                        final p = _pembelians[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              'Vendor: ${p.namaVendor}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Tanggal: ${p.tanggal}\nMetode: ${p.metodePembayaran}\nTotal: Rp${p.total}',
                            ),
                            isThreeLine: true,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (detailDialogContext) => AlertDialog(
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
                                      onPressed: () =>
                                          Navigator.pop(detailDialogContext),
                                      child: const Text('Tutup'),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(detailDialogContext);
                                        _deletePembelian(p.id!);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () => _showForm(pembelian: p),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
