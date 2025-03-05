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

  String _doubleToHex(double value) =>
      (value * 255).round().toRadixString(16).padLeft(2, '0');

  int _colorToHex(Color color) {
    return int.parse(
        '${_doubleToHex(color.a)}'
        '${_doubleToHex(color.r)}'
        '${_doubleToHex(color.g)}'
        '${_doubleToHex(color.b)}',
        radix: 16);
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'color': _colorToHex(_color),
        'icon': _icon.codePoint,
      };

  factory Category.formJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        color: Color(json['color']),
        icon: IconData(json['icon'], fontFamily: "MaterialIcons"),
      );
}
