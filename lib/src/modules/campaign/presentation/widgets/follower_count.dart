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
      width: 200, // Fixed width
      height: 50,
      child: ShadSelect<String>(
        placeholder: const Text('Follower'),
        options: followerCounts.entries
            .map((e) => ShadOption(value: e.key, child: Text(e.value)))
            .toList(),
        selectedOptionBuilder: (context, value) {
          return Text(followerCounts[value]!);
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