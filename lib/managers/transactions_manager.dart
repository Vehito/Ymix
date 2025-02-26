import 'package:flutter/material.dart';

import '../models/transaction.dart';

abstract class TransactionsManager with ChangeNotifier {
  List<Transaction> get allItems;

  int get itemCount {
    return allItems.length;
  }

  List<Transaction> getItemsWithDate(DateTime date) {
    return allItems
        .where((item) =>
            item.dateTime.day == date.day &&
            item.dateTime.month == date.month &&
            item.dateTime.year == date.year)
        .toList();
    // return allItems
    // .where((item) => item.dateTime.isAtSameMomentAs(date))
    // .toList();
  }

  List<Transaction> getItemsWithPeriod(DateTime start, DateTime end) {
    return allItems
        .where((item) =>
            item.dateTime.isAfter(start) && item.dateTime.isBefore(end))
        .toList();
  }

  void addTransaction(
    int amount,
    String currency,
    String accountId,
    String categoryId,
    DateTime dateTime,
    List<String>? tags,
    String? comment,
  );
}
