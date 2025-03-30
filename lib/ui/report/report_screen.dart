import 'package:flutter/material.dart';
import 'package:ymix/ui/report/report_tabview.dart';

import '../shared/build_form.dart';

class ReportScreen extends StatefulWidget {
  static const routeName = '/reports';
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<ReportScreen> {
  // true: expense - false: income - null: Expense & income
  final ValueNotifier<bool?> _isExpense = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final Map<bool?, List<Widget>> tabBarViews = {
      true: [
        const TabBar(
          tabs: [Text('DATE'), Text('MONTH'), Text('YEAR')],
          isScrollable: true,
          labelStyle: TextStyle(color: Colors.white),
        ),
        ValueListenableBuilder(
          valueListenable: _isExpense,
          builder: (context, value, child) => TabBarView(children: [
            ReportTabview(mode: 'DATE', isExpense: _isExpense.value),
            ReportTabview(mode: 'MONTH', isExpense: _isExpense.value),
            ReportTabview(mode: 'YEAR', isExpense: _isExpense.value)
          ]),
        )
      ],
      false: [
        const TabBar(
          tabs: [Text('DATE'), Text('MONTH'), Text('YEAR')],
          isScrollable: true,
          labelStyle: TextStyle(color: Colors.white),
        ),
        ValueListenableBuilder(
          valueListenable: _isExpense,
          builder: (context, value, child) => TabBarView(children: [
            ReportTabview(mode: 'DATE', isExpense: _isExpense.value),
            ReportTabview(mode: 'MONTH', isExpense: _isExpense.value),
            ReportTabview(mode: 'YEAR', isExpense: _isExpense.value)
          ]),
        )
      ],
      null: [
        const TabBar(
          tabs: [
            Text('CURRENT'),
            Text('MONTH'),
            Text('QUARTER'),
            Text('YEAR'),
            Text('CUSTOM')
          ],
          isScrollable: true,
          labelStyle: TextStyle(color: Colors.white),
        ),
        ValueListenableBuilder(
          valueListenable: _isExpense,
          builder: (context, value, child) => TabBarView(children: [
            const CurrentTabView(),
            ReportTabview(mode: 'MONTH', isExpense: _isExpense.value),
            ReportTabview(mode: 'QUARTER', isExpense: _isExpense.value),
            ReportTabview(mode: 'YEAR', isExpense: _isExpense.value),
            ReportTabview(mode: 'CUSTOM', isExpense: _isExpense.value),
          ]),
        )
      ]
    };
    return StatefulBuilder(
      builder: (context, setState) {
        return DefaultTabController(
          length: (tabBarViews[_isExpense.value]![0] as TabBar).tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Dropdown(
                  width: 200,
                  const ['Expense & Income', 'Expense', 'Income'],
                  (selectedValue) => setState(() {
                        switch (selectedValue) {
                          case 'Expense & Income':
                            _isExpense.value = null;
                            break;
                          case 'Expense':
                            _isExpense.value = true;
                            break;
                          case 'Income':
                            _isExpense.value = false;
                            break;
                        }
                      })),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: tabBarViews[_isExpense.value]![0],
              ),
            ),
            body: tabBarViews[_isExpense.value]![1],
          ),
        );
      },
    );
  }
}
