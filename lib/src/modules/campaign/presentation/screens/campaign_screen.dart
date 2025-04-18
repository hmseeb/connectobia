import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_card.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/search_field.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';


class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
  children: [
    const SearchField(),
    const SizedBox(height: 16),
    ...List.generate(
      3,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // Adds space between cards
        child: const CampaignCard())),// Generates 5 CampaignCards
  ],
),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createCampaign);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
