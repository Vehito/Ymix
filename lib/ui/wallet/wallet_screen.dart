import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/wallet_manager.dart';
import 'package:ymix/models/wallet.dart';
import 'package:ymix/ui/screen.dart';
import 'package:ymix/ui/shared/format_helper.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<Wallet>> loadWallets() async {
      final manager = context.watch<WalletManager>();
      await manager.init();
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                alignment: Alignment.center,
                child: const Text("No Wallet"),
              ),
              FloatingActionButton(
                elevation: 10,
                backgroundColor: Colors.lightGreen.shade200,
                onPressed: () {
                  Navigator.pushNamed(context, WalletForm.routeName);
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final wallet = snapshot.data![index];
                    return Card(
                      color: Colors.white54,
                      child: ListTile(
                        title: Text(wallet.name),
                        leading: const Icon(Icons.wallet),
                        trailing: Text(
                          '${FormatHelper.numberFormat.format(wallet.balance)}đ',
                        ),
                        subtitle: Text(wallet.description ?? ''),
                        onTap: () => Navigator.pushNamed(
                            context, WalletForm.routeName,
                            arguments: wallet),
                      ),
                    );
                  },
                ),
              ),
              FloatingActionButton(
                elevation: 10,
                backgroundColor: Colors.lightGreen.shade200,
                onPressed: () {
                  Navigator.pushNamed(context, WalletForm.routeName);
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        }
      },
    );
  }
}
