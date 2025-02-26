import 'dart:ui';
import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:toggle_switch/toggle_switch.dart';

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

  int _amount = 0;
  String _currency = 'VND';
  String? _walletId;
  String? _categoryId;
  DateTime _dateTime = DateTime.now();
  List<String>? _tags;
  String? _comment;

  late final List<Category> _categories;
  String? _selectedCategoryName;
  late final List<Wallet> _wallets;
  String? _selectedWalletName;

  // final currencyFormat = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    final originalTransation = widget.transaction;
    _categories = context.read<CategoryManager>().categories;
    _wallets = context.read<WalletManager>().allItems;
    if (originalTransation != null) {
      _controller.text = originalTransation.id!;
      _amount = originalTransation.amount;
      _walletId = originalTransation.accountId;
      _categoryId = originalTransation.categoryId;
      _dateTime = originalTransation.dateTime;
      _tags = originalTransation.tags;
      _comment = originalTransation.comment;

      _selectedCategoryName =
          _categories.firstWhere((category) => category.id == _categoryId).name;
      _selectedWalletName =
          _wallets.firstWhere((wallet) => wallet.id == _walletId).name;
    }
    super.initState();
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
                _buildToggleSwitch(),
                const SizedBox(height: 20),
                _buildAmountForm(),
                const SizedBox(height: 20),
                _buildWalletForm(),
                const SizedBox(height: 20),
                _buildCategoryForm(),
                const SizedBox(height: 20),
                _buildDateTimeForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return ToggleSwitch(
      animate: true,
      animationDuration: 500,
      centerText: true,
      minWidth: 200,
      initialLabelIndex: _selectedMode, // Sử dụng biến trạng thái
      labels: const ['Expenses', 'Income'],
      activeBgColor: const [Colors.lightBlue],
      icons: const [Icons.money_off, Icons.attach_money],
      onToggle: (index) {
        setState(() {
          _selectedMode = index!; // Cập nhật trạng thái
        });
      },
    );
  }

  Widget _buildAmountForm() {
    return Card(
      color: _formColor,
      shadowColor: Colors.black,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUnfocus,
        keyboardType: TextInputType.number,
        initialValue: _amount.toString(),
        selectionWidthStyle: BoxWidthStyle.tight,
        onSaved: (newValue) => _amount = int.parse(newValue!),
        decoration: const InputDecoration(
          hintText: 'Enter amount',
          icon: Icon(Icons.attach_money_outlined),
          labelText: 'Amount *',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (int.tryParse(value) == null || int.tryParse(value) == 0) {
            return 'Invalid amount';
          }
          if (value.length != value.replaceAll(' ', '').length) {
            return 'Amount must not contain any spaces';
          }
          if (int.tryParse(value)! < 0) {
            return "Amount can not be negative";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryForm() {
    return FormField<String>(
      autovalidateMode: AutovalidateMode.always,
      initialValue: _categoryId,
      onSaved: (newValue) => _categoryId = newValue,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Category is required";
        }
        return null;
      },
      builder: (field) => Card(
        color: _formColor,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.menu),
              title: const Text('Category *'),
              subtitle: Divider(color: _dividerColor),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return _buildCategoryChoiceChip(category, field);
                }).toList(),
              ),
            ),
            _buildValidatorContainer(
              field.errorText,
              "Category selected: $_selectedCategoryName",
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChoiceChip(Category category, FormFieldState field) {
    return ChoiceChip(
      label: Text(
        category.name,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      showCheckmark: false,
      selected: _categoryId == category.id, // Kiểm tra trạng thái chọn
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _categoryId = category.id;
            _selectedCategoryName = category.name;
          });
          field.didChange(category.id); // Cập nhật giá trị trong form
        }
      },
      color: WidgetStatePropertyAll(category.color.withAlpha(230)),
      avatar: _categoryId != category.id
          ? Icon(
              category.icon,
              color: Colors.white,
              size: 20,
            )
          : CircleAvatar(
              backgroundColor: Colors.white,
              radius: 40,
              child: Icon(
                Icons.check,
                color: category.color,
                size: 20,
              ),
            ),
      selectedColor: Colors.white,
    );
  }

  Widget _buildWalletForm() {
    return FormField<String>(
      initialValue: _walletId,
      autovalidateMode: AutovalidateMode.always,
      onSaved: (newValue) => setState(() {
        _walletId = newValue!;
      }),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Wallet is required';
        }
        return null;
      },
      builder: (field) => Card(
        color: _formColor,
        child: Column(
          children: [
            ListTile(
              title: const Text('Wallet *'),
              leading: const Icon(Icons.wallet),
              subtitle: Divider(
                color: _dividerColor,
              ),
            ),
            PromptedChoice<String>.single(
              title: 'Choose one',
              value: _selectedWalletName,
              onChanged: (value) => field.didChange(value),
              itemCount: _wallets.length,
              itemBuilder: (state, i) {
                return RadioListTile(
                  value: _wallets[i].name,
                  groupValue: state.single,
                  onChanged: (value) {
                    state.select(_wallets[i].id!);
                    _selectedWalletName = _wallets[i].name;
                  },
                  title: ChoiceText(
                    _wallets[i].name,
                    highlight: state.search?.value,
                  ),
                );
              },
              promptDelegate: ChoicePrompt.delegateBottomSheet(),
              anchorBuilder: ChoiceAnchor.create(inline: true),
            ),
            _buildValidatorContainer(
              field.errorText,
              '$_selectedWalletName is selected',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeForm(BuildContext context) {
    return FormField<DateTime>(
      initialValue: _dateTime,
      onSaved: (newValue) => _dateTime = newValue!,
      builder: (field) => Card(
        color: _formColor,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(DateFormat('dd/MM/yyyy').format(field.value!)),
              trailing: IconButton(
                onPressed: () async {
                  field.didChange(
                    await showDatePicker(
                          context: context,
                          initialDate: _dateTime,
                          firstDate: DateTime(_dateTime.year - 1),
                          lastDate: DateTime(_dateTime.year + 1),
                        ) ??
                        field.value,
                  );
                },
                icon: const Icon(Icons.change_circle),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildValidatorContainer(String? errorText, String successfulText) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      alignment: Alignment.centerLeft,
      child: Text(
        errorText ?? successfulText,
        style: TextStyle(
          color: errorText != null ? Colors.redAccent : Colors.lightBlue,
          fontSize: 15,
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _selectedMode == 0
          ? context.read<ExpensesManager>().addTransaction(_amount, _currency,
              _walletId!, _categoryId!, _dateTime, _tags, _comment)
          : context.read<IncomeManager>().addTransaction(_amount, _currency,
              _walletId!, _categoryId!, _dateTime, _tags, _comment);
      Navigator.pop(context);
    }
  }
}
