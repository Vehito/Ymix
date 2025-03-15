import 'transactions.dart';

class Income extends Transactions {
  Income({
    super.id,
    required super.amount,
    required super.currencySymbol,
    required super.walletId,
    required super.categoryId,
    required super.dateTime,
    super.tags,
    super.comment,
  });

  @override
  Income copyWith({
    String? id,
    double? amount,
    String? currencySymbol,
    String? walletId,
    String? categoryId,
    DateTime? dateTime,
    List<String>? tags,
    String? comment,
  }) {
    return Income(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
    );
  }
}
