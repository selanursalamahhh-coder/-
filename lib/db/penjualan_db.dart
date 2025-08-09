import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/penjualan.dart';

class PenjualanDB {
  static final PenjualanDB instance = PenjualanDB._init();
  static Database? _database;

  PenjualanDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('penjualan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE penjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        namaPelanggan TEXT NOT NULL,
        items TEXT NOT NULL,
        total INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Penjualan>> getAll({String query = ''}) async {
    final db = await instance.database;
    final maps = await db.query(
      'penjualan',
      where: query.isNotEmpty ? 'namaPelanggan LIKE ?' : null,
      whereArgs: query.isNotEmpty ? ['%$query%'] : null,
      orderBy: 'tanggal DESC',
    );
    return maps.map((e) => Penjualan.fromMap(e)).toList();
  }

  Future<int> insert(Penjualan penjualan) async {
    final db = await instance.database;
    return await db.insert('penjualan', penjualan.toMap());
  }

  Future<int> update(Penjualan penjualan) async {
    final db = await instance.database;
    return await db.update(
      'penjualan',
      penjualan.toMap(),
      where: 'id = ?',
      whereArgs: [penjualan.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('penjualan', where: 'id = ?', whereArgs: [id]);
  }
}
