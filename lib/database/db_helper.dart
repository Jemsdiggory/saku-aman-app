import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class DbHelper {
  // Singleton pattern — 1 instance saja
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saku_aman.db');
    return _database!;
  }

  // Inisialisasi database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Buat tabel saat pertama kali
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        amount   INTEGER NOT NULL,
        category TEXT NOT NULL,
        note     TEXT,
        date     TEXT NOT NULL
      )
    ''');
  }

  // CREATE — simpan pengeluaran baru
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  // READ — ambil semua pengeluaran
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final result = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // READ — ambil pengeluaran hari ini
  Future<List<Expense>> getTodayExpenses() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result = await db.query(
      'expenses',
      where: 'date LIKE ?',
      whereArgs: ['$today%'],
      orderBy: 'date DESC',
    );
    return result.map((e) => Expense.fromMap(e)).toList();
  }

  // DELETE — hapus pengeluaran
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tutup database
  Future close() async {
    final db = await database;
    db.close();
  }
}