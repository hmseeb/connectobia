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
          'Contract Details',
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
              'We want content that truly represents our brand’s commitment to sustainability. Your posts should highlight eco-friendly practices, ethical consumerism, and green lifestyle choices. The content should feel authentic—whether it’s through engaging stories, informative posts, or interactive live sessions. Show how our product fits into a sustainable lifestyle, making it a natural choice for conscious consumers. Avoid any messaging that contradicts environmental values, and ensure that your audience walks away feeling inspired to make greener choices.',
              style: theme.textTheme.p,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Terms and Conditions Section
        const Text(
          'Please review the contract details carefully before accepting. Make sure all information is correct and that you are comfortable with the terms and conditions.',
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