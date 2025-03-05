class Transaction {
  final String? _id;
  final double _amount;
  final String _currency;
  final String _walletId;
  final String _categoryId;
  final DateTime _dateTime;
  final List<String>? _tags;
  final String? _comment;

  Transaction({
    String? id,
    required double amount,
    required String currency,
    required String walletId,
    required String categoryId,
    required DateTime dateTime,
    List<String>? tags,
    String? comment,
  })  : _id = id,
        _amount = amount,
        _currency = currency,
        _walletId = walletId,
        _categoryId = categoryId,
        _dateTime = dateTime,
        _tags = tags,
        _comment = comment;

  // Getters
  String? get id => _id;
  double get amount => _amount;
  String get currency => _currency;
  String get walletId => _walletId;
  String get categoryId => _categoryId;
  DateTime get dateTime => _dateTime;
  List<String>? get tags => _tags;
  String? get comment => _comment;

  Transaction copyWith({
    String? id,
    double? amount,
    String? currency,
    String? walletId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Transaction(
      id: id ?? _id,
      amount: amount ?? _amount,
      currency: currency ?? _currency,
      walletId: walletId ?? _walletId,
      categoryId: categoryId ?? _categoryId,
      dateTime: dateTime ?? _dateTime,
      tags: tags ?? _tags,
      comment: comment ?? _comment,
    );
  }
}
