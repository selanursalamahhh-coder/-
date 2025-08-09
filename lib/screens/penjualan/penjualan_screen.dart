import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/penjualan_db.dart';
import '../../models/penjualan.dart';

import '../../db/barang_db.dart';
import '../../models/barang.dart';
import '../../db/member_db.dart';
import '../../models/member.dart';

class PenjualanScreen extends StatefulWidget {
  const PenjualanScreen({Key? key}) : super(key: key);

  @override
  State<PenjualanScreen> createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  List<Penjualan> _penjualans = [];
  String _search = '';
  bool _loading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadPenjualans();
  }

  Future<void> _loadPenjualans() async {
    setState(() => _loading = true);
    final data = await PenjualanDB.instance.getAll(query: _search);
    setState(() {
      _penjualans = data;
      _loading = false;
    });
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _loadPenjualans();
  }

  void _showForm({Penjualan? penjualan}) async {
    final formKey = GlobalKey<FormState>();
    List<Member> members = await MemberDB.instance.getAll();
    Member? selectedMember = penjualan == null
        ? (members.isNotEmpty ? members.first : null)
        : members.firstWhere(
            (m) => m.nama == penjualan.namaPelanggan,
            orElse: () => members.isNotEmpty
                ? members.first
                : Member(
                    id: null,
                    nama: '',
                    ktp: '',
                    alamat: '',
                    telepon: '',
                    email: '',
                  ),
          );
    String metodePembayaran = 'Tunai';
    final items = penjualan?.items ?? <PenjualanItem>[];
    final List<PenjualanItem> tempItems = List.from(items);
    int total = penjualan?.total ?? 0;
    // String? stokError; // sudah tidak dipakai
    String? stokDialogError;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            penjualan == null ? 'Transaksi Baru' : 'Edit Penjualan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Error: ' + _errorMsg!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  DropdownButtonFormField<Member>(
                    value: selectedMember,
                    items: members
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text(m.nama)),
                        )
                        .toList(),
                    onChanged: (m) => setStateDialog(() => selectedMember = m),
                    decoration: const InputDecoration(
                      labelText: 'Nama Pelanggan',
                    ),
                    validator: (v) => v == null ? 'Pilih pelanggan' : null,
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
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah Barang'),
                    onPressed: () async {
                      final barangList = await BarangDB.instance.getAll();
                      Barang? selectedBarang;
                      final qtyController = TextEditingController();
                      String? stokBarangDialogError;
                      await showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(
                          builder: (context, setStateBarangDialog) => AlertDialog(
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
                                if (stokBarangDialogError != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    stokBarangDialogError!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (selectedBarang != null &&
                                      int.tryParse(qtyController.text) !=
                                          null) {
                                    int qty = int.parse(qtyController.text);
                                    // Validasi stok
                                    final barangDb = await BarangDB.instance
                                        .getAll();
                                    final stokBarang = barangDb
                                        .firstWhere(
                                          (b) => b.id == selectedBarang!.id,
                                        )
                                        .stok;
                                    int qtySudahDipilih = tempItems
                                        .where(
                                          (i) =>
                                              i.barangId == selectedBarang!.id,
                                        )
                                        .fold(0, (sum, i) => sum + i.qty);
                                    if (qty + qtySudahDipilih > stokBarang) {
                                      setStateBarangDialog(() {
                                        stokBarangDialogError =
                                            'Stok barang tidak cukup! Stok tersedia: $stokBarang, yang diminta: ${qty + qtySudahDipilih}';
                                      });
                                      return;
                                    } else {
                                      setStateBarangDialog(() {
                                        stokBarangDialogError = null;
                                      });
                                      setStateDialog(() {
                                        tempItems.add(
                                          PenjualanItem(
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
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                                child: const Text('Tambah'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // stokError sudah tidak dipakai, error stok hanya di dialog tambah barang
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
                  if (stokDialogError != null) ...[
                    const SizedBox(height: 8),
                    Text(stokDialogError!, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                    final newPenjualan = Penjualan(
                      id: penjualan?.id,
                      tanggal: tanggal,
                      namaPelanggan: selectedMember?.nama ?? '',
                      items: tempItems,
                      total: total,
                    );
                    if (penjualan == null) {
                      await PenjualanDB.instance.insert(newPenjualan);
                    } else {
                      await PenjualanDB.instance.update(newPenjualan);
                    }
                    if (mounted) Navigator.pop(context);
                    _loadPenjualans();
                  }
                } catch (e) {
                  setStateDialog(() {
                    _errorMsg = e.toString();
                  });
                }
              },
              child: Text(penjualan == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePenjualan(int id) async {
    await PenjualanDB.instance.delete(id);
    _loadPenjualans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Penjualan',
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
                hintText: 'Cari Nama Pelanggan',
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
                  : _penjualans.isEmpty
                  ? const Center(child: Text('Belum ada transaksi penjualan'))
                  : ListView.builder(
                      itemCount: _penjualans.length,
                      itemBuilder: (context, i) {
                        final p = _penjualans[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              'Pelanggan: ${p.namaPelanggan}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deletePenjualan(p.id!);
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
                              onPressed: () => _showForm(penjualan: p),
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
