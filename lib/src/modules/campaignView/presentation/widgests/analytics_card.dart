import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final List<FlSpot> dataPoints;
  final Color color;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(16), // Add padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  border: const Border(
                    bottom: BorderSide(color: Colors.black, width: 1),
                    left: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}K',
                            style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: false), // ❌ Hide right-side titles
                  ),
                  topTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // ❌ Hide top titles
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 1:
                            return const Text('Mon');
                          case 2:
                            return const Text('Tue');
                          case 3:
                            return const Text('Wed');
                          case 4:
                            return const Text('Thu');
                          case 5:
                            return const Text('Fri');
                          case 6:
                            return const Text('Sat');
                          case 7:
                            return const Text('Sun');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    color: color,
                    barWidth: 4,
                    belowBarData:
                        BarAreaData(show: true, color: color.withAlpha(76)),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
