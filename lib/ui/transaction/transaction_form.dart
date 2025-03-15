import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/transactions_manager.dart';

import '../shared/build_form.dart';

import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/wallet_manager.dart';

import 'package:ymix/models/category.dart';
import 'package:ymix/models/transactions.dart';
import 'package:ymix/models/wallet.dart';

class TransactionForm extends StatefulWidget {
  static const routeName = "/transaction_form";
  const TransactionForm(this.transaction, {super.key});
  final Transactions? transaction;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isExpense = true;

  final Color _formColor = Colors.white.withAlpha(200);
  final Color _dividerColor = Colors.black38;

  double? _amount;
  String _currencySymbol = 'đ';
  String? _walletId;
  String? _categoryId;
  DateTime _dateTime = DateTime.now();
  List<String>? _tags;
  String? _comment;

  late final Set<Category> _categories;
  final ValueNotifier<String?> _selectedCategoryName =
      ValueNotifier<String?>(null);
  late final Future<void> _loadCategoriesFuture;
  late final Future<void> _loadWalletsFuture;
  late final List<Wallet>? _wallets;
  String? _selectedWalletName;

  @override
  void initState() {
    final originalTransation = widget.transaction;
    _loadCategoriesFuture = _loadCategories();
    _loadWalletsFuture = _loadWallets();
    if (originalTransation != null) {
      _controller.text = originalTransation.id!;
      _amount = originalTransation.amount;
      _walletId = originalTransation.walletId;
      _categoryId = originalTransation.categoryId;
      _dateTime = originalTransation.dateTime;
      _tags = originalTransation.tags;
      _comment = originalTransation.comment;

      _selectedCategoryName.value =
          _categories.firstWhere((category) => category.id == _categoryId).name;
      _selectedWalletName =
          context.read<WalletManager>().getWalletName(_walletId!);
    }
    super.initState();
  }

  Future<void> _loadCategories() async {
    final manager = context.read<CategoryManager>();
    if (manager.categories.isEmpty) await manager.fetchAllCategory();
    _categories = manager.categories;
  }

  Future<void> _loadWallets() async {
    final manager = context.read<WalletManager>();
    if (manager.wallets.isEmpty) await manager.fetchAllCategory();
    _wallets = manager.wallets;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController(
      text: _amount == null ? '0' : _amount.toString(),
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.transaction == null ? "Add Transaction" : "Edit Transaction",
          ),
          actions: [
            IconButton(onPressed: _submitForm, icon: const Icon(Icons.check))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  buildToggleSwitch(
                    _isExpense ? 0 : 1,
                    (_) => (_isExpense = _isExpense),
                  ),
                  const SizedBox(height: 20),
                  // Amount,

                  buildAmountForm(_amount, null, _formColor, (newValue) {
                    _amount = newValue;
                  }, controller: amountController, decimalDigits: 0),

                  const SizedBox(height: 20),
                  // Wallet
                  FutureBuilder(
                      future: _loadWalletsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Lỗi tải dữ liệu!"));
                        } else {
                          return buildPromptedChoiceForm(
                            _wallets,
                            _walletId,
                            _selectedWalletName,
                            'Wallet',
                            _formColor,
                            _dividerColor,
                            (selectedValue) {
                              _walletId = selectedValue;
                            },
                            (value) {
                              final wallet =
                                  _wallets!.firstWhere((w) => w.id == value);

                              if (!_isExpense) return null;
                              final amount = double.parse(
                                  amountController.text == ''
                                      ? '0'
                                      : amountController.text);
                              if (amount.isNaN) {
                                return 'Amount is not valid';
                              }
                              if (amount > wallet.balance) {
                                return "Selected wallet is not enough money";
                              }
                            },
                          );
                        }
                      }),

                  const SizedBox(height: 20),
                  // Category
                  FutureBuilder(
                    future: _loadCategoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text("Lỗi tải dữ liệu!"));
                      } else {
                        return ValueListenableBuilder(
                          valueListenable: _selectedCategoryName,
                          builder: (context, value, child) {
                            return buildChoiceChipForm(
                              _categories.toList(),
                              _categoryId,
                              _selectedCategoryName.value,
                              "Category",
                              _formColor,
                              _dividerColor,
                              (selectedValue) {
                                _categoryId = selectedValue;
                              },
                              (selectedValue) {
                                _categoryId = selectedValue.keys.first;
                                _selectedCategoryName.value =
                                    selectedValue.values.first;
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  // DateTime
                  buildDateTimeForm(context, _dateTime, _formColor,
                      (dateTime) => _dateTime = dateTime),
                  const SizedBox(height: 20),
                  // Comment
                  buildTextForm(_comment, "Comment", _formColor,
                      (newValue) => _comment = newValue),
                ],
              ),
            ),
          ),
        ));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final id = widget.transaction?.id;
    if (id == null) {
      await context.read<TransactionsManager>().addTransaction(
          _amount!,
          _currencySymbol,
          _walletId!,
          _categoryId!,
          _dateTime,
          _tags,
          _comment,
          _isExpense);
      if (mounted) Navigator.pop(context);
    } else {
      await context.read<TransactionsManager>().updateTransaction(Transactions(
          id: widget.transaction!.id!,
          amount: _amount!,
          currencySymbol: _currencySymbol,
          walletId: _walletId!,
          categoryId: _categoryId!,
          dateTime: _dateTime));
      if (mounted) Navigator.pop(context);
    }
  }
}
