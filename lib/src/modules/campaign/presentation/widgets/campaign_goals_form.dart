import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignGoals extends StatefulWidget {
  final Function(bool) onValidationChanged;

  const CampaignGoals({super.key, required this.onValidationChanged});

  @override
  State<CampaignGoals> createState() => _CampaignGoalsState();
}

class _CampaignGoalsState extends State<CampaignGoals> {
  final List<bool> _selectedGoals = [false, false, false, false, false];

  bool get isAtLeastOneGoalSelected => _selectedGoals.contains(true);

  void _updateValidation() {
    widget.onValidationChanged(isAtLeastOneGoalSelected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Campaign Goals',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ShadCheckboxFormField(
          id: 'goal1',
          initialValue: _selectedGoals[0],
          inputLabel: const Text('Increase Brand Awareness'),
          onChanged: (value) {
            setState(() {
              _selectedGoals[0] = value;
              _updateValidation();
            });
          },
          validator: (value) {
            if (!isAtLeastOneGoalSelected) {
              return 'You must select at least one goal';
            }
            return null;
          },
        ),
        ShadCheckboxFormField(
          id: 'goal2',
          initialValue: _selectedGoals[1],
          inputLabel: const Text('Generate Leads'),
          onChanged: (value) {
            setState(() {
              _selectedGoals[1] = value;
              _updateValidation();
            });
          },
        ),
        ShadCheckboxFormField(
          id: 'goal3',
          initialValue: _selectedGoals[2],
          inputLabel: const Text('Drive Website Traffic'),
          onChanged: (value) {
            setState(() {
              _selectedGoals[2] = value;
              _updateValidation();
            });
          },
        ),
        ShadCheckboxFormField(
          id: 'goal4',
          initialValue: _selectedGoals[3],
          inputLabel: const Text('Boost Sales'),
          onChanged: (value) {
            setState(() {
              _selectedGoals[3] = value;
              _updateValidation();
            });
          },
        ),
        ShadCheckboxFormField(
          id: 'goal5',
          initialValue: _selectedGoals[4],
          inputLabel: const Text('Engage Social Media Audience'),
          onChanged: (value) {
            setState(() {
              _selectedGoals[4] = value;
              _updateValidation();
            });
          },
        ),
      ],
    );
  }
}