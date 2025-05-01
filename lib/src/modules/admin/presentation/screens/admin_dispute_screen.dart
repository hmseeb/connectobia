import 'package:flutter/material.dart';

class Dispute {
  final String campaignName;
  final String brandName;
  final String influencerName;
  final String reportedBy;
  final String reportText;
  final String campaignId;

  Dispute({
    required this.campaignName,
    required this.brandName,
    required this.influencerName,
    required this.reportedBy,
    required this.reportText,
    required this.campaignId,
  });
}

class DisputeDetailsPage extends StatelessWidget {
  final Dispute dispute;

  const DisputeDetailsPage({super.key, required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Campaign Information'),
            _buildDetailItem('📢 Campaign Name', dispute.campaignName),
            _buildDetailItem('🏢 Brand', dispute.brandName),
            _buildDetailItem('👤 Influencer', dispute.influencerName),
            _buildDetailItem('🧾 Reported By', dispute.reportedBy),
            const Divider(height: 40),
            _buildSectionHeader('Report Details'),
            Text(dispute.reportText,
                style: const TextStyle(fontSize: 16, height: 1.5)),
            const Spacer(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.blue),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showActionDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Take Action'),
          ),
        ),
      ],
    );
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: const Text('Are you sure you want to take this action?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action completed successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class AdminDisputePanel extends StatefulWidget {
  const AdminDisputePanel({super.key});

  @override
  State<AdminDisputePanel> createState() => _AdminDisputePanelState();
}

class _AdminDisputePanelState extends State<AdminDisputePanel> {
  final List<Dispute> allDisputes = [
    Dispute(
      campaignName: 'Summer Blast',
      brandName: 'SunCo',
      influencerName: 'InstaQueen',
      reportedBy: 'Admin1',
      reportText: 'Influencer didn’t post on time.',
      campaignId: 'CAMP001',
    ),
    Dispute(
      campaignName: 'Tech Wave',
      brandName: 'GadgetGuru',
      influencerName: 'TechStar',
      reportedBy: 'Admin2',
      reportText: 'Wrong product tagging.',
      campaignId: 'CAMP002',
    ),
  ];

  late List<Dispute> filteredDisputes;
  String searchQuery = '';
  String selectedBrandFilter = 'All';

  @override
  void initState() {
    super.initState();
    filteredDisputes = List.from(allDisputes);
  }

  void _filterDisputes() {
    setState(() {
      filteredDisputes = allDisputes.where((dispute) {
        final matchesSearch = dispute.campaignName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            dispute.influencerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            dispute.reportedBy.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesBrand = selectedBrandFilter == 'All' || dispute.brandName == selectedBrandFilter;
        return matchesSearch && matchesBrand;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispute Management'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: filteredDisputes.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final dispute = filteredDisputes[index];
                  return ListTile(
                    title: Text(
                      dispute.campaignName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Brand: ${dispute.brandName}'),
                        Text('Influencer: ${dispute.influencerName}'),
                        Text('Reported by: ${dispute.reportedBy}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisputeDetailsPage(dispute: dispute),
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search disputes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              searchQuery = value;
              _filterDisputes();
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedBrandFilter,
          items: [
            const DropdownMenuItem(
              value: 'All',
              child: Text('All Brands'),
            ),
            ...allDisputes
                .map((d) => d.brandName)
                .toSet()
                .map((brand) => DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    )),
          ],
          onChanged: (value) {
            setState(() {
              selectedBrandFilter = value!;
              _filterDisputes();
            });
          },
        ),
      ],
    );
  }
}