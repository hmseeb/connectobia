import 'package:connectobia/globals/constants/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A custom shad selector
///
/// [CustomShadSelect] is a custom widget that wraps the [ShadSelect] widget
/// and provides a sorted list of items to display in the dropdown.
///
/// The widget also provides a placeholder for the dropdown and a callback
/// function that is called when an item is selected.
///
/// {@category Widgets}
class CustomShadSelect extends StatefulWidget {
  /// [items] is a map of key-value pairs where the key is the value to be
  final Map<String, String> items;

  /// [placeholder] is displayed in the dropdown when no item is selected
  final String placeholder;

  /// [onSelected] is a callback function that is called when an item is selected
  final void Function(String selectedValue) onSelected;

  /// [focusNode] is used to control the focus of the dropdown
  final FocusNode focusNode;

  const CustomShadSelect({
    super.key,
    required this.items,
    required this.placeholder,
    required this.onSelected,
    required this.focusNode,
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
      minWidth: 400,
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
