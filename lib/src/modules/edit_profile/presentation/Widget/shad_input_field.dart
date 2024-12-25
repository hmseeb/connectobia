import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ShadInputField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final int maxLines;

  const ShadInputField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: shadTheme.colorScheme.foreground),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: shadTheme.colorScheme.foreground.withOpacity(0.5)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: shadTheme.colorScheme.foreground),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: shadTheme.colorScheme.secondary),
          ),
        ),
      ),
    );
  }
}
