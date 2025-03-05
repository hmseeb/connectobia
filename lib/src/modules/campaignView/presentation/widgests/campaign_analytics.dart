import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submit Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // ✅ ShadInput (instead of TextField)
          const ShadInput(
            placeholder: Text('Enter content link'),
          ),
          
          const SizedBox(height: 16),
          
          // ✅ ShadButton (instead of ElevatedButton)
          ShadButton(
            onPressed: () {},
            child: const Text('Submit'),
          ),
          
          const SizedBox(height: 24),
          
          _buildAnalyticsCard('Followers Growth', [
            FlSpot(1, 50),
            FlSpot(2, 70),
            FlSpot(3, 85),
            FlSpot(4, 120),
            FlSpot(5, 150),
            FlSpot(6, 180),
            FlSpot(7, 200),
          ], Colors.blue),
        ],
      ),
    );
  }

Widget _buildAnalyticsCard(String title, List<FlSpot> dataPoints, Color color) {
  return ShadCard(
    padding: const EdgeInsets.all(16), // Add padding
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          return Text('${value.toInt()}K', style: const TextStyle(fontSize: 12));
        },
      ),
    ),
    rightTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false), // ❌ Hide right-side titles
    ),
    topTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false), // ❌ Hide top titles
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
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.3)),
      dotData: FlDotData(show: true),
    ),
  ],
)

          ),
        ),
      ],
    ),
  );
}

}
