import './transaction.dart';

class Expense extends Transaction {
  Expense({
    String? id,
    required int amount,
    required String currency,
    required String accountId,
    required String categoryId,
    required DateTime dateTime,
    List<String>? tags,
    String? comment,
  }) : super(
          id: id,
          amount: amount,
          currency: currency,
          accountId: accountId,
          categoryId: categoryId,
          dateTime: dateTime,
          tags: tags,
          comment: comment,
        );

  @override
  Expense copyWith({
    String? id,
    int? amount,
    String? currency,
    String? accountId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
    );
  }
}
