import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfileAnalyticsCard extends StatelessWidget {
  final String title;
  final String value;

  const ProfileAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatValue(value),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: ShadColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(String value) {
    // Try to parse as int for formatting large numbers
    try {
      final intValue = int.parse(value);

      // Format based on size
      if (intValue >= 1000000) {
        // Format as millions (e.g., 1.2M)
        return '${(intValue / 1000000).toStringAsFixed(1)}M';
      } else if (intValue >= 1000) {
        // Format as thousands (e.g., 1.2K)
        return '${(intValue / 1000).toStringAsFixed(1)}K';
      }

      // Return as is for smaller numbers
      return value;
    } catch (e) {
      // If not a valid number, return as is
      return value;
    }
  }
}
