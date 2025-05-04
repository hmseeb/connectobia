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
        child: Row(
          children: [
            _buildIcon(title),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTitle(title),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatValue(value),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: _getValueColor(value),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String title) {
    IconData iconData;
    Color iconColor;

    // Select icon based on metric type
    switch (title.toUpperCase()) {
      case 'FOLLOWERS':
        iconData = Icons.people_alt_rounded;
        iconColor = Colors.blue;
        break;
      case 'MEDIA COUNT':
        iconData = Icons.photo_library_rounded;
        iconColor = Colors.purple;
        break;
      case 'AVG INTERACTIONS':
        iconData = Icons.touch_app_rounded;
        iconColor = Colors.orange;
        break;
      case 'AVG LIKES':
        iconData = Icons.favorite_rounded;
        iconColor = Colors.red;
        break;
      case 'AVG COMMENTS':
        iconData = Icons.chat_bubble_rounded;
        iconColor = Colors.green;
        break;
      case 'ENG RATE':
        iconData = Icons.trending_up_rounded;
        iconColor = Colors.teal;
        break;
      case 'AVG VIDEO VIEWS':
        iconData = Icons.visibility_rounded;
        iconColor = Colors.indigo;
        break;
      case 'AVG VIDEO LIKES':
        iconData = Icons.thumb_up_alt_rounded;
        iconColor = Colors.pink;
        break;
      case 'AVG VIDEO COMMENTS':
        iconData = Icons.comment_rounded;
        iconColor = Colors.amber;
        break;
      case 'COUNTRY':
        iconData = Icons.public_rounded;
        iconColor = Colors.blue.shade800;
        break;
      case 'GENDER':
        iconData = Icons.people_rounded;
        iconColor = Colors.purple.shade800;
        break;
      default:
        iconData = Icons.analytics_rounded;
        iconColor = ShadColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatTitle(String title) {
    // Convert from ALL CAPS to Title Case
    // e.g., "AVG INTERACTIONS" -> "Avg Interactions"
    final words = title.split(' ');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatValue(String value) {
    // Handle empty or "0" values
    if (value.isEmpty || value == '0') {
      return '-';
    }

    // Handle engagement rate (percentage)
    if (title.toUpperCase() == 'ENG RATE') {
      try {
        final numValue = double.parse(value);
        // Format as percentage with one decimal place
        return '${numValue.toStringAsFixed(1)}%';
      } catch (_) {
        return '$value%';
      }
    }

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

  Color _getValueColor(String value) {
    // Use gray for zero/empty values
    if (value.isEmpty || value == '0') {
      return Colors.grey;
    }

    try {
      // For engagement rate metric, use color scale
      if (title.toUpperCase() == 'ENG RATE') {
        final engRate = double.parse(value);
        if (engRate > 5.0) return Colors.green; // Excellent
        if (engRate > 3.5) return Colors.green.shade600; // Very good
        if (engRate > 2.0) return Colors.amber.shade700; // Good
        if (engRate > 1.0) return Colors.orange; // Average
        return Colors.red; // Below average
      }

      // For other metrics, use primary for positive numbers
      final numValue = double.parse(value);
      if (numValue > 0) {
        return ShadColors.primary;
      }
    } catch (_) {}

    return ShadColors.primary;
  }
}
