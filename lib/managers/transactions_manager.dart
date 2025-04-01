library transactions_manager;

import 'package:flutter/material.dart';
import 'package:ymix/models/expense.dart';
import 'package:ymix/models/income.dart';
import 'package:ymix/services/spending_limit_service.dart';
import 'package:ymix/services/transaction_service.dart';
import 'package:ymix/services/wallet_service.dart';

import '../models/transactions.dart';
part 'income_manager.dart';
part 'expenses_manager.dart';

class TransactionsManager with ChangeNotifier {
  static final TransactionsManager _instance = TransactionsManager._internal();
  static TransactionsManager get instance => _instance;

  TransactionsManager._internal();
  final TransactionService _transactionService = TransactionService.instance;

  List<Transactions> transactions = [];

  int get itemCount {
    return transactions.length;
  }

  Future<List<Transactions>> getTransactions(
      {List<String>? idList,
      List<String>? walletIds,
      List<String>? categoryIds,
      DateTime? dateTime,
      DateTimeRange? period,
      bool? isExpense}) async {
    return await _transactionService.fetchTransactions(
        idList: idList,
        walletIds: walletIds,
        categoryIds: categoryIds,
        dateTime: dateTime,
        period: period,
        isExpense: isExpense);
  }

  Future<double> getTotalAmountInPeriod(DateTime start, DateTime end,
      {bool? isExpense, String? categoryId, String? walletId}) async {
    return await _transactionService.getTotalAmountInPeriod(start, end,
        isExpense: isExpense, categoryId: categoryId, walletId: walletId);
  }

  Future<void> addTransaction(
      double amount,
      String currencySymbol,
      String walletId,
      String categoryId,
      DateTime dateTime,
      List<String>? tags,
      String? comment,
      bool isExpense) async {
    final transaction = Transactions(
        amount: amount,
        currencySymbol: currencySymbol,
        walletId: walletId,
        categoryId: categoryId,
        dateTime: dateTime);
    final walletService = WalletService.instance;
    final walletBalance =
        await walletService.fetchBalanceById(transaction.walletId);
    if (walletBalance == null ||
        (isExpense && walletBalance < transaction.amount)) {
      return;
    }
    await _transactionService.addTransaction(transaction, isExpense);
    await walletService.changeAmount(
        walletId, isExpense ? (0 - amount) : amount);
    if (isExpense) {
      await SpendingLimitService.instance
          .updateCurrentSpendingInPeriod(amount, dateTime);
    }
    notifyListeners();
  }

  Future<void> updateTransaction(Transactions transaction) async {
    await _transactionService.updateTransaction(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(
      String id, double amount, DateTime dateTime) async {
    await _transactionService.deleteTransaction(id);
    await SpendingLimitService.instance
        .updateCurrentSpendingInPeriod(0 - amount, dateTime);
    notifyListeners();
  }
}
