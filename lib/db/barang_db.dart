import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/barang.dart';

class BarangDB {
  static final BarangDB instance = BarangDB._init();
  static Database? _database;

  BarangDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dendahmart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Always ensure table exists after open
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS barang (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            kategori TEXT NOT NULL,
            harga INTEGER NOT NULL,
            stok INTEGER NOT NULL,
            satuan TEXT NOT NULL,
            gambarPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS member (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            ktp TEXT NOT NULL,
            alamat TEXT NOT NULL,
            telepon TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS barang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga INTEGER NOT NULL,
        stok INTEGER NOT NULL,
        satuan TEXT NOT NULL,
        gambarPath TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS member (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        ktp TEXT NOT NULL,
        alamat TEXT NOT NULL,
        telepon TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  Future<Barang> insert(Barang barang) async {
    final db = await instance.database;
    final id = await db.insert('barang', barang.toMap());
    return barang..id = id;
  }

  Future<List<Barang>> getAll({String? query}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'barang',
        where: 'nama LIKE ? OR kategori LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('barang', orderBy: 'id DESC');
    }
    return maps.map((e) => Barang.fromMap(e)).toList();
  }

  Future<int> update(Barang barang) async {
    final db = await instance.database;
    return db.update(
      'barang',
      barang.toMap(),
      where: 'id = ?',
      whereArgs: [barang.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('barang', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
