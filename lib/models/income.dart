import './transaction.dart';

class Income extends Transaction {
  Income({
    super.id,
    required super.amount,
    required super.currency,
    required super.account,
    required super.categoryId,
    required super.dateTime,
    super.tags,
    super.comment,
  });

  @override
  Income copyWith({
    String? id,
    int? amount,
    String? currency,
    String? account,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Income(
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
