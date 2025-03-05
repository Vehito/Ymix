import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TransactionService {
  static Database? _database;
  static final TransactionService instanse = TransactionService._internal();

  TransactionService._internal();

  // Future<Database> get database async {
  //   if (_database != null) return _database!;
  // }

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createTransactionsTable);
  }

  Future<void> _createTransactionsTable(Database db, int version) async {
    await db.execute('''CREATE TABLE Transactions (
        id TEXT PRIMARY KEY NOT NULL,
        amount INTERGER NOT NULL,
        currency TEXT NOT NULL,
        walletId TEXT NOT NULL,
        categoryId TEXT NOT NULL
      )''');
  }
}
