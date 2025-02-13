import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import './pie_chart.dart';

import '../shared/dialog_utils.dart';

class SummarySlot extends StatefulWidget {
  const SummarySlot(this.transactions, {super.key});

  final List<Transaction> transactions;

  @override
  State<SummarySlot> createState() => _SummarySlotState();
}

class _SummarySlotState extends State<SummarySlot> {
  DateTime _chosenDate1 = DateTime.now();
  DateTime? _chosenDate2;

  Map<String, double> _getIndicatorsData() {
    Map<String, double> indicatorMap = {};
    for (var transaction in widget.transactions) {
      indicatorMap[transaction.category] =
          (indicatorMap[transaction.category] ?? 0) + transaction.amount;
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
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints.expand(width: 350, height: 400),
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: const Dropdown()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _bulidDateForm(context),
              _bulidPeriodForm(context),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              _displayDate(),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Center(
            child: PieChartSample(_getIndicatorsData()),
          )
        ],
      ),
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
        setState(() {
          if (selectedDate != null) {
            _chosenDate1 = selectedDate;
          }
        });
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
        setState(() {
          if (selectedDate1 != null) {
            _chosenDate1 = selectedDate1;
          }
        });
        if (context.mounted) {
          final selectedDate2 = await showDatePicker(
            context: context,
            helpText: "Choose the end time",
            initialDate: currentDate,
            firstDate: DateTime(currentDate.year - 1),
            lastDate: DateTime(currentDate.year + 1),
            barrierLabel: "aaa",
          );
          setState(() {
            if (selectedDate2 != null &&
                selectedDate2.isAfter(selectedDate1!)) {
              _chosenDate2 = selectedDate2;
            } else {
              _chosenDate2 = null;
              showErrorDialog(context, "Invalid end time!");
            }
          });
        }
      },
    );
  }
}

class Dropdown extends StatefulWidget {
  const Dropdown({super.key});

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  static const List<String> list = <String>['Day', 'Week', 'Month', 'Year'];
  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.lightBlue),
      underline: Container(
        height: 2,
        color: Colors.blueAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      menuWidth: 100.0,
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
