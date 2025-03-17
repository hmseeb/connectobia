import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/domain/models/contract.dart';

// Define a consistent currency format to use throughout the app
final currencyFormat = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

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
        color: color.withAlpha(25),
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
    if (types.isEmpty) {
      return 'N/A';
    }

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
  final List<String>? initialPostTypes;
  final DateTime? initialDeliveryDate;
  final String? initialGuidelines;
  final bool? initialConfirmDetails;
  final bool? initialAcceptTerms;

  const ContractDetailsStep({
    super.key,
    this.campaignFormState,
    required this.onContractDetailsChanged,
    this.initialPostTypes,
    this.initialDeliveryDate,
    this.initialGuidelines,
    this.initialConfirmDetails,
    this.initialAcceptTerms,
  });

  @override
  ContractDetailsStepState createState() => ContractDetailsStepState();
}

class ContractDetailsStepState extends State<ContractDetailsStep>
    with SingleTickerProviderStateMixin {
  // Default selections
  final Map<String, bool> _selectedPostTypes = {
    'post': false,
    'story': false,
    'reel': false,
    'carousel': false,
  };
  late DateTime _deliveryDate;
  final TextEditingController _guidelinesController = TextEditingController();
  final TextEditingController _paymentDetailsController =
      TextEditingController();
  bool _confirmDetails = false;
  bool _acceptTerms = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Helper to get list of selected post types
  List<String> get selectedPostTypesList => _selectedPostTypes.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final formattedBudget =
            currencyFormat.format(widget.campaignFormState?.budget ?? 0);
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Name',
                          widget.campaignFormState?.title ?? "Campaign"),
                      _buildSummaryRow('Category',
                          widget.campaignFormState?.category ?? "Category"),
                      _buildSummaryRow(
                          'Budget',
                          currencyFormat
                              .format(widget.campaignFormState?.budget ?? 0)),
                      _buildSummaryRow('Timeline',
                          '${DateFormat('MMM dd, yyyy').format(widget.campaignFormState?.startDate ?? DateTime.now())} - ${DateFormat('MMM dd, yyyy').format(widget.campaignFormState?.endDate ?? DateTime.now().add(const Duration(days: 30)))}'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Post Type Section
                ShadCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Content Types",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Select the types of content you need from the influencer:",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        children: _selectedPostTypes.entries.map((entry) {
                          return ShadCheckbox(
                            value: entry.value,
                            onChanged: (bool value) {
                              setState(() {
                                _selectedPostTypes[entry.key] = value;
                                _notifyChanges();
                              });
                            },
                            label: Text(
                                '${entry.key[0].toUpperCase()}${entry.key.substring(1)}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Delivery Date Section
                ShadCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Delivery Date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Select the date when content should be delivered:",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _selectDeliveryDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(_deliveryDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today, size: 20),
                            ],
                          ),
                        ),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ContractDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle updates from the form state if needed
    if (widget.campaignFormState != oldWidget.campaignFormState &&
        widget.campaignFormState != null) {
      // Update post types from form state
      for (final postType in widget.campaignFormState!.selectedPostTypes) {
        if (_selectedPostTypes.containsKey(postType)) {
          _selectedPostTypes[postType] = true;
        }
      }

      // Update guidelines
      if (_guidelinesController.text !=
          widget.campaignFormState!.contentGuidelines) {
        _guidelinesController.text =
            widget.campaignFormState!.contentGuidelines;
      }

      // Update checkboxes
      _confirmDetails = widget.campaignFormState!.confirmDetails;
      _acceptTerms = widget.campaignFormState!.acceptTerms;

      // Update delivery date
      if (widget.campaignFormState!.deliveryDate != null) {
        _deliveryDate = widget.campaignFormState!.deliveryDate!;
      } else {
        _deliveryDate = widget.campaignFormState!.endDate;
      }
    }
  }

  @override
  void dispose() {
    _guidelinesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize with values if provided
    if (widget.initialPostTypes != null &&
        widget.initialPostTypes!.isNotEmpty) {
      for (var postType in widget.initialPostTypes!) {
        if (_selectedPostTypes.containsKey(postType)) {
          _selectedPostTypes[postType] = true;
        }
      }
    }

    _deliveryDate = widget.initialDeliveryDate ??
        DateTime.now().add(const Duration(days: 14));

    if (widget.initialGuidelines != null) {
      _guidelinesController.text = widget.initialGuidelines!;
    }

    _confirmDetails = widget.initialConfirmDetails ?? false;
    _acceptTerms = widget.initialAcceptTerms ?? false;

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Update parent with initial values if any were provided
    if (widget.initialPostTypes != null ||
        widget.initialDeliveryDate != null ||
        widget.initialGuidelines != null ||
        widget.initialConfirmDetails != null ||
        widget.initialAcceptTerms != null) {
      _updateContractDetails();
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _notifyChanges() {
    widget.onContractDetailsChanged(
      selectedPostTypesList,
      _deliveryDate,
      _guidelinesController.text,
      _confirmDetails,
      _acceptTerms,
    );
  }

  void _selectDeliveryDate(BuildContext context) async {
    final currentContext = context;
    final DateTime? picked = await showDatePicker(
      context: currentContext,
      initialDate: _deliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _deliveryDate) {
      if (!mounted) return;
      setState(() {
        _deliveryDate = picked;
        _notifyChanges();
      });
    }
  }

  void _updateContractDetails() {
    widget.onContractDetailsChanged(
      selectedPostTypesList,
      _deliveryDate,
      _guidelinesController.text,
      _confirmDetails,
      _acceptTerms,
    );
  }
}
