import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/expenses_manager.dart';
import 'package:ymix/managers/income_manager.dart';
import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/transaction.dart';
import 'package:ymix/ui/widgets/pie_chart.dart';

import './transaction_form.dart';

import '../shared/build_form.dart';
import '../shared/format_helper.dart';

class TransactionsScreen extends StatefulWidget {
  static const routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedMode = 0;
  final DateTime _now = DateTime.now();
  late DateTime _chosenDate1;
  DateTime? _chosenDate2;
  double _total = 0;
  late TransactionsManager manager;
  late List<Transaction> _transactions;
  Map<String, double> _indicatorMap = {};
  late final List<Category> _categories;
  late final Future<void> _fetchCategoriesFuture;

  String _displayDate() {
    if (_chosenDate2 != null) {
      return ("From: ${FormatHelper.dateFormat.format(_chosenDate1)} - To: ${FormatHelper.dateFormat.format(_chosenDate2!)}");
    }
    return FormatHelper.dateFormat.format(_chosenDate1);
  }

  Future<void> _loadCategories() async {
    final manager = context.read<CategoryManager>();
    if (manager.categories.isEmpty) {
      await manager.fetchAllCategory();
      _categories = manager.categories;
    }
  }

  List<Transaction> _getTransactions() {
    manager = _selectedMode == 0
        ? context.watch<ExpensesManager>()
        : context.watch<IncomeManager>();

    List<Transaction> transactions = _chosenDate2 == null
        ? manager.getItemsWithDate(_chosenDate1)
        : manager.getItemsWithPeriod(_chosenDate1, _chosenDate2!);

    return transactions;
  }

  Map<String, double> _getIndicatorsData() {
    _transactions = _getTransactions();
    _total = _transactions.fold(0, (sum, t) => sum + t.amount);
    _indicatorMap = {};
    for (var transaction in _transactions) {
      _indicatorMap[transaction.categoryId] =
          (_indicatorMap[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return _indicatorMap;
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  @override
  void initState() {
    _chosenDate1 = _now;
    _fetchCategoriesFuture = _loadCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _bulidHeader(),
                  PieChartSample(_getIndicatorsData()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            color: Colors.white),
                        width: 200,
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '${FormatHelper.numberFormat.format(_total)}đ',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.green),
                        ),
                      ),
                      Container(
                        decoration: const ShapeDecoration(
                            shape: CircleBorder(), color: Colors.orangeAccent),
                        child: IconButton(
                          onPressed: () => Navigator.pushNamed(
                              context, TransactionForm.routeName),
                          // .then((value) => _onRefresh()),
                          icon: const Icon(Icons.add),
                          color: Colors.white,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: _fetchCategoriesFuture,
            builder: (context, snapshot) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => InkWell(
                  onTap: () {},
                  child: _buildCategoryCard(
                    _categories.firstWhere((category) =>
                        category.id == _indicatorMap.keys.elementAt(index)),
                    _indicatorMap.values.elementAt(index),
                  ),
                ),
                childCount: _indicatorMap.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulidHeader() {
    return Column(
      children: [
        const SizedBox(height: 10),
        buildToggleSwitch(
          _selectedMode,
          (changedMode) => (setState(() {
            _selectedMode = changedMode;
          })),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Dropdown(const ["Day", "Week", "Month", "Year"], (selectedValue) {
              switch (selectedValue) {
                case "Day":
                  setState(() {
                    _chosenDate1 = _now;
                    _chosenDate2 = null;
                  });
                  break;
                case "Week":
                  setState(() {
                    _chosenDate1 =
                        _now.subtract(Duration(days: _now.weekday - 1));
                    _chosenDate2 = _now.add(Duration(days: 7 - _now.weekday));
                  });
                  break;
                case "Month":
                  setState(() {
                    _chosenDate1 = DateTime(_now.year, _now.month, 1);
                    _chosenDate2 = DateTime(_now.year, _now.month + 1, 0);
                  });
                  break;
                case "Year":
                  setState(() {
                    _chosenDate1 = DateTime(_now.year, 1, 1);
                    _chosenDate2 = DateTime(_now.year, 12, 31);
                  });
                  break;
              }
            }),
            bulidDateBtn(context, (selectedDate) {
              _chosenDate1 = selectedDate;
              _chosenDate2 = null;
            }),
            bulidPeriodBtn(
              context,
              (selectedDate) => _chosenDate1 = selectedDate,
              (selectedDate) => _chosenDate2 = selectedDate,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _displayDate(),
          style: const TextStyle(
              fontSize: 20, color: Colors.black38, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category, double amount) {
    return Card(
      child: ListTile(
        minTileHeight: 20,
        leading: Icon(category.icon, color: category.color),
        title: Text(category.name),
        subtitle: Text('${FormatHelper.numberFormat.format(amount)}đ'),
        tileColor: category.color.withValues(alpha: 0.2),
      ),
    );
  }
}
