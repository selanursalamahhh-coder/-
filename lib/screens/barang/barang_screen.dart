import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../db/barang_db.dart';
import '../../models/barang.dart';
import '../../db/member_db.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({Key? key}) : super(key: key);

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  List<Barang> _barangs = [];
  String _search = '';
  bool _loading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadBarangs();
  }

  Future<void> _loadBarangs() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final data = await BarangDB.instance.getAll(query: _search);
      setState(() {
        _barangs = data;
        _loading = false;
        _errorMsg = null;
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
          final data = await BarangDB.instance.getAll(query: _search);
          setState(() {
            _barangs = data;
            _loading = false;
            _errorMsg = null;
          });
        } catch (e2) {
          setState(() {
            _barangs = [];
            _loading = false;
            _errorMsg = 'Gagal inisialisasi database: ' + e2.toString();
          });
        }
      } else {
        setState(() {
          _barangs = [];
          _loading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _loadBarangs();
  }

  void _showForm({Barang? barang}) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: barang?.nama ?? '');
    final kategoriController = TextEditingController(
      text: barang?.kategori ?? '',
    );
    final hargaController = TextEditingController(
      text: barang?.harga.toString() ?? '',
    );
    final stokController = TextEditingController(
      text: barang?.stok.toString() ?? '',
    );
    final satuanController = TextEditingController(text: barang?.satuan ?? '');
    String? gambarPath = barang?.gambarPath;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            barang == null ? 'Tambah Barang' : 'Edit Barang',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showModalBottomSheet<String>(
                        context: context,
                        builder: (sheetContext) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Kamera'),
                              onTap: () =>
                                  Navigator.pop(sheetContext, 'camera'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('Galeri'),
                              onTap: () =>
                                  Navigator.pop(sheetContext, 'gallery'),
                            ),
                          ],
                        ),
                      );
                      if (picked != null) {
                        final ImagePicker picker = ImagePicker();
                        XFile? file;
                        if (picked == 'camera') {
                          file = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 70,
                          );
                        } else {
                          file = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 70,
                          );
                        }
                        if (file != null) {
                          setStateDialog(() => gambarPath = file?.path);
                        }
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: gambarPath == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(gambarPath!),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: kategoriController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Kategori wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Harga wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: stokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Stok wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: satuanController,
                    decoration: const InputDecoration(labelText: 'Satuan'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Satuan wajib diisi' : null,
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
                  if (formKey.currentState!.validate()) {
                    final newBarang = Barang(
                      id: barang?.id,
                      nama: namaController.text,
                      kategori: kategoriController.text,
                      harga: int.tryParse(hargaController.text) ?? 0,
                      stok: int.tryParse(stokController.text) ?? 0,
                      satuan: satuanController.text,
                      gambarPath: gambarPath,
                    );
                    if (barang == null) {
                      await BarangDB.instance.insert(newBarang);
                    } else {
                      await BarangDB.instance.update(newBarang);
                    }
                    if (mounted) {
                      Navigator.pop(dialogContext);
                      // Tunggu sebentar agar dialog tertutup sebelum reload
                      await Future.delayed(const Duration(milliseconds: 200));
                      _loadBarangs();
                    }
                  }
                } catch (e) {
                  print('Error simpan barang: $e');
                  setStateDialog(() {
                    _errorMsg = e.toString();
                  });
                }
              },
              child: Text(barang == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBarang(int id) async {
    await BarangDB.instance.delete(id);
    _loadBarangs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Barang',
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
                hintText: 'Cari Nama atau Kategori',
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
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Error: ' + _errorMsg!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _barangs.isEmpty
                  ? const Center(child: Text('Data barang kosong'))
                  : ListView.builder(
                      itemCount: _barangs.length,
                      itemBuilder: (context, i) {
                        final b = _barangs[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                (b.gambarPath != null &&
                                    b.gambarPath!.isNotEmpty &&
                                    File(b.gambarPath!).existsSync())
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(b.gambarPath!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                  ),
                            title: Text(
                              b.nama,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Kategori: ${b.kategori}\nHarga: ${b.harga}\nStok: ${b.stok} ${b.satuan}',
                            ),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () => _showForm(barang: b),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteBarang(b.id!),
                                ),
                              ],
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
