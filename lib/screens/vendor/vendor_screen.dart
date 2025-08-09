import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/vendor_db.dart';
import '../../models/vendor.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({Key? key}) : super(key: key);

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  List<Vendor> _vendors = [];
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() => _loading = true);
    final data = await VendorDB.instance.getAll(query: _search);
    setState(() {
      _vendors = data;
      _loading = false;
    });
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _loadVendors();
  }

  void _showForm({Vendor? vendor}) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: vendor?.nama ?? '');
    final alamatController = TextEditingController(text: vendor?.alamat ?? '');
    final teleponController = TextEditingController(
      text: vendor?.telepon ?? '',
    );
    final emailController = TextEditingController(text: vendor?.email ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          vendor == null ? 'Tambah Vendor' : 'Edit Vendor',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Vendor'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: teleponController,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Telepon wajib diisi' : null,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Email wajib diisi' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
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
              if (formKey.currentState!.validate()) {
                final newVendor = Vendor(
                  id: vendor?.id,
                  nama: namaController.text,
                  alamat: alamatController.text,
                  telepon: teleponController.text,
                  email: emailController.text,
                );
                if (vendor == null) {
                  await VendorDB.instance.insert(newVendor);
                } else {
                  await VendorDB.instance.update(newVendor);
                }
                if (mounted) Navigator.pop(context);
                _loadVendors();
              }
            },
            child: Text(vendor == null ? 'Simpan' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteVendor(int id) async {
    await VendorDB.instance.delete(id);
    _loadVendors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Vendor',
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
                hintText: 'Cari Nama atau Alamat',
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
                  : _vendors.isEmpty
                  ? const Center(child: Text('Data vendor kosong'))
                  : ListView.builder(
                      itemCount: _vendors.length,
                      itemBuilder: (context, i) {
                        final v = _vendors[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              v.nama,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Alamat: ${v.alamat}\nTelepon: ${v.telepon}\nEmail: ${v.email}',
                              style: GoogleFonts.poppins(fontSize: 13),
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
                                  onPressed: () => _showForm(vendor: v),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteVendor(v.id!),
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
