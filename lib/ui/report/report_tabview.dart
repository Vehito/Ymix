import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/ui/report/parameters_form.dart';
import 'package:ymix/ui/report/report_detail.dart';
import 'package:ymix/ui/shared/format_helper.dart';
import 'package:ymix/ui/widgets/bar_chart.dart';

class ReportTabview extends StatefulWidget {
  const ReportTabview({
    super.key,
    required this.mode,
    required this.isExpense,
  });

  final String mode;
  final bool? isExpense;

  @override
  State<ReportTabview> createState() => _ReportTabviewState();
}

class _ReportTabviewState extends State<ReportTabview> {
  final ValueNotifier<DateTimeRange?> _period = ValueNotifier(null);
  final ValueNotifier<List<String>?> _walletIds = ValueNotifier(null);
  final ValueNotifier<List<String>?> _categoryIds = ValueNotifier(null);

  ValueNotifier<int> combinedNotifier = ValueNotifier(0);

  void updateCombinedNotifier() {
    combinedNotifier.value++;
  }

  void setupListeners() {
    _period.addListener(updateCombinedNotifier);
    _walletIds.addListener(updateCombinedNotifier);
    _categoryIds.addListener(updateCombinedNotifier);
  }

  DateTimeRange _getRange() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    switch (widget.mode) {
      case 'DATE':
        return DateTimeRange(
          start: DateTime(year, month, 1),
          end: DateTime(year, month + 1, 0),
        );
      case 'QUARTER':
        // final startMonthOfQuarter = ((month - 1) ~/ 3) * 3 + 1;
        // return DateTimeRange(
        //   start: DateTime(year, startMonthOfQuarter),
        //   end: DateTime(year, startMonthOfQuarter + 2),
        // );
        return DateTimeRange(
          start: DateTime(year, 1, 1),
          end: DateTime(year, 12, 31),
        );
      case 'MONTH':
        return DateTimeRange(
          start: DateTime(year, 1, 1),
          end: DateTime(year, 12, 31),
        );
      case 'YEAR':
        return DateTimeRange(
          start: DateTime(year - 3),
          end: DateTime(year + 3),
        );
      case 'CUSTOM':
        return DateTimeRange(
          start: DateTime(year, month, 1),
          end: DateTime(year, month + 1, 0),
        );
    }
    return DateTimeRange(start: now, end: now);
  }

  List<String> _getIndicatorsName() {
    switch (widget.isExpense) {
      case true:
        return ['Expense'];
      case false:
        return ['Income'];
      case null:
        return ['Expense', 'Income'];
    }
  }

  @override
  void initState() {
    _period.addListener(updateCombinedNotifier);
    _walletIds.addListener(updateCombinedNotifier);
    _categoryIds.addListener(updateCombinedNotifier);
    super.initState();
  }

  @override
  void dispose() {
    _period.removeListener(updateCombinedNotifier);
    _walletIds.removeListener(updateCombinedNotifier);
    _categoryIds.removeListener(updateCombinedNotifier);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    final List<String> titleList = [];
    final List<double> totalAmount = [];
    final Map<String, List<Transactions>> transactionsData = {};

    String handleTitleIndex(DateTime dateTime) {
      switch (widget.mode) {
        case 'DATE':
          return FormatHelper.dayMonthFormat.format(dateTime);
        case 'MONTH':
          return FormatHelper.monthFormat.format(dateTime);
        case 'YEAR':
          return dateTime.year.toString();
        case 'QUARTER':
          final quarter = ((dateTime.month - 1) ~/ 3) + 1;
          return 'Q$quarter';
        case 'CUSTOM':
          return FormatHelper.dayMonthFormat.format(dateTime);
      }
      return FormatHelper.dateFormat.format(dateTime);
    }

    List<List<double>> handleFetchedData(
        {required List<Transactions> transactions1,
        List<Transactions>? transactions2}) {
      final Map<String, double> data1 = {};

      titleList.clear();
      totalAmount.clear();
      transactionsData.clear();
      totalAmount.add(0);
      for (var transaction in transactions1) {
        totalAmount[0] += transaction.amount;
        final index = handleTitleIndex(transaction.dateTime);
        if (!titleList.contains(index)) titleList.add(index);
        if (data1.containsKey(index)) {
          data1[index] = data1[index]! + transaction.amount;
          transactionsData['e$index']!.add(transaction);
        } else {
          data1[index] = transaction.amount;
          transactionsData['e$index'] = [transaction];
        }
      }
      if (transactions2 != null) {
        final Map<String, double> data2 = {};
        totalAmount.add(0);
        for (var income in transactions2) {
          totalAmount[1] += income.amount;
          final index = handleTitleIndex(income.dateTime);
          if (!titleList.contains(index)) titleList.add(index);
          if (data2.containsKey(index)) {
            data2[index] = data2[index]! + income.amount;
            transactionsData['i$index']!.add(income);
          } else {
            data2[index] = income.amount;
            transactionsData['i$index'] = [income];
          }
        }
        for (var title in titleList) {
          if (!data2.containsKey(title)) data2[title] = 0;
        }
        return [data1.values.toList(), data2.values.toList()];
      }
      return [data1.values.toList()];
    }

    List<Color> getColors() {
      if (widget.isExpense != null) return [Colors.green];
      return [Colors.red, Colors.green];
    }

    List<Gradient> getGradients() {
      if (widget.isExpense != null) {
        return [
          const LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)
        ];
      } else {
        return [
          const LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          const LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)
        ];
      }
    }

    Future<List<List<double>>> getData() async {
      if (widget.isExpense != null) {
        final transactions = await transactionsManager.getTransactions(
            period: _period.value ?? _getRange(),
            categoryIds: _categoryIds.value,
            walletIds: _walletIds.value,
            isExpense: widget.isExpense);
        return handleFetchedData(transactions1: transactions);
      } else {
        final expenses = await transactionsManager.getTransactions(
            period: _period.value ?? _getRange(),
            categoryIds: _categoryIds.value,
            walletIds: _walletIds.value,
            isExpense: true);
        final incomes = await transactionsManager.getTransactions(
            period: _period.value ?? _getRange(),
            categoryIds: _categoryIds.value,
            walletIds: _walletIds.value,
            isExpense: false);
        return handleFetchedData(
            transactions1: expenses, transactions2: incomes);
      }
    }

    Widget buildSummarySlot() {
      return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu!"));
          } else {
            final data = snapshot.requireData;
            final dataListLength = data.length;
            final dataLength = data[0].length;
            final summaryName = widget.isExpense == null
                ? (['expense', 'income'])
                : widget.isExpense!
                    ? ['expense']
                    : ['income'];
            const textStyle = TextStyle(color: Colors.black45, fontSize: 17);
            return Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        BarChartSample(
                          indicatorsDataList: data,
                          titleList: titleList,
                          indicatorsName: _getIndicatorsName(),
                          colorList: getColors(),
                          gradientList: getGradients(),
                        ),
                        const SizedBox(height: 10),
                        ...List<Widget>.generate(
                          dataListLength,
                          (index) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total ${summaryName[index]}',
                                  style: textStyle),
                              Text(
                                  '${FormatHelper.numberFormat.format(totalAmount[index])}đ')
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...List<Widget>.generate(
                          dataListLength,
                          (index) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Average ${summaryName[index]}/${widget.mode.toLowerCase()}',
                                  style: textStyle),
                              Text(
                                  '${dataLength == 0 ? '0' : FormatHelper.numberFormat.format(totalAmount[index] / dataLength)}đ')
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 15),
                Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        ...List.generate(
                          dataLength,
                          (index) => Column(children: [
                            _buildListTile(
                                amount1: data[0][index],
                                amount2: widget.isExpense == null
                                    ? data[1][index]
                                    : null,
                                title: titleList[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportDetail(
                                        transactions1: transactionsData[
                                            'e${titleList[index]}']!,
                                        transactions2: transactionsData[
                                            'i${titleList[index]}'],
                                      ),
                                    ),
                                  );
                                }),
                            const Divider(),
                          ]),
                        )
                      ],
                    ))
              ],
            );
          }
        },
      );
    }

    return ListView(
      children: [
        ValueListenableBuilder(
          valueListenable: _period,
          builder: (context, value, child) => _buildOptionCard(
              period: _period.value ?? _getRange(),
              isCustom: widget.mode == 'CUSTOM',
              onTap: () async {
                final data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParametersForm(
                          mode: widget.mode,
                          originalPeriod: _period.value ?? _getRange(),
                          originalWalletIds: _walletIds.value,
                          originalCategoryIds: _categoryIds.value),
                    )) as ParametersFormOutput?;
                if (data == null) return;
                _period.value = data.period;
                _walletIds.value = data.walletIds;
                _categoryIds.value = data.categoryIds;
              }),
        ),
        const SizedBox(height: 15),
        ValueListenableBuilder(
          valueListenable: combinedNotifier,
          builder: (context, value, child) => buildSummarySlot(),
        )
      ],
    );
  }
}

