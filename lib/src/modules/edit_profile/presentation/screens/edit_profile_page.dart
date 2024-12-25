import 'package:connectobia/src/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/src/theme/buttons.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:connectobia/src/modules/edit_profile/presentation/Widget/shad_input_field.dart';
import 'package:connectobia/src/modules/edit_profile/presentation/Widget/user_profile_banner.dart';
import 'package:connectobia/src/modules/edit_profile/presentation/Widget/user_profile_avatar.dart';
import 'package:connectobia/src/shared/data/constants/industries.dart';

class EditUserProfileScreen extends StatefulWidget {
  final String name;
  final String industry;
  final String description;
  final String avatar;
  final String banner;

  const EditUserProfileScreen({
    super.key,
    required this.name,
    required this.industry,
    required this.description,
    required this.avatar,
    required this.banner,
  });

  @override
  State createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String? _selectedIndustry;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedIndustry = widget.industry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shadTheme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: shadTheme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: shadTheme.colorScheme.foreground,
          ),
        ),
        backgroundColor: shadTheme.colorScheme.background,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: shadTheme.colorScheme.foreground,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner Widget
                  UserProfileBanner(
                    banner: widget.banner,
                  ),
                  // Avatar Widget
                  Positioned(
                    bottom: -50,
                    left: 16,
                    child: UserProfileAvatar(
                      avatar: widget.avatar,
                      onEdit: () {
                        // Handle avatar edit logic
                      },
                    ),
                  ),
                  // Change Banner Button
                  Positioned(
                    bottom: 10,
                    right: 16,
                    child: SizedBox(
                      width: 150,
                      height: 50,
                      child: PrimaryButton(
                        text: 'Change Banner',
                        onPressed: () {
                          // Handle banner change logic
                        },
                        isLoading: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),

              // Fields Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    ShadInputField(
                      controller: _nameController,
                      placeholder: 'Enter your full name',
                    ),
                    const SizedBox(height: 16),

                    // Industry Field
                    CustomShadSelect(
                      items: IndustryList.industries,
                      placeholder: 'Select industry...',
                      initialValue: _selectedIndustry,
                      onSelected: (selectedIndustry) {
                        setState(() {
                          _selectedIndustry = selectedIndustry;
                        });
                      }, focusNode: FocusNode(),
                    ),
                    const SizedBox(height: 16),

                    // Bio/Description Field
                    ShadInputField(
                      controller: _descriptionController,
                      placeholder: 'Add a short bio about yourself',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: PrimaryButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
