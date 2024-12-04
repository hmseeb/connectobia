import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectobia/common/constants/avatar.dart';
import 'package:connectobia/common/constants/industries.dart';
import 'package:connectobia/common/widgets/transparent_appbar.dart';
import 'package:connectobia/modules/auth/domain/model/user.dart';
import 'package:connectobia/modules/auth/presentation/widgets/custom_shad_select.dart';
import 'package:connectobia/modules/auth/presentation/widgets/firstlast_name.dart';
import 'package:connectobia/modules/dashboard/application/profile_settings/profile_settings.dart';
import 'package:connectobia/modules/dashboard/data/user_repo.dart';
import 'package:connectobia/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

class UserSettingSheet extends StatefulWidget {
  final User user;

  const UserSettingSheet({super.key, required this.user});

  @override
  State<UserSettingSheet> createState() => _UserSettingSheetState();
}

class _UserSettingSheetState extends State<UserSettingSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _brandNameController;
  late final editProfileBloc = BlocProvider.of<ProfileSettingsBloc>(context);
  late String industry = widget.user.industry;
  final FocusNode industryFocusNode = FocusNode();
  final ImagePicker picker = ImagePicker();
  late final Brightness brightness = ShadTheme.of(context).brightness;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSettingsBloc, ProfileSettingsState>(
      listener: (context, state) {
        if (state is ProfileSettingsSuccess) {
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
        } else if (state is ProfileSettingsFailure) {
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
          appBar: transparentAppBar('User Settings', context: context),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner image
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: widget.user.banner.isEmpty
                              ? Avatar.getBannerPlaceholder()
                              : Avatar.getUserImage(
                                  id: widget.user.id,
                                  image: widget.user.banner,
                                ),
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () async {
                            // show cuperino action sheet
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    onPressed: () async {
                                      final XFile? bannerImage =
                                          await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 50,
                                      );
                                      if (bannerImage != null) {
                                        await UserRepo.updateUserImage(
                                          image: bannerImage,
                                          username: widget.user.username,
                                          isAvatar: false,
                                        );
                                      }
                                    },
                                    child: const Text('Choose from Gallery'),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () async {
                                      final XFile? bannerImage =
                                          await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 50,
                                      );
                                      if (bannerImage != null) {
                                        await UserRepo.updateUserImage(
                                          image: bannerImage,
                                          username: widget.user.username,
                                          isAvatar: false,
                                        );
                                      }
                                    },
                                    child: const Text('Take Photo'),
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                          color: brightness == Brightness.light
                              ? ShadColors.dark
                              : ShadColors.light,
                        ),
                      ),
                      // Avatar image with camera icon
                      Positioned(
                        bottom: 0,
                        left: 10,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            // show cuperino action sheet
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                    onPressed: () async {
                                      final XFile? avatarImage =
                                          await picker.pickImage(
                                        source: ImageSource.gallery,
                                        imageQuality: 50,
                                      );
                                      if (avatarImage != null) {
                                        await UserRepo.updateUserImage(
                                          image: avatarImage,
                                          username: widget.user.username,
                                          isAvatar: true,
                                        );
                                      }
                                    },
                                    child: const Text('Choose from Gallery'),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () async {
                                      final XFile? avatarImage =
                                          await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 50,
                                      );
                                      if (avatarImage != null) {
                                        await UserRepo.updateUserImage(
                                          image: avatarImage,
                                          username: widget.user.username,
                                          isAvatar: true,
                                        );
                                      }
                                    },
                                    child: const Text('Take Photo'),
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(
                                    widget.user.avatar.isEmpty
                                        ? Avatar.getAvatarPlaceholder(
                                            widget.user.firstName,
                                            widget.user.lastName)
                                        : Avatar.getUserImage(
                                            id: widget.user.id,
                                            image: widget.user.avatar,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          brightness == Brightness.light
                                              ? ShadColors.light
                                              : ShadColors.dark,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: brightness == Brightness.light
                                            ? ShadColors.dark
                                            : ShadColors.light,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            placeholder: IndustryFormatter.keyToValue(
                                widget.user.industry),
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
                            onPressed: () {
                              editProfileBloc.add(
                                ProfileSettingsSave(
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                  username: _usernameController.text,
                                  brandName: _brandNameController.text,
                                  industry: industry,
                                ),
                              );
                            },
                            child: state is ProfileSettingsLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: brightness == Brightness.light
                                        ? ShadColors.dark
                                        : ShadColors.light,
                                  ))
                                : const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
