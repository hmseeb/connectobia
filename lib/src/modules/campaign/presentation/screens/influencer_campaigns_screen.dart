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

    if (_assignedCampaigns.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      itemCount: _assignedCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _assignedCampaigns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCampaignCard(campaign),
        );
      },
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

    if (_availableCampaigns.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      itemCount: _availableCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _availableCampaigns[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCampaignCard(campaign),
        );
      },
    );
  }

  Widget _buildCampaignActions(Campaign campaign) {
    if (campaign.status.toLowerCase() == 'assigned') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ShadButton.destructive(
            onPressed: () => _updateCampaignStatus(campaign.id, 'declined'),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 8),
          ShadButton(
            onPressed: () => _updateCampaignStatus(campaign.id, 'in_progress'),
            child: const Text('Accept'),
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
          ShadButton(
            onPressed: () => _applyToCampaign(campaign.id),
            child: const Text('Apply'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ShadButton.secondary(
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
          child: const Text('View Details'),
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
            _buildInfoRow(
                Icons.category, 'Category', campaign.category.toUpperCase()),
            _buildInfoRow(Icons.attach_money, 'Budget', formattedBudget),
            _buildInfoRow(Icons.date_range, 'Timeline',
                '$formattedStartDate to $formattedEndDate'),
            _buildInfoRow(Icons.flag, 'Goals',
                campaign.goals.map((g) => g.toUpperCase()).join(', ')),
            const SizedBox(height: 16),
            _buildCampaignActions(campaign),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
