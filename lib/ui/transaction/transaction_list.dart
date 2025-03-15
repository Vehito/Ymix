import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/ui/widgets/transaction_card.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key, this.transactionsId, this.categoryId});
  static const routeName = 'transaction_list';
  final List<String>? transactionsId;
  final String? categoryId;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  Future<List<Transactions>> _loadTransaction() async {
    final List<Transactions> transactions;
    if (widget.transactionsId != null) {
      transactions = await context
          .watch<TransactionsManager>()
          .getTransactionListWithId(widget.transactionsId!);
    } else if (widget.categoryId != null) {
      transactions = await context
          .watch<TransactionsManager>()
          .getTransactionsByCategoryId(widget.categoryId!);
    } else {
      transactions = [];
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction List"),
      ),
      body: FutureBuilder(
          future: _loadTransaction(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Lỗi tải dữ liệu!"));
            } else {
              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) => TransactionCard(
                  transactions[index],
                  onTap: () => Navigator.pushNamed(
                      context, '/transaction_detail',
                      arguments: transactions[index]),
                ),
              );
            }
          }),
    );
  }
}
