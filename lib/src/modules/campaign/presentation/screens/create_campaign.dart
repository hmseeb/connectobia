import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_goals_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/contract_details.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/custom_progress_indicator.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/navigation_buttons.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/select_influencer.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';

class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key});

  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _campaignDescriptionController = TextEditingController();
  int _currentStep = 1;
  bool _isStep2Valid = false; // Track validation for Step 2

  @override
  void dispose() {
    _campaignNameController.dispose();
    _campaignDescriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep == 2 && !_isStep2Valid) {
      // Show error if Step 2 is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must select at least one goal')),
      );
      return;
    }
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      print('Moving to step $_currentStep');
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
      print('Moving to step $_currentStep');
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return CampaignFormCard(
          campaignNameController: _campaignNameController,
          campaignDescriptionController: _campaignDescriptionController,
        );
      case 2:
        return CampaignGoals(
          onValidationChanged: (isValid) {
            setState(() {
              _isStep2Valid = isValid;
            });
          },
        );
      case 3:
        return SelectInfluencerStep(
          onSelectedInfluencersChanged: (selected) {
            print("Selected Influencers: $selected");
          },
        );
      case 4:
        return ContractDetailsStep();
      default:
        return const Center(child: Text('Invalid Step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Create Campaign', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: _buildStepContent(), // Wrap step content in a scrollable widget
                  ),
                ],
              ),
            ),
            Column(
              children: [
                // Use the NavigationButtons widget
                NavigationButtons(
                  currentStep: _currentStep,
                  onPrevious: _goToPreviousStep,
                  onNext: _goToNextStep,
                ),
                const SizedBox(height: 10),
                // Use the CustomProgressIndicator widget
                CustomProgressIndicator(currentStep: _currentStep),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}