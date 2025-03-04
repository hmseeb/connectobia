import 'package:connectobia/src/modules/campaignView/presentation/widgests/campaign_contract_view.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignDetailsPage extends StatefulWidget {
  const CampaignDetailsPage({super.key});

  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage> {
  bool _isExpanded = false;
  int _currentStep = 1;

  final String _campaignDescription =
      "This campaign aims to promote eco-friendly products that help reduce carbon footprints. "
      "We are looking for influencers who can create engaging content showcasing sustainability.";

  void _goToNextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            ShadCard(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text('Innovate Your World', style: ShadTheme.of(context).textTheme.p),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Campaign Goals',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            ShadCard(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text('Brand Awareness', style: ShadTheme.of(context).textTheme.p),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Brand Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            ShadCard(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text('Brand ABC', style: ShadTheme.of(context).textTheme.p),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Campaign Description',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            ShadCard(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isExpanded
                        ? _campaignDescription
                        : '${_campaignDescription.substring(0, 100)}...',
                    style: ShadTheme.of(context).textTheme.p,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Text(
                      _isExpanded ? 'See Less' : 'See More',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return const CampaignContract();
      default:
        return const Center(child: Text('Invalid Step'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Campaign Details', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: _buildStepContent()),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShadButton(
                  onPressed: _currentStep > 1 ? _goToPreviousStep : null,
                  child: const Text('Back'),
                ),
                _currentStep < 2
                    ? ShadButton(
                        onPressed: _goToNextStep,
                        child: const Text('Next'),
                      )
                    : ShadButton(
                        onPressed: () {
                          // Handle contract signing logic
                        },
                        size: ShadButtonSize.lg,
                        child: const Text(
                          'Sign Contract',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
