import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pembelian.dart';

class PembelianDB {
  static final PembelianDB instance = PembelianDB._init();
  static Database? _database;

  PembelianDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pembelian.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pembelian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        namaVendor TEXT NOT NULL,
        metodePembayaran TEXT NOT NULL,
        items TEXT NOT NULL,
        total INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Pembelian>> getAll({String query = ''}) async {
    final db = await instance.database;
    final maps = await db.query(
      'pembelian',
      where: query.isNotEmpty ? 'namaVendor LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%'] : null,
      orderBy: 'tanggal DESC',
    );
    return maps.map((e) => Pembelian.fromMap(e)).toList();
  }

  Future<int> insert(Pembelian pembelian) async {
    final db = await instance.database;
    return await db.insert('pembelian', pembelian.toMap());
  }

  Future<int> update(Pembelian pembelian) async {
    final db = await instance.database;
    return await db.update(
      'pembelian',
      pembelian.toMap(),
      where: 'id = ?',
      whereArgs: [pembelian.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('pembelian', where: 'id = ?', whereArgs: [id]);
  }
}
