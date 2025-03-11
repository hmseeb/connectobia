import 'package:connectobia/src/modules/campaignView/presentation/widgests/infocard.dart';
import 'package:flutter/material.dart';

class CampaignInfoWidget extends StatefulWidget {
  const CampaignInfoWidget({super.key});

  @override
  State<CampaignInfoWidget> createState() => _CampaignInfoWidgetState();
}

class _CampaignInfoWidgetState extends State<CampaignInfoWidget> {
  final String _campaignDescription =
      "This campaign aims to promote eco-friendly products that help reduce carbon footprints. "
      "We are looking for influencers who can create engaging content showcasing sustainability.";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Campaign Name'),
        const InfoCard(text: 'Innovate Your World'),
        const SizedBox(height: 16),
        
        _buildSectionTitle('Campaign Goals'),
        const InfoCard(text: 'Brand Awareness'),
        const SizedBox(height: 16),

        _buildSectionTitle('Brand Name'),
        const InfoCard(
          text: 'Brand ABC',
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.business, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('Campaign Description'),
        InfoCard(text: _campaignDescription),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
    );
  }
}