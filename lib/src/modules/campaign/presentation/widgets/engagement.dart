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
      width: 200, // Fixed width for the dropdown
      height: 50, // Fixed height
      child: ShadSelect<String>(
        placeholder: const Text('Engage...'),
        options: engagementOptions.entries
            .map(
              (e) => ShadOption(
                value: e.key,
                child: SizedBox(
                  width: 180, // Constrain the width of the option text
                  child: Text(
                    e.value,
                    overflow: TextOverflow.ellipsis, // Truncate with ellipsis
                  ),
                ),
              ),
            )
            .toList(),
        selectedOptionBuilder: (context, value) {
          return SizedBox(
            width: 180, // Constrain the width of the selected text
            child: Text(
              engagementOptions[value]!,
              overflow: TextOverflow.ellipsis, // Truncate with ellipsis
            ),
          );
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