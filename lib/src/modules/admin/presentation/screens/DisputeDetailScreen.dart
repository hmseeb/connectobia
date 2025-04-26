import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';

class Dispute {
  final String campaignName;
  final String brandName;
  final String influencerName;
  final String reportedBy;
  final String reportText;
  final String campaignId;

  Dispute({
    required this.campaignName,
    required this.brandName,
    required this.influencerName,
    required this.reportedBy,
    required this.reportText,
    required this.campaignId,
  });
}

class DisputeDetailsPage extends StatefulWidget {
  final Dispute dispute;

  const DisputeDetailsPage({super.key, required this.dispute});

  @override
  State<DisputeDetailsPage> createState() => _DisputeDetailsPageState();
}

class _DisputeDetailsPageState extends State<DisputeDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: transparentAppBar('Dispute Details', context: context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisputeInfoCard(),
            const SizedBox(height: 16),
            _buildReportTextCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
            const Spacer(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Dispute Information Card
  Widget _buildDisputeInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Campaign Name', widget.dispute.campaignName),
            _buildDetailRow('Brand Name', widget.dispute.brandName),
            _buildDetailRow('Influencer Name', widget.dispute.influencerName),
            _buildDetailRow('Reported By', widget.dispute.reportedBy),
          ],
        ),
      ),
    );
  }

  // Report Text Card
  Widget _buildReportTextCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Text:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.dispute.reportText,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Actions Card
  Widget _buildActionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing Campaign ID: ${widget.dispute.campaignId}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('View Campaign'),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Buttons
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: ShadButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ShadButton(
            onPressed: () {
              // Handle Next button press
            },
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  // Helper Method for displaying label-value pairs
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
