import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ymix/models/spending_limit.dart';

class SpendingLimitService {
  Database? _spendingLimitDatabase;
  static final SpendingLimitService instance = SpendingLimitService._internal();
  SpendingLimitService._internal();

  final dbName = 'SpendingLimits';

  Future<Database> get _database async {
    if (_spendingLimitDatabase != null) return _spendingLimitDatabase!;
    _spendingLimitDatabase = await _initDatabase('spending_limits.db');
    return _spendingLimitDatabase!;
  }

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createSpendingLimitTable);
  }

  Future<void> _createSpendingLimitTable(Database db, int version) async {
    await db.execute('''CREATE TABLE $dbName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      categoryId TEXT NOT NULL,
      start INTEGER NOT NULL,
      end INTEGER NOT NULL,
      amount REAL NOT NULL,
      currencySymbol TEXT NOT NULL,
      currentSpending REAL NOT NULL,
      status TEXT NOT NULL,
      FOREIGN KEY (categoryId) REFERENCES Categories (id)
    )''');
  }

  Future<List<SpendingLimit>> fetchAllLimit() async {
    List<SpendingLimit> list = [];
    try {
      final db = await _database;
      final limitModels = await db.query(dbName);
      for (var model in limitModels) {
        list.add(SpendingLimit.formJson(model));
      }
      return list;
    } catch (e) {
      return list;
    }
  }

  Future<SpendingLimit?> fetchLimitById(String id) async {
    try {
      final db = await _database;
      final model =
          await db.query(dbName, where: 'id = ?', whereArgs: [id], limit: 1);
      return SpendingLimit.formJson(model[0]);
    } catch (e) {
      return null;
    }
  }

  Future<SpendingLimit?> addLimit(SpendingLimit limit) async {
    try {
      final db = await _database;
      final id = await db.insert(dbName, limit.toJson());
      return limit.copyWith(id: id.toString());
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    if (_spendingLimitDatabase != null) {
      try {
        await _spendingLimitDatabase!.close();
        _spendingLimitDatabase = null;
      } catch (e) {
        debugPrint("Error closing database: $e");
      }
    }
  }
}
