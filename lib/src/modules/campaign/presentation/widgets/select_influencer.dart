import 'package:connectobia/src/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/engagement.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/follower_count.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
  final TextEditingController searchController = TextEditingController();
  String industry = '';
  String selectedFollowerCount = '';
  String selectedEngagement = '';
  String searchQuery = '';

  void _toggleInfluencerSelection(String influencer) {
    setState(() {
      // If the selected influencer is already selected, deselect it
      if (_selectedInfluencers.contains(influencer)) {
        _selectedInfluencers.clear();
      } else {
        // Deselect any previously selected influencer and select the new one
        _selectedInfluencers.clear();
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

        // Search Bar
        ShadInputFormField(
          controller: searchController,
          placeholder: const Text('Search influencers...'),
          prefix: const Icon(Icons.search),
          onChanged: (query) {
            setState(() {
              searchQuery = query;
            });
          },
        ),
        const SizedBox(height: 10),

        // Filters (Category, Follower Count, Engagement Rate)
        Row(
          children: [
            Expanded(
              child: CustomShadSelect(
              items: IndustryList.industries,
              placeholder: 'Industry',
              onSelected: (selectedIndustry) {
                industry = selectedIndustry;
              },
              focusNode: industryFocusNode,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: FollowerCountSelect(
                onSelected: (value) {
                  setState(() {
                    selectedFollowerCount = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: EngagementSelect(
                onSelected: (value) {
                  setState(() {
                    selectedEngagement = value;
                  });
                },
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
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
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
                  children: _availableInfluencers
                      .where((influencer) => influencer.toLowerCase().contains(searchQuery.toLowerCase()))
                      .map((influencer) {
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
          height: 90,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedInfluencers.isEmpty
              ? const Center(
                  child: Text(
                    'No influencer selected',
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