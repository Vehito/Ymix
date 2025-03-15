import 'package:ymix/models/income.dart';

import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/services/transaction_service.dart';

class IncomeManager extends TransactionsManager {
  static final IncomeManager _instance = IncomeManager._internal();
  static IncomeManager get instance => _instance;

  IncomeManager._internal();
  final TransactionService _transactionService = TransactionService.instance;
  List<Income> _incomes = [];

  @override
  List<Transactions> get transactions => _incomes;
}
