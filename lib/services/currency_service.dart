import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ymix/models/currency.dart';

class CurrencyService {
  Database? _currencyDatabase;
  static final CurrencyService instance = CurrencyService._internal();
  CurrencyService._internal();

  final dbName = 'Currencies';

  Future<Database> get _database async {
    if (_currencyDatabase != null) return _currencyDatabase!;
    _currencyDatabase = await _initDatabase('currencies.db');
    return _currencyDatabase!;
  }

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createCurrenciesTable);
  }

  Future<void> _createCurrenciesTable(Database db, int version) async {
    await db.execute('''CREATE TABLE Currencies (
        code TEXT PRIMARY KEY NOT NULL,
        symbol TEXT NOT NULL,
        decimalDigits INTEGER NOT NULL,
        exchangeRate REAL NOT NULL
      )''');
    var batch = db.batch();
    batch.insert(
      dbName,
      Currency(code: 'VND', symbol: 'đ', decimalDigits: 0, exchangeRate: 24000)
          .toJson(),
    );
    batch.insert(
      dbName,
      Currency(code: 'USAD', symbol: '\$', decimalDigits: 2, exchangeRate: 1)
          .toJson(),
    );
    await batch.commit();
  }

  Future<List<Currency>> fetchAllCurrencies() async {
    final List<Currency> currencies = [];
    try {
      final db = await _database;
      final currencyModels = await db.query(dbName);
      for (var model in currencyModels) {
        currencies.add(Currency.formJson(model));
      }
      return currencies;
    } catch (e) {
      return currencies;
    }
  }

  Future<Currency?> fetchWalletById(String code) async {
    final Currency? currency;
    try {
      final db = await _database;
      final result = await db.query(dbName,
          where: 'code == ?', whereArgs: [code], limit: 1);
      currency = Currency.formJson(result[0]);
      return currency;
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    if (_currencyDatabase != null) {
      try {
        await _currencyDatabase!.close();
        _currencyDatabase = null;
      } catch (e) {
        debugPrint("Error closing database: $e");
      }
    }
  }
}
