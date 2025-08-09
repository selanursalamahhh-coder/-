import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vendor.dart';

class VendorDB {
  static final VendorDB instance = VendorDB._init();
  static Database? _database;

  VendorDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vendor.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vendor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        alamat TEXT NOT NULL,
        telepon TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  Future<List<Vendor>> getAll({String query = ''}) async {
    final db = await instance.database;
    final maps = await db.query(
      'vendor',
      where: query.isNotEmpty ? 'nama LIKE ? OR alamat LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%', '%$query%'] : null,
      orderBy: 'nama ASC',
    );
    return maps.map((e) => Vendor.fromMap(e)).toList();
  }

  Future<int> insert(Vendor vendor) async {
    final db = await instance.database;
    return await db.insert('vendor', vendor.toMap());
  }

  Future<int> update(Vendor vendor) async {
    final db = await instance.database;
    return await db.update(
      'vendor',
      vendor.toMap(),
      where: 'id = ?',
      whereArgs: [vendor.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('vendor', where: 'id = ?', whereArgs: [id]);
  }
}
