import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/build_form.dart';

import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/expenses_manager.dart';
import 'package:ymix/managers/income_manager.dart';
import 'package:ymix/managers/wallet_manager.dart';

import 'package:ymix/models/category.dart';
import 'package:ymix/models/transaction.dart';
import 'package:ymix/models/wallet.dart';

class TransactionForm extends StatefulWidget {
  static const routeName = "/transaction_form";
  const TransactionForm(this.transaction, {super.key});
  final Transaction? transaction;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedMode = 0;

  final Color _formColor = Colors.white.withAlpha(200);
  final Color _dividerColor = Colors.black38;

  double? _amount;
  String _currency = 'VND';
  String? _walletId;
  String? _categoryId;
  DateTime _dateTime = DateTime.now();
  List<String>? _tags;
  String? _comment;

  late final List<Category> _categories;
  // String? _selectedCategoryName;
  // final ValueNotifier< String?> _categoryId = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _selectedCategoryName =
      ValueNotifier<String?>(null);
  late final Future<void> _fetchCategoriesFuture;
  late final List<Wallet> _wallets;
  String? _selectedWalletName;

  @override
  void initState() {
    final originalTransation = widget.transaction;
    _wallets = context.read<WalletManager>().allItems;
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
          _wallets.firstWhere((wallet) => wallet.id == _walletId).name;
    }
    super.initState();
    _fetchCategoriesFuture = _loadCategories();
  }

  Future<void> _loadCategories() async {
    final manager = context.read<CategoryManager>();
    await manager.fetchAllCategory();
    _categories = manager.categories;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    _selectedMode,
                    (changedMode) => (setState(() {
                      _selectedMode = changedMode;
                    })),
                  ),
                  const SizedBox(height: 20),
                  // Amount,
                  buildAmountForm(_amount, _formColor, (newValue) {
                    _amount = newValue;
                  }),
                  const SizedBox(height: 20),
                  // Wallet
                  buildPromptedChoiceForm(
                      _wallets,
                      _walletId,
                      _selectedWalletName,
                      'Wallet',
                      _formColor,
                      _dividerColor, (selectedValue) {
                    _walletId = selectedValue;
                  }),
                  const SizedBox(height: 20),
                  // Category
                  FutureBuilder(
                    future: _fetchCategoriesFuture,
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
                              _categories,
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

  // Future<void> _fetchData() async {
  //   await context.read<CategoryManager>().fetchAllCategory();
  // }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    final id = widget.transaction?.id;
    if (id == null) {
      _selectedMode == 0
          ? context.read<ExpensesManager>().addTransaction(_amount!, _currency,
              _walletId!, _categoryId!, _dateTime, _tags, _comment)
          : context.read<IncomeManager>().addTransaction(_amount!, _currency,
              _walletId!, _categoryId!, _dateTime, _tags, _comment);
      Navigator.pop(context);
    } else {
      _selectedMode == 0
          ? context.read<ExpensesManager>().editTransaction(
              id: id,
              amount: _amount!,
              currency: _currency,
              walletId: _walletId!,
              categoryId: _categoryId!,
              dateTime: _dateTime,
              tags: _tags,
              comment: _comment)
          : context.read<IncomeManager>().editTransaction(
              id: id,
              amount: _amount!,
              currency: _currency,
              walletId: _walletId!,
              categoryId: _categoryId!,
              dateTime: _dateTime,
              tags: _tags,
              comment: _comment);
      Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    }
  }
}
