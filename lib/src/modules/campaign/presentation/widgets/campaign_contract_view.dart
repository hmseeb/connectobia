import 'package:connectobia/src/modules/campaign/presentation/widgets/infocard.dart';
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
  final TextEditingController _suggestionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Contract Details'),
        const SizedBox(height: 16),

        // Post Type & Budget Row
        Row(
          children: [
            Expanded(child: _buildLabeledInfoCard('Post Type', 'Post')),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledInfoCard('Budget', '300 Rs')),
          ],
        ),
        const SizedBox(height: 16),

        // Delivery Date
        _buildLabeledInfoCard('Delivery Date', 'March 10, 2025'),
        const SizedBox(height: 16),

        // Additional Requirements
        _buildLabeledInfoCard(
          'Content Guidelines',
          'We want content that truly represents our brand’s commitment to sustainability. '
              'Your posts should highlight eco-friendly practices, ethical consumerism, and green lifestyle choices. '
              'The content should feel authentic—whether it’s through engaging stories, informative posts, or interactive live sessions. '
              'Show how our product fits into a sustainable lifestyle, making it a natural choice for conscious consumers. '
              'Avoid any messaging that contradicts environmental values, and ensure that your audience walks away feeling inspired to make greener choices.',
          isMultiline: true,
        ),
        const SizedBox(height: 24),

        // Terms and Conditions
        const Text(
          'Please review the contract details carefully before accepting. Make sure all information is correct and that you are comfortable with the terms and conditions.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Confirm Details Checkbox
        _buildCheckbox('I confirm all details are correct', _confirmDetails,
            (value) {
          setState(() => _confirmDetails = value);
        }),
        const SizedBox(height: 8),

        // Accept Terms Checkbox
        _buildCheckbox('I accept all terms and conditions', _acceptTerms,
            (value) {
          setState(() => _acceptTerms = value);
        }),
        const SizedBox(height: 16),

        // Suggestions Input Field
        _buildSectionTitle('Suggestions'),
        const SizedBox(height: 8),
        ShadInput(
          controller: _suggestionsController,
          placeholder: Text('Enter your suggestions...'),
          maxLines: 5,
        ),
        const SizedBox(height: 16),

        // Submit Button
        ShadButton(
          onPressed: () {
            // Handle submission logic
            final suggestions = _suggestionsController.text;
            print('Submitted Suggestions: $suggestions');
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        ShadCheckbox(
          value: value,
          onChanged: (val) => onChanged(val),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Widget _buildLabeledInfoCard(String title, String content,
      {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        InfoCard(text: content, isMultiline: isMultiline),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
    );
  }
}
