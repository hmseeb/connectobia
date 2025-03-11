import 'package:connectobia/src/modules/campaign/presentation/widgets/goals_cheakbox.dart';
import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SVG Image (Above the Card)
          SvgPicture.asset(
            AssetsPath.campaignGoals, // Replace with your actual SVG asset path
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 10), // Adds space between image and card
          // The ShadCard containing goals
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Keeps it responsive
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
                    id: 'goal1',
                    label: 'Increase Brand Awareness',
                    sublabel: 'Expand your reach and brand awareness',
                    initialValue: _selectedGoals[0],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals[0] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'goal2',
                    label: 'Drive Sales',
                    sublabel: 'Attract Potential Customers and Enhance Sales Performance',
                    initialValue: _selectedGoals[1],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals[1] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'goal3',
                    label: 'Boost Engagement',
                    sublabel: 'Increase audience interaction and participation',
                    initialValue: _selectedGoals[2],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals[2] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'goal4',
                    label: 'More Website Visits',
                    sublabel: 'Use influencers to bring users to your site',
                    initialValue: _selectedGoals[3],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals[3] = value;
                        _updateValidation();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CampaignGoalCheckbox(
                    id: 'goal5',
                    label: 'Improve Brand Recognition',
                    sublabel: 'Ensure users remember and recognize the brand.',
                    initialValue: _selectedGoals[4],
                    onChanged: (value) {
                      setState(() {
                        _selectedGoals[4] = value;
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
}