import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/memo.dart';

class MemoDatabase {
  static final MemoDatabase instance = MemoDatabase._init();

  static Database? _database;

  MemoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE memos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      number INTEGER NOT NULL,
      genre TEXT,
      title TEXT,
      artist TEXT,
      key TEXT,
      machine TEXT,
      notes TEXT
    )
    ''');
  }

  Future<List<Memo>> readAllMemos() async {
    final db = await instance.database;
    final orderBy = 'number ASC';
    final result = await db.query('memos', orderBy: orderBy);
    return result.map((map) => Memo.fromMap(map)).toList();
  }

  Future<int> createMemo(Memo memo) async {
    final db = await instance.database;
    return await db.insert('memos', memo.toMap());
  }

  Future<int> updateMemo(Memo memo) async {
    final db = await instance.database;
    return await db.update('memos', memo.toMap(),
        where: 'id = ?', whereArgs: [memo.id]);
  }

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;
    return await db.delete('memos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
