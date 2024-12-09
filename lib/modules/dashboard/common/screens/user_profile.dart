import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/extensions/string_extention.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/views/user_setting.dart';
import 'package:connectobia/modules/dashboard/common/application/brand_profile/brand_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/common/widgets/user_profile_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  final String profileType;
  final bool self;
  const UserProfile(
      {super.key,
      required this.userId,
      this.self = false,
      required this.profileType});

  @override
  State createState() => _UserProfileState();
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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    if (widget.profileType == 'influencer') {
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
                                      userId: state.influencer.id,
                                      image: state.influencer.banner,
                                      collectionId:
                                          state.influencer.collectionId)
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
                                              userId: state.influencer.id,
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
                                    if (widget.self) ...[
                                      ProfileButtons(),
                                      const SizedBox(height: 16),
                                    ],
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
                                          color:
                                              state.influencer.connectedSocial
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
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(0xffd62976),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      LucideIcons.instagram,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Instagram',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                      ],
                                    ),
                                    Text(
                                      state.influencer.industry.isEmpty
                                          ? 'Uncategorized'
                                          : state.influencer.industry,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    // influencer private profile details
                                    const SizedBox(height: 16),
                                    if (state.influencerProfile.title
                                        .isNotEmpty) ...[
                                      LabeledTextField(
                                          state.influencerProfile.title),
                                      // about influencer
                                      const SizedBox(height: 16),
                                    ],
                                    const SizedBox(height: 16),

                                    if (state.influencerProfile.description
                                        .isNotEmpty) ...[
                                      ReadMoreText(
                                        state.influencerProfile.description
                                            .removeAllHtmlTags(),
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
                                          value: state
                                              .influencerProfile.followers
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
    } else {
      return BlocConsumer<BrandProfileBloc, BrandProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: transparentAppBar(
              state is BrandProfileLoaded ? state.brand.brandName : '',
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
              enabled: state is BrandProfileLoading,
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
                              imageUrl: state is BrandProfileLoaded
                                  ? Avatar.getUserImage(
                                      userId: state.brand.id,
                                      image: state.brand.banner,
                                      collectionId: state.brand.collectionId)
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
                                      state is BrandProfileLoaded
                                          ? Avatar.getUserImage(
                                              userId: state.brand.id,
                                              image: state.brand.avatar,
                                              collectionId:
                                                  state.brand.collectionId)
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
                    state is BrandProfileLoaded
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
                                    if (widget.self) ...[
                                      ProfileButtons(),
                                      const SizedBox(height: 16),
                                    ],
                                    Row(
                                      children: [
                                        Text(
                                          state.brand.brandName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // verified badge
                                        const SizedBox(width: 8),
                                        if (state.brand.verified)
                                          Icon(
                                            Icons.verified,
                                            color: Colors.green,
                                          ),
                                        const Spacer(),
                                        // location icon
                                      ],
                                    ),
                                    Text(
                                      state.brand.industry.isEmpty
                                          ? 'Uncategorized'
                                          : state.brand.industry,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                    // brand private profile details
                                    const SizedBox(height: 16),
                                    if (state
                                        .brandProfile.title.isNotEmpty) ...[
                                      LabeledTextField(
                                          state.brandProfile.title),
                                      // about brand
                                      const SizedBox(height: 16),
                                    ],
                                    // description in rich text with "View More" gesture

                                    if (state.brandProfile.description
                                        .isNotEmpty) ...[
                                      ReadMoreText(
                                        state.brandProfile.description
                                            .removeAllHtmlTags(),
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
}
