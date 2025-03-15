class Wallet {
  final String? _id;
  final String _name;
  final double _balance;
  final String? _description;

  Wallet({
    String? id,
    required String name,
    required double balance,
    String? description,
  })  : _id = id,
        _name = name,
        _balance = balance,
        _description = description;

  // Getters
  String? get id => _id;
  String get name => _name;
  double get balance => _balance;
  String? get description => _description;

  // Setter cho balance với validation
  // set balance(double newBalance) {
  //   if (newBalance < 0) {
  //     throw ArgumentError("Balance cannot be negative");
  //   }
  //   _balance = newBalance;
  // }

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    String? description,
  }) {
    return Wallet(
      id: id ?? _id,
      name: name ?? _name,
      balance: balance ?? _balance,
      description: description ?? _description,
    );
  }

  Map<String, dynamic> toJson() =>
      {'name': _name, 'balance': _balance, 'description': _description};

  factory Wallet.formJson(Map<String, dynamic> json) => Wallet(
        id: json['id'].toString(),
        name: json['name'],
        balance: json['balance'],
        description: json['description'],
      );
}
