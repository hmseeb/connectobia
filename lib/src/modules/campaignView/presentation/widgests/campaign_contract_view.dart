import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignContract extends StatefulWidget {
  const CampaignContract({super.key});

  @override
  State<CampaignContract> createState() => _CampaignContractState();
}

class _CampaignContractState extends State<CampaignContract> {
  bool _confirmDetails = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
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
                    child: SizedBox(
                      width: double.infinity,
                      child: Text('Post', style: theme.textTheme.p),
                    ),
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
                    child: SizedBox(
                      width: double.infinity,
                      child: Text('\$300 USD', style: theme.textTheme.p),
                    ),
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
          child: SizedBox(
            width: double.infinity,
            child: Text('March 10, 2025', style: theme.textTheme.p),
          ),
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
          child: SizedBox(
            width: double.infinity,
            child: Text(
              'Influencer must have at least 50K followers and engage in sustainable living content. Content should focus on eco-friendly practices, ethical consumerism, and green lifestyle choices. The influencer should actively interact with their audience through posts, stories, and live sessions to promote sustainability. Additionally, the influencers engagement rate should be above 3%, and they should avoid partnerships with brands that contradict environmental values.',
              style: theme.textTheme.p,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Terms and Conditions Section
        const Text(
          'Please review the contract details carefully before sending. Make sure all information is correct and that you are comfortable with the terms and conditions.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
    
    
        // Confirm Details Checkbox
        Row(
          children: [
            ShadCheckbox(
              value: _confirmDetails,
              onChanged: (value) {
                setState(() {
                  _confirmDetails = value;
                });
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'I confirm all details are correct',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        const SizedBox(height: 8),
    
        // Accept Terms Checkbox
        Row(
          children: [
            ShadCheckbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value;
                });
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'I accept all terms and conditions',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ],
    );
  }
}