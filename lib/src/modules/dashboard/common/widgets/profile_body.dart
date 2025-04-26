// Profile body (about section, description, and analytics)
import 'package:connectobia/src/modules/dashboard/common/widgets/profile_analytics.dart';
import 'package:connectobia/src/shared/data/extensions/string_extention.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ProfileBody extends StatelessWidget {
  final String description;
  final int? followers;
  final int? mediaCount;
  final bool hasConnectedInstagram;

  const ProfileBody({
    super.key,
    required this.description,
    this.followers,
    this.mediaCount,
    required this.hasConnectedInstagram,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Section Card
            if (description.isNotEmpty) ...[
              _buildSectionCard(
                context,
                title: 'About',
                content: ReadMoreText(
                  description.removeAllHtmlTags(),
                  trimMode: TrimMode.Line,
                  trimLines: 2,
                  trimCollapsedText: 'Read more',
                  trimExpandedText: ' Show less',
                  moreStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadColors.primary,
                  ),
                  lessStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ShadColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Analytics Card
            if (hasConnectedInstagram) ...[
              _buildSectionCard(
                context,
                title: 'Analytics',
                content: Row(
                  children: [
                    Expanded(
                      child: ProfileAnalyticsCard(
                        title: 'FOLLOWERS',
                        value: followers.toString(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ProfileAnalyticsCard(
                        title: 'MEDIA COUNT',
                        value: mediaCount.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget content}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }
}
