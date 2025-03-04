import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignInfoWidget extends StatefulWidget {
  const CampaignInfoWidget({super.key});

  @override
  State<CampaignInfoWidget> createState() => _CampaignInfoWidgetState();
}

class _CampaignInfoWidgetState extends State<CampaignInfoWidget> {
  bool _isExpanded = false;
  final String _campaignDescription =
      "This campaign aims to promote eco-friendly products that help reduce carbon footprints. "
      "We are looking for influencers who can create engaging content showcasing sustainability.";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campaign Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        const SizedBox(height: 8),
        ShadCard(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Text('Innovate Your World', style: ShadTheme.of(context).textTheme.p),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Campaign Goals',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        const SizedBox(height: 8),
        ShadCard(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: Text('Brand Awareness', style: ShadTheme.of(context).textTheme.p),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Brand Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        const SizedBox(height: 8),
        ShadCard(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.business, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text('Brand ABC', style: ShadTheme.of(context).textTheme.p),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Campaign Description',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        const SizedBox(height: 8),
        ShadCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isExpanded
                    ? _campaignDescription
                    : '${_campaignDescription.substring(0, 100)}...',
                style: ShadTheme.of(context).textTheme.p,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? 'See Less' : 'See More',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
