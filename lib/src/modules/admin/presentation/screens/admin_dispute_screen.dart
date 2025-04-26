import 'package:flutter/material.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';

// The Dispute class
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

// DisputeDetailsPage for viewing individual dispute details
class DisputeDetailsPage extends StatelessWidget {
  final Dispute dispute;

  const DisputeDetailsPage({super.key, required this.dispute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Dispute Details', context: context),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Name: ${dispute.campaignName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Brand Name: ${dispute.brandName}', style: const TextStyle(fontSize: 16)),
            Text('Influencer Name: ${dispute.influencerName}', style: const TextStyle(fontSize: 16)),
            Text('Reported By: ${dispute.reportedBy}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            const Text('Report Text:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(dispute.reportText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Logic for viewing campaign, or any other action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing Campaign ID: ${dispute.campaignId}')),
                  );
                },
                child: const Text('View Campaign'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// AdminDisputePanel to show the list of disputes
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
    Dispute(
      campaignName: 'Fashion Fiesta',
      brandName: 'GlamWorld',
      influencerName: 'StyleIcon',
      reportedBy: 'Admin3',
      reportText: 'Low engagement issue.',
      campaignId: 'CAMP003',
    ),
  ];

  List<Dispute> filteredDisputes = [];
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
      appBar: transparentAppBar('Dispute Management', context: context),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDisputes.length,
                itemBuilder: (context, index) {
                  final dispute = filteredDisputes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Campaign Name', dispute.campaignName),
                          _buildDetailRow('Brand Name', dispute.brandName),
                          _buildDetailRow('Influencer Name', dispute.influencerName),
                          _buildDetailRow('Reported By', dispute.reportedBy),
                          const SizedBox(height: 10),
                          const Text(
                            'Report Text:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dispute.reportText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to DisputeDetailsPage when a card is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DisputeDetailsPage(dispute: dispute),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('View Campaign'),
                            ),
                          ),
                        ],
                      ),
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
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search...',
              hintText: 'Campaign, Influencer, Reporter',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              searchQuery = value;
              _filterDisputes();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedBrandFilter,
            decoration: InputDecoration(
              labelText: 'Filter Brand',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem(value: 'All', child: Text('All Brands')),
              ...allDisputes.map((d) => d.brandName).toSet().map(
                    (brand) => DropdownMenuItem(
                      value: brand,
                      child: Text(brand),
                    ),
                  ),
            ],
            onChanged: (value) {
              selectedBrandFilter = value!;
              _filterDisputes();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
