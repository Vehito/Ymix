import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ymix/services/category_service.dart';
import 'package:ymix/services/currency_service.dart';
import 'package:ymix/services/wallet_service.dart';
import '../models/transactions.dart';
import 'package:path/path.dart';

class TransactionService {
  static Database? _transactionDatabase;
  static final TransactionService instance = TransactionService._internal();
  TransactionService._internal();

  final dbName = 'Transactions';

  Future<Database> get _database async {
    if (_transactionDatabase != null) return _transactionDatabase!;
    _transactionDatabase = await _initDatabase('transactions.db');
    return _transactionDatabase!;
  }

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    await CategoryService.instance.initDatabase('categories.db');
    await WalletService.instance.initDatabase('wallets.db');
    await CurrencyService.instance.initDatabase('currencies.db');
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createTransactionsTable);
  }

  Future<void> _createTransactionsTable(Database db, int version) async {
    await db.execute('''CREATE TABLE $dbName (
        id INTEGER PRIMARY KEY NOT NULL,
        amount REAL NOT NULL,
        currencySymbol TEXT NOT NULL,
        walletId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        dateTime INTEGER NOT NULL,
        comment TEXT,
        type TEXT CHECK(type IN ('income', 'expense'))  NOT NULL,
        FOREIGN KEY (currencySymbol) REFERENCES Currencies (symbol),
        FOREIGN KEY (walletId) REFERENCES Wallets (id),
        FOREIGN KEY (categoryId) REFERENCES Categories (id)
      )''');
  }

  Future<List<Transactions>> fetchAllTransactions() async {
    final List<Transactions> transactions = [];
    try {
      final db = await _database;
      final transactionModels = await db.query(dbName);
      for (var model in transactionModels) {
        transactions.add(Transactions.formJson(model));
      }
      return transactions;
    } catch (e) {
      return transactions;
    }
  }

  Future<List<Transactions>> fetchTransactionsInDay(
      DateTime dateTime, bool isExpense) async {
    final List<Transactions> transactions = [];
    try {
      final db = await _database;
      final transactionModels = await db
          .query(dbName, where: 'dateTime = ? AND type = ?', whereArgs: [
        dateTime.difference(DateTime(2020, 1, 1)).inDays,
        isExpense ? 'expense' : 'income'
      ]);
      for (var model in transactionModels) {
        transactions.add(Transactions.formJson(model));
      }
      return transactions;
    } catch (e) {
      return transactions;
    }
  }

  Future<List<Transactions>> fetchTransactionsInPeriod(
      DateTime start, DateTime end, bool isExpense) async {
    final List<Transactions> transactions = [];
    try {
      final db = await _database;
      final transactionModels = await db.query(dbName,
          where: 'dateTime BETWEEN ? AND ? AND type = ?',
          whereArgs: [
            start.difference(DateTime(2020, 1, 1)).inDays,
            end.difference(DateTime(2020, 1, 1)).inDays,
            isExpense ? 'expense' : 'income'
          ]);
      for (var model in transactionModels) {
        transactions.add(Transactions.formJson(model));
      }
      return transactions;
    } catch (e) {
      return transactions;
    }
  }

  Future<Transactions?> fetchTransactionById(String id) async {
    try {
      final db = await _database;
      final model =
          await db.query(dbName, where: 'id = ?', whereArgs: [id], limit: 1);
      return Transactions.formJson(model[0]);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<List<Transactions>> fetchTransactionByCategoryId(String id) async {
    final List<Transactions> transactions = [];
    try {
      final db = await _database;
      final transactionModels =
          await db.query(dbName, where: 'categoryId = ?', whereArgs: [id]);
      for (var model in transactionModels) {
        transactions.add(Transactions.formJson(model));
      }
      return transactions;
    } catch (e) {
      return transactions;
    }
  }

  Future<Transactions?> addTransaction(
      Transactions transaction, bool isExpense) async {
    try {
      final db = await _database;
      final model = transaction.toJson();
      model['type'] = isExpense ? 'expense' : 'income';
      await db.insert(dbName, model);
      return transaction;
    } catch (e) {
      return null;
    }
  }

  Future<int?> updateTransaction(Transactions transaction) async {
    try {
      final db = await _database;
      return await db.update(dbName, transaction.toJson(),
          where: 'id = ?', whereArgs: [int.parse(transaction.id!)]);
    } catch (e) {
      return null;
    }
  }

  Future<int?> deleteTheTransaction(String id) async {
    try {
      final db = await _database;
      return await db.delete(dbName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    if (_transactionDatabase != null) {
      try {
        await _transactionDatabase!.close();
        _transactionDatabase = null;
      } catch (e) {
        debugPrint("Error closing database: $e");
      }
    }
  }
}
