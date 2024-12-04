part of 'profile_settings.dart';

@immutable
sealed class ProfileSettingsEvent {}

class ProfileSettingsSave extends ProfileSettingsEvent {
  final String firstName;
  final String lastName;
  final String username;
  final String industry;
  final String brandName;

  ProfileSettingsSave({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.industry,
    required this.brandName,
  });
}
