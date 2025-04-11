import 'dart:io';

import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:connectobia/src/theme/buttons.dart';
import 'package:connectobia/src/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: "John Doe");
  final TextEditingController _emailController = TextEditingController(text: "john.doe@example.com");
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _socialController = TextEditingController();
  String? _selectedIndustry;
  XFile? _profileImage;
  XFile? _bannerImage;

  Future<void> _pickImage(bool isBanner) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBanner) {
          _bannerImage = pickedFile;
        } else {
          _profileImage = pickedFile;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: transparentAppBar('Edit Profile', context: context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image
                  _ProfileBanner(
                    image: _bannerImage,
                    onPressed: () => _pickImage(true),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Profile Picture
                  _ProfileImageSection(
                    image: _profileImage,
                    onPressed: () => _pickImage(false),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  // Personal Info Section
                  _SectionHeader(title: 'Profile Information'),
                  const SizedBox(height: 16),
                  _ProfileInputField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _ProfileInputField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _IndustryDropdown(
                    selectedIndustry: _selectedIndustry,
                    onChanged: (value) => setState(() => _selectedIndustry = value),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),

                  // Bio & Social Section
                  _SectionHeader(title: 'Bio & Social Media'),
                  const SizedBox(height: 16),
                  _BioInputField(
                    controller: _bioController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _ProfileInputField(
                    controller: _socialController,
                    label: 'Social Media Handle',
                    icon: Icons.link,
                    isDark: isDark,
                    prefixText: '@',
                  ),
                ],
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: 'Save Changes',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widgets
class _ProfileBanner extends StatelessWidget {
  final XFile? image;
  final VoidCallback onPressed;
  final bool isDark;

  const _ProfileBanner({
    required this.image,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? ShadColors.darkForeground : ShadColors.lightForeground,
          borderRadius: BorderRadius.circular(12),
          image: image != null
              ? DecorationImage(
                  image: FileImage(File(image!.path)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Center(
                child: Icon(
                  Icons.camera_alt,
                  color: isDark ? ShadColors.light : ShadColors.dark,
                  size: 32,
                ),
              )
            : null,
      ),
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  final XFile? image;
  final VoidCallback onPressed;
  final bool isDark;

  const _ProfileImageSection({
    required this.image,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ShadColors.primary,
                width: 2,
              ),
              image: image != null
                  ? DecorationImage(
                      image: FileImage(File(image!.path)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? Icon(
                    Icons.person,
                    size: 48,
                    color: isDark ? ShadColors.light : ShadColors.dark,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ShadColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  size: 20,
                  color: ShadColors.light,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ShadTheme.of(context).colorScheme.foreground,
        fontFamily: GoogleFonts.varelaRound().fontFamily,
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final String? prefixText;

  const _ProfileInputField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? ShadColors.light : ShadColors.dark,
        fontFamily: GoogleFonts.varelaRound().fontFamily,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
      ),
    );
  }
}

class _IndustryDropdown extends StatelessWidget {
  final String? selectedIndustry;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const _IndustryDropdown({
    required this.selectedIndustry,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedIndustry,
      hint: Text('Select Industry'),
      items: const ['Technology', 'Finance', 'Healthcare', 'Education', 'Marketing']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      dropdownColor: isDark ? ShadColors.dark : ShadColors.light,
      style: TextStyle(
        color: isDark ? ShadColors.light : ShadColors.dark,
        fontFamily: GoogleFonts.varelaRound().fontFamily,
      ),
    );
  }
}

class _BioInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const _BioInputField({
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: TextStyle(
        color: isDark ? ShadColors.light : ShadColors.dark,
        fontFamily: GoogleFonts.varelaRound().fontFamily,
      ),
      decoration: InputDecoration(
        labelText: 'Bio',
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ShadColors.primary),
        ),
        hintText: 'Tell us about yourself...',
      ),
    );
  }
}