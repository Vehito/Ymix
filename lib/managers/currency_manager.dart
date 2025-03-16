import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:ymix/models/currency.dart';
import 'package:ymix/services/currency_service.dart';

class CurrencyManager with ChangeNotifier {
  static final CurrencyManager _instance = CurrencyManager._internal();
  static CurrencyManager get instance => _instance;

  CurrencyManager._internal();
  final CurrencyService _currencyService = CurrencyService.instance;
  List<Currency> _currencies = [];

  List<Currency> get currencies => _currencies;

  Future<void> init() async {
    if (_currencies.isEmpty) fetchAllCategory();
  }

  Future<void> fetchAllCategory() async {
    _currencies = await _currencyService.fetchAllCurrencies();
    await _currencyService.close();
  }

  Future<Currency?> getCurrencyByCode(String code) async {
    return _currencies.firstWhereOrNull((c) => c.code == code) ??
        await _currencyService.fetchCurrencyByCode(code);
  }

  Future<Currency?> getCurrencyBySymbol(String symbol) async {
    return _currencies.firstWhereOrNull((c) => c.symbol == symbol) ??
        await _currencyService.fetchCurrencyBySymbol(symbol);
  }
}
