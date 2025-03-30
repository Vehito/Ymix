import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/managers.dart';
import 'package:ymix/models/category.dart';
import 'package:ymix/models/spending_limit.dart';
import 'package:ymix/ui/shared/build_form.dart';
import '../shared/dialog_utils.dart';

class SpendingLimitForm extends StatefulWidget {
  static const routeName = '/spending_limit_form';
  const SpendingLimitForm({super.key, this.spendingLimit});

  final SpendingLimit? spendingLimit;

  @override
  State<SpendingLimitForm> createState() => _SpendingLimitFormState();
}

class _SpendingLimitFormState extends State<SpendingLimitForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color _formColor = Colors.white.withAlpha(200);
  final Color _dividerColor = Colors.black38;

  double? _amount;
  String _currencySymbol = 'đ';
  String? _categoryId;
  final ValueNotifier<String?> _selectedCategoryName =
      ValueNotifier<String?>(null);
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    final originalLimit = widget.spendingLimit;
    if (originalLimit != null) {
      _amount = originalLimit.amount;
      _currencySymbol = originalLimit.currencySymbol;
      _categoryId = originalLimit.categoryId;
      _start = originalLimit.start;
      _end = originalLimit.end;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<Set<Category>> loadCategories() async {
      final manager = context.read<CategoryManager>();
      await manager.init();
      final categories = manager.categories;
      if (_categoryId != null) {
        _selectedCategoryName.value =
            categories.firstWhere((ca) => ca.id == _categoryId).name;
      }

      return categories;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${widget.spendingLimit == null ? 'Add' : 'Edit'} Spending Limit"),
        actions: [
          IconButton(onPressed: _submitForm, icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Amount
                buildAmountForm(_amount, null, _formColor,
                    (newValue) => _amount = newValue),
                const SizedBox(height: 20),
                // Category
                FutureBuilder(
                  future: loadCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Lỗi tải dữ liệu!"));
                    } else {
                      return ValueListenableBuilder(
                        valueListenable: _selectedCategoryName,
                        builder: (context, value, child) => buildChoiceChipForm(
                            snapshot.data!.toList(),
                            _categoryId,
                            _selectedCategoryName.value,
                            'Category',
                            _formColor,
                            _dividerColor, (selectedValue) {
                          _categoryId = selectedValue;
                        }, (selectedValue) {
                          _categoryId = selectedValue.keys.first;
                          _selectedCategoryName.value =
                              selectedValue.values.first;
                        }),
                      );
                    }
                  },
                ),
                buildDateTimeForm(
                    context: context,
                    dateTime: _start ?? DateTime.now(),
                    formColor: _formColor,
                    onDateSaved: (newDate) => _start = newDate,
                    title: "Start: "),
                buildDateTimeForm(
                    context: context,
                    dateTime:
                        _end ?? DateTime.now().add(const Duration(days: 1)),
                    formColor: _formColor,
                    onDateSaved: (newDate) => _end = newDate,
                    title: "End: "),
              ],
            ),
          )),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final id = widget.spendingLimit?.id;
    if (id == null) {
      final confirm = await showConfirmDialog(context,
          "Do you wanna sync current spending with transactions in period you choose ?");
      if (mounted) {
        await context.read<SpendingLimitManager>().addSpendingLimit(
            _categoryId!,
            _start!,
            _end!,
            _amount!,
            _currencySymbol,
            0,
            "active",
            confirm!);
      }
      if (mounted) Navigator.pop(context);
    } else {
      final newLimit = widget.spendingLimit!.copyWith(
          categoryId: _categoryId, amount: _amount, start: _start, end: _end);
      await context.read<SpendingLimitManager>().updateLimit(newLimit);
      if (mounted) Navigator.pop(context);
    }
  }
}
