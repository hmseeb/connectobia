import 'dart:async';

import 'package:connectobia/src/modules/onboarding/application/bloc/influencer_onboard_bloc.dart';
import 'package:connectobia/src/services/storage/pb.dart';
import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/domain/models/brand.dart';
import 'package:connectobia/src/shared/domain/models/brand_profile.dart';
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

import '../../../../shared/data/singletons/account_type.dart';
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

class _UserProfileState extends State<UserProfile> with WidgetsBindingObserver {
  bool _isLoadingUser = false;
  String? _loadingError;
  bool _showRefreshingIndicator = false;
  Timer? _refreshIndicatorTimer;

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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadUserInfo,
              tooltip: 'Refresh Profile',
            ),
          ],
        ),
        body: _buildErrorWidget(),
      );
    }

    return widget.profileType == 'influencers'
        ? _buildInfluencerProfile(context)
        : _buildBrandProfile(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to the foreground, refresh data
      debugPrint('App resumed - refreshing profile data');
      _loadUserInfo();
    }
  }

  @override
  void dispose() {
    _refreshIndicatorTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint(
        'UserProfile initState - ID: ${widget.userId}, profileType: ${widget.profileType}, self: ${widget.self}');

    // Remove unnecessary debug message for new accounts
    _loadUserInfo();
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
        industry: 'Loading...',
        username: '',
        isVerified: true,
        isInfluencerVerified: false,
        connectedSocial: false,
        description: 'Loading brand profile...',
        followers: 0,
        mediaCount: 0,
        profileType: 'brands',
        email: 'Loading...',
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
            email: state.brand.email,
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
            industry: 'industry',
            username: 'username',
            isVerified: true,
            isInfluencerVerified: false,
            connectedSocial: false,
            description: 'Loading brand description...',
            followers: 0,
            mediaCount: 0,
            profileType: 'brands',
            email: 'Loading...',
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
            onPressed: _loadUserInfo,
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
        industry: 'Loading...',
        username: '',
        isVerified: true,
        isInfluencerVerified: false,
        connectedSocial: false,
        description: 'Loading influencer profile...',
        followers: 0,
        mediaCount: 0,
        profileType: 'influencers',
        email: 'Loading...',
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
            email: state.influencer.email,
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
            industry: 'industry',
            username: 'username',
            isVerified: true,
            isInfluencerVerified: false,
            connectedSocial: false,
            description: 'Loading influencer description...',
            followers: 0,
            mediaCount: 0,
            profileType: 'influencers',
            influencerProfile: null,
            email: 'Loading...',
          );
        }
      },
    );
  }

  Widget _buildProfileScaffold({
    required bool isLoading,
    required BuildContext context,
    required String userId,
    String? avatar,
    String? banner,
    String? collectionId,
    String? name,
    String? industry,
    String? username,
    required bool isVerified,
    required bool isInfluencerVerified,
    required bool connectedSocial,
    String? description,
    int? followers,
    int? mediaCount,
    required String profileType,
    InfluencerProfile? influencerProfile,
    String? email,
  }) {
    // Ensure all required fields have default values if null/empty
    final String displayUserId = userId.isNotEmpty ? userId : "unknown";
    final String displayAvatar = avatar?.isNotEmpty == true ? avatar! : "";
    final String displayBanner = banner?.isNotEmpty == true ? banner! : "";
    final String displayCollectionId =
        collectionId?.isNotEmpty == true ? collectionId! : "";
    final String displayName = name?.isNotEmpty == true
        ? name!
        : (profileType == "brands" ? "New Brand" : "New Influencer");
    final String displayIndustry =
        industry?.isNotEmpty == true ? industry! : "No industry selected";
    final String displayUsername =
        username?.isNotEmpty == true ? username! : "username";
    final String displayDescription = description?.isNotEmpty == true
        ? description!
        : (profileType == "brands"
            ? "This brand hasn't added a description yet."
            : "This user hasn't added a bio yet.");
    final String displayEmail =
        email?.isNotEmpty == true ? email! : "No email set";

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: !isLoading ? () => Navigator.pop(context) : () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserInfo,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      floatingActionButton: widget.self
          ? FloatingActionButton.extended(
              onPressed: () {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preparing to edit profile...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                debugPrint('Edit Profile button pressed');
                Object? user;

                try {
                  if (profileType == 'brands') {
                    // For brands, use the state from BrandProfileBloc
                    final brandState =
                        BlocProvider.of<BrandProfileBloc>(context).state;
                    if (brandState is BrandProfileLoaded) {
                      user = brandState.brand;
                      debugPrint(
                          'Found brand user object: ${brandState.brand.id}');
                    }
                  } else {
                    // For influencers, use the state from InfluencerProfileBloc
                    final influencerState =
                        BlocProvider.of<InfluencerProfileBloc>(context).state;
                    if (influencerState is InfluencerProfileLoaded) {
                      user = influencerState.influencer;
                      debugPrint(
                          'Found influencer user object: ${influencerState.influencer.id}');
                    }
                  }

                  // If we couldn't get a valid user object from bloc
                  if (user == null) {
                    debugPrint('Creating fallback user for edit profile');
                    // Create a fallback user based on displayUserId
                    if (profileType == 'brands') {
                      user = Brand(
                        id: displayUserId,
                        brandName: displayName,
                        email: displayEmail,
                        industry: displayIndustry,
                        profile: displayUserId,
                        avatar: displayAvatar,
                        banner: displayBanner,
                        collectionId: displayCollectionId.isNotEmpty
                            ? displayCollectionId
                            : 'brands',
                        collectionName: 'brands',
                        created: DateTime.now(),
                        updated: DateTime.now(),
                        emailVisibility: true,
                        onboarded: true,
                        verified: true,
                      );
                    } else {
                      user = Influencer(
                        id: displayUserId,
                        fullName: displayName,
                        email: displayEmail,
                        username: displayUsername,
                        industry: displayIndustry,
                        profile: displayUserId,
                        avatar: displayAvatar,
                        banner: displayBanner,
                        collectionId: displayCollectionId.isNotEmpty
                            ? displayCollectionId
                            : 'influencers',
                        collectionName: 'influencers',
                        created: DateTime.now(),
                        updated: DateTime.now(),
                        emailVisibility: true,
                        onboarded: true,
                        verified: true,
                        connectedSocial: connectedSocial,
                      );
                    }
                    debugPrint('Created fallback user: ${user.toString()}');
                  }

                  // Navigate to edit profile screen with immediate navigation
                  Navigator.pushNamed(
                    context,
                    editProfileScreen,
                    arguments: {'user': user},
                  ).then((_) {
                    // After returning from edit profile screen, refresh profile data
                    debugPrint(
                        'Returned from edit profile screen, refreshing data');
                    if (mounted) {
                      _loadUserInfo();
                    }
                  });
                } catch (e) {
                  debugPrint('Error navigating to edit profile: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening profile editor: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            )
          : (profileType == 'influencers' &&
                  CollectionNameSingleton.instance == 'brands')
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Navigate to chat/messages screen with influencer info
                    Navigator.pushNamed(
                      context,
                      messagesScreen,
                      arguments: {
                        'userId': displayUserId,
                        'name': displayName,
                        'avatar': displayAvatar,
                        'collectionId': displayCollectionId,
                        'hasConnectedInstagram': connectedSocial,
                        'chatExists': false,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                )
              : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserInfo();
        },
        child: Skeletonizer(
          enabled: isLoading &&
              followers == 0 &&
              mediaCount == 0, // Only show skeleton on initial load
          child: StatefulBuilder(
            builder: (context, setState) {
              // If we're loading, set a timer to hide the indicator after 3 seconds
              if (isLoading) {
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    _showRefreshingIndicator = false;
                  });
                });
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showRefreshingIndicator)
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Skeletonizer(
                                  enabled: true,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Refreshing profile...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                    ProfileImage(
                      userId: displayUserId,
                      avatar: displayAvatar,
                      banner: displayBanner,
                      collectionId: displayCollectionId,
                      name: displayName,
                      onBackButtonPressed:
                          !isLoading ? () => Navigator.pop(context) : () {},
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileHeader(
                            name: displayName,
                            industry: displayIndustry,
                            username: displayUsername,
                            isVerified: isVerified,
                            hasConnectedInstagram: connectedSocial,
                          ),

                          // Add email display
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.email,
                                    size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  displayEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Show Connect Instagram button for influencers viewing their own profile
                          if (widget.self &&
                              !connectedSocial &&
                              profileType == 'influencers' &&
                              !isLoading) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.instagram,
                                            color: Color(0xffd62976),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Instagram Connection',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Connect your Instagram account to showcase your analytics and improve your profile visibility to brands.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 16),
                                      BlocConsumer<InfluencerOnboardBloc,
                                          InfluencerOnboardState>(
                                        listener: (context, state) {
                                          if (state is Onboarded) {
                                            // Reload profile when Instagram is connected successfully
                                            final currentState = BlocProvider
                                                    .of<InfluencerProfileBloc>(
                                                        context)
                                                .state;
                                            if (currentState
                                                is InfluencerProfileLoaded) {
                                              // Create a new influencer object with connectedSocial set to true
                                              final updatedInfluencer =
                                                  currentState.influencer
                                                      .copyWith(
                                                connectedSocial: true,
                                              );

                                              debugPrint(
                                                  'Instagram connected successfully, reloading profile with connectedSocial=true');

                                              // Reload the profile with the updated influencer
                                              BlocProvider.of<
                                                          InfluencerProfileBloc>(
                                                      context)
                                                  .add(
                                                InfluencerProfileLoad(
                                                  profileId: displayUserId,
                                                  influencer: updatedInfluencer,
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
                                                description:
                                                    Text(state.message),
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
                      description: displayDescription,
                      followers: followers,
                      mediaCount: mediaCount,
                      hasConnectedInstagram: connectedSocial,
                      profile: influencerProfile,
                      isInfluencer: profileType == 'influencers',
                      isLoading: isLoading,
                    ),
                    if (!isLoading)
                      ProfileReviews(
                        profileId: displayUserId,
                        isBrand: profileType == 'brands',
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleLoadingState(bool isLoading) {
    _refreshIndicatorTimer?.cancel();

    if (isLoading) {
      if (mounted) {
        setState(() {
          _showRefreshingIndicator = true;
        });
      }

      _refreshIndicatorTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showRefreshingIndicator = false;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _showRefreshingIndicator = false;
        });
      }
    }
  }

  Future<void> _loadUserInfo() async {
    if (mounted) {
      setState(() {
        _isLoadingUser = true;
        _loadingError = null;
      });

      _handleLoadingState(true);
    }

    try {
      // Set a timeout to prevent infinite loading - reduce to 5 seconds
      bool hasTimedOut = false;
      Timer timeoutTimer = Timer(const Duration(seconds: 5), () {
        hasTimedOut = true;
        if (mounted) {
          setState(() {
            _isLoadingUser = false;
            // Don't set error, just allow interaction with partial data
            debugPrint(
                'Profile loading timed out - proceeding with partial data');
          });

          // Show a subtle message about timeout
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Loading took longer than expected. Some data may be incomplete.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });

      // Always get a fresh PocketBase instance to reduce caching issues
      final pb = await PocketBaseSingleton.instance;
      debugPrint('Fetching fresh data from PocketBase for profile refresh');

      if (widget.profileType == 'influencers') {
        // Create a basic placeholder influencer profile if needed
        InfluencerProfile? placeholderProfile;
        Influencer? placeholderInfluencer;

        // First try to get the profile - but don't fail if we can't
        try {
          final profileRecord =
              await pb.collection('influencerProfile').getOne(widget.userId);
          debugPrint('Found influencer profile record: ${profileRecord.id}');
          placeholderProfile = InfluencerProfile.fromRecord(profileRecord);
        } catch (e) {
          debugPrint(
              'Could not find influencer profile, creating placeholder: $e');
          // Create a minimal placeholder profile using the empty factory
          placeholderProfile = InfluencerProfile.empty(id: widget.userId);
        }

        // Now try to get the influencer
        try {
          final influencerRecords = await pb.collection('influencers').getList(
                filter: 'profile = "${widget.userId}"',
                page: 1,
                perPage: 1,
              );

          if (influencerRecords.items.isNotEmpty) {
            placeholderInfluencer =
                Influencer.fromRecord(influencerRecords.items.first);
            debugPrint(
                'Found matching influencer: ${placeholderInfluencer.fullName}');
          }
        } catch (e) {
          debugPrint(
              'Could not find influencer, will use placeholder data: $e');
        }

        // If we couldn't find the influencer, create a placeholder
        if (placeholderInfluencer == null) {
          // First try to get the user ID directly
          try {
            final userRecord =
                await pb.collection('influencers').getOne(widget.userId);
            placeholderInfluencer = Influencer.fromRecord(userRecord);
            debugPrint(
                'Found influencer by direct ID: ${placeholderInfluencer.fullName}');
          } catch (e) {
            debugPrint(
                'Could not find influencer by ID, using complete placeholder: $e');

            // Create a complete placeholder as last resort
            placeholderInfluencer = Influencer(
              id: widget.userId.isNotEmpty
                  ? widget.userId
                  : 'temp_${DateTime.now().millisecondsSinceEpoch}',
              collectionId: 'influencers',
              collectionName: 'influencers',
              fullName: 'New User',
              email: '',
              username: '',
              avatar: '', // Ensure avatar is empty string not null
              banner: '', // Ensure banner is empty string not null
              emailVisibility: true,
              verified: true,
              connectedSocial: false,
              onboarded: true,
              industry: '',
              profile: widget.userId,
              created: DateTime.now(),
              updated: DateTime.now(),
            );
          }
        }

        // Ensure the influencer has a profile ID set
        if (placeholderInfluencer.profile.isEmpty) {
          debugPrint(
              'Influencer has no profile ID, setting profile ID to ${placeholderProfile.id}');
          placeholderInfluencer = placeholderInfluencer.copyWith(
            profile: placeholderProfile.id,
          );
        }

        // Cancel timeout timer if we haven't timed out yet
        if (!hasTimedOut) {
          timeoutTimer.cancel();
          if (mounted) {
            // Set state and update bloc
            setState(() {
              _isLoadingUser = false;
            });

            // Turn off the loading indicator after successful load
            _handleLoadingState(false);

            BlocProvider.of<InfluencerProfileBloc>(context).add(
              InfluencerProfileLoad(
                profileId: placeholderProfile.id,
                influencer: placeholderInfluencer,
              ),
            );
          }
        }
      } else if (widget.profileType == 'brands') {
        // Similar approach for brands
        BrandProfile? placeholderProfile;
        Brand? placeholderBrand;

        // First try to get the profile
        try {
          final profileRecord =
              await pb.collection('brandProfile').getOne(widget.userId);
          debugPrint('Found brand profile record: ${profileRecord.id}');
          placeholderProfile = BrandProfile.fromRecord(profileRecord);
        } catch (e) {
          debugPrint('Could not find brand profile, creating placeholder: $e');
          placeholderProfile = BrandProfile.empty(id: widget.userId);
        }

        // Now try to get the brand
        try {
          final brandRecords = await pb.collection('brands').getList(
                filter: 'profile = "${widget.userId}"',
                page: 1,
                perPage: 1,
              );

          if (brandRecords.items.isNotEmpty) {
            placeholderBrand = Brand.fromRecord(brandRecords.items.first);
            debugPrint('Found matching brand: ${placeholderBrand.brandName}');
          }
        } catch (e) {
          debugPrint('Could not find brand, will use placeholder data: $e');
        }

        // If we couldn't find the brand, create a placeholder
        if (placeholderBrand == null) {
          // First try to get the brand directly by ID
          try {
            final brandRecord =
                await pb.collection('brands').getOne(widget.userId);
            placeholderBrand = Brand.fromRecord(brandRecord);
            debugPrint(
                'Found brand by direct ID: ${placeholderBrand.brandName}');
          } catch (e) {
            debugPrint(
                'Could not find brand by ID, using complete placeholder: $e');

            // Create a complete placeholder as last resort
            placeholderBrand = Brand(
              id: widget.userId.isNotEmpty
                  ? widget.userId
                  : 'temp_${DateTime.now().millisecondsSinceEpoch}',
              collectionId: 'brands',
              collectionName: 'brands',
              brandName: 'New Brand',
              email: '',
              avatar: '', // Ensure avatar is empty string not null
              banner: '', // Ensure banner is empty string not null
              emailVisibility: true,
              verified: true,
              onboarded: true,
              industry: '',
              profile: widget.userId,
              created: DateTime.now(),
              updated: DateTime.now(),
            );
          }
        }

        // Ensure the brand has a profile ID set
        if (placeholderBrand.profile.isEmpty) {
          debugPrint(
              'Brand has no profile ID, setting profile ID to ${placeholderProfile.id}');
          placeholderBrand = placeholderBrand.copyWith(
            profile: placeholderProfile.id,
          );
        }

        // Cancel timeout timer if we haven't timed out yet
        if (!hasTimedOut) {
          timeoutTimer.cancel();
          if (mounted) {
            // Set state and update bloc
            setState(() {
              _isLoadingUser = false;
            });

            // Turn off the loading indicator after successful load
            _handleLoadingState(false);

            BlocProvider.of<BrandProfileBloc>(context).add(
              LoadBrandProfile(
                profileId: placeholderProfile.id,
                brand: placeholderBrand,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in profile loading: $e');
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _loadingError = e.toString();
        });

        // Turn off the loading indicator on error
        _handleLoadingState(false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        // Always ensure loading state is turned off
        setState(() {
          _isLoadingUser = false;
        });

        // Ensure loading indicator is turned off
        Future.delayed(Duration(seconds: 3), () {
          _handleLoadingState(false);
        });
      }
    }
  }
}
