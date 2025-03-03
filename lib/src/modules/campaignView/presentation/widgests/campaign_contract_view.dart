import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignContract extends StatelessWidget {
  const CampaignContract({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Details Title
          const Text(
            'Campaign Details',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Post Type & Budget Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post Type',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ShadCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Post', style: theme.textTheme.p),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ShadCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('\$300 USD', style: theme.textTheme.p),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Delivery Date
          const Text(
            'Delivery Date',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ShadCard(
            padding: const EdgeInsets.all(16.0),
            child: Text('March 10, 2025', style: theme.textTheme.p),
          ),
          const SizedBox(height: 16),

          // Additional Requirements
          const Text(
            'Additional Requirements',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ShadCard(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Influencer must have at least 50K followers and engage in sustainable living content.',
              style: theme.textTheme.p,
            ),
          ),
        ],
      ),
    );
  }
}
