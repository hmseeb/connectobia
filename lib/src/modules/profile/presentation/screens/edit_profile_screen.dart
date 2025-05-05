import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../modules/auth/data/repositories/auth_repo.dart';
import '../../../../services/storage/pb.dart';
import '../../../../shared/data/constants/industries.dart';
import '../../../../shared/domain/models/brand.dart';
import '../../../../shared/domain/models/brand_profile.dart';
import '../../../../shared/domain/models/influencer.dart';
import '../../../../shared/domain/models/influencer_profile.dart';
import '../../../../theme/colors.dart';
import '../../application/user/user_bloc.dart';
import '../widgets/avatar_uploader.dart';
import '../widgets/banner_uploader.dart';
import '../widgets/change_email_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  final dynamic user;

  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedIndustry;
  XFile? _profileImage;
  XFile? _bannerImage;
  bool _formIsDirty = false;
  bool _formIsValid = false;

  dynamic _originalUser;
  dynamic _profileData;
  bool _isBrand = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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
            } else if (state is UserUpdating) {
              // Keep loading indicator visible while updates are in progress
              if (!_isLoading) {
                setState(() {
                  _isLoading = true;
                });
              }
            } else if (state is UserLoaded && _originalUser != null) {
              // Update was successful - all updates have completed
              setState(() {
                _isLoading = false;
                _originalUser = state
                    .user; // Update the local reference to match the updated state
              });

              // Check if this is an update completion (forceRefresh flag is true)
              if ((state).forceRefresh) {
                debugPrint(
                    'Profile update completed successfully, force refresh detected');

                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Slight delay to ensure snackbar is visible before navigation
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    // Pass fresh data back to the profile screen
                    Navigator.pop(context, _originalUser);
                  }
                });
              }
            } else if (state is UserError) {
              // Update failed with error
              setState(() {
                _isLoading = false;
              });
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Failed to update profile: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ShadButton(
              onPressed: _formIsDirty && _formIsValid ? _handleSave : null,
              child: const Text('Save Changes'),
            ),
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // More robust initialization with multiple loading attempts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_originalUser != null) ...[
              // Stack for banner and profile image with Twitter-style overlay
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner image uploader
                  _bannerImage == null
                      ? BannerUploader(
                          bannerUrl: _isBrand
                              ? (_originalUser as Brand).banner
                              : (_originalUser as Influencer).banner,
                          userId: _isBrand
                              ? (_originalUser as Brand).id
                              : (_originalUser as Influencer).id,
                          collectionId: _isBrand
                              ? (_originalUser as Brand).collectionId
                              : (_originalUser as Influencer).collectionId,
                          isEditable: true,
                          onBannerSelected: _onBannerSelected,
                          height: 200,
                        )
                      : TemporaryBannerUploader(
                          image: _bannerImage,
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              maxWidth: 1200,
                              maxHeight: 800,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              _onBannerSelected(image);
                            }
                          },
                          height: 200,
                        ),

                  // Profile image uploader (avatar) positioned to overlay banner
                  Positioned(
                    bottom: -50,
                    left: 16,
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
                            size: 100,
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
                            size: 100,
                          ),
                  ),
                ],
              ),

              // Add padding to account for overlapping avatar
              SizedBox(height: 60),
            ],

            // Personal Information Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSection(
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
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

                  // Email field with Change Email button
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ShadInputFormField(
                                controller: _emailController,
                                placeholder: const Text('Email address'),
                                prefix: const Icon(LucideIcons.mail),
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                                enabled: false,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: _showEmailChangeDialog,
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Email cannot be changed directly. Click the Change button to request a change.',
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

                    // Username field (now non-editable like email)
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
                            readOnly: true,
                            enabled: false,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Username cannot be changed. Please contact support if you need to update your username.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
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
            ),

            const SizedBox(height: 16),

            // Bio Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSection(
                title: 'Bio',
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
                ],
              ),
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

    // Check if banner or profile image has changed
    if (_bannerImage != null || _profileImage != null) return true;

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
      if (_selectedIndustry != influencer.industry) return true;

      if (_profileData != null) {
        final InfluencerProfile profile = _profileData;
        if (_bioController.text != (profile.description)) return true;
      }
    }

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

    setState(() {
      _isLoading = true;
    });

    // Check if we have an original user loaded
    if (_originalUser == null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot update profile: no user data loaded. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });

      // Try reinitializing the user data as a recovery mechanism
      _initializeUserData();
      return;
    }

    // Verify authentication before proceeding
    _verifyAuthAndProceedWithUpdate();
  }

  // Comprehensive user data initialization method
  Future<void> _initializeUserData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Try multiple methods to ensure we have user data

      // Method 1: Use user from widget prop if provided
      if (widget.user != null) {
        debugPrint('Loading user data from widget prop');
        await _loadUserData(widget.user);
        return;
      }

      // Method 2: Check if UserBloc already has loaded state
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoaded) {
        debugPrint('Loading user data from UserBloc state');
        await _loadUserData(userState.user);
        return;
      }

      // Method 3: Request fresh user data using AuthRepository directly
      try {
        debugPrint('Attempting to load user directly from AuthRepository');
        final user = await AuthRepository.getUser();

        if (user != null) {
          debugPrint('Successfully loaded user from AuthRepository');
          await _loadUserData(user);
          // Also update the UserBloc to maintain state consistency
          if (mounted) {
            context.read<UserBloc>().add(UpdateUserState(user));
          }
          return;
        }
      } catch (e) {
        debugPrint('Error loading user from AuthRepository: $e');
      }

      // Method 4: As a last resort, request user through UserBloc
      debugPrint('Requesting user through UserBloc.FetchUser event');
      if (mounted) {
        context.read<UserBloc>().add(FetchUser());
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error initializing user data: $e');
      setState(() {
        _isLoading = false;
      });

      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Error initializing profile editor: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadUserData(dynamic user) async {
    if (!mounted) return;

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

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _scaffoldMessengerKey.currentState?.showSnackBar(
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

  void _onBannerSelected(XFile image) {
    setState(() {
      _bannerImage = image;
      _formIsDirty = true;
    });
  }

  // Add this method to show email change dialog
  void _showEmailChangeDialog() {
    try {
      // Get the current email value before opening sheet
      final String currentEmail = _emailController.text.trim();
      final userBloc = BlocProvider.of<UserBloc>(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: false, // Use closest navigator instead of root
        isDismissible: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: BlocProvider.value(
                  value: userBloc,
                  child: ChangeEmailSheet(
                    side: ShadSheetSide.bottom,
                    currentEmail: currentEmail,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing email change dialog: $e');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
            content:
                Text('Error opening email change dialog: ${e.toString()}')),
      );
    }
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

  // New method to verify authentication and proceed with update
  Future<void> _verifyAuthAndProceedWithUpdate() async {
    try {
      // Ensure loading state is visible
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      // Check authentication status
      final pb = await PocketBaseSingleton.instance;
      if (!pb.authStore.isValid) {
        debugPrint('Cannot update profile: user is not authenticated');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content:
                Text('You are not logged in. Please log in and try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Double-check user ID
      if (_originalUser == null) {
        debugPrint('Cannot update profile: original user object is null');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Cannot access user data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });

        // Try to re-initialize user data as recovery mechanism
        await _initializeUserData();
        return;
      }

      final String userId = _isBrand
          ? (_originalUser as Brand).id
          : (_originalUser as Influencer).id;

      if (userId.isEmpty) {
        debugPrint('Cannot update profile: user ID is empty');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('User ID is missing. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      debugPrint(
          'Authentication verified, proceeding with profile update for user ID: $userId');

      // More defensive approach for formatting description
      String formattedDescription = _bioController.text.trim();
      try {
        if (formattedDescription.isNotEmpty) {
          if (!formattedDescription.contains('<p>') &&
              !formattedDescription.contains('</p>')) {
            formattedDescription = '<p>$formattedDescription</p>';
          }
        } else {
          formattedDescription = '<p></p>';
        }
      } catch (e) {
        debugPrint('Error formatting description: $e');
        formattedDescription = '<p>${_bioController.text}</p>';
      }

      // First ensure the user bloc has the most up-to-date user state
      final userBloc = context.read<UserBloc>();

      // First, explicitly verify we have a valid user state in the bloc
      final currentBlocState = userBloc.state;
      if (currentBlocState is! UserLoaded &&
          currentBlocState is! UserProfileLoaded) {
        debugPrint(
            'UserBloc state is not loaded, forcing state update before proceeding');
        // Force a state update with our local user data to ensure the bloc has valid user data
        userBloc.add(UpdateUserState(_originalUser));

        // Give time for the state to update before proceeding
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify the update was successful
        final updatedBlocState = userBloc.state;
        if (updatedBlocState is! UserLoaded &&
            updatedBlocState is! UserProfileLoaded) {
          debugPrint(
              'Failed to update UserBloc state. Attempting fallback method.');

          // Try direct fetch as fallback
          try {
            final freshUser = await AuthRepository.getUser();
            if (freshUser != null) {
              debugPrint('Successfully fetched fresh user data');
              userBloc.add(UpdateUserState(freshUser));
              await Future.delayed(const Duration(milliseconds: 500));
            } else {
              throw Exception('Could not fetch user data');
            }
          } catch (e) {
            debugPrint('Failed to fetch user data: $e');
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Failed to update user state: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }

      // Create a custom event that includes the user ID explicitly
      try {
        debugPrint(
            'Updating profile for ${_isBrand ? 'Brand' : 'Influencer'}: ${_isBrand ? (_originalUser as Brand).brandName : (_originalUser as Influencer).fullName}');

        // Wait a short time to ensure state is updated
        await Future.delayed(const Duration(milliseconds: 300));

        // Make sure we're still in loading state
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        // Make all updates sequentially with explicit types and null handling
        userBloc.add(
          UpdateUser(
            fullName: _isBrand ? null : _nameController.text,
            brandName: _isBrand ? _nameController.text : null,
            username: null,
            industry: _selectedIndustry,
            description: formattedDescription,
          ),
        );

        // Wait between requests to avoid race conditions
        await Future.delayed(const Duration(milliseconds: 500));

        // Handle media uploads individually to avoid overwhelming the API
        if (_profileImage != null) {
          // Ensure we're still in loading state
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          userBloc.add(UpdateUserAvatar(avatar: _profileImage));
          await Future.delayed(const Duration(milliseconds: 500));
        }

        if (_bannerImage != null) {
          // Ensure we're still in loading state
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          userBloc.add(UpdateUserBanner(banner: _bannerImage));
        }

        // Note: we don't set _isLoading to false here because the BlocConsumer
        // will handle this when state transitions to UserLoaded
      } catch (e) {
        debugPrint('Error during profile update: $e');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error verifying authentication: $e');
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Authentication error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}
