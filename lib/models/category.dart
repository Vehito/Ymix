import 'package:flutter/material.dart';

class Category {
  final String? _id;
  final String _name;
  final Color _color;
  final IconData _icon;

  Category({
    String? id,
    required String name,
    required Color color,
    required IconData icon,
  })  : _id = id,
        _name = name,
        _color = color,
        _icon = icon;

  String? get id => _id;
  String get name => _name;
  Color get color => _color;
  IconData get icon => _icon;

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return Category(
      id: id ?? _id,
      name: name ?? _name,
      color: color ?? _color,
      icon: icon ?? _icon,
    );
  }
}
