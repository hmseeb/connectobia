import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EngagementSelect extends StatelessWidget {
  final Function(String) onSelected;

  const EngagementSelect({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Define engagement options
    const Map<String, String> engagementOptions = {
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
    };

    return SizedBox(
      width: 200, // Fixed width
      height: 50, // Fixed height
      child: ShadSelect<String>(
        placeholder: const Text('Engagement'),
        options: engagementOptions.entries
            .map((e) => ShadOption(value: e.key, child: Text(e.value)))
            .toList(),
        selectedOptionBuilder: (context, value) {
          return Text(engagementOptions[value]!);
        },
        onChanged: (value) {
          if (value != null) {
            onSelected(value);
          }
        },
      ),
    );
  }
}