part of 'transactions_manager.dart';

class IncomeManager extends TransactionsManager {
  IncomeManager._internal()
      : super._internal(); // Constructor riêng của IncomeManager

  static final IncomeManager _instance = IncomeManager._internal();
  static IncomeManager get instance => _instance;

  List<Income> _incomes = [];

  @override
  List<Transactions> get transactions => _incomes;
}
