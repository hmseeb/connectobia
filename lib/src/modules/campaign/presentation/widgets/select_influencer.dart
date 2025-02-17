import 'package:connectobia/src/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/engagement.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/follower_count.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:flutter/material.dart';

class SelectInfluencerStep extends StatefulWidget {
  final Function(List<String>) onSelectedInfluencersChanged;

  const SelectInfluencerStep({super.key, required this.onSelectedInfluencersChanged});

  @override
  State<SelectInfluencerStep> createState() => _SelectInfluencerStepState();
}

class _SelectInfluencerStepState extends State<SelectInfluencerStep> {
  final List<String> _selectedInfluencers = [];
  final List<String> _availableInfluencers = List.generate(5, (index) => 'Influencer ${index + 1}');
  final FocusNode industryFocusNode = FocusNode();
  String industry = '';
  String selectedFollowerCount = ''; // Track selected follower count
  String selectedEngagement = ''; // Track selected engagement

  void _toggleInfluencerSelection(String influencer) {
    setState(() {
      if (_selectedInfluencers.contains(influencer)) {
        _selectedInfluencers.remove(influencer);
      } else {
        _selectedInfluencers.add(influencer);
      }
      widget.onSelectedInfluencersChanged(_selectedInfluencers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Influencer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Category Selection
        CustomShadSelect(
          items: IndustryList.industries,
          placeholder: 'Select industry...',
          onSelected: (selectedIndustry) {
            industry = selectedIndustry;
          },
          focusNode: industryFocusNode,
        ),
        const SizedBox(height: 10),

        // Row for Follower Count & Engagement
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Follower Count'),
                  FollowerCountSelect(
                    onSelected: (value) {
                      setState(() {
                        selectedFollowerCount = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Engagement'),
                  EngagementSelect(
                    onSelected: (value) {
                      setState(() {
                        selectedEngagement = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Available Influencers Box
        const Text(
          'Available Influencers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent), // Transparent border
            borderRadius: BorderRadius.circular(8),
          ),
          child: _availableInfluencers.isEmpty
              ? const Center(
                  child: Text(
                    'No influencers available',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView(
                  children: _availableInfluencers.map((influencer) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(influencer),
                      subtitle: const Text('@username | Fashion & Beauty | 100k+ followers'),
                      trailing: IconButton(
                        icon: Icon(
                          _selectedInfluencers.contains(influencer) ? Icons.check_circle : Icons.add_circle,
                          color: _selectedInfluencers.contains(influencer) ? Colors.blue : Colors.grey,
                        ),
                        onPressed: () => _toggleInfluencerSelection(influencer),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 20),

        // Selected Influencers Box
        const Text(
          'Selected Influencers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent), // Transparent border
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedInfluencers.isEmpty
              ? const Center(
                  child: Text(
                    'No influencers selected',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView(
                  children: _selectedInfluencers.map((influencer) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(influencer),
                      subtitle: const Text('@username | Fashion & Beauty | 100k+ followers'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _toggleInfluencerSelection(influencer),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}