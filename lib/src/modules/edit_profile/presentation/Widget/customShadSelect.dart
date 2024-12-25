import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomShadSelect extends StatelessWidget {
  final List<String> items;
  final String placeholder;
  final String? initialValue;
  final ValueChanged<String> onSelected;

  const CustomShadSelect({
    super.key,
    required this.items,
    required this.placeholder,
    this.initialValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: shadTheme.colorScheme.foreground),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: initialValue,
          hint: Text(
            placeholder,
            style: TextStyle(color: shadTheme.colorScheme.foreground.withOpacity(0.5)),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: shadTheme.colorScheme.foreground,
          ),
          onChanged: (String? newValue) {
            onSelected(newValue!);
          },
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: shadTheme.colorScheme.foreground),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
