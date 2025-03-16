import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ymix/models/wallet.dart';

class WalletService {
  Database? _walletDatebase;
  static final WalletService instance = WalletService._internal();
  WalletService._internal();

  Future<Database> get _database async {
    if (_walletDatebase != null) return _walletDatebase!;
    _walletDatebase = await initDatabase('wallets.db');
    return _walletDatebase!;
  }

  Future<Database> initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createWalletTable);
  }

  Future<void> _createWalletTable(Database db, int version) async {
    await db.execute('''CREATE TABLE Wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        description TEXT
    )''');
  }

  Future<Wallet?> addWallet(Wallet wallet) async {
    try {
      final db = await _database;
      final int id = await db.insert('Wallets', wallet.toJson());
      return wallet.copyWith(id: id.toString());
    } catch (e) {
      return null;
    }
  }

  Future<int?> updateWallet(Wallet wallet) async {
    try {
      final db = await _database;
      return await db.update("Wallets", wallet.toJson(),
          where: 'id = ?', whereArgs: [int.parse(wallet.id!)]);
    } catch (e) {
      return null;
    }
  }

  Future<List<Wallet>> fetchAllWallet() async {
    final List<Wallet> wallets = [];
    try {
      final db = await _database;
      final walletModels = await db.query('Wallets');
      for (var model in walletModels) {
        wallets.add(Wallet.formJson(model));
      }
      return wallets;
    } catch (e) {
      return wallets;
    }
  }

  Future<Wallet?> fetchWalletById(String id) async {
    try {
      final db = await _database;
      final model =
          await db.query('Wallets', where: 'id = ?', whereArgs: [id], limit: 1);
      return Wallet.formJson(model[0]);
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    if (_walletDatebase != null) {
      try {
        await _walletDatebase!.close();
        _walletDatebase = null;
      } catch (e) {
        debugPrint("Error closing database: $e");
      }
    }
  }
}
