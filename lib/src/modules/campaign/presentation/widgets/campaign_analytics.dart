import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'analytics_card.dart'; // Import the new file

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

          // ✅ Use the AnalyticsCard here
          AnalyticsCard(
            title: 'post Engagement',
            dataPoints: [
              FlSpot(1, 50),
              FlSpot(2, 70),
              FlSpot(3, 85),
              FlSpot(4, 120),
              FlSpot(5, 150),
              FlSpot(6, 180),
              FlSpot(7, 200),
            ],
            color: Colors.blue,
          ),
          const SizedBox(height: 16), 
          AnalyticsCard(
            title: 'links Clicked',
            dataPoints: [
              FlSpot(1, 50),
              FlSpot(2, 70),
              FlSpot(3, 85),
              FlSpot(4, 120),
              FlSpot(5, 150),
              FlSpot(6, 180),
              FlSpot(7, 200),
            ],
            color: Colors.blue,
          ),
          const SizedBox(height: 16), 
          AnalyticsCard(
            title: 'Followers Growth',
            dataPoints: [
              FlSpot(1, 50),
              FlSpot(2, 70),
              FlSpot(3, 85),
              FlSpot(4, 120),
              FlSpot(5, 150),
              FlSpot(6, 180),
              FlSpot(7, 200),
            ],
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
