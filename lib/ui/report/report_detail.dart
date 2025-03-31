import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/ui/shared/build_form.dart';
import 'package:ymix/ui/shared/format_helper.dart';
import 'package:ymix/ui/transaction/transaction_list.dart';
import 'package:ymix/ui/widgets/pie_chart.dart';

class ReportDetail extends StatefulWidget {
  const ReportDetail(
      {super.key, required this.transactions1, this.transactions2});

  final List<Transactions> transactions1;
  final List<Transactions>? transactions2;

  @override
  State<ReportDetail> createState() => _ReportDetailState();
}

class _ReportDetailState extends State<ReportDetail> {
  double _total = 0;
  final ValueNotifier<bool> _isExpense = ValueNotifier(true);
  Map<String, double> indicatorsData = {};

  @override
  Widget build(BuildContext context) {
    Future<Set<Category>> loadCategories() async {
      final categoryManager = context.read<CategoryManager>();
      await categoryManager.init();
      return categoryManager.categories;
    }

    List<String> getIdListInCategory(
        String categoryId, List<Transactions> transactions1) {
      final List<String> idList = [];
      for (var transaction in transactions1) {
        if (transaction.categoryId == categoryId) {
          idList.add(transaction.id!);
        }
      }
      return idList;
    }

    Map<String, double> getIndicatorsData(List<Transactions> transactions) {
      _total = transactions.fold(0, (sum, t) => sum + t.amount);
      indicatorsData = {};
      for (var transaction in transactions) {
        indicatorsData[transaction.categoryId] =
            (indicatorsData[transaction.categoryId] ?? 0) + transaction.amount;
      }
      return indicatorsData;
    }

    final transactions1 = widget.transactions1;
    final transactions2 = widget.transactions2;
    List<Transactions> usedTransactions = transactions1;

    getIndicatorsData(usedTransactions);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Detail'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  if (transactions2 != null) ...[
                    const SizedBox(height: 10),
                    buildToggleSwitch(
                      _isExpense.value ? 0 : 1,
                      (_) {
                        _isExpense.value = !_isExpense.value;
                        usedTransactions =
                            _isExpense.value ? transactions1 : transactions2;
                        getIndicatorsData(usedTransactions);
                      },
                    )
                  ],
                  const SizedBox(height: 15),
                  ValueListenableBuilder(
                    valueListenable: _isExpense,
                    builder: (context, value, child) => Column(
                      children: [
                        PieChartSample(indicatorsData),
                        const SizedBox(height: 10),
                        Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          FutureBuilder<Set<Category>>(
              future: loadCategories(),
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
                  return ValueListenableBuilder(
                    valueListenable: _isExpense,
                    builder: (context, value, child) => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              'transaction_list',
                              arguments: TransactionListAgrs(
                                transactionsId: getIdListInCategory(
                                    indicatorsData.keys.elementAt(index),
                                    usedTransactions),
                                isEdit: false,
                              ),
                            );
                          },
                          child: _buildCategoryCard(
                            snapshot.data!.firstWhere((category) =>
                                category.id ==
                                indicatorsData.keys.elementAt(index)),
                            indicatorsData.values.elementAt(index),
                          ),
                        ),
                        childCount: indicatorsData.length,
                      ),
                    ),
                  );
                }
              }),
        ],
      ),
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
