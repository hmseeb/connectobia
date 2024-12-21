// Profile body (about section, description, and analytics)
import 'package:connectobia/src/modules/dashboard/common/widgets/profile_analytics.dart';
import 'package:connectobia/src/shared/data/extensions/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ProfileBody extends StatelessWidget {
  final String description;
  final int? followers;
  final int? mediaCount;

  const ProfileBody({
    super.key,
    required this.description,
    this.followers,
    this.mediaCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'About',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              ReadMoreText(
                description.removeAllHtmlTags(),
                trimMode: TrimMode.Line,
                trimLines: 2,
                trimCollapsedText: 'Read more',
                trimExpandedText: ' Show less',
                moreStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                lessStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Analytics section
            Text(
              'Analytics',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ProfileAnalyticsCard(
                  title: 'FOLLOWERS',
                  value: followers.toString(),
                ),
                const SizedBox(width: 16),
                ProfileAnalyticsCard(
                  title: 'MEDIA COUNT',
                  value: mediaCount.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
