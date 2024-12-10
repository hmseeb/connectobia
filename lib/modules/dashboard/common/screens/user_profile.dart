import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../common/widgets/transparent_appbar.dart';
import '../../../auth/domain/model/brand.dart';
import '../../../auth/domain/model/influencer.dart';
import '../application/brand_profile/brand_profile_bloc.dart';
import '../application/influencer_profile/influencer_profile_bloc.dart';
import '../widgets/profile_body.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_image.dart';

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
  Brand? brand;
  Influencer? influencer;
  @override
  Widget build(BuildContext context) {
    if (widget.profileType == 'influencer') {
      return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
        listener: (context, state) {
          if (state is InfluencerProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
              ),
            );
          } else if (state is InfluencerProfileLoaded) {
            influencer = state.influencer;
          }
        },
        builder: (context, state) {
          influencer =
              state is InfluencerProfileLoaded ? state.influencer : null;
          return Scaffold(
            appBar: transparentAppBar(
              state is InfluencerProfileLoaded
                  ? '@${influencer!.username}'
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
                            userId: influencer!.id,
                            avatar: influencer!.avatar,
                            banner: influencer!.banner,
                            collectionId: influencer!.collectionId,
                          )
                        : SizedBox(),
                    if (state is InfluencerProfileLoaded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileHeader(
                          name: influencer!.fullName,
                          industry: influencer!.industry,
                          username: influencer!.username,
                          isVerified: influencer!.connectedSocial,
                          connectedSocial: influencer!.connectedSocial,
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
        listener: (context, state) {
          if (state is BrandProfileLoaded) {
            brand = state.brand;
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: transparentAppBar(
              state is BrandProfileLoaded ? brand!.brandName : '',
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
                        userId: brand!.id,
                        avatar: brand!.avatar,
                        banner: brand!.banner,
                        collectionId: brand!.collectionId,
                      )
                    else
                      SizedBox(),
                    if (state is BrandProfileLoaded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProfileHeader(
                          name: brand!.brandName,
                          industry: brand!.industry,
                          username: '',
                          isVerified: brand!.verified,
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
