part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

class EditProfileSave extends EditProfileEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String industry;
  final String brandName;

  EditProfileSave({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.industry,
    required this.brandName,
  });
}
