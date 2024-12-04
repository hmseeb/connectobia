part of 'edit_profile_bloc.dart';

@immutable
sealed class EditProfileEvent {}

class EditProfileSave extends EditProfileEvent {
  final String title;
  final String description;

  EditProfileSave({
    required this.title,
    required this.description,
  });
}
