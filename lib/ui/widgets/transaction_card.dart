import 'package:flutter/material.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/models/transactions.dart';
import 'package:provider/provider.dart';

import '../shared/format_helper.dart';

// class TransactionList extends StatelessWidget {
//   const TransactionList(this.transactions, {super.key});

//   final List<Transaction> transactions;

//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       itemCount: transactions.length,
//       padding: const EdgeInsets.only(bottom: 20.0),
//       shrinkWrap: true,
//       itemBuilder: (context, index) {
//         return TransactionCard(transactions[index]);
//       },
//       separatorBuilder: (BuildContext context, int index) =>
//           const SizedBox(height: 10),
//     );
//   }
// }

class TransactionCard extends StatelessWidget {
  const TransactionCard(this.transaction, {super.key, this.onTap});

  final Transactions transaction;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final category =
        context.read<CategoryManager>().getCategory(transaction.categoryId);

    return Card(
      child: ListTile(
        minTileHeight: 20,
        leading: Icon(category.icon, color: category.color),
        title: Text(category.name.toUpperCase()),
        subtitle: Text(
            "${FormatHelper.numberFormat.format(transaction.amount)}${transaction.currencySymbol} - ${FormatHelper.dateFormat.format(transaction.dateTime)}"),
        tileColor: category.color.withValues(alpha: 0.2),
        onTap: onTap == null ? null : () => onTap!(),
      ),
    );
  }
}
