import 'package:flutter/material.dart';

class Category {
  final String? id;
  final String name;
  final Color color;
  final IconData icon;

  Category({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
