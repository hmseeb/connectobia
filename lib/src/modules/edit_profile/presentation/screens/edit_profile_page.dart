import 'dart:io';

import 'package:connectobia/src/modules/edit_profile/application/bloc/edit_profile_bloc.dart';
import 'package:connectobia/src/modules/edit_profile/application/bloc/edit_profile_event.dart';
import 'package:connectobia/src/modules/edit_profile/application/bloc/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  String _selectedIndustry = 'Technology'; // Example industry
  XFile? _avatar;
  XFile? _banner;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                onPressed: _submitForm(context),
              ),
            ],
          ),
          body: BlocConsumer<EditProfileBloc, EditProfileState>(
            listener: (context, state) {
              if (state is EditProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              } else if (state is EditProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              if (state is EditProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        ShadcnInput(
                          label: 'Full Name',
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Username
                        ShadcnInput(
                          label: 'Username',
                          controller: _usernameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Industry Dropdown
                        ShadcnDropdownMenu(
                          label: 'Industry',
                          value: _selectedIndustry,
                          items: ['Technology', 'Finance', 'Healthcare'],
                          onChanged: (newValue) {
                            setState(() {
                              _selectedIndustry = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Brand Name
                        ShadcnInput(
                          label: 'Brand Name',
                          controller: _brandNameController,
                        ),
                        const SizedBox(height: 16),

                        // Avatar Image Picker
                        ShadcnCard(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: _avatar == null
                                ? const Icon(Icons.camera_alt, size: 40)
                                : Image.file(
                                    File(_avatar!.path),
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Banner Image Picker
                        ShadcnCard(
                          child: GestureDetector(
                            onTap: _pickBanner,
                            child: _banner == null
                                ? Container(
                                    height: 150,
                                    color: Colors.grey[200],
                                    child:
                                        const Icon(Icons.camera_alt, size: 40),
                                  )
                                : Image.file(
                                    File(_banner!.path),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Function to pick an avatar image
  Future<void> _pickAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = pickedFile;
      });
    }
  }

  // Function to pick a banner image
  Future<void> _pickBanner() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _banner = pickedFile;
      });
    }
  }

  // Function to submit the form
  _submitForm(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fullNameController.text;
      final username = _usernameController.text;
      final industry = _selectedIndustry;
      final brandName = _brandNameController.text;

      context.read<EditProfileBloc>().add(UpdateProfileEvent(
            fullName: fullName,
            username: username,
            industry: industry,
            brandName: brandName,
            avatar: _avatar,
            banner: _banner,
          ));
    }
  }
}

class ShadcnCard extends StatelessWidget {
  final Widget child;

  const ShadcnCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}

class ShadcnDropdownMenu extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const ShadcnDropdownMenu({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}

class ShadcnInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const ShadcnInput({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }
}
