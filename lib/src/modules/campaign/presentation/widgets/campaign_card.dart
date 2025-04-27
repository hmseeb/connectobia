import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/status_badge.dart';
import 'package:connectobia/src/modules/campaignView/presentation/screens/campaign_view.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    // For skeleton loading, just return the card without Dismissible
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

    // Use Dismissible when we have a real campaign
    return Dismissible(
      key: Key(campaign!.id),
      // Support both horizontal directions
      direction: DismissDirection.horizontal,
      // Additional properties for better user experience
      dismissThresholds: const {
        DismissDirection.startToEnd:
            0.25, // Lower threshold for easier triggering
        DismissDirection.endToStart: 0.25,
      },
      // Provide haptic feedback when the threshold is reached
      onUpdate: (details) {
        if (details.progress >= 0.2 && details.progress <= 0.22) {
          HapticFeedback.mediumImpact();
        }
      },
      // Resize animation when dismissing
      resizeDuration: const Duration(milliseconds: 300),
      // Confirm dialog for delete
      confirmDismiss: (direction) async {
        // Provide haptic feedback when fully dismissed
        HapticFeedback.heavyImpact();

        if (direction == DismissDirection.endToStart) {
          // Delete action - right to left swipe
          // Show confirmation dialog
          bool confirmed = false;
          showDeleteConfirmationDialog(
            context,
            () {
              confirmed = true;
            },
          );
          if (confirmed) {
            try {
              await CampaignRepository.deleteCampaign(campaign!.id);
              onDeleted();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting campaign: $e')),
                );
              }
            }
          }
          return false; // Don't actually dismiss the item, we'll handle it manually
        } else if (direction == DismissDirection.startToEnd) {
          // Double action for left to right swipe - show modal for options
          _showActionOptions(context);
          return false; // Don't dismiss the item
        }
        return false;
      },
      // Background for multiple actions
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue.shade700,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.menu, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Actions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Secondary background for delete (right to left swipe)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
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

  void _duplicateCampaign(BuildContext context) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duplicating campaign...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Create a copy with a new title
      final copiedCampaign = Campaign(
        collectionId: campaign!.collectionId,
        collectionName: campaign!.collectionName,
        id: '', // Empty id for a new record
        title: '${campaign!.title} (Copy)',
        description: campaign!.description,
        goals: campaign!.goals,
        category: campaign!.category,
        budget: campaign!.budget,
        startDate: campaign!.startDate,
        endDate: campaign!.endDate,
        status: 'draft', // Always start as draft
        brand: campaign!.brand,
        selectedInfluencer: '', // Clear the influencer
        created: DateTime.now(),
        updated: DateTime.now(),
      );

      // Save the new campaign
      await CampaignRepository.createCampaign(copiedCampaign);

      // Reload campaigns
      if (context.mounted) {
        context.read<CampaignBloc>().add(LoadCampaigns());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign duplicated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating campaign: $e')),
        );
      }
    }
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

  void _showActionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Campaign Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Campaign'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.of(context).pushNamed(
                  createCampaign,
                  arguments: {'campaign': campaign},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Campaign'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _duplicateCampaign(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
