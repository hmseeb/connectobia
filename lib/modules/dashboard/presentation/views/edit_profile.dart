import 'package:connectobia/globals/constants/avatar.dart';
import 'package:connectobia/globals/constants/industries.dart';
import 'package:connectobia/globals/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/modules/auth/presentation/widgets/firstlast_name.dart';
import 'package:connectobia/modules/dashboard/application/edit_profile/edit_profile_bloc.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditProfileSheet extends StatefulWidget {
  final User user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class LabeledTextField extends StatelessWidget {
  final String text;
  const LabeledTextField(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ShaderToast {}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _brandNameController;
  late final editProfileBloc = BlocProvider.of<EditProfileBloc>(context);
  late String industry = widget.user.industry;
  final FocusNode industryFocusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSuccess) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Profile updated successfully'),
            ),
          );
          Navigator.pop(
              context,
              widget.user.copyWith(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                username: _usernameController.text,
                brandName: _brandNameController.text,
                industry: industry,
              ));
        } else if (state is EditProfileFailure) {
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Profile update failed'),
            ),
          );
        }
      },
      builder: (context, state) {
        final Brightness brightness = ShadTheme.of(context).brightness;
        return Scaffold(
          appBar: transparentAppBar('Edit Profile', context: context),
          body: Center(
            child: SizedBox(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        ShadAvatar(
                          UserAvatar.getAvatarUrl(
                              widget.user.firstName, widget.user.lastName),
                          placeholder: Text(
                              '${widget.user.firstName[0]} ${widget.user.lastName[0]}'), //Avatar
                          size: const Size(100, 100),
                        ),
                        // Edit Picture or banner
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Edit Avatar',
                            style: TextStyle(
                              color: ShadColors.kSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FirstLastName(
                    firstName: _firstNameController,
                    lastName: _lastNameController,
                    showLabels: true,
                  ),
                  const SizedBox(height: 8),
                  const LabeledTextField('Username'),
                  ShadInputFormField(
                    placeholder: const Text('Username'),
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 8),
                  widget.user.brandName.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LabeledTextField('Brand Name'),
                            ShadInputFormField(
                              placeholder: const Text('Brand Name'),
                              keyboardType: TextInputType.name,
                              controller: _brandNameController,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                  const LabeledTextField('Industry'),
                  SizedBox(
                    width: double.infinity,
                    child: CustomShadSelect(
                      items: IndustryList.industries,
                      placeholder:
                          IndustryFormatter.keyToValue(widget.user.industry),
                      onSelected: (value) {
                        industry = value;
                      },
                      focusNode: industryFocusNode,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      child: state is EditProfileLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: brightness == Brightness.light
                                    ? ShadColors.kBackground
                                    : ShadColors.kForeground,
                              ),
                            )
                          : const Text('Save'),
                      onPressed: () {
                        editProfileBloc.add(
                          EditProfileSave(
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            username: _usernameController.text,
                            brandName: _brandNameController.text,
                            industry: industry,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _brandNameController = TextEditingController(text: widget.user.brandName);
  }
}
