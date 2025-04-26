import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/domain/models/contract.dart';

class ContractDetailsCard extends StatelessWidget {
  final Contract contract;
  final bool allowActions;
  final VoidCallback? onSign;
  final VoidCallback? onReject;

  const ContractDetailsCard({
    super.key,
    required this.contract,
    this.allowActions = false,
    this.onSign,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return ShadCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contract header
          Row(
            children: [
              const Icon(Icons.description, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Contract Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(contract.status),
            ],
          ),
          const Divider(height: 24),

          // Contract content
          _buildInfoRow('Payment', currencyFormat.format(contract.payout)),
          const SizedBox(height: 16),

          _buildInfoRow(
              'Delivery Date', dateFormat.format(contract.deliveryDate)),
          const SizedBox(height: 16),

          _buildInfoRow('Content Type', _formatPostTypes(contract.postType)),
          const SizedBox(height: 16),

          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              contract.terms,
              style: const TextStyle(height: 1.5),
            ),
          ),

          // Signature status
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSignatureStatus('Brand', contract.isSignedByBrand,
                  contract.brandRecord?.data?['brandName'] ?? 'Brand'),
              const SizedBox(width: 20),
              _buildSignatureStatus('Influencer', contract.isSignedByInfluencer,
                  contract.influencerRecord?.data?['fullName'] ?? 'Influencer'),
            ],
          ),

          // Action buttons
          if (allowActions && contract.status == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShadButton.destructive(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  ShadButton(
                    onPressed: onSign,
                    child: const Text('Sign Contract'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }

  Widget _buildSignatureStatus(String role, bool isSigned, String name) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSigned ? Colors.green : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isSigned ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isSigned ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'signed':
        color = Colors.green;
        label = 'Signed';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'completed':
        color = Colors.purple;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatPostTypes(List<String> types) {
    if (types.isEmpty) return 'N/A';

    return types.map((type) {
      // Capitalize first letter of each type
      return '${type[0].toUpperCase()}${type.substring(1)}';
    }).join(', ');
  }
}

class ContractDetailsStep extends StatefulWidget {
  final CampaignFormState? campaignFormState;
  final Function(List<String>, DateTime?, String, bool, bool)
      onContractDetailsChanged;

  const ContractDetailsStep({
    super.key,
    this.campaignFormState,
    required this.onContractDetailsChanged,
  });

  @override
  ContractDetailsStepState createState() => ContractDetailsStepState();
}

class ContractDetailsStepState extends State<ContractDetailsStep> {
  final List<String> _postTypes = ['Reel', 'Carousel', 'Post', 'Story'];
  List<String> _selectedPostTypes = [];
  bool _confirmDetails = false;
  bool _acceptTerms = false;
  late TextEditingController _guidelinesController;

  @override
  Widget build(BuildContext context) {
    // Get campaign info from campaign form state
    final campaignName = widget.campaignFormState?.title ?? "Campaign";
    final campaignCategory = widget.campaignFormState?.category ?? "Category";
    final campaignBudget =
        "\$${widget.campaignFormState?.budget.toString() ?? "0"}";
    final startDate = DateFormat('MMM dd, yyyy').format(
      widget.campaignFormState?.startDate ?? DateTime.now(),
    );
    final endDate = DateFormat('MMM dd, yyyy').format(
      widget.campaignFormState?.endDate ??
          DateTime.now().add(const Duration(days: 30)),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Contract Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Campaign Summary
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaign Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Name', campaignName),
                _buildSummaryRow('Category', campaignCategory),
                _buildSummaryRow('Budget', campaignBudget),
                _buildSummaryRow('Timeline', '$startDate - $endDate'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Post Type Section
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Content Format',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select the type of content you want:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: _postTypes.map((type) {
                    return ShadCheckbox(
                      value: _selectedPostTypes.contains(type),
                      onChanged: (bool value) {
                        setState(() {
                          if (value) {
                            _selectedPostTypes.add(type);
                          } else {
                            _selectedPostTypes.remove(type);
                          }
                          _notifyChanges();
                        });
                      },
                      label: Text(type),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Content Guidelines Section
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Content Guidelines',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Provide any specific requirements or instructions:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ShadInputFormField(
                  controller: _guidelinesController,
                  placeholder: const Text(
                      'Examples: specific colors, messaging, hashtags, etc.'),
                  maxLines: 5,
                  onChanged: (value) {
                    _notifyChanges();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Terms and Agreement
          ShadCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agreement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please review the contract details carefully before sending. Make sure all information is correct and that you are comfortable with the terms and conditions.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ShadCheckbox(
                  value: _confirmDetails,
                  onChanged: (value) {
                    setState(() {
                      _confirmDetails = value;
                      _notifyChanges();
                    });
                  },
                  label: const Text('I confirm all details are correct'),
                ),
                const SizedBox(height: 8),
                ShadCheckbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value;
                      _notifyChanges();
                    });
                  },
                  label: const Text('I accept all terms and conditions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(ContractDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update if the form state changes
    if (widget.campaignFormState != oldWidget.campaignFormState &&
        widget.campaignFormState != null) {
      _selectedPostTypes =
          List.from(widget.campaignFormState!.selectedPostTypes);

      if (_guidelinesController.text !=
          widget.campaignFormState!.contentGuidelines) {
        _guidelinesController.text =
            widget.campaignFormState!.contentGuidelines;
      }

      _confirmDetails = widget.campaignFormState!.confirmDetails;
      _acceptTerms = widget.campaignFormState!.acceptTerms;
    }
  }

  @override
  void dispose() {
    _guidelinesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _guidelinesController = TextEditingController();

    // Initialize from form state if available
    if (widget.campaignFormState != null) {
      _selectedPostTypes =
          List.from(widget.campaignFormState!.selectedPostTypes);
      _guidelinesController.text = widget.campaignFormState!.contentGuidelines;
      _confirmDetails = widget.campaignFormState!.confirmDetails;
      _acceptTerms = widget.campaignFormState!.acceptTerms;
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _notifyChanges() {
    // Get the campaign end date to use as delivery date
    final DateTime campaignEndDate = widget.campaignFormState?.endDate ??
        DateTime.now().add(const Duration(days: 30));

    widget.onContractDetailsChanged(
      _selectedPostTypes,
      campaignEndDate, // Use campaign end date instead of selectedDate
      _guidelinesController.text,
      _confirmDetails,
      _acceptTerms,
    );
  }
}
