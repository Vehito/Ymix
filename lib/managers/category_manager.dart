import '../models/category.dart';
import 'package:flutter/material.dart';

class CategoryManager with ChangeNotifier {
  final List<Category> categories = [
    Category(id: "1", name: "food", color: Colors.green, icon: Icons.food_bank),
    Category(
        id: '2',
        name: "entertainment",
        color: Colors.red,
        icon: Icons.music_note),
    Category(id: '3', name: "travel", color: Colors.blue, icon: Icons.map),
  ];

  Category getCategory(String id) {
    return categories.firstWhere((category) => category.id == id);
  }

  Color getColor(String id) {
    return categories.firstWhere((category) => category.id == id).color;
  }

  IconData getIconData(String id) {
    return categories.firstWhere((category) => category.id == id).icon;
  }
}
