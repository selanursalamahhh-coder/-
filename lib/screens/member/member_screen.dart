import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/member_db.dart';
import '../../models/member.dart';
import '../../db/barang_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class MemberScreen extends StatefulWidget {
  const MemberScreen({Key? key}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  List<Member> _members = [];
  String _search = '';
  bool _loading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    try {
      final data = await MemberDB.instance.getAll(query: _search);
      setState(() {
        _members = data;
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
          final data = await MemberDB.instance.getAll(query: _search);
          setState(() {
            _members = data;
            _loading = false;
            _errorMsg = null;
          });
        } catch (e2) {
          setState(() {
            _members = [];
            _loading = false;
            _errorMsg = 'Gagal inisialisasi database: ' + e2.toString();
          });
        }
      } else {
        setState(() {
          _members = [];
          _loading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  void _onSearch(String value) {
    setState(() => _search = value);
    _loadMembers();
  }

  void _showForm({Member? member}) async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: member?.nama ?? '');
    final ktpController = TextEditingController(text: member?.ktp ?? '');
    final alamatController = TextEditingController(text: member?.alamat ?? '');
    final teleponController = TextEditingController(
      text: member?.telepon ?? '',
    );
    final emailController = TextEditingController(text: member?.email ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            member == null ? 'Tambah Member' : 'Edit Member',
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
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: ktpController,
                    decoration: const InputDecoration(labelText: 'Nomor KTP'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'KTP wajib diisi' : null,
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
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Telepon wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Email wajib diisi' : null,
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
                    final newMember = Member(
                      id: member?.id,
                      nama: namaController.text,
                      ktp: ktpController.text,
                      alamat: alamatController.text,
                      telepon: teleponController.text,
                      email: emailController.text,
                    );
                    if (member == null) {
                      await MemberDB.instance.insert(newMember);
                    } else {
                      await MemberDB.instance.update(newMember);
                    }
                    if (mounted) Navigator.pop(dialogContext);
                    _loadMembers();
                  }
                } catch (e) {
                  setStateDialog(() {
                    _errorMsg = e.toString();
                  });
                }
              },
              child: Text(member == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMember(int id) async {
    await MemberDB.instance.delete(id);
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Member',
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
                hintText: 'Cari ID, Nama, atau KTP',
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
                  : _members.isEmpty
                  ? const Center(child: Text('Data member kosong'))
                  : ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (context, i) {
                        final m = _members[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              m.nama,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'KTP: ${m.ktp}\n${m.alamat}\n${m.telepon}\n${m.email}',
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
                                  onPressed: () => _showForm(member: m),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteMember(m.id!),
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
