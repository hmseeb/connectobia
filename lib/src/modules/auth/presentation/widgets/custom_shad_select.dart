import 'package:connectobia/src/globals/constants/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomShadSelect extends StatefulWidget {
  final Map<String, String> items;
  final String placeholder;
  final void Function(String selectedValue) onSelected;
  final FocusNode focusNode; // Add focusNode as a parameter

  const CustomShadSelect({
    super.key,
    required this.items,
    required this.placeholder,
    required this.onSelected,
    required this.focusNode, // Accept focusNode here
  });

  @override
  CustomShadSelectState createState() => CustomShadSelectState();
}

class CustomShadSelectState extends State<CustomShadSelect> {
  Map<String, String> get sortedItems => {
        // sort the items by value name
        for (final item
            in widget.items.entries.toList()
              ..sort((a, b) => a.value.compareTo(b.value)))
          item.key: item.value
      };

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.height(context);
    return ShadSelect<String>(
      enabled: true,
      focusNode: widget.focusNode, // Use the provided focus node
      minWidth: 350,
      maxWidth: 350,
      maxHeight: height * 30,
      placeholder: Text(widget.placeholder),
      options: [
        ...sortedItems.entries.map(
          (item) => ShadOption(
            value: item.key,
            child: Text(item.value),
          ),
        ),
      ],
      selectedOptionBuilder: (context, value) {
        widget.onSelected(value);
        return Text(widget.items[value] ?? '');
      },
    );
  }
}
