import 'package:connectobia/src/modules/campaignView/presentation/widgests/campaign_contract_view.dart';
import 'package:connectobia/src/modules/campaignView/presentation/widgests/campaign_info.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignDetailsPage extends StatefulWidget {
  const CampaignDetailsPage({super.key});

  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage> {

  int _currentStep = 1;

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
        return const CampaignInfoWidget();
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
              children: [
                Expanded(
                  flex: 3, // 30% width
                  child: ShadButton(
                    onPressed: _currentStep > 1 ? _goToPreviousStep : null,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7, // 70% width
                  child: ShadButton(
                    onPressed: _currentStep < 2 ? _goToNextStep : () {
                      // Handle contract signing logic
                    },
                    size: ShadButtonSize.lg,
                    child: Text(
                      _currentStep < 2 ? 'Next' : 'Sign Contract',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
