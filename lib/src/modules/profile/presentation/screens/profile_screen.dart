import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/screens.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
import '../../../../theme/colors.dart';
import '../../application/user/user_bloc.dart';
import '../components/avatar_uploader.dart';
import '../components/profile_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _profileData;
  bool _isLoadingProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Profile', context: context),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // Only clear cached profile data if we don't already have it
            if (_profileData == null) {
              debugPrint(
                  'UserLoaded state received, will trigger profile fetch');
              setState(() {
                _isLoadingProfile = false;
              });
            } else {
              debugPrint(
                  'UserLoaded state received with existing profile data');
            }
          } else if (state is UserProfileLoaded) {
            debugPrint(
                'UserProfileLoaded state received, updating profile data');
            setState(() {
              _profileData = state.profileData;
              _isLoadingProfile = false;
            });
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else if (state is UserProfileLoaded) {
            // If we have profile data loaded
            debugPrint('Rendering with UserProfileLoaded state');
            if (state.profileData is BrandProfile) {
              final brandProfile = state.profileData as BrandProfile;
              debugPrint(
                  'Rendering with brand profile, description: "${brandProfile.description}"');
            } else if (state.profileData is InfluencerProfile) {
              final influencerProfile = state.profileData as InfluencerProfile;
              debugPrint(
                  'Rendering with influencer profile, description: "${influencerProfile.description}"');
            }
            return _buildProfileContent(context, state.user);
          } else if (state is UserLoaded) {
            if (_isLoadingProfile) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildProfileContent(context, state.user);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, editProfileScreen);
          // Refresh data when returning from edit screen
          setState(() {
            _profileData = null; // Clear cached profile data
            _isLoadingProfile = false;
          });
          context.read<UserBloc>().add(FetchUser()); // Refresh user data
        },
        backgroundColor: ShadColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any resources
    _profileData = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Clear profile data at start
    _profileData = null;
    context.read<UserBloc>().add(FetchUser());
  }

  Widget _buildProfileContent(BuildContext context, dynamic user) {
    final bool isBrand = user is Brand;

    String avatar = '';
    String name = '';
    String email = '';
    String username = '';
    String collectionId = '';
    String userId = '';
    String industry = '';
    String description = '';
    String profileId = '';

    if (isBrand) {
      final Brand brand = user;
      avatar = brand.avatar;
      name = brand.brandName;
      email = brand.email;
      username = '';
      collectionId = brand.collectionId;
      userId = brand.id;
      industry = brand.industry;
      profileId = brand.profile;

      // Dispatch event to fetch profile data
      if (_profileData == null) {
        debugPrint('Fetching brand profile data via bloc event');
        context.read<UserBloc>().add(FetchUserProfile(
              profileId: profileId,
              isBrand: true,
            ));
      } else if (_profileData is BrandProfile) {
        description = (_profileData as BrandProfile).description;
        debugPrint('Using cached brand profile: "$description"');
      }
    } else {
      final Influencer influencer = user;
      avatar = influencer.avatar;
      name = influencer.fullName;
      email = influencer.email;
      username = influencer.username;
      collectionId = influencer.collectionId;
      userId = influencer.id;
      industry = influencer.industry;
      profileId = influencer.profile;

      // Dispatch event to fetch profile data
      if (_profileData == null) {
        debugPrint('Fetching influencer profile data via bloc event');
        context.read<UserBloc>().add(FetchUserProfile(
              profileId: profileId,
              isBrand: false,
            ));
      } else if (_profileData is InfluencerProfile) {
        description = (_profileData as InfluencerProfile).description;
        debugPrint('Using cached influencer profile: "$description"');
      }
    }

    // Force manual fetch of profile data if not already loading
    if (!_isLoadingProfile && description.isEmpty && profileId.isNotEmpty) {
      Future.microtask(() => _forceRefreshProfileData(profileId, isBrand));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AvatarUploader(
              avatarUrl: avatar,
              userId: userId,
              collectionId: collectionId,
              isEditable: false,
              size: 120,
            ),
          ),
          const SizedBox(height: 24),

          // Main user info section
          _buildSection(
            title: 'Personal Information',
            children: [
              ProfileField(
                label: isBrand ? 'Brand Name' : 'Full Name',
                value: name,
                icon: Icons.business,
                isEditable: false,
              ),
              ProfileField(
                label: 'Email',
                value: email,
                icon: Icons.email,
                isEditable: false,
              ),
              if (!isBrand)
                ProfileField(
                  label: 'Username',
                  value: username,
                  icon: Icons.alternate_email,
                  isEditable: false,
                ),
              ProfileField(
                label: 'Industry',
                value: industry,
                icon: Icons.category,
                isEditable: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio and additional info
          _buildSection(
            title: 'Bio',
            children: [
              Builder(builder: (context) {
                String bioText = '';

                // Get description directly from the profile data
                if (_profileData != null) {
                  if (_profileData is BrandProfile) {
                    bioText = (_profileData as BrandProfile).description;
                    debugPrint('Displaying brand bio: "$bioText"');
                  } else if (_profileData is InfluencerProfile) {
                    bioText = (_profileData as InfluencerProfile).description;
                    debugPrint('Displaying influencer bio: "$bioText"');
                  }
                } else {
                  debugPrint('Profile data is null, no bio to display');
                }

                return ProfileBioField(
                  label: 'About',
                  value: bioText,
                  isEditable: false,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Future<void> _fetchProfileData(String profileId, bool isBrand) async {
    if (_isLoadingProfile || profileId.isEmpty) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          isBrand ? 'brandProfile' : 'influencerProfile';

      debugPrint(
          'Fetching profile data from $profileCollectionName with ID: $profileId');

      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      debugPrint('Profile data fetched: ${profileRecord.data}');

      setState(() {
        if (isBrand) {
          _profileData = BrandProfile.fromRecord(profileRecord);
          debugPrint(
              'Brand profile description: ${(_profileData as BrandProfile).description}');
        } else {
          _profileData = InfluencerProfile.fromRecord(profileRecord);
          debugPrint(
              'Influencer profile description: ${(_profileData as InfluencerProfile).description}');
        }
        _isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      setState(() {
        _isLoadingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: ${e.toString()}')),
      );
    }
  }

  Future<void> _forceRefreshProfileData(String profileId, bool isBrand) async {
    if (_isLoadingProfile || profileId.isEmpty) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          isBrand ? 'brandProfile' : 'influencerProfile';

      debugPrint(
          'Refreshing profile data from $profileCollectionName with ID: $profileId');

      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      debugPrint('Profile data refreshed: ${profileRecord.data}');

      setState(() {
        if (isBrand) {
          _profileData = BrandProfile.fromRecord(profileRecord);
          debugPrint(
              'Brand profile description: ${(_profileData as BrandProfile).description}');
        } else {
          _profileData = InfluencerProfile.fromRecord(profileRecord);
          debugPrint(
              'Influencer profile description: ${(_profileData as InfluencerProfile).description}');
        }
        _isLoadingProfile = false;
      });
    } catch (e) {
      debugPrint('Error refreshing profile data: $e');
      setState(() {
        _isLoadingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error refreshing profile data: ${e.toString()}')),
      );
    }
  }
}
