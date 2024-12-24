// edit_profile_event.dart

import 'package:image_picker/image_picker.dart';

abstract class EditProfileEvent {}

class UpdateProfileEvent extends EditProfileEvent {
  final String fullName;
  final String username;
  final String industry;
  final String brandName;
  final XFile? avatar;
  final XFile? banner;

  UpdateProfileEvent({
    required this.fullName,
    required this.username,
    required this.industry,
    required this.brandName,
    this.avatar,
    this.banner,
  });
}
