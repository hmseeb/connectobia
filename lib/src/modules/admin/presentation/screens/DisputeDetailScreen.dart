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

class DisputeDetailsPage extends StatelessWidget {
  final Dispute dispute;

  const DisputeDetailsPage({super.key, required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Dispute Details', context: context),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDisputeInfoCard(),
              const SizedBox(height: 16),
              _buildReportTextCard(),
              const SizedBox(height: 16),
              _buildActionsCard(context),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputeInfoCard() {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('📢 Campaign', dispute.campaignName),
          _buildDetailRow('🏢 Brand', dispute.brandName),
          _buildDetailRow('👤 Influencer', dispute.influencerName),
          _buildDetailRow('🧾 Reported By', dispute.reportedBy),
        ],
      ),
    );
  }

  Widget _buildReportTextCard() {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📝 Report Text',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(dispute.reportText),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return ShadCard(
      child: Column(
        children: [
          ShadButton(
            child: const Text('🔍 View Campaign'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing Campaign ID: ${dispute.campaignId}')),
              );
            },
          ),
          const SizedBox(height: 12),
          ShadButton(
            child: const Text('⚖️ Take Action'),
            onPressed: () => _showActionDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShadButton(
            child: const Text('⬅️ Back'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ShadButton(
            child: const Text('➡️ Next'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Next clicked')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Take Action'),
        content: const Text('What action would you like to take?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action taken successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}