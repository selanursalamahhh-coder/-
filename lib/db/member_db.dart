import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/member.dart';

class MemberDB {
  static final MemberDB instance = MemberDB._init();
  static Database? _database;

  MemberDB._init();

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
          CREATE TABLE IF NOT EXISTS member (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            ktp TEXT NOT NULL,
            alamat TEXT NOT NULL,
            telepon TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
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
      },
    );
  }

  Future _createDB(Database db, int version) async {
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
  }

  Future<Member> insert(Member member) async {
    final db = await instance.database;
    final id = await db.insert('member', member.toMap());
    return member..id = id;
  }

  Future<List<Member>> getAll({String? query}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'member',
        where: 'id LIKE ? OR nama LIKE ? OR ktp LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('member', orderBy: 'id DESC');
    }
    return maps.map((e) => Member.fromMap(e)).toList();
  }

  Future<int> update(Member member) async {
    final db = await instance.database;
    return db.update(
      'member',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('member', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
