import 'package:ymix/services/category_service.dart';

import '../models/category.dart';
import 'package:flutter/material.dart';

class CategoryManager with ChangeNotifier {
  static final CategoryManager _instance = CategoryManager._internal();
  static CategoryManager get instance => _instance;

  CategoryManager._internal();
  final CategoryService _categoryService = CategoryService.instance;

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> fetchAllCategory() async {
    _categories = await _categoryService.fetchAllCategory();
  }

  Future<void> addCategory() async {
    await _categoryService.insertCategory(Category(
        id: "1", name: "Food", color: Colors.green, icon: Icons.food_bank));
  }

  Category getCategory(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  Color getColor(String id) {
    return _categories.firstWhere((category) => category.id == id).color;
  }

  IconData getIconData(String id) {
    return _categories.firstWhere((category) => category.id == id).icon;
  }
}
