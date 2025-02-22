class Transaction {
  final String? id;
  final int amount;
  final String currency;
  final String account;
  final String categoryId;
  final DateTime dateTime;
  final List<String>? tags;
  final String? comment;

  Transaction({
    this.id,
    required this.amount,
    required this.currency,
    required this.account,
    required this.categoryId,
    required this.dateTime,
    this.tags,
    this.comment,
  });

  Transaction copyWith({
    String? id,
    int? amount,
    String? currency,
    String? account,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      account: account ?? this.account,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
    );
  }
}
