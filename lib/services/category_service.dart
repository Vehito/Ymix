import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ymix/models/category.dart';

class CategoryService {
  Database? _categoryDatabase;
  static final CategoryService instance = CategoryService._internal();
  CategoryService._internal();

  Future<Database> get _database async {
    if (_categoryDatabase != null) return _categoryDatabase!;
    _categoryDatabase = await initDatabase('categories.db');
    return _categoryDatabase!;
  }

  Future<Database> initDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final filePath = join(databasePath, fileName);
    return await openDatabase(filePath,
        version: 1, onCreate: _createCategoriesTable);
  }

  Future<void> _createCategoriesTable(Database db, int version) async {
    await db.execute('''CREATE TABLE Categories (
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        isExpense INTERGER NOT NULL
      )''');

    var batch = db.batch();
    batch.insert(
        'Categories',
        Category(
                id: "1",
                name: "Food",
                color: Colors.green,
                icon: Icons.food_bank,
                isExpense: true)
            .toJson());

    batch.insert(
        'Categories',
        Category(
                id: '2',
                name: "Entertainment",
                color: Colors.red,
                icon: Icons.music_note,
                isExpense: true)
            .toJson());

    batch.insert(
        'Categories',
        Category(
                id: '3',
                name: "Travel",
                color: Colors.blue,
                icon: Icons.map,
                isExpense: true)
            .toJson());
    batch.insert(
        'Categories',
        Category(
                id: '4',
                name: "Gaming",
                color: Colors.pink,
                icon: Icons.games,
                isExpense: true)
            .toJson());
    batch.insert(
        'Categories',
        Category(
                id: '5',
                name: "Job",
                color: Colors.yellow,
                icon: Icons.work,
                isExpense: false)
            .toJson());
    batch.insert(
        'Categories',
        Category(
                id: '6',
                name: "Gift",
                color: Colors.purple,
                icon: Icons.card_giftcard,
                isExpense: false)
            .toJson());
    batch.insert(
        'Categories',
        Category(
                id: '7',
                name: "Interest",
                color: Colors.red,
                icon: Icons.savings,
                isExpense: false)
            .toJson());
    batch.insert(
        'Categories',
        Category(
                id: '8',
                name: "Other",
                color: Colors.grey,
                icon: Icons.help,
                isExpense: false)
            .toJson());

    await batch.commit();
  }

  Future<Category> insertCategory(Category category) async {
    final db = await _database;
    await db.insert('Categories', category.toJson());
    return category;
  }

  Future<Set<Category>> fetchAllCategory() async {
    final Set<Category> categories = {};
    try {
      final db = await _database;
      final categoryModels = await db.query('Categories');
      for (final categoryModel in categoryModels) {
        categories.add(Category.formJson(categoryModel));
      }
      return categories;
    } catch (e) {
      return categories;
    }
  }

  Future<void> close() async {
    if (_categoryDatabase != null) {
      try {
        await _categoryDatabase!.close();
        _categoryDatabase = null;
      } catch (e) {
        debugPrint("Error closing database: $e");
      }
    }
  }
}
