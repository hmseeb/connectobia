import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(context),
            const SizedBox(height: 16),
            _buildCampaignCard(context), // Pass context to navigate
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createCampaign);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔍 Search Bar Widget
  Widget _buildSearchField(BuildContext context) {
    return ShadInputFormField(
      placeholder: const Text('Search Campaigns'),
      prefix: const Icon(Icons.search),
      onChanged: (value) {},
    );
  }

  /// 📌 Campaign Card Widget (Clickable)
  Widget _buildCampaignCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the campaign detail page
        Navigator.of(context).pushNamed(campaignDetails);
      },
      child: ShadCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header (Campaign Title, Status & Menu)
            Row(
              children: [
                Expanded(
                  child: const Text(
                    'Clean Pakistan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                _statusBadge('In Progress', Colors.blue),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            
            // ✅ Campaign Description (Truncated)
            const Text(
              'Design a clean and professional landing page for a finance appkekfsdkfsdkc',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Text(
                  'Price: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '2000 Rs',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ Profile Avatar + Brand Name + Arrow Icon
            Row(
              children: [
                _profileAvatar('https://via.placeholder.com/40'),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'LifeBuoy',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Status Badge Widget
  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 🟢 Profile Avatar Widget
  Widget _profileAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 14,
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}
