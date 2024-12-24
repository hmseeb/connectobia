// edit_profile_state.dart

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileUpdated extends EditProfileState {
  final String message;

  EditProfileUpdated(this.message);
}

class EditProfileError extends EditProfileState {
  final String error;

  EditProfileError(this.error);
}
