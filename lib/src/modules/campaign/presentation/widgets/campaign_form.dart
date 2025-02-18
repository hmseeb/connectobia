import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignFormCard extends StatelessWidget {
  final TextEditingController campaignNameController;
  final TextEditingController campaignDescriptionController;

  const CampaignFormCard({
    super.key,
    required this.campaignNameController,
    required this.campaignDescriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShadCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Campaign Name',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ShadInputFormField(
              controller: campaignNameController,
              placeholder: const Text('Enter campaign name'),
            ),
            const SizedBox(height: 20),
            Text(
              'Campaign Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ShadInputFormField(
              controller: campaignDescriptionController,
              placeholder: const Text('Enter campaign description'),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
