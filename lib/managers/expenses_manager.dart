import 'package:ymix/models/transaction.dart';

import '../models/expense.dart';
import 'package:ymix/managers/transactions_manager.dart';

class ExpensesManager extends TransactionsManager {
  final List<Expense> _expenses = [
    Expense(
      id: "e1",
      amount: 20000,
      currency: "VND",
      walletId: "1",
      categoryId: "1",
      dateTime: DateTime(2025, 4, 11),
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Expense(
      id: "e2",
      amount: 344000,
      currency: "VND",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 1, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e3",
      amount: 34000,
      currency: "VND",
      walletId: "3",
      categoryId: "3",
      dateTime: DateTime(2025, 2, 10),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e4",
      amount: 34000,
      currency: "VND",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e5",
      amount: 34000,
      currency: "VND",
      walletId: "1",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
  ];

  @override
  List<Transaction> get transactions => _expenses;

  @override
  void addTransaction(
    double amount,
    String currency,
    String walletId,
    String categoryId,
    DateTime dateTime,
    List<String>? tags,
    String? comment,
  ) {
    transactions.add(Expense(
      id: "e${DateTime.now().toIso8601String()}",
      amount: amount,
      currency: currency,
      walletId: walletId,
      categoryId: categoryId,
      dateTime: dateTime,
    ));
  }

  @override
  Expense getTransactionWithId(String id) {
    return _expenses.firstWhere((expense) => expense.id! == id);
  }

  @override
  void deleteTransaction(String id) {
    _expenses.remove(_expenses.firstWhere((expense) => expense.id! == id));
  }
}
