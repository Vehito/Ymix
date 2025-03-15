class Transactions {
  final String? _id;
  final double _amount;
  final String _currencySymbol;
  final String _walletId;
  final String _categoryId;
  final DateTime _dateTime;
  final List<String>? _tags;
  final String? _comment;

  Transactions({
    String? id,
    required double amount,
    required String currencySymbol,
    required String walletId,
    required String categoryId,
    required DateTime dateTime,
    List<String>? tags,
    String? comment,
  })  : _id = id,
        _amount = amount,
        _currencySymbol = currencySymbol,
        _walletId = walletId,
        _categoryId = categoryId,
        _dateTime = dateTime,
        _tags = tags,
        _comment = comment;

  // Getters
  String? get id => _id;
  double get amount => _amount;
  String get currencySymbol => _currencySymbol;
  String get walletId => _walletId;
  String get categoryId => _categoryId;
  DateTime get dateTime => _dateTime;
  List<String>? get tags => _tags;
  String? get comment => _comment;

  Transactions copyWith({
    String? id,
    double? amount,
    String? currencySymbol,
    String? walletId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Transactions(
      id: id ?? _id,
      amount: amount ?? _amount,
      currencySymbol: currencySymbol ?? _currencySymbol,
      walletId: walletId ?? _walletId,
      categoryId: categoryId ?? _categoryId,
      dateTime: dateTime ?? _dateTime,
      tags: tags ?? _tags,
      comment: comment ?? _comment,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id ?? _dateTime.difference(DateTime(2020, 1, 1)).inSeconds,
        'amount': _amount,
        'currencySymbol': _currencySymbol,
        'walletId': _walletId,
        'categoryId': _categoryId,
        'dateTime': _dateTime.difference(DateTime(2020, 1, 1)).inDays,
        'comment': _comment,
      };

  factory Transactions.formJson(Map<String, dynamic> json) => Transactions(
        id: json['id'].toString(),
        amount: json['amount'],
        currencySymbol: json['currencySymbol'],
        walletId: json['walletId'],
        categoryId: json['categoryId'],
        dateTime: DateTime(2020, 1, 1).add(Duration(days: json['dateTime'])),
        comment: json['comment'],
      );
}
