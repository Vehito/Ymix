import 'package:ymix/services/category_service.dart';

import '../models/category.dart';
import 'package:flutter/material.dart';

class CategoryManager with ChangeNotifier {
  static final CategoryManager _instance = CategoryManager._internal();
  static CategoryManager get instance => _instance;

  CategoryManager._internal();
  final CategoryService _categoryService = CategoryService.instance;

  Set<Category> _categories = {};

  Set<Category> get categories => _categories;

  Future<void> init() async {
    if (categories.isEmpty) fetchAllCategory();
  }

  Future<void> fetchAllCategory() async {
    _categories = await _categoryService.fetchAllCategory();
    await _categoryService.close();
  }

  Category getCategory(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  String getCategoryName(String id) {
    return _categories.firstWhere((ca) => ca.id == id).name;
  }

  Color getColor(String id) {
    return _categories.firstWhere((category) => category.id == id).color;
  }

  IconData getIconData(String id) {
    return _categories.firstWhere((category) => category.id == id).icon;
  }
}
