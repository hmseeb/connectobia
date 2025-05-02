import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/application/contract/contract_bloc.dart';
import 'package:connectobia/src/modules/dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:connectobia/src/shared/data/constants/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
              debugPrint('CampaignBloc state: $state');
              if (state is CampaignLoaded) {
                debugPrint(
                    'Campaign loaded: ${state.campaign.id}, ${state.campaign.title}');
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
                debugPrint('Campaign error: ${state.message}');
                setState(() {
                  isLoading = false;
                  campaign = null;
                });
                _showErrorToast(state.message);
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
                  debugPrint('No contract available for this campaign');
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

                          // Display selected influencer information for brand view
                          if (userType == 'brand' && campaign!.selectedInfluencer != null && campaign!.selectedInfluencer!.isNotEmpty)
                            Column(
                              children: [
                                ShadCard(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 20),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Selected Influencer',
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
                                      FutureBuilder<Influencer>(
                                        future: _getInfluencerById(campaign!.selectedInfluencer!),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          } else if (snapshot.hasError) {
                                            debugPrint('Error loading influencer: ${snapshot.error}');
                                            return const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Unable to load influencer details',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else if (!snapshot.hasData) {
                                            return const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.person_off, color: Colors.grey, size: 48),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Influencer not found',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          final influencer = snapshot.data!;
                                          if (influencer.profile.isEmpty) {
                                            return const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.person_off, color: Colors.grey, size: 48),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Influencer profile not available',
                                                    style: TextStyle(color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return BlocProvider(
                                            create: (context) => InfluencerProfileBloc()
                                              ..add(InfluencerProfileLoad(
                                                profileId: influencer.profile,
                                                influencer: influencer,
                                              )),
                                            child: BlocBuilder<InfluencerProfileBloc, InfluencerProfileState>(
                                              builder: (context, state) {
                                                if (state is InfluencerProfileLoaded) {
                                                  return Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 30,
                                                        backgroundImage: NetworkImage(
                                                          Avatar.getUserImage(
                                                            collectionId: state.influencer.collectionId,
                                                            image: state.influencer.avatar,
                                                            recordId: state.influencer.id,
                                                          ),
                                                        ),
                                                        child: state.influencer.avatar.isEmpty
                                                            ? const Icon(Icons.person, size: 30)
                                                            : null,
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              state.influencer.fullName,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              '@${state.influencer.username}',
                                                              style: TextStyle(
                                                                color: Theme.of(context).textTheme.bodySmall?.color,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                            Text(
                                                              '${state.influencerProfile.followers.toStringAsFixed(0)} followers',
                                                              style: TextStyle(
                                                                color: Theme.of(context).textTheme.bodySmall?.color,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else if (state is InfluencerProfileError) {
                                                  debugPrint('Error loading influencer profile: ${state.message}');
                                                  return const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Unable to load influencer profile',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),

                          // Status management (for influencers)
                          if (userType == 'influencer' &&
                              campaign!.status == 'draft')
                            Column(
                              children: [
                                _buildStatusUpdateSection(),
                                const SizedBox(height: 24),
                              ],
                            ),

                          // Contracts section
                          if (contract != null)
                            Column(
                              children: [
                                _buildContractSection(contract!),
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

            final providedUserType = args['userType'] as String?;
            if (providedUserType != null && providedUserType.isNotEmpty) {
              userType = providedUserType;
            }
          }
        } catch (e) {
          debugPrint('Error parsing arguments: $e');
        }
      } else {
        debugPrint('Warning: No arguments provided to CampaignDetailsPage');
      }

      // Check if campaignId is valid
      if (campaignId.isEmpty) {
        debugPrint('Warning: Empty campaignId in CampaignDetailsPage');
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
    // Initialize with values from widget if available
    campaignId = widget.campaignId ?? '';
    userType = widget.userType ?? 'brand'; // Default to 'brand' if not provided

    // Get the current user ID
    _getCurrentUserId();

    // Check if campaignId is valid from constructor
    if (campaignId.isNotEmpty) {
      // Delay to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Widget _buildCampaignDetails(Campaign campaign) {
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
          _buildDetailRow('Budget', '\$${campaign.budget.toStringAsFixed(2)}',
              Icons.attach_money),
          _buildDetailRow(
              'Category',
              campaign.category.replaceAll('_', ' ').toUpperCase(),
              Icons.category),
          _buildDetailRow(
              'Goals',
              campaign.goals.map((g) => g.toUpperCase()).join(', '),
              Icons.flag),
          _buildDetailRow(
            'Duration',
            '${_formatDate(campaign.startDate)} to ${_formatDate(campaign.endDate)}',
            Icons.date_range,
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

            // Contract actions for influencer
            if (userType == 'influencer' &&
                contract.status == 'pending' &&
                !contract.isSignedByInfluencer)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ShadButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Sign Contract',
                            'Are you sure you want to sign this contract? This will legally bind you to the terms specified.',
                            () => _signContract(contract.id),
                          );
                        },
                        child: const Text('Sign Contract'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton.secondary(
                        onPressed: () {
                          _showConfirmationDialog(
                            'Reject Contract',
                            'Are you sure you want to reject this contract? This action cannot be undone.',
                            () => _rejectContract(contract.id),
                          );
                        },
                        child: const Text('Reject'),
                      ),
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

  Widget _buildStatusUpdateSection() {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.update, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Update Campaign Status',
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
            'As an influencer, you can change this campaign from draft to active status.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () {
                _showConfirmationDialog(
                  'Activate Campaign',
                  'Are you sure you want to activate this campaign? This will make it visible to all potential influencers.',
                  () => _updateCampaignStatus('active'),
                );
              },
              child: const Text('Activate Campaign'),
            ),
          ),
        ],
      ),
    );
  }

  void _completeContract(String contractId) {
    context.read<ContractBloc>().add(
          CompleteContract(contractId),
        );
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
    switch (status) {
      case 'pending':
        return Colors.amber.shade100;
      case 'signed':
        return Colors.green.shade100;
      case 'completed':
        return Colors.purple.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getContractStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber.shade800;
      case 'signed':
        return AppColors.success;
      case 'completed':
        return Colors.purple.shade800;
      case 'rejected':
        return AppColors.error;
      default:
        return Colors.grey.shade800;
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final pb = await PocketBaseSingleton.instance;
      if (pb.authStore.isValid) {
        setState(() {
          userId = pb.authStore.record?.id ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
    }
  }

  void _loadData() {
    try {
      // Validate campaignId before proceeding
      if (campaignId.isEmpty) {
        debugPrint('Error: Empty campaignId in _loadData');
        setState(() {
          isLoading = false;
        });
        _showErrorToast('Campaign ID is missing');
        return;
      }

      // Reset loading state
      setState(() {
        isLoading = true;
        // Don't clear the existing campaign data until new data is loaded
        // This prevents the campaign from disappearing during refresh
      });

      // Debug the campaign ID we're trying to load
      debugPrint('Loading campaign data for ID: "$campaignId"');

      // Load campaign details with error handling
      context.read<CampaignBloc>().add(LoadCampaign(campaignId));

      // Load contract if exists
      context.read<ContractBloc>().add(LoadCampaignContract(campaignId));
    } catch (e) {
      debugPrint('Error in _loadData: $e');
      setState(() {
        isLoading = false;
        // Keep existing campaign data on error
        // Only set campaign to null if it was never loaded
        if (campaign == null) {
          _showErrorToast('Failed to load campaign: $e');
        } else {
          _showErrorToast('Error refreshing data. Using cached data instead.');
        }
      });
    }
  }

  void _rejectContract(String contractId) {
    context.read<ContractBloc>().add(
          RejectContract(contractId),
        );
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
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(message),
      ),
    );
  }

  void _showSuccessToast(String message) {
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(message),
      ),
    );
  }

  void _signContract(String contractId) {
    context.read<ContractBloc>().add(
          SignContractByInfluencer(contractId),
        );
  }

  void _updateCampaignStatus(String status) {
    if (campaign != null) {
      context.read<CampaignBloc>().add(
            UpdateCampaignStatus(campaign!.id, status),
          );
    }
  }

  Future<Influencer> _getInfluencerById(String influencerId) async {
    try {
      final pb = await PocketBaseSingleton.instance;
      final record = await pb.collection('influencers').getOne(influencerId);
      if (record == null) {
        throw Exception('Influencer not found');
      }
      return Influencer.fromRecord(record);
    } catch (e) {
      debugPrint('Error getting influencer: $e');
      rethrow;
    }
  }
}
