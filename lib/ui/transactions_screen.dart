import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './widgets/summary_slot.dart';

import 'package:ymix/managers/transactions_manager.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SummarySlot(
        context.read<TransactionsManager>().items,
      ),
    );
  }
}
