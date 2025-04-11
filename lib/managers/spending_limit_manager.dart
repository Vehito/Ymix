import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ymix/models/spending_limit.dart';
import 'package:ymix/services/spending_limit_service.dart';
import 'package:ymix/services/transaction_service.dart';

class SpendingLimitManager with ChangeNotifier {
  static final SpendingLimitManager _instance =
      SpendingLimitManager._internal();
  static SpendingLimitManager get instance => _instance;

  SpendingLimitManager._internal();
  final SpendingLimitService _spendingLimitService =
      SpendingLimitService.instance;

  List<SpendingLimit> _spendingLimitList = [];

  List<SpendingLimit> get spendingLimitList => _spendingLimitList;

  Future<void> init() async {
    if (_spendingLimitList.isEmpty) await fetchAllSpendingLimit();
  }

  Future<void> fetchAllSpendingLimit() async {
    _spendingLimitList = await _spendingLimitService.fetchAllLimit();
    await _spendingLimitService.close();
  }

  Future<SpendingLimit?> getLimitById(String id) async {
    SpendingLimit? limit =
        _spendingLimitList.firstWhereOrNull((limit) => limit.id == id);
    return limit ?? await _spendingLimitService.fetchLimitById(id);
  }

  Future<void> addSpendingLimit(
      String categoryId,
      DateTime start,
      DateTime end,
      double amount,
      String currencySymbol,
      double currentSpending,
      String status,
      bool isSync) async {
    if (isSync) {
      currentSpending = await TransactionService.instance
          .getTotalAmountInPeriod(start, end,
              isExpense: true, categoryIds: [categoryId]);
    }
    if (currentSpending > amount) status = 'exceeded';
    if (end.isBefore(DateTime.now())) status = 'expired';
    final newLimit = await _spendingLimitService.addLimit(SpendingLimit(
        categoryId: categoryId,
        start: start,
        end: end,
        amount: amount,
        currencySymbol: currencySymbol,
        currentSpending: currentSpending,
        status: status));
    if (newLimit != null) _spendingLimitList.add(newLimit);
    notifyListeners();
  }

  Future<void> updateLimit(SpendingLimit limit) async {
    final oldCategoryId = (await getLimitById(limit.id!))!.categoryId;
    if (limit.categoryId != oldCategoryId) {
      final currentSpending = await TransactionService.instance
          .getTotalAmountInPeriod(limit.start, limit.end,
              isExpense: true, categoryIds: [limit.categoryId]);
      limit = limit.copyWith(currentSpending: currentSpending);
    }
    await _spendingLimitService.updateLimit(limit);
    notifyListeners();
  }

  Future<void> deleteLimit(String id) async {
    await _spendingLimitService.deleteLimit(id);
    notifyListeners();
  }
}
