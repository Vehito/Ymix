import 'package:ymix/models/income.dart';

import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transaction.dart';

class IncomeManager extends TransactionsManager {
  final List<Income> _incomes = [
    Income(
      id: "i1",
      amount: 24000,
      currency: "VND",
      walletId: "1",
      categoryId: "1",
      dateTime: DateTime(2025, 10, 12),
      tags: ['Xem phim'],
      comment: "aaa",
    ),
    Income(
      id: "i2",
      amount: 344000,
      currency: "VND",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 10, 15),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Income(
      id: "i3",
      amount: 34000,
      currency: "VND",
      walletId: "3",
      categoryId: "3",
      dateTime: DateTime(2025, 2, 20),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
    Income(
      id: "i4",
      amount: 34000,
      currency: "VND",
      walletId: "2",
      categoryId: "2",
      dateTime: DateTime(2025, 2, 11),
      // tags: ['Xem phim'],
      // comment: "aaa",
    ),
  ];

  @override
  List<Transaction> get transactions => _incomes;

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
    transactions.add(Income(
      id: "i${DateTime.now().toIso8601String()}",
      amount: amount,
      currency: currency,
      walletId: walletId,
      categoryId: categoryId,
      dateTime: dateTime,
    ));
  }

  @override
  Income getTransactionWithId(String id) {
    return _incomes.firstWhere((income) => income.id! == id);
  }

  @override
  void deleteTransaction(String id) {
    _incomes.remove(_incomes.firstWhere((income) => income.id == id));
  }
}
