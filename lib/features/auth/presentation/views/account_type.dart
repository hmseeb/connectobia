import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

SizedBox selectAccountType(Map<String, String> accountTypes) {
  return SizedBox(
    width: 350,
    child: ShadSelect<String>(
      placeholder: const Text('Select account type'),
      options: [
        const Padding(
          padding: EdgeInsets.fromLTRB(32, 6, 6, 6),
        ),
        ...accountTypes.entries
            .map((e) => ShadOption(value: e.key, child: Text(e.value))),
      ],
      selectedOptionBuilder: (context, value) => Text(accountTypes[value]!),
      onChanged: print,
    ),
  );
}
