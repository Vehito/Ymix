import 'package:flutter/material.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/models/transaction.dart';
import 'package:provider/provider.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile(this.transaction, {super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final category =
        context.read<CategoryManager>().getCategory(transaction.categoryId);
    return Card(
      margin: const EdgeInsets.only(bottom: 100),
      child: ListTile(
        style: ListTileStyle.list,
        leading: Icon(category.icon, color: category.color),
        title: Text(category.name.toUpperCase()),
        subtitle: Text("${transaction.amount}đ"),
        tileColor: category.color,
        onTap: () => print("hahaah"),
      ),
    );
  }
}
