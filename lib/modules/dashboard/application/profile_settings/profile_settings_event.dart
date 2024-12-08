part of 'profile_settings.dart';

@immutable
sealed class ProfileSettingsEvent {}

class ProfileSettingsSave extends ProfileSettingsEvent {
  final String fullName;
  final String username;
  final String industry;
  final String brandName;

  ProfileSettingsSave({
    required this.fullName,
    required this.username,
    required this.industry,
    required this.brandName,
  });
}
