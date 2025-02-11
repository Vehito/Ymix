class Transaction {
  final String? id;
  final int amount;
  final String currency;
  final String account;
  final String category;
  final DateTime dateTime;
  final List<String>? tags;
  final String? comment;

  Transaction({
    this.id,
    required this.amount,
    required this.currency,
    required this.account,
    required this.category,
    required this.dateTime,
    this.tags,
    this.comment,
  });

  Transaction copyWith({
    String? id,
    int? amount,
    String? currency,
    String? account,
    String? category,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      account: account ?? this.account,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
    );
  }
}
