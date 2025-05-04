import 'package:connectobia/src/modules/chatting/application/messaging/realtime_messaging_bloc.dart';
import 'package:connectobia/src/modules/onboarding/application/bloc/influencer_onboard_bloc.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/influencer.dart';
import 'package:connectobia/src/shared/domain/models/influencer_profile.dart';
import 'package:connectobia/src/shared/presentation/widgets/custom_dialogue.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';

import '../application/brand_profile/brand_profile_bloc.dart';
import '../application/influencer_profile/influencer_profile_bloc.dart';
import '../widgets/profile_body.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_image.dart';
import '../widgets/profile_reviews.dart';

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
  bool _isLoadingUser = false;
  String? _loadingError;

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'UserProfile build - profileType: ${widget.profileType}, self: ${widget.self}, userId: ${widget.userId}');

    // If we have a loading error, show the error widget
    if (_loadingError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildErrorWidget(),
      );
    }

    return widget.profileType == 'influencers'
        ? _buildInfluencerProfile(context)
        : _buildBrandProfile(context);
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
        'UserProfile initState - ID: ${widget.userId}, profileType: ${widget.profileType}, self: ${widget.self}');

    // The critical issue: clarify exactly what type of ID we're working with
    debugPrint('IMPORTANT: Clarifying whether ID is a user ID or profile ID');

    _loadProfile();
  }

  Widget _buildBrandProfile(BuildContext context) {
    debugPrint('Building Brand Profile - self: ${widget.self}');

    if (_isLoadingUser) {
      return _buildProfileScaffold(
        isLoading: true,
        context: context,
        userId: '',
        avatar: '',
        banner: '',
        collectionId: 'collectionId',
        name: 'Loading...',
        isInfluencerVerified: false,
        industry: 'Loading...',
        username: '',
        isVerified: true,
        connectedSocial: false,
        description: 'Loading brand profile...',
        followers: 0,
        mediaCount: 0,
        profileType: 'brands',
      );
    }

    return BlocConsumer<BrandProfileBloc, BrandProfileState>(
      listener: (context, state) {
        debugPrint('BrandProfileBloc state: ${state.runtimeType}');
        if (state is BrandProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is BrandProfileLoaded) {
          debugPrint('Brand profile loaded successfully');
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
          debugPrint(
              'Brand profile still loading... state: ${state.runtimeType}');
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

  // Widget to show when there's an error loading the profile
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _loadingError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: _loadProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfluencerProfile(BuildContext context) {
    debugPrint('Building Influencer Profile - self: ${widget.self}');

    if (_isLoadingUser) {
      return _buildProfileScaffold(
        isLoading: true,
        context: context,
        userId: '',
        avatar: '',
        banner: '',
        collectionId: 'collectionId',
        name: 'Loading...',
        isInfluencerVerified: false,
        industry: 'Loading...',
        username: '',
        isVerified: true,
        connectedSocial: false,
        description: 'Loading influencer profile...',
        followers: 0,
        mediaCount: 0,
        profileType: 'influencers',
      );
    }

    return BlocConsumer<InfluencerProfileBloc, InfluencerProfileState>(
      listener: (context, state) {
        debugPrint('InfluencerProfileBloc state: ${state.runtimeType}');
        if (state is InfluencerProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is InfluencerProfileLoaded) {
          debugPrint(
              'Influencer profile loaded successfully - connectedSocial: ${state.influencer.connectedSocial}');
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
            influencerProfile: state.influencerProfile,
          );
        } else {
          debugPrint(
              'Influencer profile still loading... state: ${state.runtimeType}');
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
            influencerProfile: null,
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
    InfluencerProfile? influencerProfile,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      name: name,
                      industry: industry,
                      username: username,
                      isVerified: isVerified,
                      hasConnectedInstagram: connectedSocial,
                    ),

                    // Show Connect Instagram button for influencers viewing their own profile
                    if (widget.self &&
                        !connectedSocial &&
                        profileType == 'influencers' &&
                        !isLoading) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
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
                                Text(
                                  'Instagram Connection',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                BlocConsumer<InfluencerOnboardBloc,
                                    InfluencerOnboardState>(
                                  listener: (context, state) {
                                    if (state is Onboarded) {
                                      // Reload profile when Instagram is connected successfully
                                      final currentState = BlocProvider.of<
                                              InfluencerProfileBloc>(context)
                                          .state;
                                      if (currentState
                                          is InfluencerProfileLoaded) {
                                        BlocProvider.of<InfluencerProfileBloc>(
                                                context)
                                            .add(
                                          InfluencerProfileLoad(
                                            profileId: userId,
                                            influencer: currentState.influencer,
                                          ),
                                        );
                                      }

                                      ShadToaster.of(context).show(
                                        ShadToast(
                                          title: const Text(
                                              'Instagram connected successfully'),
                                        ),
                                      );
                                    } else if (state
                                        is ConnectingInstagramFailure) {
                                      ShadToaster.of(context).show(
                                        ShadToast.destructive(
                                          title: const Text(
                                              'Failed to connect Instagram'),
                                          description: Text(state.message),
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    final isConnecting =
                                        state is ConnectingInstagram;
                                    return Opacity(
                                      opacity: isConnecting ? 0.6 : 1.0,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: SocialAuthBtn(
                                          icon: AssetsPath.instagram,
                                          onPressed: isConnecting
                                              ? () {} // Empty function when connecting
                                              : () {
                                                  customDialogue(
                                                    context: context,
                                                    title:
                                                        'You need an Instagram Business account',
                                                    description:
                                                        'If you don\'t have one, you can create one by converting your personal account to a business account.',
                                                    onContinue: () {
                                                      HapticFeedback
                                                          .mediumImpact();
                                                      BlocProvider.of<
                                                                  InfluencerOnboardBloc>(
                                                              context)
                                                          .add(
                                                              ConnectInstagram());
                                                    },
                                                  );
                                                },
                                          text: isConnecting
                                              ? 'Connecting Instagram...'
                                              : 'Connect Instagram',
                                          borderSide: const BorderSide(),
                                          backgroundColor:
                                              ShadColors.lightForeground,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ProfileBody(
                description: description,
                followers: followers,
                mediaCount: mediaCount,
                hasConnectedInstagram: connectedSocial,
                profile: influencerProfile,
              ),
              if (!isLoading)
                ProfileReviews(
                  profileId: userId,
                  isBrand: profileType == 'brands',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingUser = true;
      _loadingError = null;
    });

    try {
      if (widget.profileType == 'influencers') {
        // APPROACH 1: Try treating the ID as a user ID from the 'influencers' collection
        try {
          debugPrint(
              'Attempting to load influencer user with ID: ${widget.userId}');
          final pb = await PocketBaseSingleton.instance;
          final userRecord =
              await pb.collection('influencers').getOne(widget.userId);

          // If this succeeds, we have an influencer user ID
          final influencer = Influencer.fromRecord(userRecord);
          debugPrint(
              '✅ Successfully loaded influencer: ${influencer.fullName}, profile ID: ${influencer.profile}');

          if (influencer.profile.isNotEmpty) {
            // Load the profile using the profile ID from the influencer record
            if (mounted) {
              BlocProvider.of<InfluencerProfileBloc>(context).add(
                InfluencerProfileLoad(
                  profileId: influencer.profile,
                  influencer: influencer,
                ),
              );
            }
            return;
          } else {
            throw Exception('Influencer has no linked profile');
          }
        } catch (e) {
          debugPrint('🔄 First approach failed: $e');

          // APPROACH 2: Try treating the ID as a profile ID from 'influencerProfile' collection
          try {
            debugPrint(
                'Attempting to load influencer profile directly with ID: ${widget.userId}');
            final pb = await PocketBaseSingleton.instance;
            final profileRecord =
                await pb.collection('influencerProfile').getOne(widget.userId);

            // If this succeeds, we have a profile ID
            debugPrint(
                '✅ Successfully found profile record with ID: ${widget.userId}');

            // Now we need to find the associated influencer
            try {
              debugPrint(
                  'Searching for influencer with profile=${widget.userId}');
              final influencerRecords =
                  await pb.collection('influencers').getList(
                        filter: 'profile = "${widget.userId}"',
                        page: 1,
                        perPage: 1,
                      );

              if (influencerRecords.items.isNotEmpty) {
                final influencer =
                    Influencer.fromRecord(influencerRecords.items.first);
                debugPrint(
                    '✅ Found matching influencer: ${influencer.fullName}');

                if (mounted) {
                  BlocProvider.of<InfluencerProfileBloc>(context).add(
                    InfluencerProfileLoad(
                      profileId: widget.userId,
                      influencer: influencer,
                    ),
                  );
                }
                return;
              } else {
                debugPrint('⚠️ No influencer found with this profile ID');
                // No matching influencer found, create a temporary one
                final tempInfluencer = Influencer(
                  id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  collectionId: 'influencers',
                  collectionName: 'influencers',
                  fullName: 'Unknown Influencer',
                  email: '',
                  username: '',
                  avatar: '',
                  banner: '',
                  emailVisibility: true,
                  verified: true,
                  connectedSocial: false,
                  onboarded: true,
                  industry: '',
                  profile: widget.userId,
                  created: DateTime.now(),
                  updated: DateTime.now(),
                );

                if (mounted) {
                  BlocProvider.of<InfluencerProfileBloc>(context).add(
                    InfluencerProfileLoad(
                      profileId: widget.userId,
                      influencer: tempInfluencer,
                    ),
                  );
                }
                return;
              }
            } catch (e) {
              debugPrint('Error finding influencer for profile: $e');
              rethrow;
            }
          } catch (e) {
            debugPrint('🔄 Second approach failed: $e');
            throw Exception(
                'Failed to load profile: ID is neither a valid influencer ID nor a valid profile ID');
          }
        }
      } else if (widget.profileType == 'brands') {
        // APPROACH 1: Try treating the ID as a user ID from the 'brands' collection
        try {
          debugPrint('Attempting to load brand user with ID: ${widget.userId}');
          final pb = await PocketBaseSingleton.instance;
          final userRecord =
              await pb.collection('brands').getOne(widget.userId);

          // If this succeeds, we have a brand user ID
          final brand = Brand.fromRecord(userRecord);
          debugPrint(
              '✅ Successfully loaded brand: ${brand.brandName}, profile ID: ${brand.profile}');

          if (brand.profile.isNotEmpty) {
            // Load the profile using the profile ID from the brand record
            if (mounted) {
              BlocProvider.of<BrandProfileBloc>(context).add(
                LoadBrandProfile(
                  profileId: brand.profile,
                  brand: brand,
                ),
              );
            }
            return;
          } else {
            throw Exception('Brand has no linked profile');
          }
        } catch (e) {
          debugPrint('🔄 First approach failed: $e');

          // APPROACH 2: Try treating the ID as a profile ID from 'brandProfile' collection
          try {
            debugPrint(
                'Attempting to load brand profile directly with ID: ${widget.userId}');
            final pb = await PocketBaseSingleton.instance;
            final profileRecord =
                await pb.collection('brandProfile').getOne(widget.userId);

            // If this succeeds, we have a profile ID
            debugPrint(
                '✅ Successfully found profile record with ID: ${widget.userId}');

            // Now we need to find the associated brand
            try {
              debugPrint('Searching for brand with profile=${widget.userId}');
              final brandRecords = await pb.collection('brands').getList(
                    filter: 'profile = "${widget.userId}"',
                    page: 1,
                    perPage: 1,
                  );

              if (brandRecords.items.isNotEmpty) {
                final brand = Brand.fromRecord(brandRecords.items.first);
                debugPrint('✅ Found matching brand: ${brand.brandName}');

                if (mounted) {
                  BlocProvider.of<BrandProfileBloc>(context).add(
                    LoadBrandProfile(
                      profileId: widget.userId,
                      brand: brand,
                    ),
                  );
                }
                return;
              } else {
                debugPrint('⚠️ No brand found with this profile ID');
                // No matching brand found, create a temporary one
                final tempBrand = Brand(
                  id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  collectionId: 'brands',
                  collectionName: 'brands',
                  brandName: 'Unknown Brand',
                  email: '',
                  avatar: '',
                  banner: '',
                  emailVisibility: true,
                  verified: true,
                  onboarded: true,
                  industry: '',
                  profile: widget.userId,
                  created: DateTime.now(),
                  updated: DateTime.now(),
                );

                if (mounted) {
                  BlocProvider.of<BrandProfileBloc>(context).add(
                    LoadBrandProfile(
                      profileId: widget.userId,
                      brand: tempBrand,
                    ),
                  );
                }
                return;
              }
            } catch (e) {
              debugPrint('Error finding brand for profile: $e');
              rethrow;
            }
          } catch (e) {
            debugPrint('🔄 Second approach failed: $e');
            throw Exception(
                'Failed to load profile: ID is neither a valid brand ID nor a valid profile ID');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in profile loading: $e');
      if (mounted) {
        setState(() {
          _loadingError = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }
}
