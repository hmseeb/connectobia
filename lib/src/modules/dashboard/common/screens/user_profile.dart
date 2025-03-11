import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
  @override
  Widget build(BuildContext context) {
    return widget.profileType == 'influencers'
        ? _buildInfluencerProfile(context)
        : _buildBrandProfile(context);
  }

  Widget _buildBrandProfile(BuildContext context) {
    return BlocConsumer<BrandProfileBloc, BrandProfileState>(
      listener: (context, state) {
        if (state is BrandProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is BrandProfileLoaded) {
          return _buildProfileScaffold(
            isLoading: false,
            context: context,
            userId: state.brand.id,
            avatar: state.brand.avatar,
            banner: state.brand.banner,
            collectionId: state.brand.collectionId,
            name: state.brand.brandName,
            industry: state.brand.industry,
            isInfluencerVerified: state.isInfluencerVerified,
            username: '',
            isVerified: state.brand.verified,
            connectedSocial: false,
            description: state.brandProfile.description,
            followers: null,
            mediaCount: null,
            profileType: 'brands',
          );
        } else {
          return _buildProfileScaffold(
            isLoading: true,
            context: context,
            userId: '',
            avatar: '',
            banner: '',
            collectionId: 'collectionId',
            name: 'name',
            isInfluencerVerified: false,
            industry: 'industry',
            username: 'username',
            isVerified: true,
            connectedSocial: false,
            description: 'Loading brand description...',
            followers: 0,
            mediaCount: 0,
            profileType: 'brands',
          );
        }
      },
    );
  }

  Widget _buildInfluencerProfile(BuildContext context) {
    return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
      listener: (context, state) {
        if (state is InfluencerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is InfluencerProfileLoaded) {
          return _buildProfileScaffold(
            isLoading: false,
            context: context,
            userId: state.influencer.id,
            avatar: state.influencer.avatar,
            banner: state.influencer.banner,
            collectionId: state.influencer.collectionId,
            name: state.influencer.fullName,
            industry: state.influencer.industry,
            isInfluencerVerified: true,
            username: state.influencer.username,
            isVerified: state.influencer.verified,
            connectedSocial: state.influencer.connectedSocial,
            description: state.influencerProfile.description,
            followers: state.influencerProfile.followers,
            mediaCount: state.influencerProfile.mediaCount,
            profileType: 'influencers',
          );
        } else {
          return _buildProfileScaffold(
            isLoading: true,
            context: context,
            userId: 'id',
            avatar: '',
            banner: '',
            collectionId: 'collectionId',
            name: 'name',
            isInfluencerVerified: false,
            industry: 'industry',
            username: 'username',
            isVerified: true,
            connectedSocial: false,
            description: 'Loading influencer description...',
            followers: 0,
            mediaCount: 0,
            profileType: 'influencers',
          );
        }
      },
    );
  }

  Widget _buildProfileScaffold({
    required bool isLoading,
    required BuildContext context,
    required bool connectedSocial,
    required String description,
    required int? followers,
    required int? mediaCount,
    required String userId,
    required bool isInfluencerVerified,
    required String avatar,
    required String banner,
    required String collectionId,
    required String name,
    required String industry,
    required String username,
    required bool isVerified,
    required String profileType,
  }) {
    return Scaffold(
      floatingActionButton:
          BlocBuilder<RealtimeMessagingBloc, RealtimeMessagingState>(
        builder: (context, state) {
          return isVerified
              ? FloatingActionButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (isInfluencerVerified) {
                            BlocProvider.of<RealtimeMessagingBloc>(context)
                                .add(GetMessagesByUserId(userId));
                            Navigator.pushNamed(
                              context,
                              messagesScreen,
                              arguments: {
                                'userId': userId,
                                'name': name,
                                'avatar': avatar,
                                'collectionId': collectionId,
                                'hasConnectedInstagram': connectedSocial,
                              },
                            );
                          } else {
                            ShadToaster.of(context).show(
                              ShadToast.destructive(
                                title: const Text(
                                    'Please connect your Instagram account to be able to connect with other users'),
                              ),
                            );
                          }
                        },
                  child: const Icon(Icons.message),
                )
              : const SizedBox();
        },
      ),
      body: Skeletonizer(
        enabled: isLoading,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(
                userId: userId,
                avatar: avatar,
                banner: banner,
                collectionId: collectionId,
                onBackButtonPressed:
                    !isLoading ? () => Navigator.pop(context) : () {},
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ProfileHeader(
                  name: name,
                  industry: industry,
                  username: username,
                  isVerified: isVerified,
                  hasConnectedInstagram: connectedSocial,
                ),
              ),
              ProfileBody(
                description: description,
                followers: followers,
                mediaCount: mediaCount,
                hasConnectedInstagram: connectedSocial,
                // profileType: profileType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}