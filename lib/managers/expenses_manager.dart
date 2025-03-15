import 'package:ymix/models/transactions.dart';

import '../models/expense.dart';
import 'package:ymix/managers/transactions_manager.dart';

class ExpensesManager extends TransactionsManager {
  final List<Expense> _expenses = [
    Expense(
      id: "e1",
      amount: 20000,
      currencySymbol: "đ",
      walletId: "1",
      categoryId: "1",
      dateTime: DateTime(2025, 4, 11),
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Expense(
      id: "e2",
      amount: 344000,
      currencySymbol: "đ",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 1, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e3",
      amount: 34000,
      currencySymbol: "đ",
      walletId: "3",
      categoryId: "3",
      dateTime: DateTime(2025, 2, 10),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e4",
      amount: 34000,
      currencySymbol: "đ",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Expense(
      id: "e5",
      amount: 34000,
      currencySymbol: "đ",
      walletId: "1",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 21),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
  ];

  @override
  List<Transactions> get transactions => _expenses;


}
