import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignGoalCheckbox extends StatelessWidget {
  final String id;
  final String label;
  final String sublabel;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const CampaignGoalCheckbox({
    super.key,
    required this.id,
    required this.label,
    required this.sublabel,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ShadCheckboxFormField(
      id: id,
      initialValue: initialValue,
      inputLabel: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      onChanged: onChanged,
      inputSublabel: Text(sublabel),
    );
  }
}
