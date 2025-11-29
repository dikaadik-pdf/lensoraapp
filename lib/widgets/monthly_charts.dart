import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyLineChart extends StatelessWidget {
  final List<double> values;

  const MonthlyLineChart({
    super.key,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(values.length, (i) {
              return FlSpot(i.toDouble(), values[i]);
            }),
            isCurved: true,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
