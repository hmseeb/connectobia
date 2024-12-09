import 'package:connectobia/modules/dashboard/brand/application/edit_profile/edit_profile_bloc.dart';
import 'package:connectobia/modules/dashboard/brand/presentation/views/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditInfluencerProfile extends StatefulWidget {
  const EditInfluencerProfile({super.key});

  @override
  State<EditInfluencerProfile> createState() => EditInfluencerProfileState();
}

class EditInfluencerProfileState extends State<EditInfluencerProfile> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            elevation: 0,
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LabeledTextField('Title'),
                        ShadInput(
                          controller: _titleController,
                        ),
                        const SizedBox(height: 16),
                        const LabeledTextField('Description'),
                        ShadInputFormField(
                          keyboardType: TextInputType.multiline,
                          controller: _descriptionController,
                          maxLines: 5,
                          maxLength: 100,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ShadButton(
                            onPressed: () {
                              BlocProvider.of<EditProfileBloc>(context).add(
                                EditProfileSave(
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                ),
                              );
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }
}
