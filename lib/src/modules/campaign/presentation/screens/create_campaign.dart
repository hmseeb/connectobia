import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Ensure you have imported ShadCN UI

class CreateCampaign extends StatefulWidget {
  const CreateCampaign({super.key});

  @override
  State<CreateCampaign> createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _campaignDescriptionController = TextEditingController();
  int _currentStep = 1; // Tracks the current step (1 out of 4)

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
      // Navigate to the next page or step
      // You can replace this with your navigation logic
      print('Moving to step $_currentStep');
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
            const SizedBox(height: 100), // Add space at the top to push fields down
            // Campaign Name Field
            ShadInputFormField(
              controller: _campaignNameController,
              label: const Text('Campaign Name'),
              placeholder: const Text('Enter campaign name'),
            ),
            const SizedBox(height: 20), // Space between fields
            // Campaign Description Field
            ShadInputFormField(
              controller: _campaignDescriptionController,
              label: const Text('Campaign Description'),
              placeholder: const Text('Enter campaign description'),
              maxLines: 5, // Allows multiple lines for description
            ),
            const Spacer(), // Pushes the "Next" button and progress bar to the bottom
            // Next Button
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: _goToNextStep,
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 10), // Space between button and progress bar
            // Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 4, // Progress out of 4 steps
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}