import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_goals_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/contract_details.dart';
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

  // Custom Step Progress Indicator
  Widget _buildCustomProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Row(
          children: [
            // Step Circle
            Container(
              width: 30,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentStep > index ? Colors.blue : Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _currentStep > index ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Line between steps (except for the last step)
            if (index < 3)
              Container(
                width: 50,
                height: 2,
                color: _currentStep > index + 1 ? Colors.blue : Colors.grey[300],
              ),
          ],
        );
      }),
    );
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
            Expanded(child: _buildStepContent()),
            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Keep space for Back button even when it's hidden
                if (_currentStep > 1)
                  TextButton(
                    onPressed: _goToPreviousStep,
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 70), // Maintain space for hidden Back button
                TextButton(
                  onPressed: _goToNextStep,
                  child: const Text('Next'),
                ),
              ],
            ),
            // Custom Step Progress Indicator
            _buildCustomProgressIndicator(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}