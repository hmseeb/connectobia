// Reusable widget for profile details header
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String industry;
  final String username;
  final bool isVerified;
  final bool connectedSocial;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.industry,
    required this.username,
    required this.isVerified,
    required this.connectedSocial,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              industry,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        // Verified badge
        const SizedBox(width: 8),
        if (isVerified)
          const Icon(
            Icons.verified,
            color: Colors.green,
          ),
        const Spacer(),
        // Location icon or social link
        if (connectedSocial)
          GestureDetector(
            onTap: () {
              final url = 'https://instagram.com/$username';
              launchUrl(Uri.parse(url));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xffd62976),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(
                    LucideIcons.instagram,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Instagram',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Reusable widget for profile analytics
