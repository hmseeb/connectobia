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
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
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
                label: const Text('Campaign Name'),
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
                label: const Text('Campaign Description'),
                placeholder: const Text('Enter campaign description'),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
