import 'package:ymix/models/transaction.dart';

import '../models/expense.dart';
import 'package:ymix/managers/transactions_manager.dart';

class ExpensesManager extends TransactionsManager {
  final List<Expense> _items = [
    Expense(
      id: "1",
      amount: 20000,
      currency: "VND",
      accountId: "main",
      categoryId: "1",
      dateTime: DateTime(2025, 4, 11),
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Expense(
      id: "2",
      amount: 344000,
      currency: "VND",
      accountId: "main",
      categoryId: "2",
      dateTime: DateTime(2025, 1, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "3",
      amount: 34000,
      currency: "VND",
      accountId: "main",
      categoryId: "3",
      dateTime: DateTime(2025, 2, 10),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "4",
      amount: 34000,
      currency: "VND",
      accountId: "main",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "5",
      amount: 34000,
      currency: "VND",
      accountId: "main",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
  ];

  @override
  List<Transaction> get allItems => _items;

  @override
  void addTransaction(
    int amount,
    String currency,
    String accountId,
    String categoryId,
    DateTime dateTime,
    List<String>? tags,
    String? comment,
  ) {
    allItems.add(Expense(
      amount: amount,
      currency: currency,
      accountId: accountId,
      categoryId: categoryId,
      dateTime: dateTime,
    ));
  }
}
