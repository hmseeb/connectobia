import 'package:flutter/material.dart';

class CampaignForm extends StatelessWidget {
  final TextEditingController campaignNameController;
  final TextEditingController campaignDescriptionController;

  const CampaignForm({
    Key? key,
    required this.campaignNameController,
    required this.campaignDescriptionController,
  }) : super(key: key);

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
              TextField(
                controller: campaignNameController,
                decoration: const InputDecoration(
                  labelText: 'Campaign Name',
                  hintText: 'Enter campaign name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Campaign Description',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: campaignDescriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Campaign Description',
                  hintText: 'Enter campaign description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
