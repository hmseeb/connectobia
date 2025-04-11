import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadInputFormField(
      placeholder: const Text('Search Campaigns'),
      prefix: const Icon(Icons.search),
      onChanged: (value) {},
    );
  }
}
