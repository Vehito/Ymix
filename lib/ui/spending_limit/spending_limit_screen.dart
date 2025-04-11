import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/managers.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/spending_limit.dart';
import 'package:ymix/ui/screen.dart';
import 'package:ymix/ui/shared/dialog_utils.dart';
import 'package:ymix/ui/shared/format_helper.dart';
import 'package:ymix/ui/spending_limit/spending_limit_form.dart';
import '../shared/build_form.dart';

class SpendingLimitScreen extends StatefulWidget {
  const SpendingLimitScreen({super.key});

  @override
  State<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends State<SpendingLimitScreen> {
  final ValueNotifier<DateTime?> _chosenDate1 = ValueNotifier<DateTime?>(null);
  final ValueNotifier<DateTime?> _chosenDate2 = ValueNotifier<DateTime?>(null);

  String _displayDate() {
    if (_chosenDate1.value == null) {
      return '';
    } else if (_chosenDate2.value != null) {
      return ("From: ${FormatHelper.dateFormat.format(_chosenDate1.value!)} - To: ${FormatHelper.dateFormat.format(_chosenDate2.value!)}");
    }
    return FormatHelper.dateFormat.format(_chosenDate1.value!);
  }

  @override
  Widget build(BuildContext context) {
    final spendingLimitManager = context.watch<SpendingLimitManager>();
    final categoryManager = context.read<CategoryManager>();
    late final Set<Category> categories;

    Future<void> loadCategories() async {
      await categoryManager.init();
      categories = categoryManager.categories;
    }

    List<SpendingLimit> filterLimitList(List<SpendingLimit> limitList) {
      final List<SpendingLimit> newList = [];
      if (_chosenDate1.value == null) {
        return limitList;
      } else if (_chosenDate2.value == null) {
        for (var limit in limitList) {
          if (_chosenDate1.value!.isBefore(limit.start) ||
              _chosenDate1.value!.isAfter(limit.end)) {
            continue;
          }
          newList.add(limit);
        }
      } else {
        for (var limit in limitList) {
          if ((_chosenDate1.value!.isBefore(limit.start) &&
                  _chosenDate2.value!.isBefore(limit.end)) ||
              (_chosenDate1.value!.isAfter(limit.start) &&
                  _chosenDate2.value!.isAfter(limit.end))) {
            continue;
          }
          newList.add(limit);
        }
      }
      return newList;
    }

    Future<List<SpendingLimit>> loadLimitList() async {
      await loadCategories();
      await spendingLimitManager.fetchAllSpendingLimit();
      return spendingLimitManager.spendingLimitList;
    }

    Category loadCategory(String id) {
      return categories.firstWhere((ca) => ca.id == id);
    }

    Widget buildHeader() {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50)),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildDateBtn(context, (newDate) {
                  _chosenDate1.value = newDate;
                  _chosenDate2.value = null;
                }),
                buildPeriodBtn(context, (period) {
                  _chosenDate1.value = period.start;
                  _chosenDate2.value = period.end;
                }),
                ElevatedButton.icon(
                    icon: const Icon(Icons.autorenew),
                    onPressed: () {
                      _chosenDate1.value = null;
                      _chosenDate2.value = null;
                    },
                    label: const Text("Clear")),
              ],
            ),
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
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: buildHeader()),
        FutureBuilder<List<SpendingLimit>>(
          future: loadLimitList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return const SliverToBoxAdapter(
                  child: Center(child: Text("Lỗi tải dữ liệu!")));
            } else if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data!.isEmpty) {
              return const SliverToBoxAdapter(
                  child: Center(child: Text("No Spending Limit!")));
            } else {
              return ValueListenableBuilder(
                valueListenable: _chosenDate1,
                builder: (context, value, child) {
                  final limitList = _chosenDate1.value == null
                      ? snapshot.data!
                      : filterLimitList(snapshot.requireData);
                  return SliverList.separated(
                    itemCount: limitList.length,
                    itemBuilder: (context, index) => _buildCard(
                        loadCategory(limitList[index].categoryId),
                        limitList[index],
                        context),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                  );
                },
              );
            }
          },
        )
      ],
    );
  }

  Widget _buildCard(
      Category category, SpendingLimit limit, BuildContext context) {
    return Dismissible(
      key: ValueKey(limit.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showConfirmDialog(
          context, 'Do you wanna remove this spending limit?'),
      onDismissed: (direction) =>
          context.read<SpendingLimitManager>().deleteLimit(limit.id!),
      child: Card(
        color: limit.status == 'active'
            ? Colors.green.shade100
            : limit.status == 'exceeded'
                ? Colors.red.shade100
                : Colors.yellow.shade100,
        child: ListTile(
          leading: const Icon(Icons.bar_chart),
          title: Row(
            children: [
              const Text('Category: '),
              Icon(category.icon, color: category.color),
              Text(category.name)
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Current: ${FormatHelper.numberFormat.format(limit.currentSpending)}${limit.currencySymbol}'),
              Text(
                  'Amount:  ${FormatHelper.numberFormat.format(limit.amount)}${limit.currencySymbol}'),
              Text(
                  'Progress: ${((limit.currentSpending * 100) / limit.amount).toStringAsFixed(0)}%'),
              Text(
                  '${FormatHelper.dateFormat.format(limit.start)} - ${FormatHelper.dateFormat.format(limit.end)}'),
              Text('Status: ${limit.status}',
                  style: const TextStyle(fontSize: 15))
            ],
          ),
          trailing: PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: () => Navigator.pushNamed(
                    context, SpendingLimitForm.routeName,
                    arguments: limit),
                child: const Text("Edit"),
              ),
              PopupMenuItem(
                onTap: () => Navigator.pushNamed(
                    context, TransactionList.routeName,
                    arguments: TransactionListAgrs(
                        period:
                            DateTimeRange(start: limit.start, end: limit.end),
                        isExpense: true)),
                child: const Text("Transaction History"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
