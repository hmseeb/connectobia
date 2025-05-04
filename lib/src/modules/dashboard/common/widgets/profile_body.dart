// Profile body (about section, description, and analytics)
import 'package:connectobia/src/modules/dashboard/common/widgets/profile_analytics.dart';
import 'package:connectobia/src/shared/data/extensions/string_extention.dart';
import 'package:connectobia/src/shared/domain/models/influencer_profile.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ProfileBody extends StatelessWidget {
  final String description;
  final int? followers;
  final int? mediaCount;
  final bool hasConnectedInstagram;
  final InfluencerProfile? profile;

  const ProfileBody({
    super.key,
    required this.description,
    this.followers,
    this.mediaCount,
    required this.hasConnectedInstagram,
    this.profile,
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
                helpText: 'Personal information and bio',
                icon: Icons.person_rounded,
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

            // Basic Analytics Card
            if (hasConnectedInstagram) ...[
              _buildSectionCard(
                context,
                title: 'Basic Analytics',
                helpText: 'Key metrics from your Instagram account',
                icon: Icons.auto_graph_rounded,
                content: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ProfileAnalyticsCard(
                            title: 'FOLLOWERS',
                            value: followers.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileAnalyticsCard(
                            title: 'MEDIA COUNT',
                            value: mediaCount.toString(),
                          ),
                        ),
                      ],
                    ),

                    // Demographic data
                    if (profile != null &&
                        (profile!.country.isNotEmpty ||
                            profile!.gender.isNotEmpty)) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Demographics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (profile!.country.isNotEmpty)
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'COUNTRY',
                                value: profile!.country,
                              ),
                            ),
                        ],
                      ),
                      if (profile!.gender.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'GENDER',
                                value: profile!.gender,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Engagement Analytics
              if (profile != null) ...[
                const SizedBox(height: 16),
                _buildSectionCard(
                  context,
                  title: 'Engagement Analytics',
                  helpText: 'How your audience interacts with your content',
                  icon: Icons.thumb_up_alt_rounded,
                  content: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ProfileAnalyticsCard(
                              title: 'AVG INTERACTIONS',
                              value: profile!.avgInteractions.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileAnalyticsCard(
                              title: 'AVG LIKES',
                              value: profile!.avgLikes.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileAnalyticsCard(
                              title: 'AVG COMMENTS',
                              value: profile!.avgComments.toString(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileAnalyticsCard(
                              title: 'ENG RATE',
                              value: profile!.engRate.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Video Analytics
                if (profile!.avgVideoViews > 0 ||
                    profile!.avgVideoLikes > 0 ||
                    profile!.avgVideoComments > 0) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context,
                    title: 'Video Analytics',
                    helpText: 'Performance metrics for your video content',
                    icon: Icons.videocam_rounded,
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'AVG VIDEO VIEWS',
                                value: profile!.avgVideoViews.toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'AVG VIDEO LIKES',
                                value: profile!.avgVideoLikes.toString(),
                              ),
                            ),
                          ],
                        ),
                        if (profile!.avgVideoComments > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileAnalyticsCard(
                                  title: 'AVG VIDEO COMMENTS',
                                  value: profile!.avgVideoComments.toString(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required String helpText,
      required IconData icon,
      required Widget content}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.grey.shade800,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              helpText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }
}
