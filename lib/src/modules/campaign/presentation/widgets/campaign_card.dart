import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/campaign_view.dart';
import 'package:connectobia/src/modules/campaign/presentation/screens/create_campaign.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/status_badge.dart';
import 'package:connectobia/src/modules/chatting/presentation/screens/messages_screen.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:connectobia/src/shared/data/repositories/brand_repo.dart';
import 'package:connectobia/src/shared/data/repositories/influencer_repo.dart';
import 'package:connectobia/src/shared/data/singletons/account_type.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
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

    // Format currency with PKR
    final formattedBudget =
        NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0).format(budget);
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
            // User Profile Section - moved to very top
            if (campaign != null)
              Column(
                children: [
                  _buildUserProfileSection(context),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
              ),

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
            const SizedBox(height: 12),

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

  Widget _buildUserProfileSection(BuildContext context) {
    final bool isBrand = CollectionNameSingleton.instance == 'brands';

    return FutureBuilder(
      future: _getUserDetails(isBrand),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Simple shimmer loading effect without using Skeletonizer
          return Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userData = snapshot.data;
        String name = '';
        String avatar = '';
        String userId = '';
        String collectionId = '';
        bool hasConnectedSocial = false;
        String industry = '';

        if (isBrand && userData is Influencer) {
          name = userData.fullName;
          avatar = userData.avatar;
          userId = userData.id;
          collectionId = 'influencers';
          hasConnectedSocial = userData.connectedSocial;
          industry = userData.industry;
        } else if (!isBrand && userData is Brand) {
          name = userData.brandName;
          avatar = userData.avatar;
          userId = userData.id;
          collectionId = 'brands';
          hasConnectedSocial = userData.verified;
          industry = userData.industry;
        }

        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: avatar.isNotEmpty
                        ? CachedNetworkImageProvider(
                            Avatar.getUserImage(
                              collectionId: collectionId,
                              image: avatar,
                              recordId: userId,
                            ),
                          )
                        : null,
                    child: avatar.isEmpty
                        ? Icon(Icons.person,
                            size: 16, color: Colors.grey.shade700)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name.isNotEmpty
                                    ? name
                                    : (isBrand ? 'Influencer' : 'Brand'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasConnectedSocial) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          industry.isNotEmpty
                              ? industry
                              : (isBrand ? 'Influencer' : 'Brand'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (userData != null) {
                  _openChat(context, userData);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
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

  Future<dynamic> _getUserDetails(bool isBrand) async {
    if (campaign == null) return null;

    try {
      if (isBrand) {
        // If current user is a brand, get the influencer details
        if (campaign!.selectedInfluencer != null &&
            campaign!.selectedInfluencer!.isNotEmpty) {
          return await InfluencerRepository.getInfluencerById(
              campaign!.selectedInfluencer!);
        }
      } else {
        // If current user is an influencer, get the brand details
        return await BrandRepository.getBrandById(campaign!.brand);
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
    return null;
  }

  void _openChat(BuildContext context, dynamic userData) {
    if (userData == null) return;

    final bool isBrand = CollectionNameSingleton.instance == 'brands';

    String name = '';
    String avatar = '';
    String userId = '';
    String collectionId = '';
    bool hasConnectedSocial = false;

    if (isBrand && userData is Influencer) {
      name = userData.fullName;
      avatar = userData.avatar;
      userId = userData.id;
      collectionId = 'influencers';
      hasConnectedSocial = userData.connectedSocial;
    } else if (!isBrand && userData is Brand) {
      name = userData.brandName;
      avatar = userData.avatar;
      userId = userData.id;
      collectionId = 'brands';
      hasConnectedSocial = userData.verified;
    }

    if (userId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MessagesScreen(
            name: name,
            avatar: avatar,
            userId: userId,
            collectionId: collectionId,
            hasConnectedInstagram: hasConnectedSocial,
          ),
        ),
      );
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
