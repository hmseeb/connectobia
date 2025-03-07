import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/data/constants/screens.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: transparentAppBar('Profile', context: context),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else if (state is UserLoaded) {
            return _buildProfileContent(context, state.user);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, editProfileScreen);
        },
        backgroundColor: ShadColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
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
    String bio = '';

    if (isBrand) {
      final Brand brand = user;
      avatar = brand.avatar;
      name = brand.brandName;
      email = brand.email;
      username = '';
      collectionId = brand.collectionId;
      userId = brand.id;
      industry = brand.industry;
      bio = '';
    } else {
      final Influencer influencer = user;
      avatar = influencer.avatar;
      name = influencer.fullName;
      email = influencer.email;
      username = influencer.username;
      collectionId = influencer.collectionId;
      userId = influencer.id;
      industry = influencer.industry;
      bio = '';
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
              ProfileBioField(
                label: 'About',
                value: bio,
                isEditable: false,
              ),
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
}
