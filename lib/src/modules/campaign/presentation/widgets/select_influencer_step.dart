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
        const Text('Select Influencer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ShadInputFormField(
          label: const Text('Category *'),
          placeholder: const Text('Fashion, Beauty, Tech'),
        ),
        const SizedBox(height: 10),
        ShadInputFormField(
          label: const Text('Follower Count & Engagement'),
          placeholder: const Text('10k-50k, 50k-100k, High, Medium, Low'),
        ),
        const SizedBox(height: 20),
        const Text('Available Influencers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: List.generate(5, (index) {
              String influencer = 'Influencer ${index + 1}';
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
            }),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Selected Influencers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Column(
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
      ],
    );
  }
}
