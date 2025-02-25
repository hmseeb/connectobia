import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FollowerCountSelect extends StatelessWidget {
  final Function(String) onSelected;

  const FollowerCountSelect({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Define follower count options
    const Map<String, String> followerCounts = {
      '1k-10k': '1k-10k',
      '10k-50k': '10k-50k',
      '50k-100k': '50k-100k',
      '100k-500k': '100k-500k',
      '500k-1M': '500k-1M',
    };

    return SizedBox(
      child: ShadSelect<String>(
        placeholder: const Text('Follower'),
        options: followerCounts.entries
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
              followerCounts[value]!,
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