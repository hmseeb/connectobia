import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/dashboard/common/application/brand_profile/brand_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/common/application/influencer_profile/influencer_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/common/widgets/profile_body.dart';
import 'package:connectobia/modules/dashboard/common/widgets/profile_header.dart';
import 'package:connectobia/modules/dashboard/common/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfile extends StatefulWidget {
  final String userId;
  final String profileType;
  final bool self;

  const UserProfile({
    super.key,
    required this.userId,
    this.self = false,
    required this.profileType,
  });

  @override
  State createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    if (widget.profileType == 'influencer') {
      return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: transparentAppBar(
              state is InfluencerProfileLoaded
                  ? '@${state.influencer.username}'
                  : '',
              context: context,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.message),
            ),
            body: Skeletonizer(
              enabled: state is InfluencerProfileLoading,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    state is InfluencerProfileLoaded
                        ? ProfileImage(
                            userId: state.influencer.id,
                            avatar: state.influencer.avatar,
                            banner: state.influencer.banner,
                            collectionId: state.influencer.collectionId,
                          )
                        : SizedBox(),
                    if (state is InfluencerProfileLoaded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileHeader(
                          name: state.influencer.fullName,
                          industry: state.influencer.industry,
                          username: state.influencer.username,
                          isVerified: state.influencer.connectedSocial,
                          connectedSocial: state.influencer.connectedSocial,
                        ),
                      )
                    else
                      const SizedBox(),
                    if (state is InfluencerProfileLoaded)
                      ProfileBody(
                        description: state.influencerProfile.description,
                        followers: state.influencerProfile.followers,
                        mediaCount: state.influencerProfile.mediaCount,
                      )
                    else
                      const SizedBox(),
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
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.message),
            ),
            body: Skeletonizer(
              enabled: state is BrandProfileLoading,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state is BrandProfileLoaded)
                      ProfileImage(
                        userId: state.brand.id,
                        avatar: state.brand.avatar,
                        banner: state.brand.banner,
                        collectionId: state.brand.collectionId,
                      )
                    else
                      SizedBox(),
                    if (state is BrandProfileLoaded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileHeader(
                          name: state.brand.brandName,
                          industry: state.brand.industry,
                          username: '',
                          isVerified: state.brand.verified,
                          connectedSocial: false,
                        ),
                      )
                    else
                      const SizedBox(),
                    state is BrandProfileLoaded
                        ? ProfileBody(
                            description: state.brandProfile.description,
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
