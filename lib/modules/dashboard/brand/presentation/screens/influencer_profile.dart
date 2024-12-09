import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/constants/path.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/dashboard/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/views/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class InfluencerProfile extends StatefulWidget {
  final String userId;
  const InfluencerProfile({super.key, required this.userId});

  @override
  State createState() => _InfluencerProfileState();
}

class ProfileAnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  const ProfileAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ShadCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfluencerProfileState extends State<InfluencerProfile> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
      listener: (context, state) {
        if (state is InfluencerProfileLoaded) {}
      },
      builder: (context, state) {
        return Scaffold(
          appBar: transparentAppBar(
            state is InfluencerProfileLoaded
                ? '@${state.influencer.username}'
                : '',
            context: context,
            // Add this when more options are available
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.more_vert),
            //     onPressed: () {},
            //   ),
            // ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(
              LucideIcons.messageSquare,
            ),
          ),
          body: Skeletonizer(
            enabled: state is InfluencerProfileLoading,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Banner image
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: state is InfluencerProfileLoaded
                                ? Avatar.getUserImage(
                                    id: state.influencer.id,
                                    image: state.influencer.banner,
                                    collectionId: state.influencer.collectionId)
                                : Avatar.getAvatarPlaceholder('HA'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(
                                    state is InfluencerProfileLoaded
                                        ? Avatar.getUserImage(
                                            id: state.influencer.id,
                                            image: state.influencer.avatar,
                                            collectionId:
                                                state.influencer.collectionId)
                                        : Avatar.getAvatarPlaceholder('HA'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  state is InfluencerProfileLoaded
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // influencer public profile details
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        state.influencer.fullName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // verified badge
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.verified,
                                        color: state.influencer.connectedSocial
                                            ? Colors.blue
                                            : Colors.green,
                                      ),
                                      const Spacer(),
                                      // location icon
                                      if (state.influencer.connectedSocial)
                                        GestureDetector(
                                          onTap: () {
                                            // launch url to their instagram profile
                                            String url =
                                                'https://instagram.com/${state.influencer.username}';
                                            // launch url
                                            launchUrl(Uri.parse(url));
                                          },
                                          child: Image.asset(
                                            AssetsPath.instagram,
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    state.influencer.industry.isEmpty
                                        ? 'Uncategorized'
                                        : state.influencer.industry,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  // influencer private profile details
                                  const SizedBox(height: 16),
                                  if (state
                                      .influencerProfile.title.isNotEmpty) ...[
                                    LabeledTextField(
                                        state.influencerProfile.title),
                                    // about influencer
                                    const SizedBox(height: 16),
                                  ],
                                  // description in rich text with "View More" gesture

                                  if (state.influencerProfile.description
                                      .isNotEmpty) ...[
                                    ReadMoreText(
                                      state.influencerProfile.description,
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
                                    // analytics
                                    const SizedBox(height: 16),
                                  ],
                                  Row(
                                    children: [
                                      ProfileAnalyticsCard(
                                        title: 'FOLLOWERS',
                                        value: state.influencerProfile.followers
                                            .toString(),
                                      ),
                                      SizedBox(width: 16),
                                      ProfileAnalyticsCard(
                                        title: 'MEDIA COUNT',
                                        value: state
                                            .influencerProfile.mediaCount
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
