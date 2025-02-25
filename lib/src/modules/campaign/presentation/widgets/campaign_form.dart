import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/assets.dart'; // Import the flutter_svg package

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add the SVG image here
        Center(
          child: SvgPicture.asset(
            AssetsPath.login, // Replace with your SVG asset path
            height: 150,
            width: 150,
          ),
        ),
        const SizedBox(height: 10), // Add spacing below the image
        Text(
          'Campaign Name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ShadInputFormField(
          controller: campaignNameController,
          placeholder: const Text('Enter campaign name'),
        ),
        const SizedBox(height: 20),
        Text(
          'Campaign Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        ShadInputFormField(
          controller: campaignDescriptionController,
          placeholder: const Text('Enter campaign description'),
          maxLines: 5,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}