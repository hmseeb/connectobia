
import 'package:connectobia/src/modules/campaign/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/profile_avatar.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                const Expanded(
                  child: Text(
                    'Clean Pakistan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const StatusBadge(text: 'In Progress', color: Colors.blue),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.of(context).pushNamed(createCampaign);
                    } else if (value == 'delete') {
                      showDeleteConfirmationDialog(context, () {
                        // Handle campaign deletion logic here
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ Campaign Description
            const Text(
              'Design a clean and professional landing page for a finance app.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 12),

            // ✅ Price Section
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
                const ProfileAvatar(imageUrl: 'https://via.placeholder.com/40'),
                const SizedBox(width: 10),
                const Expanded(
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
}
