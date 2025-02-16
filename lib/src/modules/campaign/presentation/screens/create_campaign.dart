import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key});

  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _campaignDescriptionController = TextEditingController();
  int _currentStep = 1;

  @override
  void dispose() {
    _campaignNameController.dispose();
    _campaignDescriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
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
        return Column(
          children: [
            const SizedBox(height: 100),
            ShadInputFormField(
              controller: _campaignNameController,
              label: const Text('Campaign Name'),
              placeholder: const Text('Enter campaign name'),
            ),
            const SizedBox(height: 20),
            ShadInputFormField(
              controller: _campaignDescriptionController,
              label: const Text('Campaign Description'),
              placeholder: const Text('Enter campaign description'),
              maxLines: 5,
            ),
          ],
        );
      case 2:
        return const Center(child: Text('Step 2 Content'));
      case 3:
        return const Center(child: Text('Step 3 Content'));
      case 4:
        return const Center(child: Text('Step 4 Content'));
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

            const SizedBox(height: 10),
            // Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 4,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}