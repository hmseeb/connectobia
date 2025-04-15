import 'dart:async';
import 'dart:convert';

import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/application/contract/contract_bloc.dart';
import 'package:connectobia/src/modules/campaign/data/contract_repository.dart';
import 'package:connectobia/src/modules/profile/data/review_repository.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class CampaignDetailsPage extends StatefulWidget {
  final String? campaignId;
  final String? userType;

  const CampaignDetailsPage({
    super.key,
    this.campaignId,
    this.userType,
  });

  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage> {
  late String campaignId;
  late String userType;
  String userId = '';
  bool isLoading = true;
  Campaign? campaign;
  Contract? contract;
  bool showSubmission = false;
  bool _isUrlEditingMode = false;
  bool _isUrlSubmitting = false;
  List<TextEditingController> _urlControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        titleTextStyle: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CampaignBloc, CampaignState>(
            listener: (context, state) {
              if (state is CampaignLoaded) {
                setState(() {
                  campaign = state.campaign;
                  isLoading = false;
                });
              } else if (state is CampaignUpdated) {
                setState(() {
                  campaign = state.campaign;
                });
                _showSuccessToast('Campaign status updated successfully');
              } else if (state is CampaignError) {
                if (isLoading || campaign == null) {
                  setState(() {
                    isLoading = false;
                    campaign = null;
                  });
                  _showErrorToast(state.message);
                } else {
                  _showErrorToast('Error updating campaign: ${state.message}');
                }
              }
            },
          ),
          BlocListener<ContractBloc, ContractState>(
            listener: (context, state) {
              if (state is CampaignContractLoaded) {
                setState(() {
                  contract = state.contract;
                });
                if (contract == null) {
                  // No contract available message
                } else {
                  // If this was triggered by the Accept button for influencers
                  if (userType == 'influencer' && campaign?.status == 'draft') {
                    _showSuccessToast(
                        'Please review and sign the contract below');
                  }
                }
              } else if (state is ContractCreated) {
                setState(() {
                  contract = state.contract;
                });
                _showSuccessToast('Contract created successfully');
              } else if (state is ContractSigned) {
                setState(() {
                  contract = state.contract;
                });
                _showSuccessToast('Contract signed successfully');

                // Ensure we don't trigger a full reload that could cause errors
                // Just update local campaign state instead
                if (campaign != null) {
                  setState(() {
                    campaign = campaign!.copyWith(status: 'in_progress');
                  });
                }
              } else if (state is ContractCompleted) {
                setState(() {
                  contract = state.contract;
                });
                _showSuccessToast(
                    'Contract marked as completed successfully! You can now leave a review.');
              } else if (state is ContractRejected) {
                setState(() {
                  contract = state.contract;
                });
                _showSuccessToast('Contract rejected successfully');

                // Update local campaign state instead of triggering a reload
                if (campaign != null) {
                  setState(() {
                    campaign = campaign!.copyWith(status: 'declined');
                  });
                }
              } else if (state is ContractUrlsUpdated) {
                setState(() {
                  contract = state.contract;
                });
                _showSuccessToast('Content submitted successfully');
              } else if (state is ContractError) {
                _showErrorToast(state.message);
              }
            },
          ),
        ],
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading campaign details...'),
                  ],
                ),
              )
            : campaign == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Campaign not found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            'We could not find a campaign with ID: $campaignId. '
                            'It may have been deleted or you do not have access to it.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShadButton(
                          onPressed: _loadData,
                          child: const Text('Try Again'),
                        ),
                        const SizedBox(height: 8),
                        ShadButton.secondary(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCampaignHeader(campaign!),
                          const SizedBox(height: 16),
                          _buildCampaignDetails(campaign!),
                          const SizedBox(height: 24),

                          // Contracts section
                          if (contract != null)
                            Column(
                              children: [
                                _buildContractSection(contract!),
                                const SizedBox(height: 24),
                              ],
                            ),

                          // When there's no contract yet but user is an influencer
                          if (contract == null &&
                              userType == 'influencer' &&
                              campaign!.status.toLowerCase() != 'declined' &&
                              campaign!.status.toLowerCase() != 'completed')
                            Column(
                              children: [
                                _buildAcceptRejectSection(),
                                const SizedBox(height: 24),
                              ],
                            ),

                          // Add some padding at the bottom for better scrolling
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only try to extract arguments if campaignId is still empty (not provided via constructor)
    if (campaignId.isEmpty) {
      // Try to extract arguments from route
      final routeSettings = ModalRoute.of(context)?.settings;
      if (routeSettings?.arguments != null) {
        try {
          final args = routeSettings!.arguments as Map<String, dynamic>?;
          if (args != null) {
            // Only update values if arguments are provided
            final providedCampaignId = args['campaignId'] as String?;
            if (providedCampaignId != null && providedCampaignId.isNotEmpty) {
              campaignId = providedCampaignId;
            }

            // We still take the userType from route args temporarily
            // but we'll verify it with _getCurrentUserIdAndType later
            final providedUserType = args['userType'] as String?;
            if (providedUserType != null && providedUserType.isNotEmpty) {
              userType = providedUserType;
            }
          }
        } catch (e) {
          // Error handling
        }
      }

      // Check if campaignId is valid
      if (campaignId.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Load data with the campaign ID we have (either from args or the default)
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    campaignId = widget.campaignId ?? '';
    userType = widget.userType ?? '';

    _loadData();
  }

  Widget _buildAcceptRejectSection() {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Campaign Invitation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'You have been invited to participate in this campaign. Please review the details above and decide if you would like to proceed.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ShadButton.destructive(
                  onPressed: () {
                    _showConfirmationDialog(
                      'Reject Campaign',
                      'Are you sure you want to reject this campaign? This action cannot be undone.',
                      () => _rejectContract(''),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Reject Campaign'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShadButton(
                  onPressed: () {
                    _showConfirmationDialog(
                      'Accept Campaign',
                      'Do you want to accept this campaign and proceed to create a contract?',
                      () => _signContract(''),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16),
                      SizedBox(width: 8),
                      Text('Accept Campaign'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignDetails(Campaign campaign) {
    // Format currency
    final currencyFormat =
        NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
    final formattedBudget = currencyFormat.format(campaign.budget);

    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Campaign Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildDetailRow('Category', campaign.category.toUpperCase()),
          _buildDetailRow(
            'Budget',
            formattedBudget,
          ),
          _buildDetailRow(
            'Timeline',
            '${_formatDate(campaign.startDate)} to ${_formatDate(campaign.endDate)}',
          ),
          _buildDetailRow(
            'Goals',
            campaign.goals.map((g) => g.toUpperCase()).join(', '),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHeader(Campaign campaign) {
    return RepaintBoundary(
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(campaign.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        campaign.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getBadgeTextColor(campaign.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              campaign.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractSection(Contract contract) {
    final bool canTakeAction = campaign!.status.toLowerCase() != 'declined' &&
        campaign!.status.toLowerCase() != 'completed' &&
        userType == 'influencer' &&
        (contract.status.toLowerCase() == 'pending' ||
            contract.status.toLowerCase() == 'draft');

    // Check if we should show submission field
    final bool showSubmission = userType == 'influencer' &&
        campaign!.status.toLowerCase() == 'active' &&
        contract.status.toLowerCase() == 'signed';

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.article, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Contract Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getContractStatusColor(contract.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contract.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getContractStatusTextColor(contract.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Post Types', contract.postType.join(', ')),
            _buildDetailRow('Delivery Date',
                contract.deliveryDate.toString().substring(0, 10)),
            _buildDetailRow('Terms', contract.terms),
            if (contract.guidelines.isNotEmpty)
              _buildDetailRow('Guidelines', contract.guidelines),

            // URL Submission & Display Section
            _buildUrlDisplaySection(contract),

            // Influencer contract actions - now directly under contract details
            if (canTakeAction)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Please review the contract details above and decide whether to sign or reject it.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ShadButton.destructive(
                            onPressed: () {
                              _showConfirmationDialog(
                                'Reject Contract',
                                'Are you sure you want to reject this contract? This action cannot be undone.',
                                () => _rejectContract(contract.id),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 5),
                                Text('Reject Contract'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ShadButton(
                            onPressed: () {
                              _showConfirmationDialog(
                                'Sign Contract',
                                'By signing this contract, you agree to all the terms and conditions. Proceed?',
                                () => _signContract(contract.id),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 5),
                                Text('Sign Contract'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Status information when no action is needed
            if (userType == 'influencer' && !canTakeAction && !showSubmission)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusMessage(),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

            // Contract completion for brand
            if (userType == 'brand' && contract.status == 'signed')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ShadButton(
                  onPressed: () {
                    _showConfirmationDialog(
                      'Complete Contract',
                      'Are you sure you want to mark this contract as completed? This will release the payment to the influencer.',
                      () => _completeContract(contract.id),
                    );
                  },
                  child: const Text('Mark as Completed'),
                ),
              ),

            // Review option for completed contracts
            if (contract.status == 'completed')
              FutureBuilder<bool>(
                future: _checkIfReviewExists(contract.id),
                builder: (context, snapshot) {
                  // Only show the button if the user hasn't reviewed yet
                  if (snapshot.hasData && !snapshot.data!) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ShadButton.secondary(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/review',
                            arguments: {'contractId': contract.id},
                          ).then((_) {
                            // Refresh the review status when returning from review screen
                            setState(() {});
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('Leave a Review'),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Thanks for your review!',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  // Show loading indicator while checking
                  return const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced method to display URLs with better UI
  Widget _buildUrlDisplaySection(Contract contract) {
    // Parse URLs from the contract
    List<String> urls = _parseUrlsFromContract(contract);

    // Return empty widget if no URLs and user can't edit
    if (urls.isEmpty &&
        !(userType == 'influencer' && contract.status == 'signed')) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Submitted Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // Only show edit button to influencers for signed contracts
              if (userType == 'influencer' &&
                  contract.status == 'signed' &&
                  !_isUrlEditingMode)
                ShadButton.outline(
                  onPressed: () {
                    _initializeUrlControllers(urls);
                    setState(() {
                      _isUrlEditingMode = true;
                    });
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14),
                      SizedBox(width: 4),
                      Text('Edit URLs'),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isUrlEditingMode)
            // URL Editing UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the URLs where your content for this campaign can be viewed.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // URL Input Fields
                ..._buildUrlInputFields(),

                // Add URL Button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: ShadButton.outline(
                      onPressed: () {
                        setState(() {
                          _urlControllers.add(TextEditingController());
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14),
                          SizedBox(width: 4),
                          Text('Add Another URL'),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.secondary(
                        onPressed: () {
                          setState(() {
                            _isUrlEditingMode = false;
                            _urlControllers.clear();
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton(
                        onPressed: _isUrlSubmitting ? null : _submitUrls,
                        child: _isUrlSubmitting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else if (urls.isNotEmpty)
            // Display URL List
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: urls.map((url) => _buildUrlItem(url)).toList(),
              ),
            )
          else if (userType == 'influencer' && contract.status == 'signed')
            // Show prompt for influencers with signed contracts but no URLs yet
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No content submitted yet',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "Edit URLs" to add links to your content for this campaign.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildUrlInputFields() {
    return List.generate(
      _urlControllers.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _urlControllers[index],
                decoration: InputDecoration(
                  hintText: 'https://example.com/your-post',
                  prefixIcon: const Icon(Icons.link, size: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_urlControllers.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _urlControllers.removeAt(index);
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // Widget to display a single URL with a clickable link
  Widget _buildUrlItem(String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchUrl(url),
              child: Text(
                url,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _launchUrl(url),
            tooltip: 'Open link',
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfReviewExists(String contractId) async {
    try {
      if (contract == null) return false;

      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;
      final userCollection = pb.authStore.model.collectionId;
      final isBrand = userCollection == 'brands';

      if (isBrand) {
        return await ReviewRepository.brandReviewExists(
          campaignId: campaign!.id,
          brandId: userId,
          influencerId: contract!.influencer,
        );
      } else {
        return await ReviewRepository.influencerReviewExists(
          campaignId: campaign!.id,
          influencerId: userId,
          brandId: contract!.brand,
        );
      }
    } catch (e) {
      debugPrint('Error checking review existence: $e');
      return false;
    }
  }

  void _completeContract(String contractId) {
    try {
      // Show loading first
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Processing'),
          description: const Text('Completing contract...'),
        ),
      );

      // Update contract
      context.read<ContractBloc>().add(CompleteContract(contractId));

      // Update local state
      setState(() {
        if (contract != null) {
          contract = contract!.copyWith(status: 'completed');
        }
        if (campaign != null) {
          campaign = campaign!.copyWith(status: 'completed');
        }
      });
    } catch (e) {
      _showErrorToast('Error completing contract: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getBadgeColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade100;
      case 'completed':
        return Colors.blue.shade100;
      case 'draft':
        return Colors.yellow.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getBadgeTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade800;
      case 'completed':
        return Colors.blue.shade800;
      case 'draft':
        return Colors.amber.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _getContractStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow.shade100;
      case 'signed':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'completed':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getContractStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;
      case 'signed':
        return Colors.green.shade800;
      case 'rejected':
        return Colors.red.shade800;
      case 'completed':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Future<void> _getCurrentUserIdAndType() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      if (pb.authStore.isValid) {
        final record = pb.authStore.record;
        final recordId = record?.id ?? '';
        final collectionName = record?.collectionName;

        setState(() {
          userId = recordId;

          // Determine user type from record collection name
          if (collectionName != null) {
            if (collectionName.toLowerCase().contains('influencer')) {
              userType = 'influencer';
            } else if (collectionName.toLowerCase().contains('brand')) {
              userType = 'brand';
            }
          }
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  String _getStatusMessage() {
    if (campaign == null) {
      return 'Campaign information not available.';
    }

    switch (campaign!.status.toLowerCase()) {
      case 'declined':
        return 'You have declined this campaign. No further action is required.';
      case 'completed':
        return 'This campaign has been successfully completed. Thank you for your participation!';
      case 'in_progress':
        if (contract != null) {
          if (contract!.status.toLowerCase() == 'signed') {
            return 'You have signed the contract. Please work on the deliverables as agreed.';
          } else if (contract!.status.toLowerCase() == 'rejected') {
            return 'You have rejected the contract for this campaign.';
          } else if (contract!.status.toLowerCase() == 'completed') {
            return 'This contract has been marked as completed. The campaign is now finalized.';
          }
        }
        return 'This campaign is in progress. Please check with the brand for next steps.';
      default:
        return 'Current status: ${campaign!.status.toUpperCase()}';
    }
  }

  void _initializeUrlControllers(List<String> urls) {
    _urlControllers =
        urls.map((url) => TextEditingController(text: url)).toList();
    if (_urlControllers.isEmpty) {
      _urlControllers.add(TextEditingController());
    }
  }

  void _launchUrl(String url) async {
    try {
      debugPrint('Attempting to launch URL: $url');

      // Make sure URL has a scheme
      String urlToLaunch = url.trim();
      if (!urlToLaunch.startsWith('http://') &&
          !urlToLaunch.startsWith('https://')) {
        urlToLaunch = 'https://$urlToLaunch';
        debugPrint('Added https:// prefix: $urlToLaunch');
      }

      // Show loading toast
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Opening Link'),
          description: const Text('Opening in external browser...'),
        ),
      );

      final Uri uri = Uri.parse(urlToLaunch);
      debugPrint('Parsed URI: $uri');

      if (await url_launcher.canLaunchUrl(uri)) {
        debugPrint('URI can be launched, attempting launch...');
        final bool launched = await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        );

        if (!launched) {
          debugPrint('Launch returned false');
          _showErrorToast('Failed to open link: $urlToLaunch');
        } else {
          debugPrint('URL launched successfully');
        }
      } else {
        debugPrint('canLaunchUrl returned false');
        _showErrorToast('Could not open link: $urlToLaunch');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      _showErrorToast('Error opening link: ${e.toString()}');
    }
  }

  Future<void> _loadData() async {
    // Skip loading if we're already in a terminal state (like declined/completed)
    // or if we're in the middle of a state transition (like signing a contract)
    if (campaign != null &&
        (campaign!.status.toLowerCase() == 'declined' ||
            campaign!.status.toLowerCase() == 'completed')) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get current user ID and type
      await _getCurrentUserIdAndType();

      // Load campaign details
      context.read<CampaignBloc>().add(LoadCampaign(campaignId));

      // Load contract for this campaign
      context.read<ContractBloc>().add(LoadCampaignContract(campaignId));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorToast('Error loading data: $e');
    }
  }

  List<String> _parseUrlsFromContract(Contract contract) {
    List<String> urls = [];
    if (contract.postUrl != null && contract.postUrl!.isNotEmpty) {
      try {
        // Check if it's a JSON string that needs to be parsed
        if (contract.postUrl!.startsWith('[')) {
          // It's a JSON array string
          debugPrint('Parsing JSON array from postUrl: ${contract.postUrl}');
          final parsed = jsonDecode(contract.postUrl!);
          if (parsed is List) {
            urls = parsed.map((url) => url.toString()).toList();
          } else {
            // Fallback if the parsed result is not a list
            urls = [contract.postUrl!];
          }
        } else {
          // If it's not a JSON array, try to see if it's a JSON string
          try {
            final parsed = jsonDecode(contract.postUrl!);
            if (parsed is List) {
              urls = parsed.map((url) => url.toString()).toList();
            } else {
              // Single item, not in a list
              urls = [parsed.toString()];
            }
          } catch (e) {
            // Not valid JSON, treat as single URL
            urls = [contract.postUrl!];
          }
        }
      } catch (e) {
        // If parsing fails, just use it directly
        debugPrint('Error parsing postUrl, using as-is: $e');
        urls = [contract.postUrl!];
      }

      // Log the parsed URLs for debugging
      debugPrint('Parsed URLs: $urls');
    }
    return urls;
  }

  void _rejectContract(String contractId) {
    // Show loading toast
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Processing'),
        description: const Text('Rejecting...'),
      ),
    );

    try {
      // If no contract exists yet, we just need to update the campaign status
      if (contractId.isEmpty) {
        context.read<CampaignBloc>().add(
              UpdateCampaignStatus(campaign!.id, 'rejected'),
            );

        // Update local state to prevent reload issues
        setState(() {
          if (campaign != null) {
            campaign = campaign!.copyWith(status: 'rejected');
          }
        });

        // Show success message
        _showSuccessToast('Campaign rejected successfully');
      } else {
        // Reject the existing contract
        // The contract repository will also update the campaign status
        context.read<ContractBloc>().add(RejectContract(contractId));

        // Update local state to prevent reload issues
        setState(() {
          if (campaign != null) {
            campaign = campaign!.copyWith(status: 'rejected');
          }
          if (contract != null) {
            contract = contract!.copyWith(status: 'rejected');
          }
        });
      }
    } catch (e) {
      debugPrint('Error in _rejectContract: $e');
      _showErrorToast('Error rejecting: $e');
    }
  }

  void _showConfirmationDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Wrap action in a try/catch to prevent errors
              try {
                onConfirm();
              } catch (e) {
                _showErrorToast('Error: $e');
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Error'),
        description: Text(message),
      ),
    );
  }

  void _showSuccessToast(String message) {
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Success'),
        description: Text(message),
      ),
    );
  }

  void _signContract(String contractId) {
    // If no contract exists yet, we need to create one
    if (contractId.isEmpty) {
      // Show loading
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Processing'),
          description: const Text('Creating and signing contract...'),
        ),
      );

      // First update campaign status to in_progress
      context.read<CampaignBloc>().add(
            UpdateCampaignStatus(campaign!.id, 'in_progress'),
          );

      // Then load or create contract for this campaign
      context.read<ContractBloc>().add(LoadCampaignContract(campaignId));

      // After contract is loaded/created, sign it
      Future.delayed(const Duration(seconds: 1), () {
        if (contract != null && contract!.id.isNotEmpty) {
          context
              .read<ContractBloc>()
              .add(SignContractByInfluencer(contract!.id));
        }
      });
    } else {
      // Show loading toast
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Processing'),
          description: const Text('Signing contract...'),
        ),
      );

      try {
        // Sign the existing contract
        context.read<ContractBloc>().add(SignContractByInfluencer(contractId));

        // Update campaign status to in_progress
        context.read<CampaignBloc>().add(
              UpdateCampaignStatus(campaign!.id, 'in_progress'),
            );

        // Don't reload the campaign immediately to avoid race conditions
        // Instead, just update the local state if needed
        setState(() {
          if (campaign != null) {
            campaign = campaign!.copyWith(status: 'in_progress');
          }
          if (contract != null) {
            contract = contract!.copyWith(
              status: 'signed',
              isSignedByInfluencer: true,
            );
          }
        });
      } catch (e) {
        _showErrorToast('Error signing contract: $e');
      }
    }
  }

  Future<void> _submitUrls() async {
    if (_urlControllers.isEmpty) {
      _showErrorToast('Please add at least one URL');
      return;
    }

    // Validate all URLs
    bool allValid = true;
    List<String> validUrls = [];

    for (var controller in _urlControllers) {
      final url = controller.text.trim();
      if (url.isNotEmpty) {
        String formattedUrl = url;
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          formattedUrl = 'https://$url';
        }

        try {
          final uri = Uri.parse(formattedUrl);
          if (uri.hasAuthority) {
            validUrls.add(formattedUrl);
          } else {
            allValid = false;
            break;
          }
        } catch (e) {
          allValid = false;
          break;
        }
      }
    }

    if (!allValid) {
      _showErrorToast('Please enter valid URLs for all fields');
      return;
    }

    if (validUrls.isEmpty) {
      _showErrorToast('Please add at least one URL');
      return;
    }

    // Set submitting state to show loading
    setState(() {
      _isUrlSubmitting = true;
    });

    // Convert to JSON string for transport - this is what the repository expects
    final postUrlsJson = jsonEncode(validUrls);

    // Log what we're sending
    debugPrint('DIRECT SUBMISSION: ${validUrls.length} URLs');
    debugPrint('JSON to submit: $postUrlsJson');

    // Show loading indicator
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Updating Content'),
        description: const Text('Saving your changes...'),
      ),
    );

    try {
      // Directly call the repository method to ensure it works
      if (contract != null) {
        final updatedContract =
            await ContractRepository.updatePostUrls(contract!.id, postUrlsJson);

        // Update the contract in state directly
        setState(() {
          contract = updatedContract;
          _isUrlEditingMode = false;
          _isUrlSubmitting = false;
          _urlControllers.clear();
        });

        _showSuccessToast('Content URLs updated successfully');
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isUrlSubmitting = false;
      });
      _showErrorToast('Error updating URLs: $e');
    }
  }
}
