import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/extensions/string_extention.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/dashboard/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/views/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
                ? state.influencer.expand.user.username
                : '',
            context: context,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
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
                                    id: state.influencer.expand.user.id,
                                    image: state.influencer.expand.user.banner)
                                : Avatar.getBannerPlaceholder(),
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
                                            id: state.influencer.expand.user.id,
                                            image: state
                                                .influencer.expand.user.avatar)
                                        : Avatar.getAvatarPlaceholder('H', 'A'),
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
                          child: SizedBox(
                            width: 400,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // influencer public profile details
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Text(
                                        '${state.influencer.expand.user.firstName} ${state.influencer.expand.user.lastName}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // verified badge
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      state.influencer.expand.user.verified
                                          ? const Icon(
                                              Icons.verified,
                                              color: Colors.green,
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(IndustryFormatter.keyToValue(state
                                          .influencer.expand.user.industry)),
                                      // location
                                      const Spacer(),
                                      // location icon
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.grey,
                                        size: 14,
                                      ),
                                      Text(
                                        state.influencer.location,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // influencer private profile details
                                  const SizedBox(height: 16),
                                  LabeledTextField(state.influencer.title),
                                  // about influencer
                                  const SizedBox(height: 16),
                                  // description in rich text with "View More" gesture
                                  ReadMoreText(
                                    state.influencer.description
                                        .removeAllHtmlTags(),
                                    trimMode: TrimMode.Line,
                                    trimLines: 2,
                                    trimCollapsedText: 'Show more',
                                    trimExpandedText: ' Show less',
                                    moreStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // analytics
                                  const SizedBox(height: 16),

                                  const Row(
                                    children: [
                                      ProfileAnalyticsCard(
                                        title: 'FOLLOWERS',
                                        value: '80K',
                                      ),
                                      SizedBox(width: 16),
                                      ProfileAnalyticsCard(
                                        title: 'ENG. RATE',
                                        value: '2.3%',
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
