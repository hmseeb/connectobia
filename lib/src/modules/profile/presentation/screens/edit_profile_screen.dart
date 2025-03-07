import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../theme/colors.dart';
import '../../application/user/user_bloc.dart';
import '../components/avatar_uploader.dart';
import '../components/profile_field.dart';

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
  bool _isBrand = false;

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
            _populateFields(state.user);
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
    _loadUserData();
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
                ProfileField(
                  label: _isBrand ? 'Brand Name' : 'Full Name',
                  value: '',
                  icon: _isBrand ? Icons.business : Icons.person,
                  isEditable: true,
                  controller: _nameController,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  isRequired: true,
                  onChanged: (_) => _updateFormState(),
                ),

                ProfileField(
                  label: 'Email',
                  value: '',
                  icon: Icons.email,
                  isEditable: true,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(val)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  isRequired: true,
                  onChanged: (_) => _updateFormState(),
                ),

                if (!_isBrand)
                  ProfileField(
                    label: 'Username',
                    value: '',
                    icon: Icons.alternate_email,
                    isEditable: true,
                    controller: _usernameController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Username is required';
                      }
                      if (val.contains(' ')) {
                        return 'Username cannot contain spaces';
                      }
                      return null;
                    },
                    isRequired: true,
                    onChanged: (_) => _updateFormState(),
                  ),

                // Industry Dropdown
                _buildIndustryDropdown(),
              ],
            ),

            const SizedBox(height: 16),

            // Bio Section
            _buildSection(
              title: 'Bio & Social',
              children: [
                ProfileBioField(
                  label: 'Bio',
                  value: '',
                  isEditable: true,
                  controller: _bioController,
                  onChanged: (_) => _updateFormState(),
                ),
                ProfileField(
                  label: 'Social Media Handle',
                  value: '',
                  icon: Icons.link,
                  isEditable: true,
                  controller: _socialController,
                  onChanged: (_) => _updateFormState(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            onChanged: (value) {
              setState(() {
                _selectedIndustry = value;
                _updateFormState();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an industry';
              }
              return null;
            },
            items: IndustryList.industries.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      if (_emailController.text != brand.email) return true;
      if (_selectedIndustry != brand.industry) return true;
    } else {
      final Influencer influencer = _originalUser;
      if (_nameController.text != influencer.fullName) return true;
      if (_emailController.text != influencer.email) return true;
      if (_usernameController.text != influencer.username) return true;
      if (_selectedIndustry != influencer.industry) return true;
    }

    // Always check these fields
    if (_bioController.text.isNotEmpty) return true;
    if (_socialController.text.isNotEmpty) return true;
    if (_profileImage != null) return true;

    return false;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate() || !_formIsDirty) return;

    // First update main user data
    context.read<UserBloc>().add(
          UpdateUser(
            fullName: _isBrand ? null : _nameController.text,
            brandName: _isBrand ? _nameController.text : null,
            email: _emailController.text,
            username: _isBrand ? null : _usernameController.text,
            industry: _selectedIndustry,
            bio: _bioController.text.isNotEmpty ? _bioController.text : null,
            socialHandle: _socialController.text.isNotEmpty
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

  void _loadUserData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      _populateFields(userState.user);
    } else {
      context.read<UserBloc>().add(FetchUser());
    }
  }

  void _onAvatarSelected(XFile image) {
    setState(() {
      _profileImage = image;
      _formIsDirty = true;
    });
  }

  void _populateFields(dynamic user) {
    setState(() {
      _originalUser = user;
      _isBrand = user is Brand;

      if (_isBrand) {
        final Brand brand = user;
        _nameController.text = brand.brandName;
        _emailController.text = brand.email;
        _usernameController.text = '';
        _bioController.text = ''; // Assuming bio field exists
        _socialController.text =
            ''; // Assuming social media handle field exists
        _selectedIndustry = brand.industry;
      } else {
        final Influencer influencer = user;
        _nameController.text = influencer.fullName;
        _emailController.text = influencer.email;
        _usernameController.text = influencer.username;
        _bioController.text = ''; // Assuming bio field exists
        _socialController.text =
            ''; // Assuming social media handle field exists
        _selectedIndustry = influencer.industry;
      }
    });

    // Setup listeners for dirty state
    _nameController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);
    _usernameController.addListener(_updateFormState);
    _bioController.addListener(_updateFormState);
    _socialController.addListener(_updateFormState);
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
