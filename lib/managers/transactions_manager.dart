import 'package:flutter/material.dart';

import '../models/transaction.dart';

class TransactionsManager with ChangeNotifier {
  final Map<String, Color> _color = {
    "entertainment": Colors.red,
  };

  final List<Transaction> _items = [
    Transaction(
      id: "1",
      amount: 20000,
      currency: "VND",
      account: "main",
      category: "entertainment",
      dateTime: DateTime(2025, 10, 11),
      tags: ['sex'],
      comment: "aaa",
    )
  ];

  int get itemCount {
    return _items.length;
  }

  List<Transaction> get items {
    return [..._items];
  }
}
