// Reusable widget for profile details header
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileHeader extends StatelessWidget {
  final String? name;
  final String? industry;
  final String? username;
  final bool isVerified;
  final bool hasConnectedInstagram;

  const ProfileHeader({
    super.key,
    this.name,
    this.industry,
    this.username,
    required this.isVerified,
    required this.hasConnectedInstagram,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = name?.isNotEmpty == true ? name! : "New User";
    final String displayIndustry =
        industry?.isNotEmpty == true ? industry! : "No industry selected";
    final String displayUsername =
        username?.isNotEmpty == true ? username! : "username";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              displayIndustry,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        // Verified badge
        if (hasConnectedInstagram)
          const Icon(
            Icons.verified,
            color: Colors.blue,
          ),
        const Spacer(),
        // Location icon or social link
        if (hasConnectedInstagram)
          GestureDetector(
            onTap: () async {
              final url = 'https://instagram.com/$displayUsername';
              await launchUrl(Uri.parse(url));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xffd62976),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                LucideIcons.instagram,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}

// Reusable widget for profile analytics
