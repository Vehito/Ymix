import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/expenses_manager.dart';
import 'package:ymix/managers/income_manager.dart';
import 'package:ymix/ui/widgets/transaction_list.dart';

import '../../models/transaction.dart';
import './pie_chart.dart';

import '../shared/dialog_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SummarySlot extends StatefulWidget {
  const SummarySlot(this.selectedMode, {super.key});

  final int selectedMode; // 0 is expenses, 1 is income

  @override
  State<SummarySlot> createState() => _SummarySlotState();
}

class _SummarySlotState extends State<SummarySlot> {
  final DateTime _now = DateTime.now();
  DateTime _chosenDate1 = DateTime.now();
  DateTime? _chosenDate2;

  late List<Transaction> transactions;

  List<Transaction> _getTransactions() {
    final manager = widget.selectedMode == 0
        ? context.watch<ExpensesManager>()
        : context.watch<IncomeManager>();
    return _chosenDate2 == null
        ? manager.getItemsWithDate(_chosenDate1)
        : manager.getItemsWithPeriod(_chosenDate1, _chosenDate2!);
  }

  Map<String, double> _getIndicatorsData() {
    transactions = _getTransactions();
    Map<String, double> indicatorMap = {};
    for (var transaction in transactions) {
      indicatorMap[transaction.categoryId] =
          (indicatorMap[transaction.categoryId] ?? 0) + transaction.amount;
    }
    return indicatorMap;
  }

  String _displayDate() {
    if (_chosenDate2 != null) {
      return ("From: ${DateFormat('dd/MM/yyyy').format(_chosenDate1)} - To: ${DateFormat('dd/MM/yyyy').format(_chosenDate2!)}");
    }
    return DateFormat('dd/MM/yyyy').format(_chosenDate1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          collapsedHeight: 200,
          backgroundColor: Colors.green.shade200,
          flexibleSpace: FlexibleSpaceBar(
            title: _bulidHeader(),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 30),
              constraints: const BoxConstraints.expand(width: 250, height: 200),
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(70)),
                color: Color.fromARGB(255, 165, 214, 167),
              ),
              child: PieChartSample(_getIndicatorsData())),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => TransactionTile(transactions[index]),
            childCount: transactions.length,
          ),
        ),
      ],
    );
  }

  Widget _bulidHeader() {
    return Column(
      children: [
        const SizedBox(height: 30),
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
                _chosenDate1 = _now.subtract(Duration(days: _now.weekday - 1));
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bulidDateForm(context),
            _bulidPeriodForm(context),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          _displayDate(), 
          style: const TextStyle(
              fontSize: 20, color: Colors.black38, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _bulidDateForm(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.calendar_month),
      label: const Text("Choose date"),
      onPressed: () async {
        final currentDate = DateTime.now();
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(currentDate.year - 1),
          lastDate: DateTime(currentDate.year + 1),
        );
        if (selectedDate != null) {
          setState(() {
            _chosenDate1 = selectedDate;
            _chosenDate2 = null;
          });
        }
      },
    );
  }

  Widget _bulidPeriodForm(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.timelapse),
      label: const Text("Choose Period"),
      onPressed: () async {
        final currentDate = DateTime.now();
        final selectedDate1 = await showDatePicker(
          context: context,
          helpText: "Choose the starting time",
          initialDate: currentDate,
          firstDate: DateTime(currentDate.year - 1),
          lastDate: DateTime(currentDate.year + 1),
        );

        if (selectedDate1 != null) {
          setState(() {
            _chosenDate1 = selectedDate1;
          });
        }

        if (context.mounted) {
          final selectedDate2 = await showDatePicker(
            context: context,
            helpText: "Choose the end time",
            initialDate: currentDate,
            firstDate: DateTime(currentDate.year - 1),
            lastDate: DateTime(currentDate.year + 1),
            barrierLabel: "aaa",
          );
          if (!context.mounted) {
            return; // Chỉ kiểm tra một lần trước khi thực hiện bất kỳ thao tác nào
          }
          if (selectedDate2 != null && selectedDate2.isAfter(selectedDate1!)) {
            setState(() => _chosenDate2 = selectedDate2);
          } else {
            setState(() => _chosenDate2 = null);
            showErrorDialog(context, "Invalid end time!");
          }
        }
      },
    );
  }
}

class Dropdown extends StatefulWidget {
  const Dropdown(this.valueList, this.onPressed, {super.key});

  final List<String> valueList;
  final Function(String selectedValue) onPressed;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.valueList.isNotEmpty) {
      selectedValue = widget.valueList.first;
    } else {
      showErrorDialog(context, "Selected value is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      value: selectedValue,
      buttonStyleData: ButtonStyleData(
        height: 40,
        width: 100,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        elevation: 2,
      ),
      style: const TextStyle(color: Colors.green),
      onChanged: (String? value) {
        setState(() {
          selectedValue = value!;
          widget.onPressed(selectedValue!);
        });
      },
      items: widget.valueList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
