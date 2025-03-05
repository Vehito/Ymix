import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WalletService {
  Database? _walletDatebase;
  static final WalletService instance = WalletService._internal();
  WalletService._internal();

  Future<Database> _initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createWalletTable);
  }

  Future<void> _createWalletTable(Database db, int version) async {
    await db.execute('''sql''');
  }
}
