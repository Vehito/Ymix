import './transaction.dart';

class Expense extends Transaction {
  Expense({
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
  Expense copyWith({
    String? id,
    int? amount,
    String? currency,
    String? account,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Expense(
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
