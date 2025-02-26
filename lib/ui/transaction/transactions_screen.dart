import 'package:flutter/material.dart';
import '../widgets/summary_slot.dart';

class TransactionsScreen extends StatefulWidget {
  static const routeName = '/transactions';
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: SummarySlot(),
        )
      ],
    );
  }
}
