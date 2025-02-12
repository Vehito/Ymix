import 'package:flutter/material.dart';

import '../models/transaction.dart';

class TransactionsManager with ChangeNotifier {
  static final Map<String, Color> color = {
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
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Transaction(
      id: "2",
      amount: 344000,
      currency: "VND",
      account: "main",
      category: "food",
      dateTime: DateTime(2025, 10, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Transaction(
      id: "3",
      amount: 34000,
      currency: "VND",
      account: "main",
      category: "travel",
      dateTime: DateTime(2025, 10, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    )
  ];

  int get itemCount {
    return _items.length;
  }

  List<Transaction> get items {
    return [..._items];
  }
}
