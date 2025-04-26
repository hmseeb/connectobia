import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../theme/colors.dart';
import '../../application/user/user_bloc.dart';
import '../components/avatar_uploader.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _socialController = TextEditingController();

  String? _selectedIndustry;
  XFile? _profileImage;
  bool _formIsDirty = false;
  bool _formIsValid = false;

  dynamic _originalUser;
  dynamic _profileData;
  bool _isBrand = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded && _originalUser == null) {
            _loadUserData(state.user);
          }
        },
        builder: (context, state) {
          if ((state is UserLoading || state is UserInitial) &&
              _originalUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError && _originalUser == null) {
            return Center(child: Text(state.message));
          }

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildForm();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ShadButton(
            onPressed: _formIsDirty && _formIsValid ? _handleSave : null,
            child: const Text('Save Changes'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      _loadUserData(userState.user);
    } else {
      context.read<UserBloc>().add(FetchUser());
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_originalUser != null) ...[
              Center(
                child: _profileImage == null
                    ? AvatarUploader(
                        avatarUrl: _isBrand
                            ? (_originalUser as Brand).avatar
                            : (_originalUser as Influencer).avatar,
                        userId: _isBrand
                            ? (_originalUser as Brand).id
                            : (_originalUser as Influencer).id,
                        collectionId: _isBrand
                            ? (_originalUser as Brand).collectionId
                            : (_originalUser as Influencer).collectionId,
                        isEditable: true,
                        onAvatarSelected: _onAvatarSelected,
                      )
                    : TemporaryAvatarUploader(
                        image: _profileImage,
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 800,
                            maxHeight: 800,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            _onAvatarSelected(image);
                          }
                        },
                      ),
              ),
              const SizedBox(height: 24),
            ],

            // Personal Information Section
            _buildSection(
              title: 'Personal Information',
              children: [
                // Name field
                ShadCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isBrand ? 'Brand Name *' : 'Full Name *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? ShadColors.disabled
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShadInputFormField(
                        controller: _nameController,
                        placeholder:
                            Text(_isBrand ? 'Brand name' : 'Full name'),
                        prefix: _isBrand
                            ? const Icon(LucideIcons.building2)
                            : const Icon(LucideIcons.user),
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'This field is required';
                          }
                          return null;
                        },
                        onChanged: (_) => _updateFormState(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Email field
                ShadCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email *',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShadInputFormField(
                        controller: _emailController,
                        placeholder: const Text('Email address'),
                        prefix: const Icon(LucideIcons.mail),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        enabled: false,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Email cannot be changed. Please contact support if you need to update your email address.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!_isBrand) ...[
                  const SizedBox(height: 12),

                  // Username field
                  ShadCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Username *',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShadInputFormField(
                          controller: _usernameController,
                          placeholder: const Text('Username'),
                          prefix: const Icon(LucideIcons.atSign),
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'Username is required';
                            }
                            if (val.contains(' ')) {
                              return 'Username cannot contain spaces';
                            }
                            return null;
                          },
                          onChanged: (_) => _updateFormState(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Industry Dropdown
                _buildIndustryDropdown(),
              ],
            ),

            const SizedBox(height: 16),

            // Bio Section
            _buildSection(
              title: 'Bio & Social',
              children: [
                // Bio field
                ShadCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          hintText:
                              'Write something about yourself or your brand...',
                          border: OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        onChanged: (_) => _updateFormState(),
                      ),
                    ],
                  ),
                ),

                if (!_isBrand) ...[
                  const SizedBox(height: 12),

                  // Social media handle field
                  ShadCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Social Media Handle',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShadInputFormField(
                          controller: _socialController,
                          placeholder: const Text('Your social media handle'),
                          prefix: const Icon(LucideIcons.link),
                          onChanged: (_) => _updateFormState(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryDropdown() {
    return ShadCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Industry *',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? ShadColors.disabled
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ShadSelect<String>(
              initialValue: _selectedIndustry,
              placeholder: const Text('Select industry...'),
              options: IndustryList.industries.entries
                  .map(
                    (entry) => ShadOption(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              selectedOptionBuilder: (context, value) {
                return Text(IndustryList.industries[value] ?? value);
              },
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedIndustry = value;
                    _updateFormState();
                  });
                }
              },
            ),
          ),
          if (_formKey.currentState?.validate() == false &&
              _selectedIndustry == null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Text(
                'Please select an industry',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
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

  bool _checkIfFormIsDirty() {
    if (_originalUser == null) return false;

    if (_isBrand) {
      final Brand brand = _originalUser;
      if (_nameController.text != brand.brandName) return true;
      if (_selectedIndustry != brand.industry) return true;

      if (_profileData != null) {
        final BrandProfile profile = _profileData;
        if (_bioController.text != (profile.description)) return true;
      }
    } else {
      final Influencer influencer = _originalUser;
      if (_nameController.text != influencer.fullName) return true;
      if (_usernameController.text != influencer.username) return true;
      if (_selectedIndustry != influencer.industry) return true;
      if (_socialController.text != (influencer.socialHandle ?? ''))
        return true;

      if (_profileData != null) {
        final InfluencerProfile profile = _profileData;
        if (_bioController.text != (profile.description)) return true;
      }
    }

    // Always check profile image
    if (_profileImage != null) return true;

    return false;
  }

  // Helper method to find industry key by its display value
  String _findIndustryKeyByValue(String industryValue) {
    for (var entry in IndustryList.industries.entries) {
      if (entry.value == industryValue) {
        return entry.key;
      }
    }
    // Fallback to returning the value if no match is found
    return industryValue;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate() || !_formIsDirty) return;

    // Format description text - wrap it in <p> tags if it doesn't already have them
    String formattedDescription = _bioController.text;
    if (formattedDescription.isNotEmpty &&
        !formattedDescription.trim().startsWith('<p>') &&
        !formattedDescription.trim().endsWith('</p>')) {
      formattedDescription = '<p>$formattedDescription</p>';
    }

    // First update main user data
    context.read<UserBloc>().add(
          UpdateUser(
            fullName: _isBrand ? null : _nameController.text,
            brandName: _isBrand ? _nameController.text : null,
            username: _isBrand ? null : _usernameController.text,
            industry: _selectedIndustry,
            description:
                formattedDescription.isNotEmpty ? formattedDescription : null,
            socialHandle: (!_isBrand && _socialController.text.isNotEmpty)
                ? _socialController.text
                : null,
          ),
        );

    // Then handle avatar if updated
    if (_profileImage != null) {
      context.read<UserBloc>().add(
            UpdateUserAvatar(avatar: _profileImage),
          );
    }

    // Navigate back after save
    Navigator.pop(context);
  }

  Future<void> _loadUserData(dynamic user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      _originalUser = user;
      _isBrand = user is Brand;

      // Get the profile ID from the user
      final String profileId =
          _isBrand ? (user as Brand).profile : (user as Influencer).profile;

      // Fetch the profile data
      final pb = await PocketBaseSingleton.instance;
      final profileCollectionName =
          _isBrand ? 'brandProfile' : 'influencerProfile';
      final profileRecord =
          await pb.collection(profileCollectionName).getOne(profileId);

      setState(() {
        if (_isBrand) {
          final Brand brand = user;
          _profileData = BrandProfile.fromRecord(profileRecord);

          _nameController.text = brand.brandName;
          _emailController.text = brand.email;
          _usernameController.text = '';

          // Clean description text before showing in editor
          String description = (_profileData as BrandProfile).description;
          if (description.contains('<p>') || description.contains('</p>')) {
            description =
                description.replaceAll('<p>', '').replaceAll('</p>', '');
          }
          _bioController.text = description;

          _socialController.text = '';

          // Find the industry key by matching its value
          _selectedIndustry = _findIndustryKeyByValue(brand.industry);
        } else {
          final Influencer influencer = user;
          _profileData = InfluencerProfile.fromRecord(profileRecord);

          _nameController.text = influencer.fullName;
          _emailController.text = influencer.email;
          _usernameController.text = influencer.username;

          // Clean description text before showing in editor
          String description = (_profileData as InfluencerProfile).description;
          if (description.contains('<p>') || description.contains('</p>')) {
            description =
                description.replaceAll('<p>', '').replaceAll('</p>', '');
          }
          _bioController.text = description;

          _socialController.text = influencer.socialHandle ?? '';

          // Find the industry key by matching its value
          _selectedIndustry = _findIndustryKeyByValue(influencer.industry);
        }

        _isLoading = false;
      });

      // Setup listeners for dirty state
      _nameController.addListener(_updateFormState);
      _emailController.addListener(_updateFormState);
      _usernameController.addListener(_updateFormState);
      _bioController.addListener(_updateFormState);
      _socialController.addListener(_updateFormState);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data: ${e.toString()}')),
      );
    }
  }

  void _onAvatarSelected(XFile image) {
    setState(() {
      _profileImage = image;
      _formIsDirty = true;
    });
  }

  void _updateFormState() {
    if (!mounted) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    final isDirty = _checkIfFormIsDirty();

    setState(() {
      _formIsValid = isValid;
      _formIsDirty = isDirty;
    });
  }
}
