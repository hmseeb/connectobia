import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/screens.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../shared/presentation/widgets/transparent_app_bar.dart';
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
          if (state is UserLoaded && _profileData == null) {
            setState(() {
              _isLoadingProfile = false;
            });
          } else if (state is UserProfileLoaded) {
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
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  @override
  void dispose() {
    _profileData = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        context.read<UserBloc>().add(FetchUserProfile(
              profileId: profileId,
              isBrand: true,
            ));
      } else if (_profileData is BrandProfile) {
        description = (_profileData as BrandProfile).description;
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
        context.read<UserBloc>().add(FetchUserProfile(
              profileId: profileId,
              isBrand: false,
            ));
      } else if (_profileData is InfluencerProfile) {
        description = (_profileData as InfluencerProfile).description;
      }
    }

    // Force manual fetch of profile data if not already loading
    if (!_isLoadingProfile && description.isEmpty && profileId.isNotEmpty) {
      Future.microtask(() => _refreshProfileData(profileId, isBrand));
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
          const SizedBox(height: 32),

          // Individual profile fields
          ProfileField(
            label: isBrand ? 'Brand Name' : 'Full Name',
            value: name,
            icon: Icons.business,
            isEditable: false,
          ),
          const SizedBox(height: 16),

          ProfileField(
            label: 'Email',
            value: email,
            icon: Icons.email,
            isEditable: false,
          ),
          const SizedBox(height: 16),

          if (!isBrand) ...[
            ProfileField(
              label: 'Username',
              value: username,
              icon: Icons.alternate_email,
              isEditable: false,
            ),
            const SizedBox(height: 16),
          ],

          ProfileField(
            label: 'Industry',
            value: industry,
            icon: Icons.category,
            isEditable: false,
          ),
          const SizedBox(height: 24),

          // Bio field
          Builder(builder: (context) {
            String bioText = '';

            // Get description directly from the profile data
            if (_profileData != null) {
              if (_profileData is BrandProfile) {
                bioText = (_profileData as BrandProfile).description;
              } else if (_profileData is InfluencerProfile) {
                bioText = (_profileData as InfluencerProfile).description;
              }
            }

            return ProfileBioField(
              label: 'About',
              value: bioText,
              isEditable: false,
            );
          }),
        ],
      ),
    );
  }

  Future<void> _refreshProfileData(String profileId, bool isBrand) async {
    if (_isLoadingProfile || profileId.isEmpty) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          isBrand ? 'brandProfile' : 'influencerProfile';

      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      setState(() {
        if (isBrand) {
          _profileData = BrandProfile.fromRecord(profileRecord);
        } else {
          _profileData = InfluencerProfile.fromRecord(profileRecord);
        }
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: ${e.toString()}')),
      );
    }
  }
}
