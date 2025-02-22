import 'package:ymix/models/income.dart';

import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transaction.dart';

class IncomeManager extends TransactionsManager {
  final List<Income> _items = [
    Income(
      id: "1",
      amount: 24000,
      currency: "VND",
      account: "main",
      categoryId: "1",
      dateTime: DateTime(2025, 10, 12),
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Income(
      id: "2",
      amount: 344000,
      currency: "VND",
      account: "main",
      categoryId: "2",
      dateTime: DateTime(2025, 10, 15),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Income(
      id: "3",
      amount: 34000,
      currency: "VND",
      account: "main",
      categoryId: "3",
      dateTime: DateTime(2025, 2, 20),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Income(
      id: "4",
      amount: 34000,
      currency: "VND",
      account: "main",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
  ];

  @override
  List<Transaction> get allItems => _items;
}
