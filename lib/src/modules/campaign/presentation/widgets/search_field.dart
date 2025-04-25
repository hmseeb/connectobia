import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchField({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      controller: controller,
      placeholder: const Text('Search Campaigns'),
      prefix: const Icon(Icons.search),
      onChanged: (value) {
        onSearch(value);
      },
    );
  }
}
