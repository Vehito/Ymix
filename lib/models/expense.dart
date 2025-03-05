import './transaction.dart';

class Expense extends Transaction {
  Expense({
    String? id,
    required double amount,
    required String currency,
    required String walletId,
    required String categoryId,
    required DateTime dateTime,
    List<String>? tags,
    String? comment,
  }) : super(
          id: id,
          amount: amount,
          currency: currency,
          walletId: walletId,
          categoryId: categoryId,
          dateTime: dateTime,
          tags: tags,
          comment: comment,
        );

  @override
  Expense copyWith({
    String? id,
    double? amount,
    String? currency,
    String? walletId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
    );
  }
}
