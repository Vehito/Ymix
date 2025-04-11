import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/ui/screen.dart';

import '../../managers/managers.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/currency.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/ui/widgets/pie_chart.dart';

import '../shared/build_form.dart';
import '../shared/format_helper.dart';

class TransactionsScreen extends StatefulWidget {
  static const routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isExpense = true;
  final DateTime _now = DateTime.now();
  final ValueNotifier<DateTime> _chosenDate1 =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime?> _chosenDate2 = ValueNotifier<DateTime?>(null);
  double _total = 0;
  late List<Transactions> _transactions;
  Map<String, double> _indicatorMap = {};
  late final Currency currency;
  List<Category> categories = [];

  String _displayDate() {
    if (_chosenDate2.value != null) {
      return ("From: ${FormatHelper.dateFormat.format(_chosenDate1.value)} - To: ${FormatHelper.dateFormat.format(_chosenDate2.value!)}");
    }
    return FormatHelper.dateFormat.format(_chosenDate1.value);
  }

  Future<void> _loadCategories() async {
    final manager = context.read<CategoryManager>();
    if (manager.categories.isEmpty) {
      await manager.fetchAllCategory();
    }
    categories = manager.categories.toList();
  }

  Future<void> _loadTransactions(TransactionsManager manager) async {
    _transactions = _chosenDate2.value == null
        ? await manager.getTransactions(
            dateTime: _chosenDate1.value, isExpense: _isExpense)
        : await manager.getTransactions(
            period: DateTimeRange(
                start: _chosenDate1.value, end: _chosenDate2.value!),
            isExpense: _isExpense);
  }

  Future<Map<String, double>> _getIndicatorsData(
      TransactionsManager manager) async {
    await _loadTransactions(manager);

    _total = _transactions.fold(0, (sum, t) => sum + t.amount);
    _indicatorMap = {};
    for (var transaction in _transactions) {
      _indicatorMap[transaction.categoryId] =
          (_indicatorMap[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return _indicatorMap;
  }

  // Future<void> _onRefresh(TransactionsManager manager) async {
  //   await _updateIndicator(manager);
  // }

  Future<void> _updateIndicator(TransactionsManager manager) async {
    await _getIndicatorsData(manager);
    setState(() {});
  }

  List<String> _getIdListInCategory(String categoryId) {
    final List<String> idList = [];
    for (var transaction in _transactions) {
      if (transaction.categoryId == categoryId) {
        idList.add(transaction.id!);
      }
    }
    return idList;
  }

  @override
  void initState() {
    _chosenDate1.value = _now;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final transactionManager = context.watch<TransactionsManager>();
    return RefreshIndicator(
      onRefresh: () async => await _updateIndicator(transactionManager),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: _getIndicatorsData(transactionManager),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _indicatorMap.isNotEmpty) {
                  return _buildSummarySlot(_indicatorMap, transactionManager);
                } else if (snapshot.hasError) {
                  return Text('Lỗi: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return _buildSummarySlot(
                      snapshot.requireData, transactionManager);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
          FutureBuilder(
            future: _loadCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: CircularProgressIndicator(),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          'transaction_list',
                          arguments: TransactionListAgrs(
                            transactionsId: _getIdListInCategory(
                                _indicatorMap.keys.elementAt(index)),
                          ),
                        );
                      },
                      child: _buildCategoryCard(
                        categories.firstWhere((category) =>
                            category.id == _indicatorMap.keys.elementAt(index)),
                        _indicatorMap.values.elementAt(index),
                      ),
                    ),
                    childCount: _indicatorMap.length,
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Widget _bulidHeader(TransactionsManager manager) {
    return Column(
      children: [
        const SizedBox(height: 10),
        buildToggleSwitch(
          _isExpense ? 0 : 1,
          (_) {
            _isExpense = !_isExpense;
            _updateIndicator(manager);
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Dropdown(const ["Day", "Week", "Month", "Year"], (selectedValue) {
              switch (selectedValue) {
                case "Day":
                  _chosenDate1.value = _now;
                  _chosenDate2.value = null;

                  break;
                case "Week":
                  _chosenDate1.value =
                      _now.subtract(Duration(days: _now.weekday - 1));
                  _chosenDate2.value =
                      _now.add(Duration(days: 7 - _now.weekday));

                  break;
                case "Month":
                  _chosenDate1.value = DateTime(_now.year, _now.month, 1);
                  _chosenDate2.value = DateTime(_now.year, _now.month + 1, 0);

                  break;
                case "Year":
                  _chosenDate1.value = DateTime(_now.year, 1, 1);
                  _chosenDate2.value = DateTime(_now.year, 12, 31);

                  break;
              }
              _updateIndicator(manager);
            }),
            buildDateBtn(context, (selectedDate) {
              _chosenDate1.value = selectedDate;
              _chosenDate2.value = null;
              _updateIndicator(manager);
            }),
            buildPeriodBtn(
              context,
              (period) {
                _chosenDate1.value = period.start;
                _chosenDate2.value = period.end;
                _updateIndicator(manager);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: _chosenDate1,
          builder: (context, value, child) => Text(
            _displayDate(),
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black38,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySlot(
      Map<String, double> indicatorMap, TransactionsManager manager) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.green.shade200,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        child: Column(children: [
          _bulidHeader(manager),
          ValueListenableBuilder(
              valueListenable: _chosenDate1,
              builder: (context, value, child) =>
                  PieChartSample(_indicatorMap)),
          const SizedBox(height: 10),
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white),
            width: 200,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              '${FormatHelper.numberFormat.format(_total)}đ',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
          ),
          const SizedBox(height: 10)
        ]));
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

  @override
  void dispose() {
    _chosenDate1.dispose();
    _chosenDate2.dispose();
    super.dispose();
  }
}
