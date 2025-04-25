import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/status_badge.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignCard extends StatelessWidget {
  final Campaign? campaign;
  final VoidCallback onDeleted;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    // If campaign is null, show placeholder for skeleton loading
    final title = campaign?.title ?? 'Campaign Title';
    final description = campaign?.description ??
        'Campaign description goes here with more details about the campaign.';
    final status = campaign?.status ?? 'draft';
    final budget = campaign?.budget ?? 0.0;
    final startDate = campaign?.startDate ?? DateTime.now();
    final endDate =
        campaign?.endDate ?? DateTime.now().add(const Duration(days: 30));

    // Format currency
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final formattedBudget = currencyFormat.format(budget);

    // Format date
    final dateFormat = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: () {
        if (campaign != null) {
          Navigator.of(context).pushNamed(
            campaignDetails,
            arguments: {'campaignId': campaign!.id},
          );
        }
      },
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Campaign Title, Status & Menu)
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                StatusBadge(
                  text: status.capitalizeFirst(),
                  color: _getStatusColor(status),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.of(context).pushNamed(
                        createCampaign,
                        arguments: {'campaign': campaign},
                      );
                    } else if (value == 'delete' && campaign != null) {
                      showDeleteConfirmationDialog(
                        context,
                        () async {
                          try {
                            await CampaignRepository.deleteCampaign(
                                campaign!.id);
                            onDeleted();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Budget: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedBudget,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Timeline: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to map status to color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'active':
        return Colors.green;
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'closed':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
