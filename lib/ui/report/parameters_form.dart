import 'package:flutter/material.dart';
import '../widgets/select_screen.dart';
import '../shared/build_form.dart';

class ParametersForm extends StatelessWidget {
  const ParametersForm(
      {super.key,
      required this.mode,
      required this.originalPeriod,
      this.originalCategoryIds,
      this.originalWalletIds});
  final String mode;
  final DateTimeRange originalPeriod;
  final List<String>? originalWalletIds;
  final List<String>? originalCategoryIds;

  @override
  Widget build(BuildContext context) {
    DateTimeRange period = originalPeriod;
    ValueNotifier<List<String>?> walletIds = ValueNotifier(originalWalletIds);
    ValueNotifier<List<String>?> categoryIds =
        ValueNotifier(originalCategoryIds);

    Widget getTimeForm() {
      switch (mode) {
        case 'CURRENT':
          return const SizedBox();
        case 'DATE':
          return buildDateTimeForm(
            context: context,
            dateTime: period.start,
            isMonth: true,
            onDateSaved: (newValue) {
              period = DateTimeRange(
                  start: DateTime(newValue.year, newValue.month, 1),
                  end: DateTime(newValue.year, newValue.month + 1, 0));
            },
          );
        case 'MONTH':
          return buildDateTimeForm(
            dateTime: period.start,
            context: context,
            onDateSaved: (newValue) {
              period = DateTimeRange(
                  start: DateTime(newValue.year, 1, 1),
                  end: DateTime(newValue.year, 12, 31));
            },
            isYear: true,
          );
        case 'QUARTER':
          return buildDateTimeForm(
            dateTime: period.start,
            context: context,
            onDateSaved: (newValue) {
              period = DateTimeRange(
                  start: DateTime(newValue.year, 1, 1),
                  end: DateTime(newValue.year, 12, 31));
            },
            isYear: true,
          );
        case 'YEAR':
          return buildDateRangeForm(
            start: period.start,
            end: period.end,
            context: context,
            onDateRangeSaved: (newValue) => period = newValue,
            isYear: true,
          );
      }
      return buildDateRangeForm(
        start: period.start,
        end: period.end,
        context: context,
        onDateRangeSaved: (newValue) => period = newValue,
      );
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select parameters fo report"),
        actions: [
          IconButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                }
                Navigator.pop(
                    context,
                    ParametersFormOutput(
                        period: period,
                        walletIds: walletIds.value,
                        categoryIds: categoryIds.value));
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
          key: formKey,
          child: ListView(
            children: [
              getTimeForm(),
              ValueListenableBuilder(
                valueListenable: categoryIds,
                builder: (context, value, child) => _buildListTile(
                    title: 'Categories',
                    icon: Icons.category,
                    parameter: 'category',
                    context: context,
                    subtitle: categoryIds.value == null
                        ? 'All categories'
                        : '${categoryIds.value!.length} is selected',
                    originalList: originalCategoryIds,
                    onValueSaved: (newValue) => categoryIds.value = newValue),
              ),
              ValueListenableBuilder(
                valueListenable: walletIds,
                builder: (context, value, child) => _buildListTile(
                    title: 'Wallets',
                    icon: Icons.wallet,
                    parameter: 'wallet',
                    context: context,
                    subtitle: walletIds.value == null
                        ? 'All wallets'
                        : '${walletIds.value!.length} is selected',
                    originalList: originalWalletIds,
                    onValueSaved: (newValue) => walletIds.value = newValue),
              )
            ],
          )),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required String parameter,
    required BuildContext context,
    required ValueChanged<List<String>?> onValueSaved,
    List<String>? originalList,
  }) {
    return Card(
      child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle ?? ''),
          leading: Icon(icon),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () async => onValueSaved(
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectScreen(
                          parameter: parameter, originalList: originalList),
                    )),
              )),
    );
  }
}

class ParametersFormOutput {
  const ParametersFormOutput(
      {required this.period, this.categoryIds, this.walletIds});

  final List<String>? walletIds;
  final List<String>? categoryIds;
  final DateTimeRange period;
}
