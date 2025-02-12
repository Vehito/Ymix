// import 'package:fl_chart/fl_chart.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:flutter/material.dart';

class PieChartSample extends StatefulWidget {
  const PieChartSample(this.indicatorsData, {super.key});

  final Map<String, double> indicatorsData;

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample> {
  int touchedIndex = -1;

  final Map<String, Color> categoryColors = {
    "food": Colors.green,
    "entertainment": Colors.red,
    "travel": Colors.blue,
    "shopping": Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final colorList = widget.indicatorsData.keys
        .map((category) => categoryColors[category] ?? Colors.grey)
        .toList();
    return PieChart(
      dataMap: widget.indicatorsData,
      baseChartColor: Colors.grey[300]!,
      colorList: colorList,
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
      ),
    );
  }
}
