part of 'profile_settings.dart';

final class ProfileSettingsError extends ProfileSettingsState {
  final String message;
  ProfileSettingsError(this.message);
}

final class ProfileSettingsFailure extends ProfileSettingsState {
  final String message;
  ProfileSettingsFailure(this.message);
}

final class ProfileSettingsInitial extends ProfileSettingsState {}

final class ProfileSettingsLoading extends ProfileSettingsState {}

@immutable
sealed class ProfileSettingsState {}

final class ProfileSettingsSuccess extends ProfileSettingsState {}
