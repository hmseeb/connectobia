import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_view.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/create_campaign.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/status_badge.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    // Check if user is a brand - only brands can edit campaigns
    final bool isBrand = CollectionNameSingleton.instance == 'brands';

    // If campaign is null, show placeholder for skeleton loading
    final title = campaign?.title ?? 'Untitled Campaign';
    final description = campaign?.description ?? 'No description';
    final status = campaign?.status ?? 'draft';
    final budget = campaign?.budget ?? 0.0;
    final startDate = campaign?.startDate ?? DateTime.now();
    final endDate =
        campaign?.endDate ?? DateTime.now().add(const Duration(days: 30));

    // Format currency with dynamic locale
    final locale = Localizations.localeOf(context).toString();
    final formattedBudget =
        NumberFormat.currency(locale: locale, symbol: '\$').format(budget);
    final dateFormat = DateFormat('MMM d, yyyy');

    // For skeleton loading, just return the card without Slidable
    if (campaign == null) {
      return _buildCardContent(
        context,
        title,
        description,
        status,
        formattedBudget,
        startDate,
        endDate,
        dateFormat,
      );
    }

    // Use Slidable when we have a real campaign, but only for brands
    if (isBrand) {
      return Slidable(
        key: ValueKey(campaign!.id),
        // Show actions only on the end side (right side in LTR)
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.3, // Limit how far the pane extends
          children: [
            // Edit action
            SlidableAction(
              onPressed: (context) {
                if (campaign!.status.toLowerCase() == 'active') {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ShadCard(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Unable to Edit',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You are unable to edit the campaign.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity, // Full width of parent
                              child: ShadButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  return;
                }
                HapticFeedback.mediumImpact();
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => CreateCampaignScreen(
                      campaignToEdit: campaign,
                    ),
                  ),
                )
                    .then((_) {
                  onDeleted();
                });
              },
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            // Delete action
            SlidableAction(
              onPressed: (context) async {
                if (campaign!.status.toLowerCase() == 'active') {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ShadCard(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Unable to Delete',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You are unable to delete the campaign.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity, // Full width of parent
                              child: ShadButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  return;
                }
                HapticFeedback.mediumImpact();
                showDeleteConfirmationDialog(
                  context,
                  () async {
                    try {
                      await CampaignRepository.deleteCampaign(campaign!.id);
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
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            // Cancel action - only for draft or assigned campaigns
            if (campaign != null &&
                (campaign!.status.toLowerCase() == 'draft' ||
                    campaign!.status.toLowerCase() == 'assigned'))
              SlidableAction(
                onPressed: (context) {
                  HapticFeedback.mediumImpact();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Cancel Campaign'),
                      content: const Text(
                          'Are you sure you want to cancel this campaign? Your locked funds will be released back to your account.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'OK');
                            // Add cancel campaign logic
                            try {
                              CampaignRepository.cancelCampaign(campaign!.id)
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Campaign cancelled. Funds have been released.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                // Refresh the list
                                onDeleted();
                              });
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error cancelling campaign: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.cancel,
                label: 'Cancel',
              ),
          ],
        ),
        child: _buildCardContent(
          context,
          title,
          description,
          status,
          formattedBudget,
          startDate,
          endDate,
          dateFormat,
        ),
      );
    } else {
      // For influencers, return the card without edit options
      return _buildCardContent(
        context,
        title,
        description,
        status,
        formattedBudget,
        startDate,
        endDate,
        dateFormat,
      );
    }
  }

  Widget _buildCardContent(
    BuildContext context,
    String title,
    String description,
    String status,
    String formattedBudget,
    DateTime startDate,
    DateTime endDate,
    DateFormat dateFormat,
  ) {
    return GestureDetector(
      onTap: () {
        if (campaign != null) {
          // Use Navigator.push with MaterialPageRoute instead of pushNamed
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CampaignDetailsPage(
                campaignId: campaign!.id,
                userType: 'brand', // Default user type for brand campaigns
              ),
            ),
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
