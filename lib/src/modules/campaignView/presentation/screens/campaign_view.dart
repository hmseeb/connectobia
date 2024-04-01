import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/application/collaboration/collaboration_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/contract/contract_bloc.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/domain/models/collaboration.dart';
import 'package:connectobia/src/shared/domain/models/contract.dart';
import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignDetailsPage extends StatefulWidget {
  const CampaignDetailsPage({super.key});

  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage> {
  late String campaignId;
  late String userType; // 'brand' or 'influencer'
  bool isLoading = true;
  Campaign? campaign;
  List<Collaboration> collaborations = [];
  Contract? contract;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Details'),
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
                _showErrorToast(state.message);
              }
            },
          ),
          BlocListener<CollaborationBloc, CollaborationState>(
            listener: (context, state) {
              if (state is CampaignCollaborationsLoaded) {
                setState(() {
                  collaborations = state.collaborations;
                });
              } else if (state is CollaborationCreated) {
                _showSuccessToast('Collaboration request sent successfully');
                context
                    .read<CollaborationBloc>()
                    .add(LoadCampaignCollaborations(campaignId));
              } else if (state is CollaborationAccepted) {
                _showSuccessToast('Collaboration accepted successfully');
                context
                    .read<CollaborationBloc>()
                    .add(LoadCampaignCollaborations(campaignId));
              } else if (state is CollaborationError) {
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
            ? const Center(child: CircularProgressIndicator())
            : campaign == null
                ? const Center(child: Text('Campaign not found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCampaignHeader(campaign!),
                        const SizedBox(height: 16),
                        _buildCampaignDetails(campaign!),
                        const SizedBox(height: 24),

                        // Status management (for influencers)
                        if (userType == 'influencer' &&
                            campaign!.status == 'draft')
                          _buildStatusUpdateSection(),

                        // Contracts section
                        if (contract != null) _buildContractSection(contract!),

                        // Collaborations section
                        if (collaborations.isNotEmpty)
                          _buildCollaborationsSection(),
                      ],
                    ),
                  ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    campaignId = args['campaignId'] as String;
    userType = args['userType'] as String;
    _loadData();
  }

  void _acceptCollaboration(String collaborationId) {
    context.read<CollaborationBloc>().add(
          AcceptCollaboration(collaborationId),
        );
  }

  Widget _buildCampaignDetails(Campaign campaign) {
    return ShadCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Budget', '\$${campaign.budget.toStringAsFixed(2)}'),
          _buildDetailRow('Category', campaign.category),
          _buildDetailRow('Goals', campaign.goals.join(', ')),
          _buildDetailRow(
            'Duration',
            '${campaign.startDate.toString().substring(0, 10)} to ${campaign.endDate.toString().substring(0, 10)}',
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignHeader(Campaign campaign) {
    return ShadCard(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBadgeColor(campaign.status),
                  borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
          Text(
            campaign.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationItem(Collaboration collab) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ShadCard(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount: \$${collab.proposedAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCollabBadgeColor(collab.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    collab.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getCollabBadgeTextColor(collab.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Message: ${collab.message}'),

            // Actions for influencer
            if (userType == 'influencer' && collab.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    ShadButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          'Accept Collaboration',
                          'Are you sure you want to accept this collaboration request?',
                          () => _acceptCollaboration(collab.id),
                        );
                      },
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 8),
                    ShadButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          'Reject Collaboration',
                          'Are you sure you want to reject this collaboration request?',
                          () => _rejectCollaboration(collab.id),
                        );
                      },
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ShadButton(
                      onPressed: () {
                        _showCounterOfferDialog(collab);
                      },
                      child: const Text('Counter Offer'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborationsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Collaboration Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...collaborations.map((collab) => _buildCollaborationItem(collab)),
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
            const Text(
              'Contract Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Status', contract.status),
            _buildDetailRow(
                'Payout', '\$${contract.payout.toStringAsFixed(2)}'),
            _buildDetailRow('Post Types', contract.postType.join(', ')),
            _buildDetailRow('Delivery Date',
                contract.deliveryDate.toString().substring(0, 10)),
            _buildDetailRow('Terms', contract.terms),

            // Contract actions for influencer
            if (userType == 'influencer' &&
                contract.status == 'pending' &&
                !contract.isSignedByInfluencer)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    ShadButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          'Sign Contract',
                          'Are you sure you want to sign this contract? This will legally bind you to the terms specified.',
                          () => _signContract(contract.id),
                        );
                      },
                      child: const Text('Sign Contract'),
                    ),
                    const SizedBox(width: 8),
                    ShadButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          'Reject Contract',
                          'Are you sure you want to reject this contract? This action cannot be undone.',
                          () => _rejectContract(contract.id),
                        );
                      },
                      child: const Text('Reject'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
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
          const Text(
            'Update Campaign Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'As an influencer, you can change this campaign from draft to active status.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ShadButton(
            onPressed: () {
              _showConfirmationDialog(
                'Activate Campaign',
                'Are you sure you want to activate this campaign? Once activated, brands will be able to see and collaborate with you on this campaign.',
                () => _updateCampaignStatus('active'),
              );
            },
            child: const Text('Activate Campaign'),
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

  void _counterOfferCollaboration(
      String collaborationId, double amount, String message) {
    context.read<CollaborationBloc>().add(
          CounterOfferCollaboration(
            collaborationId: collaborationId,
            counterAmount: amount,
            message: message,
          ),
        );
  }

  // Helper methods for badge styling
  Color _getBadgeColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey.shade200;
      case 'active':
        return AppColors.success.withOpacity(0.2);
      case 'assigned':
        return Colors.blue.shade100;
      case 'closed':
        return Colors.grey.shade300;
      case 'deleted':
        return AppColors.error.withOpacity(0.2);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getBadgeTextColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey.shade800;
      case 'active':
        return AppColors.success;
      case 'assigned':
        return Colors.blue.shade800;
      case 'closed':
        return Colors.grey.shade800;
      case 'deleted':
        return AppColors.error;
      default:
        return Colors.grey.shade800;
    }
  }

  Color _getCollabBadgeColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey.shade200;
      case 'accepted':
        return AppColors.success.withOpacity(0.2);
      case 'rejected':
        return AppColors.error.withOpacity(0.2);
      case 'countered':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getCollabBadgeTextColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey.shade800;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'countered':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  void _loadData() {
    // Load campaign details
    context.read<CampaignBloc>().add(LoadCampaign(campaignId));

    // Load collaborations
    context
        .read<CollaborationBloc>()
        .add(LoadCampaignCollaborations(campaignId));

    // Load contract if exists
    context.read<ContractBloc>().add(LoadCampaignContract(campaignId));
  }

  void _rejectCollaboration(String collaborationId) {
    context.read<CollaborationBloc>().add(
          RejectCollaboration(collaborationId),
        );
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

  void _showCounterOfferDialog(Collaboration collab) {
    final amountController = TextEditingController(
      text: collab.proposedAmount.toString(),
    );
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Explain your counter offer',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _counterOfferCollaboration(
                collab.id,
                double.tryParse(amountController.text) ?? collab.proposedAmount,
                messageController.text,
              );
            },
            child: const Text('Submit'),
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
}
