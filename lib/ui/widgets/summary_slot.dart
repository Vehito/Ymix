import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import './pie_chart.dart';

class SummarySlot extends StatelessWidget {
  const SummarySlot(this.transactions, {super.key});

  final List<Transaction> transactions;

  List<Indicator>? _indecators() {
    List<Indicator> indicators = [];
    transactions.forEach((transaction) => {
      indicators.add(new Indicator(color: , text: text)),
    });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: () {}, child: const Dropdown()),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.timelapse),
                label: const Text('Period'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              DateFormat('dd/MM/yyyy').format(DateTime.now()),
              style: const TextStyle(fontSize: 25),
            ),
          ),
          const Center(
            child: PieChartSample2(),
          )
        ],
      ),
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
