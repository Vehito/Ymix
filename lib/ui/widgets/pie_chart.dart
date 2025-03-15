import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ymix/managers/category_manager.dart';

class PieChartSample extends StatefulWidget {
  const PieChartSample(this.indicatorsData, {super.key});

  final Map<String, double> indicatorsData;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.indicatorsData.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 10.0),
            top: BorderSide(width: 10.0),
          ),
        ),
        constraints: const BoxConstraints.expand(width: 150, height: 150),
        alignment: Alignment.center,
        child: const Text("No transaction"),
      );
    }
    List<Color> colorList = [];
    final dataMap = Map.fromEntries(widget.indicatorsData.entries.map((entry) {
      final category = context.read<CategoryManager>().getCategory(entry.key);
      colorList.add(category.color);
      return MapEntry(category.name, entry.value);
    }));
    return PieChart(
      dataMap: dataMap,
      chartType: ChartType.ring,
      chartRadius: 150.0,
      animationDuration: const Duration(seconds: 1),
      baseChartColor: Colors.grey[300]!,
      colorList: colorList,
      chartValuesOptions:
          const ChartValuesOptions(showChartValuesInPercentage: true),
    );
  }
}
