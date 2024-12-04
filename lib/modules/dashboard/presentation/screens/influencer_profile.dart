import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/extensions/string_extention.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/dashboard/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/presentation/views/user_setting.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InfluencerProfile extends StatefulWidget {
  final String userId;
  const InfluencerProfile({super.key, required this.userId});

  @override
  State createState() => _InfluencerProfileState();
}

class _InfluencerProfileState extends State<InfluencerProfile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = ShadTheme.of(context).brightness;
    return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
      listener: (context, state) {
        if (state is InfluencerProfileLoaded) {}
      },
      builder: (context, state) {
        return Scaffold(
          // message floating action button
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
              Icons.message,
            ),
          ),
          body: Skeletonizer(
            enabled: state is InfluencerProfileLoading,
            child: Center(
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
                        // Avatar image with camera icon
                        Positioned(
                          bottom: 0,
                          left: 10,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              // show cuperino action sheet
                            },
                            child: Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: CachedNetworkImageProvider(
                                      state is InfluencerProfileLoaded
                                          ? Avatar.getUserImage(
                                              id: state
                                                  .influencer.expand.user.id,
                                              image: state.influencer.expand
                                                  .user.avatar)
                                          : Avatar.getAvatarPlaceholder(
                                              'H', 'A'),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircleAvatar(
                                        backgroundColor:
                                            brightness == Brightness.light
                                                ? ShadColors.light
                                                : ShadColors.dark,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: brightness == Brightness.light
                                              ? ShadColors.dark
                                              : ShadColors.light,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                            color: Colors.blue,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(IndustryFormatter.keyToValue(
                                        state.influencer.expand.user.industry)),
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
                                Wrap(
                                  children: [
                                    Text(
                                      _isExpanded
                                          ? state.influencer.description
                                              .removeAllHtmlTags()
                                          : (state.influencer.description
                                                      .removeAllHtmlTags()
                                                      .length >
                                                  100
                                              ? '${state.influencer.description.removeAllHtmlTags().substring(0, 100)}...'
                                              : state.influencer.description
                                                  .removeAllHtmlTags()),
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                      child: Text(
                                        _isExpanded ? 'View Less' : 'View More',
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // analytics
                                const SizedBox(height: 16),

                                const Row(
                                  children: [
                                    Expanded(
                                      child: ShadCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('ENG. RATE'),
                                            Text(
                                              '0.0%',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // average engagement per post
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: ShadCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('ENG. PER POST'),
                                            Text(
                                              '0.0%',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
