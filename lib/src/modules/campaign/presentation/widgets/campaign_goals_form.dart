import 'package:connectobia/src/modules/campaign/presentation/widgets/goals_cheakbox.dart';
import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignGoals extends StatefulWidget {
  final Function(bool) onValidationChanged;
  final Function(List<String>) onGoalsSelected;

  const CampaignGoals({
    super.key,
    required this.onValidationChanged,
    required this.onGoalsSelected,
  });

  @override
  State<CampaignGoals> createState() => _CampaignGoalsState();
}

class _CampaignGoalsState extends State<CampaignGoals> {
  // Updated to match PocketBase schema goals
  final Map<String, bool> _selectedGoals = {
    'awareness': false,
    'sales': false,
    'engagement': false,
  };

  bool get isAtLeastOneGoalSelected => _selectedGoals.values.contains(true);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SVG Image
          SvgPicture.asset(
            AssetsPath.campaignGoals,
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 10),
          // The ShadCard containing goals
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ShadCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Campaign Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CampaignGoalCheckbox(
                    id: 'awareness',
                    label: 'Increase Brand Awareness',
                    sublabel:
                        'Expand your reach and make more people familiar with your brand',
                    initialValue: _selectedGoals['awareness']!,
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals['awareness'] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'sales',
                    label: 'Drive Sales',
                    sublabel:
                        'Attract potential customers and boost conversion rates',
                    initialValue: _selectedGoals['sales']!,
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals['sales'] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'engagement',
                    label: 'Boost Engagement',
                    sublabel:
                        'Increase audience interaction and participation with your brand',
                    initialValue: _selectedGoals['engagement']!,
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals['engagement'] = value;
                        _updateValidation();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateValidation() {
    widget.onValidationChanged(isAtLeastOneGoalSelected);

    // Collect all selected goals
    List<String> selectedGoals = _selectedGoals.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    widget.onGoalsSelected(selectedGoals);
  }
}
