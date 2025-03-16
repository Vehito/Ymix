import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/transactions_manager.dart';

import '../../managers/managers.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/currency.dart';
import 'package:ymix/models/transactions.dart';
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
  bool _isExpense = true;
  final DateTime _now = DateTime.now();
  final ValueNotifier<DateTime> _chosenDate1 =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<DateTime?> _chosenDate2 = ValueNotifier<DateTime?>(null);
  double _total = 0;
  late List<Transactions> _transactions;
  Map<String, double> _indicatorMap = {};
  late final Currency currency;

  String _displayDate() {
    if (_chosenDate2.value != null) {
      return ("From: ${FormatHelper.dateFormat.format(_chosenDate1.value)} - To: ${FormatHelper.dateFormat.format(_chosenDate2.value!)}");
    }
    return FormatHelper.dateFormat.format(_chosenDate1.value);
  }

  Future<Set<Category>> _loadCategories() async {
    final manager = context.read<CategoryManager>();
    if (manager.categories.isEmpty) {
      await manager.fetchAllCategory();
    }
    return manager.categories;
  }

  Future<void> _loadTransactions(TransactionsManager manager) async {
    _transactions = _chosenDate2.value == null
        ? await manager.getTransactionsInDay(_chosenDate1.value, _isExpense)
        : await manager.getTransactionInPeriod(
            _chosenDate1.value, _chosenDate2.value!, _isExpense);
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

  Future<void> _onRefresh() async {
    setState(() {});
  }

  void _updateIndicator(TransactionsManager manager) {
    setState(() {
      _getIndicatorsData(manager);
    });
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
                    _bulidHeader(transactionManager),
                    FutureBuilder(
                      future: _getIndicatorsData(transactionManager),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            _indicatorMap.isNotEmpty) {
                          return Column(
                            children: [
                              PieChartSample(_indicatorMap),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
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
                                        shape: CircleBorder(),
                                        color: Colors.orangeAccent),
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, TransactionForm.routeName);
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Lỗi: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Column(
                            children: [
                              PieChartSample(snapshot.requireData),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
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
                                        shape: CircleBorder(),
                                        color: Colors.orangeAccent),
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
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                )),
          ),
          FutureBuilder<Set<Category>>(
              future: _loadCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("Lỗi tải dữ liệu!")),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, 'transaction_list',
                              arguments: _getIdListInCategory(
                                  _indicatorMap.keys.elementAt(index)));
                        },
                        child: _buildCategoryCard(
                          snapshot.data!.firstWhere((category) =>
                              category.id ==
                              _indicatorMap.keys.elementAt(index)),
                          _indicatorMap.values.elementAt(index),
                        ),
                      ),
                      childCount: _indicatorMap.length,
                    ),
                  );
                }
              }),
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
            bulidDateBtn(context, (selectedDate) {
              _chosenDate1.value = selectedDate;
              _chosenDate2.value = null;
              _updateIndicator(manager);
            }),
            bulidPeriodBtn(
                context, (selectedDate) => _chosenDate1.value = selectedDate,
                (selectedDate) {
              _chosenDate2.value = selectedDate;
              _updateIndicator(manager);
            }),
          ],
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: _chosenDate1,
          builder: (context, value, child) => ValueListenableBuilder(
            valueListenable: _chosenDate2,
            builder: (context, value, child) => Text(
              _displayDate(),
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold),
            ),
          ),
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

  @override
  void dispose() {
    _chosenDate1.dispose();
    _chosenDate2.dispose();
    super.dispose();
  }
}
