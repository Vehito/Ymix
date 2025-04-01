import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ymix/ui/shared/format_helper.dart';

class BarChartSample extends StatefulWidget {
  const BarChartSample(
      {required this.indicatorsDataList,
      required this.titleList,
      required this.indicatorsName,
      super.key,
      this.gradientList,
      this.colorList,
      this.chartName});

  final List<List<double>> indicatorsDataList;
  final List<String> indicatorsName;
  final List<String> titleList;
  final List<Gradient>? gradientList;
  final List<Color>? colorList;
  final String? chartName;

  @override
  State<BarChartSample> createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  int showingTooltip = -1;

  late final List<List<double>> _indicatorsDataList;
  late final List<String> _titleList;
  late final List<Gradient?>? _gradientList;
  late final List<Color?>? _colorList;
  late final double _maxValue;
  final double _maxY = 6;
  late final int _unit;

  int _getUnit() {
    if (_maxValue == 0) return 1000;
    // log10(_maxValue)
    int exponent = (log(_maxValue) / log(10)).floor();
    return pow(10, (exponent ~/ 3) * 3).toInt();
  }

  @override
  void initState() {
    _indicatorsDataList = widget.indicatorsDataList;
    _titleList = widget.titleList;
    _gradientList = widget.gradientList;
    _colorList = widget.colorList;
    _maxValue = _indicatorsDataList.fold(
        0,
        (max, list) =>
            list.fold(max, (subMax, value) => value > subMax ? value : subMax));
    _unit = _getUnit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final unitName = _unit >= 1000000000
        ? 'Billion'
        : _unit >= 1000000
            ? 'Million'
            : 'Thousand';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.chartName ?? ('(Unit: $unitName)'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        ConstrainedBox(
          constraints: const BoxConstraints.expand(height: 250, width: 400),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                barTouchData: barTouchData,
                titlesData: _titlesData,
                borderData: _borderData,
                barGroups: _generateGroupData,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxY,
              ),
            ),
          ),
        ),
        _buildLegendList(),
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        handleBuiltInTouches: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipMargin: 0,
          tooltipPadding: const EdgeInsets.all(1),
          getTooltipColor: (group) => Colors.transparent,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final originalValue = (rod.toY / _maxY) * _maxValue * _unit;
            return BarTooltipItem(
              '${FormatHelper.numberFormat.format(originalValue / _unit)}đ',
              TextStyle(
                  color: _colorList?[rodIndex], fontWeight: FontWeight.bold),
            );
          },
        ),
        touchCallback: (event, response) {
          if (response != null &&
              response.spot != null &&
              event is FlTapUpEvent) {
            setState(
              () {
                final x = response.spot!.touchedBarGroup.x;
                final isShowing = showingTooltip == x;
                if (isShowing) {
                  showingTooltip = -1;
                } else {
                  showingTooltip = x;
                }
              },
            );
          }
        },
      );

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.blue,
      fontSize: 18,
    );
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(_titleList[value.toInt()], style: style),
    );
  }

  Widget _getLeftSideTitles(double value, TitleMeta meta) {
    return Text((_maxValue * (value / _maxY) / _unit).toStringAsFixed(0));
  }

  FlTitlesData get _titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _getBottomTitles,
          ),
          axisNameWidget: const Text(
            'Time',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        leftTitles: AxisTitles(
          axisNameSize: 10,
          axisNameWidget: const SizedBox(width: 10),
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _getLeftSideTitles,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get _borderData => FlBorderData(
      show: true,
      border: const Border(
        left: BorderSide(color: Colors.black45),
        bottom: BorderSide(color: Colors.black45),
      ));

  List<BarChartGroupData> get _generateGroupData {
    // length of data
    final dataLength = _indicatorsDataList[0].length;
    // length of data list
    final dataListLength = _indicatorsDataList.length;
    final width = 200 / (dataListLength + dataLength);
    return List.generate(dataLength, (i) {
      final rods = List.generate(dataListLength, (j) {
        return BarChartRodData(
          toY: (_indicatorsDataList[j][i] / _maxValue) * _maxY,
          gradient: _gradientList?[j],
          color: _colorList?[j],
          width: width,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
        );
      });

      return BarChartGroupData(
        x: i,
        barRods: rods,
        barsSpace: 5,
        showingTooltipIndicators: showingTooltip == i
            ? List.generate(dataListLength, (index) => index)
            : [],
      );
    });
  }

  Widget _buildLegendList() {
    final indicatorsName = widget.indicatorsName;

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(indicatorsName.length, (index) {
          return Row(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  gradient: _gradientList?[index],
                  color: _colorList?[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                indicatorsName[index],
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              )
            ],
          );
        }));
  }
}
