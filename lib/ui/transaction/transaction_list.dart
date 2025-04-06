import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/transactions_manager.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/ui/shared/dialog_utils.dart';
import 'package:ymix/ui/widgets/transaction_card.dart';

class TransactionList extends StatefulWidget {
  const TransactionList(
      {super.key,
      this.transactionsId,
      this.categoryId,
      this.walletId,
      this.period,
      this.isEdit = true});
  static const routeName = 'transaction_list';
  final List<String>? transactionsId;
  final String? categoryId;
  final String? walletId;
  final DateTimeRange? period;
  final bool isEdit;
  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  Future<List<Transactions>> _loadTransaction() async {
    return context.watch<TransactionsManager>().getTransactions(
        idList: widget.transactionsId,
        categoryIds: widget.categoryId == null ? null : [widget.categoryId!],
        walletIds: widget.walletId == null ? null : [widget.walletId!],
        period: widget.period);
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
            } else if (snapshot.data!.isEmpty) {
              return const Center(child: Text("No Transaction!"));
            } else if (widget.isEdit) {
              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) =>
                    _buildCard(context, transactions[index]),
              );
            } else {
              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) => TransactionCard(
                  transactions[index],
                  onTap: () => Navigator.pushNamed(
                      context, '/transaction_detail', arguments: {
                    'transactionId': transactions[index].id,
                    'isEdit': widget.isEdit
                  }),
                ),
              );
            }
          }),
    );
  }

  Widget _buildCard(BuildContext context, Transactions transaction) {
    return Dismissible(
      key: ValueKey(transaction.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) =>
          showConfirmDialog(context, 'Do you wanna remove this transaction?'),
      onDismissed: (direction) async => await context
          .read<TransactionsManager>()
          .deleteTransaction(
              transaction.id!, transaction.amount, transaction.dateTime),
      child: TransactionCard(
        transaction,
        onTap: () => Navigator.pushNamed(context, '/transaction_detail',
            arguments: {
              'transactionId': transaction.id,
              'isEdit': widget.isEdit
            }),
      ),
    );
  }
}

class TransactionListAgrs {
  final String? walletId;
  final String? categoryId;
  final List<String>? transactionsId;
  final DateTimeRange? period;
  final bool isEdit;

  const TransactionListAgrs(
      {this.transactionsId,
      this.categoryId,
      this.walletId,
      this.period,
      this.isEdit = true});
}
