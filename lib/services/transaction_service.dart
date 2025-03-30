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
        isExpense INTEGER CHECK(isExpense IN (0, 1)) NOT NULL,
        FOREIGN KEY (currencySymbol) REFERENCES Currencies (symbol),
        FOREIGN KEY (walletId) REFERENCES Wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES Categories (id)
      )''');
  }

  Future<List<Transactions>> fetchTransactions(
      {List<String>? idList,
      String? walletId,
      String? categoryId,
      DateTime? dateTime,
      DateTimeRange? period,
      bool? isExpense}) async {
    final List<Transactions> transactions = [];
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (idList != null) {
      final String idPlaceholders = List.filled(idList.length, '?').join(', ');
      whereClause = 'id IN ($idPlaceholders)';
      whereArgs = idList;
    } else {
      List<String> clauseList = [];
      if (walletId != null) {
        clauseList.add('walletId = ?');
        whereArgs.add(walletId);
      }
      if (categoryId != null) {
        clauseList.add('categoryId = ?');
        whereArgs.add(categoryId);
      }
      if (isExpense != null) {
        clauseList.add('isExpense = ?');
        whereArgs.add(isExpense ? 1 : 0);
      }
      if (dateTime != null) {
        clauseList.add('dateTime = ?');
        whereArgs.add(_dateTimeToInt(dateTime));
      } else if (period != null) {
        clauseList.add('dateTime BETWEEN ? AND ?');
        whereArgs.add(_dateTimeToInt(period.start));
        whereArgs.add(_dateTimeToInt(period.end));
      }
      whereClause = clauseList.join(' AND ');
    }

    try {
      final db = await _database;
      final transactionModels =
          await db.query(dbName, where: whereClause, whereArgs: whereArgs);
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
      model['isExpense'] = isExpense ? 1 : 0;
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

  Future<int?> deleteTransaction(String id) async {
    try {
      final db = await _database;
      return await db.delete(dbName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      return null;
    }
  }

  Future<double> getTotalAmountInPeriod(DateTime start, DateTime end,
      {bool? isExpense, String? categoryId, String? walletId}) async {
    try {
      final db = await _database;
      String whereClause =
          'SELECT SUM(amount) as total FROM $dbName WHERE dateTime BETWEEN ? AND ?';
      List<dynamic> whereArgs = [_dateTimeToInt(start), _dateTimeToInt(end)];

      if (isExpense != null) {
        whereClause += ' AND isExpense = ?';
        whereArgs.add(isExpense ? 1 : 0);
      }
      if (categoryId != null) {
        whereClause += ' AND categoryId = ?';
        whereArgs.add(categoryId);
      }
      if (walletId != null) {
        whereClause += ' AND walletId = ?';
        whereArgs.add(walletId);
      }

      final json = await db.rawQuery(whereClause, whereArgs);
      return json.first['total'] == null ? 0 : json.first['total'] as double;
    } catch (e) {
      return 0;
    }
  }

  int _dateTimeToInt(DateTime dateTime) {
    return dateTime.difference(DateTime(2020, 1, 1)).inDays;
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
