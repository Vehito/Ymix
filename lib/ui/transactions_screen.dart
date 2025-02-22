import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import './widgets/summary_slot.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int selectedMode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ymix"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: ToggleSwitch(
              animate: true,
              animationDuration: 500,
              centerText: true,
              minWidth: 400,
              initialLabelIndex: selectedMode, // Sử dụng biến trạng thái
              labels: const ['Expenses', 'Income'],
              activeBgColor: const [Colors.lightBlue],
              icons: const [Icons.money_off, Icons.attach_money],
              onToggle: (index) {
                setState(() {
                  selectedMode = index!; // Cập nhật trạng thái
                });
              },
            ),
          ),
          // const SizedBox(height: 30),
          Expanded(
            child: SummarySlot(selectedMode),
          )
        ],
      ),
    );
  }
}
