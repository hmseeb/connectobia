part of 'edit_profile_bloc.dart';

final class EditProfileError extends EditProfileState {
  final String message;
  EditProfileError(this.message);
}

final class EditProfileFailure extends EditProfileState {
  final String message;
  EditProfileFailure(this.message);
}

final class EditProfileInitial extends EditProfileState {}

final class EditProfileLoading extends EditProfileState {}

@immutable
sealed class EditProfileState {}

final class EditProfileSuccess extends EditProfileState {}
