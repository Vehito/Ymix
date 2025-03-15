import 'package:flutter/material.dart';
import 'package:ymix/managers/wallet_manager.dart';
import 'package:ymix/services/transaction_service.dart';

import '../models/transactions.dart';

class TransactionsManager with ChangeNotifier {
  final TransactionService _transactionService = TransactionService.instance;

  List<Transactions> transactions = [];

  int get itemCount {
    return transactions.length;
  }

  Future<List<Transactions>> getTransactionsInDay(
      DateTime dateTime, bool isExpense) async {
    return await _transactionService.fetchTransactionsInDay(
        dateTime, isExpense);
  }

  Future<List<Transactions>> getTransactionInPeriod(
      DateTime start, DateTime end, bool isExpense) async {
    return _transactionService.fetchTransactionsInPeriod(start, end, isExpense);
  }

  Future<Transactions?> getTransactionWithId(String id) async {
    return await _transactionService.fetchTransactionById(id);
  }

  Future<List<Transactions>> getTransactionListWithId(
      List<String> idList) async {
    final List<Transactions> transactions = [];
    for (var id in idList) {
      transactions.add((await _transactionService.fetchTransactionById(id))!);
    }
    return transactions;
  }

  Future<List<Transactions>> getTransactionsByCategoryId(String id) async {
    return await _transactionService.fetchTransactionByCategoryId(id);
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
    final walletManager = WalletManager.instance;
    final wallet = await walletManager.getWalletById(transaction.walletId);
    if (wallet == null || wallet.balance < transaction.amount) return;

    await _transactionService.addTransaction(transaction, isExpense);
    await walletManager.editWallet(
        id: transaction.walletId,
        balance: (wallet.balance - transaction.amount));
    notifyListeners();
  }

  Future<void> updateTransaction(Transactions transaction) async {
    await _transactionService.updateTransaction(transaction);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    
  }
}
