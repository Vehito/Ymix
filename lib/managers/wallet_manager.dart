import 'package:flutter/material.dart';

import '../models/wallet.dart';

class WalletManager with ChangeNotifier {
  final List<Wallet> _items = [
    Wallet(id: '1', name: "main", balance: 100000),
    Wallet(id: 'aaa', name: "wtf", balance: 3523400),
    Wallet(id: '3', name: "mankind", balance: 124984906),
  ];

  List<Wallet> get allItems => _items;
}
