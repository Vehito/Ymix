import 'package:provider/provider.dart';
import 'package:ymix/managers/category_manager.dart';
import 'package:ymix/managers/wallet_manager.dart';

import '../shared/dialog_utils.dart';

import 'package:flutter/material.dart';
import 'package:ymix/ui/shared/format_helper.dart';

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key, required this.parameter, this.originalList});
  final String parameter;
  final List<String>? originalList;
  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  bool _selectAllStatus = false;
  List<bool> _selectedList = [];
  List<dynamic> dataList = [];
  late final List<String>? _originalList;

  void _toggleSelectAll() {
    _selectAllStatus = true;
    _selectedList = List.generate(dataList.length, (_) => true);
    setState(() {});
  }

  Future<void> _loadData(String parameter) async {
    if (parameter == 'wallet') {
      final manager = context.read<WalletManager>();
      await manager.fetchAllWallet();
      dataList = manager.wallets;
    } else {
      final manager = context.read<CategoryManager>();
      await manager.init();
      dataList = manager.categories.toList();
    }
    _selectedList = _originalList == null
        ? List.filled(dataList.length, true)
        : dataList.map((item) => _originalList.contains(item.id)).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadData(widget.parameter);
    _originalList = widget.originalList;
  }

  @override
  Widget build(BuildContext context) {
    final parameter = widget.parameter;

    return Scaffold(
        appBar: AppBar(
          title: Text('Select $parameter'),
          actions: [
            IconButton(
                onPressed: () {
                  _onSave(
                      selectedList: _selectedList,
                      dataList: dataList,
                      selectAllStatus: _selectAllStatus);
                },
                icon: const Icon(Icons.check))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: dataList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _buildListView(parameter),
        ));
  }

  void _onSave(
      {required List<bool> selectedList,
      required List<dynamic> dataList,
      required bool selectAllStatus}) {
    if (selectedList.every((item) => item == false)) {
      showErrorDialog(context, 'Choose at least 1 item');
      return;
    }
    if (selectAllStatus) {
      Navigator.pop(context, null);
    } else {
      List<String> selectedItems = [];
      for (int i = 0; i < dataList.length; i++) {
        if (selectedList[i]) selectedItems.add(dataList[i].id);
      }
      Navigator.pop(context, selectedItems);
    }
  }

  Widget _buildListView(String parameter) {
    return ListView(
      children: [
        ElevatedButton(
          onPressed: () => _toggleSelectAll(),
          child: const Text("Select all"),
        ),
        ...List.generate(dataList.length, (index) {
          return _buildCheckBoxListTile(
            title: dataList[index].name,
            icon: parameter == 'wallet' ? null : dataList[index].icon,
            subtitle: parameter == 'wallet'
                ? '${FormatHelper.numberFormat.format(dataList[index].balance)}đ'
                : null,
            value: _selectedList[index],
            onValueChanged: (value) {
              setState(() {
                _selectedList = List.from(_selectedList)..[index] = value!;
                _selectAllStatus = _selectedList.every(
                  (item) => item,
                );
              });
            },
          );
        })
      ],
    );
  }

  Widget _buildCheckBoxListTile(
      {required String title,
      IconData? icon,
      String? subtitle,
      required bool value,
      required ValueChanged<bool?> onValueChanged}) {
    return CheckboxListTile(
      value: value,
      onChanged: onValueChanged,
      title: Row(
        children: [
          if (icon != null) ...[Icon(icon)],
          Text(title)
        ],
      ),
      subtitle: Text(subtitle ?? ''),
    );
  }
}
