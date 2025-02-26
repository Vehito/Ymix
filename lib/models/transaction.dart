class Transaction {
  final String? _id;
  final int _amount;
  final String _currency;
  final String _accountId;
  final String _categoryId;
  final DateTime _dateTime;
  final List<String>? _tags;
  final String? _comment;

  Transaction({
    String? id,
    required int amount,
    required String currency,
    required String accountId,
    required String categoryId,
    required DateTime dateTime,
    List<String>? tags,
    String? comment,
  })  : _id = id,
        _amount = amount,
        _currency = currency,
        _accountId = accountId,
        _categoryId = categoryId,
        _dateTime = dateTime,
        _tags = tags,
        _comment = comment;

  // Getters
  String? get id => _id;
  int get amount => _amount;
  String get currency => _currency;
  String get accountId => _accountId;
  String get categoryId => _categoryId;
  DateTime get dateTime => _dateTime;
  List<String>? get tags => _tags;
  String? get comment => _comment;

  Transaction copyWith({
    String? id,
    int? amount,
    String? currency,
    String? accountId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Transaction(
      id: id ?? _id,
      amount: amount ?? _amount,
      currency: currency ?? _currency,
      accountId: accountId ?? _accountId,
      categoryId: categoryId ?? _categoryId,
      dateTime: dateTime ?? _dateTime,
      tags: tags ?? _tags,
      comment: comment ?? _comment,
    );
  }
}
