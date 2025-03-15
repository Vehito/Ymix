import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/expenses_manager.dart';
import 'package:ymix/managers/income_manager.dart';
import 'package:ymix/managers/wallet_manager.dart';

import 'package:ymix/models/transactions.dart';

import '../shared/format_helper.dart';

import 'package:ymix/ui/screen.dart';

class TransactionDetail extends StatefulWidget {
  static const routeName = "/transaction_detail";
  const TransactionDetail(this.transactionId, {super.key});
  final String transactionId;

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  late Transactions transaction;
  Future<void> onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction detail'),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(
                      context, TransactionForm.routeName,
                      arguments: transaction)
                  .then((_) => onRefresh()),
              icon: const Icon(Icons.edit),
            )
          ],
        ),
        body: FutureBuilder<Transactions?>(
          future: context
              .read<TransactionsManager>()
              .getTransactionWithId(widget.transactionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Lỗi tải dữ liệu!"));
            } else if (snapshot.data == null) {
              return const Center(child: Text("No transaction"));
            } else {
              transaction = snapshot.data!;
              final category = context
                  .read<CategoryManager>()
                  .getCategory(transaction.categoryId);
              final walletName = context
                  .read<WalletManager>()
                  .getWalletName(transaction.walletId);
              return ListView(
                children: [
                  const SizedBox(height: 10),
                  //Amount
                  _buildCard(
                    "Amount",
                    Icons.attach_money,
                    "${FormatHelper.numberFormat.format(transaction.amount)}đ",
                    null,
                    null,
                  ),
                  //Wallet
                  _buildCard('Wallet', Icons.wallet, walletName, null, null),
                  //Category
                  _buildCard("Category", Icons.menu, category.name,
                      category.icon, category.color),
                  //Date
                  _buildCard(
                      'Day',
                      Icons.calendar_month,
                      FormatHelper.dateFormat.format(transaction.dateTime),
                      null,
                      null),
                  //Comment

                  ElevatedButton.icon(
                      onPressed: () {
                        transaction.id!.startsWith('e')
                            ? context
                                .read<ExpensesManager>()
                                .deleteTransaction(transaction.id!)
                            : context
                                .read<IncomeManager>()
                                .deleteTransaction(transaction.id!);
                        Navigator.pop(context);
                      },
                      label: const Text("DELETE",
                          style: TextStyle(color: Colors.red)),
                      icon: const Icon(Icons.remove_circle, color: Colors.red))
                ],
              );
            }
          },
        ));
  }

  Widget _buildCard(String title, IconData cardIcon, String content,
      IconData? contentIcon, Color? colorIcon) {
    return Card(
      color: Colors.white70,
      child: ListTile(
        title: Text(title),
        leading: Icon(cardIcon),
        subtitle: contentIcon == null
            ? Text(content)
            : Row(
                children: [
                  Icon(contentIcon, color: colorIcon),
                  const SizedBox(width: 10),
                  Text(content)
                ],
              ),
      ),
    );
  }
}
