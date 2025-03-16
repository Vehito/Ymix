class SpendingLimit {
  final String? _id;
  final String _categoryId;
  final DateTime _start;
  final DateTime _end;
  final double _amount;
  final String _currencySymbol;
  final double _currentSpending;
  final String _status;

  SpendingLimit(
      {String? id,
      required String categoryId,
      required DateTime start,
      required DateTime end,
      required double amount,
      required String currencySymbol,
      required double currentSpending,
      required String status})
      : _id = id,
        _categoryId = categoryId,
        _start = start,
        _end = end,
        _amount = amount,
        _currentSpending = currentSpending,
        _currencySymbol = currencySymbol,
        _status = status;

  // Getters
  String? get id => _id;
  String get categoryId => _categoryId;
  DateTime get start => _start;
  DateTime get end => _end;
  double get amount => _amount;
  String get currencySymbol => _currencySymbol;
  double get currentSpending => _currentSpending;
  String get status => _status;

  SpendingLimit copyWith(
      {String? id,
      String? categoryId,
      DateTime? start,
      DateTime? end,
      double? amount,
      String? currencySymbol,
      double? currentSpending,
      String? status}) {
    return SpendingLimit(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        start: start ?? this.start,
        end: end ?? this.end,
        amount: amount ?? this.amount,
        currencySymbol: currencySymbol ?? _currencySymbol,
        currentSpending: currentSpending ?? this.currentSpending,
        status: status ?? this.status);
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'categoryId': _categoryId,
        'start': _start.difference(DateTime(2020, 1, 1)).inDays,
        'end': _end.difference(DateTime(2020, 1, 1)).inDays,
        'amount': _amount,
        'currencySymbol': _currencySymbol,
        'currentSpending': _currentSpending,
        'status': _status,
      };

  factory SpendingLimit.formJson(Map<String, dynamic> json) => SpendingLimit(
      id: json['id'].toString(),
      categoryId: json['categoryId'],
      start: DateTime(2020, 1, 1).add(Duration(days: json['start'])),
      end: DateTime(2020, 1, 1).add(Duration(days: json['end'])),
      amount: json['amount'],
      currencySymbol: json['currencySymbol'],
      currentSpending: json['currentSpending'],
      status: json['status']);
}
