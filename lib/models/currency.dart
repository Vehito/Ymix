class Currency {
  final String _code;
  final String _symbol;
  final int _decimalDigits;
  final double _exchangeRate;

  Currency({
    required String code,
    required String symbol,
    required int decimalDigits,
    required double exchangeRate,
  })  : _code = code,
        _symbol = symbol,
        _decimalDigits = decimalDigits,
        _exchangeRate = exchangeRate;

  // Getters
  String get code => _code;
  String get symbol => _symbol;
  int get decimalDigits => _decimalDigits;
  double get exchangeRate => _exchangeRate;

  Currency copyWith({
    String? code,
    String? symbol,
    int? decimalDigits,
    double? exchangeRate,
  }) {
    return Currency(
      code: code ?? _code,
      symbol: symbol ?? _symbol,
      decimalDigits: decimalDigits ?? _decimalDigits,
      exchangeRate: exchangeRate ?? _exchangeRate,
    );
  }

  double convertTo(double amount, Currency targetCurrency) {
    return (amount / _exchangeRate) * targetCurrency._exchangeRate;
  }
}
