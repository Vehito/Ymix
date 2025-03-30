import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/wallet_manager.dart';
import 'package:ymix/models/wallet.dart';
import 'package:ymix/ui/screen.dart';
import 'package:ymix/ui/shared/dialog_utils.dart';
import 'package:ymix/ui/shared/format_helper.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<Wallet>> loadWallets() async {
      final manager = context.watch<WalletManager>();
      await manager.fetchAllCategory();
      return manager.wallets;
    }

    return FutureBuilder<List<Wallet>>(
      future: loadWallets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Lỗi tải dữ liệu!"));
        } else if (snapshot.data!.isEmpty) {
          return Container(
            alignment: Alignment.center,
            child: const Text("No Wallet"),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final wallet = snapshot.data![index];
              return _buildCard(wallet, context);
            },
          );
        }
      },
    );
  }

  Widget _buildCard(Wallet wallet, BuildContext context) {
    return Dismissible(
      key: ValueKey(wallet.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) =>
          showConfirmDialog(context, 'Do you wanna remove this wallet?'),
      onDismissed: (direction) =>
          context.read<WalletManager>().deleteWallet(wallet.id!),
      child: Card(
        color: Colors.white54,
        child: ListTile(
          title: Text(wallet.name),
          leading: const Icon(Icons.wallet),
          trailing: PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: () => Navigator.pushNamed(context, WalletForm.routeName,
                    arguments: wallet),
                child: const Text("Edit"),
              ),
              PopupMenuItem(
                onTap: () => Navigator.pushNamed(
                    context, TransactionList.routeName,
                    arguments: TransactionListAgrs(walletId: wallet.id)),
                child: const Text("Transaction History"),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${FormatHelper.numberFormat.format(wallet.balance)}đ'),
              Text(wallet.description ?? ''),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, WalletForm.routeName,
              arguments: wallet),
        ),
      ),
    );
  }
}
