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

  /// [headerText] is the text shown in the dropdown header
  final String headerText;

  /// [width] is the width of the dropdown. If null, it will adapt to its parent
  final double? width;

  const CustomShadSelect({
    super.key,
    required this.items,
    required this.placeholder,
    required this.onSelected,
    required this.focusNode,
    this.headerText = 'Select an option',
    this.width,
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
    try {
      final theme = ShadTheme.of(context);
      return SizedBox(
        width: widget.width, // Width can be null to adapt to parent
        child: ShadSelect<String>(
          enabled: true,
          focusNode: widget.focusNode, // Use the provided focus node
          minWidth: widget.width,
          maxHeight: 220,
          placeholder: Text(widget.placeholder),
          options: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
              child: Text(
                widget.headerText,
                style: theme.textTheme.muted.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.popoverForeground,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            ...sortedItems.entries.map(
              (e) => ShadOption(
                value: e.key,
                child: SizedBox(
                  width: 300, // Constrain the width of the option text
                  child: Text(
                    e.value,
                    overflow: TextOverflow.ellipsis, // Truncate with ellipsis
                  ),
                ),
              ),
            ),
          ],
          selectedOptionBuilder: (context, value) {
            widget.onSelected(value);
            return SizedBox(
              width: 300, // Constrain the width of the selected text
              child: Text(
                widget.items[value] ?? '',
                overflow: TextOverflow.ellipsis, // Truncate with ellipsis
              ),
            );
          },
        ),
      );
    } catch (e) {
      // Handle any errors that might occur during building
      debugPrint('Error in CustomShadSelect: $e');

      // Show an error toast on the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: const Text(
                'There was a problem with the dropdown. Please try again.'),
          ),
        );
      });

      // Return a fallback widget
      return SizedBox(
        width: widget.width,
        child: ShadInputFormField(
          placeholder: Text('${widget.placeholder} (Error loading options)'),
          readOnly: true,
          suffix: const Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }
  }
}
