import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/models/transaction.dart';
import 'package:provider/provider.dart';

class TransactionList extends StatelessWidget {
  const TransactionList(this.transactions, {super.key});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.only(bottom: 20.0),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return TransactionTile(transactions[index]);
      },
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile(this.transaction, {super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final category =
        context.read<CategoryManager>().getCategory(transaction.categoryId);
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    return Card(
      child: ListTile(
        minTileHeight: 20,
        leading: Icon(category.icon, color: category.color),
        title: Text(category.name.toUpperCase()),
        subtitle: Text("${currencyFormat.format(transaction.amount)}đ"),
        tileColor: category.color.withValues(alpha: 0.2),
        onTap: () => print("hahaah"),
      ),
    );
  }
}
