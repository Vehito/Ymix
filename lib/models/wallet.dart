class Wallet {
  final String? _id;
  final String _name;
  int _balance;
  final String? _description;

  Wallet({
    String? id,
    required String name,
    required int balance,
    String? description,
  })  : _id = id,
        _name = name,
        _balance = balance,
        _description = description;

  // Getters
  String? get id => _id;
  String get name => _name;
  int get balance => _balance;
  String? get description => _description;

  // Setter cho balance với validation
  set balance(int newBalance) {
    if (newBalance < 0) {
      throw ArgumentError("Balance cannot be negative");
    }
    _balance = newBalance;
  }

  Wallet copyWith({
    String? id,
    String? name,
    int? balance,
    String? description,
  }) {
    return Wallet(
      id: id ?? _id,
      name: name ?? _name,
      balance: balance ?? _balance,
      description: description ?? _description,
    );
  }
}
