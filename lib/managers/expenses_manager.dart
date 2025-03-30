part of 'transactions_manager.dart';

class ExpensesManager extends TransactionsManager {
  ExpensesManager._internal()
      : super._internal(); // Constructor riêng của ExpensesManager

  static final ExpensesManager _instance = ExpensesManager._internal();
  static ExpensesManager get instance => _instance;

  List<Expense> _expenses = [];

  @override
  List<Transactions> get transactions => _expenses;
}
