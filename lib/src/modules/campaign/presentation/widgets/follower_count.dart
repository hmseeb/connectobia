import 'package:flutter/material.dart';

class FollowerCountSelect extends StatefulWidget {
  final Function(String?) onSelected;

  const FollowerCountSelect({super.key, required this.onSelected});

  @override
  State<FollowerCountSelect> createState() => _FollowerCountSelectState();
}

class _FollowerCountSelectState extends State<FollowerCountSelect> {
  String? _selectedValue;

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
      child: DropdownButton<String>(
        value: _selectedValue, // Track the selected value
        hint: const Text('Follower'), // Placeholder text
        items: followerCounts.entries
            .map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            // Toggle selection: if the selected value is already selected, deselect it
            _selectedValue = (_selectedValue == value) ? null : value;
          });
          // Notify the parent widget about the change
          widget.onSelected(_selectedValue);
        },
      ),
    );
  }
}