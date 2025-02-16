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
    return Align(
      alignment: Alignment.centerRight, // Align content to the right
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0), // Add right padding
        child: Card(
          elevation: 4, // Add elevation for a polished look
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Campaign Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ShadCheckboxFormField(
                  id: 'goal1',
                  initialValue: _selectedGoals[0],
                  inputLabel: const Text(
                    'Increase Brand Awareness',
                    style: TextStyle(fontSize: 16), // Larger font size
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoals[0] = value;
                      _updateValidation();
                    });
                  },
                  inputSublabel:
                      const Text('Expand your reach and brand awareness'),
                  validator: (value) {
                    if (!isAtLeastOneGoalSelected) {
                      return 'You must select at least one goal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16), // Consistent spacing
                ShadCheckboxFormField(
                  id: 'goal2',
                  initialValue: _selectedGoals[1],
                  inputLabel: const Text(
                    'Drive Sales',
                    style: TextStyle(fontSize: 16), // Larger font size
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoals[1] = value;
                      _updateValidation();
                    });
                  },
                  inputSublabel:
                      const Text('Generate leads and boost conversions'),
                ),
                const SizedBox(height: 16), // Consistent spacing
                ShadCheckboxFormField(
                  id: 'goal3',
                  initialValue: _selectedGoals[2],
                  inputLabel: const Text(
                    'Boost Engagement',
                    style: TextStyle(fontSize: 16), // Larger font size
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoals[2] = value;
                      _updateValidation();
                    });
                  },
                  inputSublabel:
                      const Text('Increase audience interaction and participation'),
                ),
                const SizedBox(height: 16), // Consistent spacing
                ShadCheckboxFormField(
                  id: 'goal4',
                  initialValue: _selectedGoals[3],
                  inputLabel: const Text(
                    'More Website Visits',
                    style: TextStyle(fontSize: 16), // Larger font size
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoals[3] = value;
                      _updateValidation();
                    });
                  },
                  inputSublabel:
                      const Text('Use influencers to bring users to your site'),
                ),
                const SizedBox(height: 16), // Consistent spacing
                ShadCheckboxFormField(
                  id: 'goal5',
                  initialValue: _selectedGoals[4],
                  inputLabel: const Text(
                    'Improve Brand Recognition',
                    style: TextStyle(fontSize: 16), // Larger font size
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoals[4] = value;
                      _updateValidation();
                    });
                  },
                  inputSublabel:
                      const Text('Ensure users remember and recognize the brand.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}