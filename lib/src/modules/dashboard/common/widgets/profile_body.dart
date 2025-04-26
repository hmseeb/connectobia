// Profile body (about section, description, and analytics)
import 'dart:async';

import 'package:connectobia/src/modules/dashboard/common/widgets/profile_analytics.dart';
import 'package:connectobia/src/shared/domain/models/influencer_profile.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileBody extends StatefulWidget {
  final String description;
  final int? followers;
  final int? mediaCount;
  final bool hasConnectedInstagram;
  final InfluencerProfile? profile;
  final bool isInfluencer;
  final bool isLoading;

  const ProfileBody({
    super.key,
    required this.description,
    this.followers,
    this.mediaCount,
    required this.hasConnectedInstagram,
    this.profile,
    this.isInfluencer = false,
    this.isLoading = false,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool _showLoadingIndicator = true;
  Timer? _loadingTimer;

  @override
  Widget build(BuildContext context) {
    // Safe handling of description text with null and empty checks
    final String displayDescription = widget.description.isNotEmpty == true
        ? widget.description
        : widget.isInfluencer
            ? "This user hasn't added a bio yet. Bio information helps brands learn more about you."
            : "This brand hasn't added a description yet.";

    // Safely access numeric values with null checks and defaults
    final int displayFollowers = widget.followers ?? 0;
    final int displayMediaCount = widget.mediaCount ?? 0;
    final bool haveValidProfile = widget.profile != null;

    // Additional safety checks for profile data
    final String displayCountry =
        haveValidProfile && widget.profile!.country.isNotEmpty
            ? widget.profile!.country
            : '';
    final String displayGender =
        haveValidProfile && widget.profile!.gender.isNotEmpty
            ? widget.profile!.gender
            : '';
    final int displayEngRate = haveValidProfile ? widget.profile!.engRate : 0;
    final int displayAvgInteractions =
        haveValidProfile ? widget.profile!.avgInteractions : 0;
    final int displayAvgLikes = haveValidProfile ? widget.profile!.avgLikes : 0;
    final int displayAvgComments =
        haveValidProfile ? widget.profile!.avgComments : 0;
    final int displayAvgVideoLikes =
        haveValidProfile ? widget.profile!.avgVideoLikes : 0;
    final int displayAvgVideoComments =
        haveValidProfile ? widget.profile!.avgVideoComments : 0;
    final int displayAvgVideoViews =
        haveValidProfile ? widget.profile!.avgVideoViews : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Section Card - Show always, regardless of whether description is empty or not
            _buildSectionCard(
              context,
              title: 'About',
              helpText: 'Personal information and bio',
              icon: Icons.person_rounded,
              content: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: widget.isLoading && _showLoadingIndicator
                    ? Skeletonizer(
                        enabled: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    : ReadMoreText(
                        displayDescription,
                        trimLines: 3,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Read more',
                        trimExpandedText: 'Show less',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.description.isEmpty
                                  ? Colors.grey.shade500
                                  : null,
                              fontStyle: widget.description.isEmpty
                                  ? FontStyle.italic
                                  : null,
                            ),
                        moreStyle: TextStyle(
                          color: ShadColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        lessStyle: TextStyle(
                          color: ShadColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Show Instagram connection message ONLY for influencers who are not connected
            if (widget.isInfluencer && !widget.hasConnectedInstagram) ...[
              _buildSectionCard(
                context,
                title: 'Instagram Connection',
                helpText:
                    'Connect your Instagram account to show your analytics',
                icon: Icons.info_outline_rounded,
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Instagram account connected',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Connect your Instagram account to display your social media analytics and improve your profile visibility.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Basic Analytics Card - only for influencers with connected Instagram
            if (widget.isInfluencer && widget.hasConnectedInstagram) ...[
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
                            value: displayFollowers.toString(),
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
                            value: displayMediaCount.toString(),
                          ),
                        ),
                      ],
                    ),

                    // Demographic data - ensure we check for null values at each level
                    if (displayCountry.isNotEmpty ||
                        displayGender.isNotEmpty) ...[
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
                      if (displayCountry.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'COUNTRY',
                                value: displayCountry,
                              ),
                            ),
                          ],
                        ),
                      if (displayGender.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ProfileAnalyticsCard(
                                title: 'GENDER',
                                value: displayGender,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // Engagement Analytics - only show if we have valid profile data
              if (haveValidProfile) ...[
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
                              value: displayAvgInteractions.toString(),
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
                              value: displayAvgLikes.toString(),
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
                              value: displayAvgComments.toString(),
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
                              value: displayEngRate.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Video Analytics - only show if we have valid metrics
                if (displayAvgVideoViews > 0 ||
                    displayAvgVideoLikes > 0 ||
                    displayAvgVideoComments > 0) ...[
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
                                value: displayAvgVideoViews.toString(),
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
                                value: displayAvgVideoLikes.toString(),
                              ),
                            ),
                          ],
                        ),
                        if (displayAvgVideoComments > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileAnalyticsCard(
                                  title: 'AVG VIDEO COMMENTS',
                                  value: displayAvgVideoComments.toString(),
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

  @override
  void didUpdateWidget(ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset timer if loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      _loadingTimer?.cancel();
      if (widget.isLoading) {
        setState(() {
          _showLoadingIndicator = true;
        });
        _loadingTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showLoadingIndicator = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set a timer to hide loading indicator after 3 seconds
    if (widget.isLoading) {
      _loadingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showLoadingIndicator = false;
          });
        }
      });
    }
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
            content,
          ],
        ),
      ),
    );
  }
}