class CurrentTabView extends StatefulWidget {
  const CurrentTabView({super.key});

  @override
  State<CurrentTabView> createState() => _CurrentTabViewState();
}

class _CurrentTabViewState extends State<CurrentTabView> {
  final ValueNotifier<List<String>?> _walletIds = ValueNotifier(null);
  final ValueNotifier<List<String>?> _categoryIds = ValueNotifier(null);
  final ValueNotifier<int> _combine = ValueNotifier(0);
  final List<double> totals = [0, 0, 0, 0, 0, 0];

  void updateCombinedNotifier() {
    _combine.value++;
  }

  void setupListeners() {
    _walletIds.addListener(updateCombinedNotifier);
    _categoryIds.addListener(updateCombinedNotifier);
  }

  @override
  void initState() {
    super.initState();
    setupListeners();
  }

  @override
  void dispose() {
    _walletIds.removeListener(updateCombinedNotifier);
    _categoryIds.removeListener(updateCombinedNotifier);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsManager = context.watch<TransactionsManager>();
    Future<List<Transactions>> getTransaction(
        {required DateTimeRange period,
        List<String>? walletIds,
        List<String>? categoryIds,
        bool? isExpense}) async {
      return await transactionsManager.getTransactions(
          period: period,
          walletIds: walletIds,
          categoryIds: categoryIds,
          isExpense: isExpense);
    }

    Future<double> getAmount(
        {required DateTimeRange period,
        bool? isExpense,
        List<String>? walletIds,
        List<String>? categoryIds}) async {
      return await transactionsManager.getTotalAmountInPeriod(
          period.start, period.end,
          walletIds: walletIds, categoryIds: categoryIds, isExpense: isExpense);
    }

    Future<void> loadTotalList(DateTime now) async {
      final startMonthOfQuarter =
          now.month.remainder(3) == 0 ? now.month ~/ 3 : now.month - 2;
      totals.clear();
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month + 1, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month + 1, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, startMonthOfQuarter, 1),
              end: DateTime(now.year, startMonthOfQuarter + 3, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, startMonthOfQuarter, 1),
              end: DateTime(now.year, startMonthOfQuarter + 3, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      totals.add(await getAmount(
          period: DateTimeRange(
              start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
    }

    Future<List<List<Transactions>>> getData() async {
      final List<List<Transactions>> data = [];
      final now = DateTime.now();
      final startMonthOfQuarter =
          now.month.remainder(3) == 0 ? now.month ~/ 3 : now.month - 2;
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month + 1, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month + 1, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, startMonthOfQuarter, 1),
              end: DateTime(now.year, startMonthOfQuarter + 3, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, startMonthOfQuarter, 1),
              end: DateTime(now.year, startMonthOfQuarter + 3, 0)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: true));
      data.add(await getTransaction(
          period: DateTimeRange(
              start: DateTime(now.year, 1, 1), end: DateTime(now.year, 12, 31)),
          walletIds: _walletIds.value,
          categoryIds: _categoryIds.value,
          isExpense: false));
      await loadTotalList(now);
      return data;
    }

    return ListView(
      children: [
        _buildOptionCard(
            period: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
            isCustom: false,
            onTap: () async {
              final data = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ParametersForm(
                      mode: 'CURRENT',
                      originalPeriod: DateTimeRange(
                          start: DateTime.now(), end: DateTime.now()),
                      originalWalletIds: _walletIds.value,
                      originalCategoryIds: _categoryIds.value,
                    ),
                  )) as ParametersFormOutput?;
              if (data == null) return;
              _walletIds.value = data.walletIds;
              _categoryIds.value = data.categoryIds;
            }),
        const SizedBox(height: 20),
        Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black26),
                borderRadius: const BorderRadius.all(Radius.circular(15))),
            child: ValueListenableBuilder(
              valueListenable: _combine,
              builder: (context, value, child) {
                return FutureBuilder(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Lỗi tải dữ liệu!"));
                    } else {
                      final data = snapshot.requireData;
                      return Column(
                        children: [
                          _buildListTile(
                              amount1: totals[0],
                              amount2: totals[1],
                              title: 'This Month',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportDetail(
                                              transactions1: data[0],
                                              transactions2: data[1],
                                            )));
                              }),
                          const Divider(),
                          _buildListTile(
                              amount1: totals[2],
                              amount2: totals[3],
                              title: 'This Quarter',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportDetail(
                                              transactions1: data[2],
                                              transactions2: data[3],
                                            )));
                              }),
                          const Divider(),
                          _buildListTile(
                              amount1: totals[4],
                              amount2: totals[5],
                              title: 'This Year',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportDetail(
                                              transactions1: data[4],
                                              transactions2: data[5],
                                            )));
                              })
                        ],
                      );
                    }
                  },
                );
              },
            ))
      ],
    );
  }
}

