import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
            padding: const EdgeInsets.all(16.0),
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
          const Text(
            'Content Format',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ShadCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          const Text(
            'Content Guidelines',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ShadCard(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            padding: const EdgeInsets.all(16.0),
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
