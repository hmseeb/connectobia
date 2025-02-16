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

  @override
  void dispose() {
    _campaignNameController.dispose();
    _campaignDescriptionController.dispose();
    super.dispose();
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
            ShadInputFormField(
              controller: _campaignNameController,
              label: const Text('Campaign Name'), // Use Text widget here
              placeholder: Text('Enter campaign name'),
            ),
            const SizedBox(height: 20), // Adds space between the two fields
            ShadInputFormField(
              controller: _campaignDescriptionController,
              label: const Text('Campaign Description'), // Use Text widget here
              placeholder: Text('Enter campaign description'),
              maxLines: 3, // Allows multiple lines for description
            ),
          ],
        ),
      ),
    );
  }
}