Widget _buildListTile(
    {required double amount1,
    double? amount2,
    required String title,
    void Function()? onTap}) {
  return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, color: Colors.black54)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${FormatHelper.numberFormat.format(amount1)}đ',
                    style: TextStyle(
                        fontSize: 17,
                        color:
                            amount2 != null ? Colors.red : Colors.blueAccent)),
                if (amount2 != null) ...[
                  Text('${FormatHelper.numberFormat.format(amount2)}đ',
                      style:
                          const TextStyle(fontSize: 17, color: Colors.green)),
                  const SizedBox(
                    width: 70,
                    child: Divider(),
                  ),
                  Text(
                      '${FormatHelper.numberFormat.format(amount2 - amount1)}đ',
                      style: const TextStyle(fontSize: 17)),
                ],
              ],
            ),
          ],
        ),
      ));
}

Widget _buildOptionCard(
    {required DateTimeRange period,
    required bool isCustom,
    void Function()? onTap}) {
  return Card(
    color: Colors.white,
    child: ListTile(
      leading: const Icon(Icons.calendar_month),
      title: Text(
        (isCustom
            ? '${FormatHelper.dateFormat.format(period.start)} - ${FormatHelper.dateFormat.format(period.end)}'
            : (period.start.year == period.end.year)
                ? period.start.year.toString()
                : '${period.start.year.toString()} - ${period.end.year.toString()}'),
      ),
      trailing: IconButton(onPressed: onTap, icon: const Icon(Icons.settings)),
    ),
  );
}
