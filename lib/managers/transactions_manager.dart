import 'package:flutter/material.dart';

import '../models/transaction.dart';

abstract class TransactionsManager with ChangeNotifier {
  List<Transaction> get transactions;

  int get itemCount {
    return transactions.length;
  }

  List<Transaction> getItemsWithDate(DateTime date) {
    return transactions
        .where((transaction) =>
            transaction.dateTime.day == date.day &&
            transaction.dateTime.month == date.month &&
            transaction.dateTime.year == date.year)
        .toList();
    // return transactions
    // .where((transaction) => transaction.dateTime.isAtSameMomentAs(date))
    // .toList();
  }

  List<Transaction> getItemsWithPeriod(DateTime start, DateTime end) {
    return transactions
        .where((transaction) =>
            transaction.dateTime.isAfter(start) &&
            transaction.dateTime.isBefore(end))
        .toList();
  }

  Transaction getTransactionWithId(String id);

  void addTransaction(
    double amount,
    String currency,
    String walletId,
    String categoryId,
    DateTime dateTime,
    List<String>? tags,
    String? comment,
  );

  void editTransaction({
    required String id,
    double? amount,
    String? currency,
    String? walletId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    var index = transactions.indexWhere((transaction) => transaction.id == id);
    transactions[index] = transactions[index].copyWith(
        id: null,
        amount: amount,
        currency: currency,
        walletId: walletId,
        categoryId: categoryId,
        dateTime: dateTime,
        tags: tags,
        comment: comment);
  }

  void deleteTransaction(String id);
}
