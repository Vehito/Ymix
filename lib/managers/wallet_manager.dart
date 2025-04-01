import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:ymix/services/wallet_service.dart';

import '../models/wallet.dart';

class WalletManager with ChangeNotifier {
  static final WalletManager _instance = WalletManager._internal();
  static WalletManager get instance => _instance;

  WalletManager._internal();
  final WalletService _walletService = WalletService.instance;

  List<Wallet> _wallets = [];

  List<Wallet> get wallets => _wallets;

  Future<void> init() async {
    if (_wallets.isEmpty) await fetchAllWallet();
  }

  Future<void> fetchAllWallet() async {
    _wallets = await _walletService.fetchAllWallet();
    await _walletService.close();
  }

  Future<Wallet?> getWalletById(String id) async {
    Wallet? wallet = _wallets.firstWhereOrNull((wallet) => wallet.id == id);
    return wallet ?? await _walletService.fetchWalletById(id);
  }

  String getWalletName(String id) {
    final wallet = _wallets.firstWhereOrNull((wallet) => wallet.id == id);
    if (wallet != null) {
      return wallet.name;
    }
    return "Unknown";
  }

  Future<void> addWallet(
      String name, double balance, String? description) async {
    final Wallet? newWallet =
        await _walletService.addWallet(Wallet(name: name, balance: balance));
    if (newWallet != null) {
      _wallets.add(newWallet);
    }
    notifyListeners();
  }

  Future<void> editWallet(
      {required String id,
      String? name,
      double? balance,
      String? description}) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index == -1) return;

    final Wallet updatedWallet = _wallets[index]
        .copyWith(name: name, balance: balance, description: description);

    final result = await _walletService.updateWallet(updatedWallet);
    if (result != null) _wallets[index] = updatedWallet;
    notifyListeners();
  }

  Future<void> deleteWallet(String id) async {
    await _walletService.deleteWallet(id);
    notifyListeners();
  }

  Future<void> changeAmount(
      {required String id, required double amount}) async {
    await _walletService.changeAmount(id, amount);
  }
}
