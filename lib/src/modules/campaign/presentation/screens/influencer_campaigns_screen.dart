import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:connectobia/src/shared/presentation/widgets/error_box.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InfluencerCampaignsScreen extends StatefulWidget {
  const InfluencerCampaignsScreen({super.key});

  @override
  State<InfluencerCampaignsScreen> createState() =>
      _InfluencerCampaignsScreenState();
}

class _InfluencerCampaignsScreenState extends State<InfluencerCampaignsScreen>
    with SingleTickerProviderStateMixin {
  bool _isAssignedLoading = true;
  bool _isAvailableLoading = true;
  String? _assignedErrorMessage;
  String? _availableErrorMessage;
  List<Campaign> _assignedCampaigns = [];
  List<Campaign> _availableCampaigns = [];
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Campaigns', context: context),
      body: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_ind),
                    SizedBox(width: 8),
                    Text('Your Campaigns'),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.campaign),
                    SizedBox(width: 8),
                    Text('Available Campaigns'),
                  ],
                ),
              ),
            ],
          ),
          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Assigned Campaigns Tab
                RefreshIndicator(
                  onRefresh: _loadAssignedCampaigns,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAssignedContent(),
                  ),
                ),
                // Available Campaigns Tab
                RefreshIndicator(
                  onRefresh: _loadAvailableCampaigns,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildAvailableContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAssignedCampaigns();
    _loadAvailableCampaigns();
  }

  Future<void> _applyToCampaign(String campaignId) async {
    // Show loading indicator
    ShadToaster.of(context).show(
      ShadToast(
        title: const Text('Applying for campaign...'),
        description: const Text('Please wait'),
      ),
    );

    try {
      final pb = await PocketBaseSingleton.instance;
      final userId = pb.authStore.model.id;

      // Call the repository to assign the influencer to this campaign
      await CampaignRepository.assignInfluencer(campaignId, userId);

      // Refresh both lists
      await _loadAssignedCampaigns();
      await _loadAvailableCampaigns();

      // Show success message
      ShadToaster.of(context).show(
        ShadToast(
          title: const Text('Application successful'),
          description: const Text('Campaign added to your list'),
        ),
      );

      // Switch to the assigned tab
      _tabController.animateTo(0);
    } catch (e) {
      // Show error message
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text('Failed to apply: $e'),
        ),
      );
    }
  }

  Widget _buildAssignedContent() {
    if (_isAssignedLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_assignedErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorBox(errors: [_assignedErrorMessage!]),
            const SizedBox(height: 16),
            ShadButton.secondary(
              onPressed: _loadAssignedCampaigns,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Step-by-step guidance card
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'How it works',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStepRow(1, 'Review campaign details',
                    'Understand requirements and expectations'),
                _buildStepRow(2, 'Accept campaign',
                    'Confirm your participation and requirements'),
                _buildStepRow(
                    3, 'Sign contract', 'Review and sign the legal agreement'),
                _buildStepRow(4, 'Complete tasks',
                    'Create content according to campaign guidelines'),
                _buildStepRow(5, 'Submit for review',
                    'Send your completed work to the brand'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_assignedCampaigns.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_ind_outlined,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No campaigns assigned yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'When brands select you for campaigns, they will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ShadButton.secondary(
                    onPressed: () {
                      _tabController
                          .animateTo(1); // Switch to Available Campaigns tab
                    },
                    child: const Text('Browse Available Campaigns'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _assignedCampaigns.length,
              itemBuilder: (context, index) {
                final campaign = _assignedCampaigns[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildCampaignCard(campaign),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAvailableContent() {
    if (_isAvailableLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_availableErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ErrorBox(errors: [_availableErrorMessage!]),
            const SizedBox(height: 16),
            ShadButton.secondary(
              onPressed: _loadAvailableCampaigns,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Step-by-step guidance card for available campaigns
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Finding Opportunities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStepRow(1, 'Browse available campaigns',
                    'Find opportunities that match your profile'),
                _buildStepRow(2, 'Review requirements',
                    'Check if the campaign aligns with your content style'),
                _buildStepRow(3, 'Apply to campaigns',
                    'Express your interest by applying'),
                _buildStepRow(4, 'Wait for brand approval',
                    'Brands will review your profile and approve if suitable'),
                _buildStepRow(5, 'Check "Your Campaigns" tab',
                    'Once approved, campaigns will appear in your tab'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_availableCampaigns.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No campaigns available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new campaign opportunities',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _availableCampaigns.length,
              itemBuilder: (context, index) {
                final campaign = _availableCampaigns[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildCampaignCard(campaign),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCampaignActions(Campaign campaign) {
    // Add support for draft status - this shows the right actions when a brand has selected you but
    // the campaign is still in draft state
    if (campaign.status.toLowerCase() == 'draft' &&
        campaign.selectedInfluencer != null &&
        campaign.selectedInfluencer!.isNotEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'View draft campaign details',
            child: ShadButton.secondary(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  campaignDetails,
                  arguments: {
                    'campaignId': campaign.id,
                    'userType': 'influencer',
                  },
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 6),
                  Text('View Draft'),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (campaign.status.toLowerCase() == 'assigned') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'Decline this campaign opportunity',
            child: ShadButton.destructive(
              onPressed: () => _showConfirmDialog(
                'Decline Campaign',
                'Are you sure you want to decline this campaign? This action cannot be undone.',
                () => _updateCampaignStatus(campaign.id, 'declined'),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Decline'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Accept and begin working on this campaign',
            child: ShadButton(
              onPressed: () =>
                  _updateCampaignStatus(campaign.id, 'in_progress'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 16),
                  SizedBox(width: 6),
                  Text('Accept'),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (campaign.status.toLowerCase() == 'active' &&
        (campaign.selectedInfluencer == null ||
            campaign.selectedInfluencer!.isEmpty)) {
      // Actions for available campaigns in the second tab
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'Apply to work on this campaign',
            child: ShadButton(
              onPressed: () => _applyToCampaign(campaign.id),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 16),
                  SizedBox(width: 6),
                  Text('Apply'),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: 'View full campaign details',
          child: ShadButton.secondary(
            onPressed: () {
              Navigator.pushNamed(
                context,
                campaignDetails,
                arguments: {
                  'campaignId': campaign.id,
                  'userType':
                      'influencer', // Indicates this is an influencer viewing the campaign
                },
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility, size: 16),
                SizedBox(width: 6),
                Text('View Details'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    // Format currency
    final currencyFormat =
        NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);
    final formattedBudget = currencyFormat.format(campaign.budget);

    // Format date
    final dateFormat = DateFormat('MMM dd, yyyy');
    final formattedStartDate = dateFormat.format(campaign.startDate);
    final formattedEndDate = dateFormat.format(campaign.endDate);

    return ShadCard(
      child: Padding(
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(campaign.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              campaign.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Campaign progress indicator - only for assigned campaigns
            if (campaign.status.toLowerCase() == 'in_progress' ||
                campaign.status.toLowerCase() == 'assigned')
              _buildProgressIndicator(campaign.status),

            // Campaign details in a more visually organized grid
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 12.0,
                children: [
                  _buildInfoTile(Icons.category, 'Category',
                      campaign.category.toUpperCase()),
                  _buildInfoTile(Icons.attach_money, 'Budget', formattedBudget),
                  _buildInfoTile(Icons.date_range, 'Timeline',
                      '$formattedStartDate\nto $formattedEndDate'),
                  _buildInfoTile(Icons.flag, 'Goals',
                      campaign.goals.map((g) => g.toUpperCase()).join(', ')),
                ],
              ),
            ),

            const SizedBox(height: 8),
            _buildCampaignActions(campaign),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String status) {
    double progressValue = 0.0;
    String progressLabel = '';

    switch (status.toLowerCase()) {
      case 'assigned':
        progressValue = 0.2;
        progressLabel = 'Awaiting your acceptance';
        break;
      case 'in_progress':
        progressValue = 0.6;
        progressLabel = 'Content creation in progress';
        break;
      case 'completed':
        progressValue = 1.0;
        progressLabel = 'Campaign completed';
        break;
      default:
        progressValue = 0.0;
        progressLabel = 'Campaign status: ${status.toUpperCase()}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaign Progress',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              '${(progressValue * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey.shade200,
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 4),
        Text(
          progressLabel,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'draft':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        displayText = 'DRAFT';
        break;
      case 'active':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = 'ACTIVE';
        break;
      case 'assigned':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        displayText = 'ASSIGNED';
        break;
      case 'in_progress':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'IN PROGRESS';
        break;
      case 'completed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'COMPLETED';
        break;
      case 'cancelled':
      case 'declined':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = status.toUpperCase();
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        displayText = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStepRow(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAssignedCampaigns() async {
    setState(() {
      _isAssignedLoading = true;
      _assignedErrorMessage = null;
    });

    try {
      final campaigns = await CampaignRepository.getAssignedCampaigns();

      setState(() {
        _assignedCampaigns = campaigns;
        _isAssignedLoading = false;
      });
    } catch (e) {
      setState(() {
        _assignedErrorMessage = 'Failed to load assigned campaigns: $e';
        _isAssignedLoading = false;
      });
    }
  }

  Future<void> _loadAvailableCampaigns() async {
    setState(() {
      _isAvailableLoading = true;
      _availableErrorMessage = null;
    });

    try {
      final campaigns = await CampaignRepository.getAvailableCampaigns();

      setState(() {
        _availableCampaigns = campaigns;
        _isAvailableLoading = false;
      });
    } catch (e) {
      setState(() {
        _availableErrorMessage = 'Failed to load available campaigns: $e';
        _isAvailableLoading = false;
      });
    }
  }

  // Add a confirmation dialog for important actions
  Future<void> _showConfirmDialog(
      String title, String content, Function onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCampaignStatus(
      String campaignId, String newStatus) async {
    // Show loading indicator
    ShadToaster.of(context).show(
      ShadToast(
        title: Text(
            '${newStatus == 'in_progress' ? 'Accepting' : 'Declining'} campaign...'),
        description: const Text('Please wait'),
      ),
    );

    try {
      // Update the campaign status
      await CampaignRepository.updateCampaignStatus(campaignId, newStatus);

      // Refresh assigned campaigns list
      await _loadAssignedCampaigns();

      // Show success message
      ShadToaster.of(context).show(
        ShadToast(
          title: Text(
              'Campaign ${newStatus == 'in_progress' ? 'accepted' : 'declined'}'),
          description:
              Text('Campaign status updated to ${newStatus.toUpperCase()}'),
        ),
      );
    } catch (e) {
      // Show error message
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('Error'),
          description: Text('Failed to update campaign: $e'),
        ),
      );
    }
  }
}
