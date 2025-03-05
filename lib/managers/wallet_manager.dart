import 'package:flutter/material.dart';

import '../models/wallet.dart';

class WalletManager with ChangeNotifier {
  final List<Wallet> _wallets = [
    Wallet(id: '1', name: "main", balance: 100000),
    Wallet(id: '2', name: "hahaha", balance: 3523400),
    Wallet(id: '3', name: "mankind", balance: 124984906),
  ];

  List<Wallet> get allItems => _wallets;

  Wallet getWallet(String id) =>
      _wallets.firstWhere((wallet) => wallet.id == id);

  String getWalletName(String id) =>
      _wallets.firstWhere((wallet) => wallet.id == id).name;
}
