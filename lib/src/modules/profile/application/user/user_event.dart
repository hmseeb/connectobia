part of 'user_bloc.dart';

class FetchUser extends UserEvent {}

class UpdateUser extends UserEvent {
  final String? fullName;
  final String? username;
  final String? email;
  final String? industry;
  final String? description;
  final String? socialHandle;
  final String? brandName;

  UpdateUser({
    this.fullName,
    this.username,
    this.email,
    this.industry,
    this.description,
    this.socialHandle,
    this.brandName,
  });
}

class UpdateUserAvatar extends UserEvent {
  final XFile? avatar;

  UpdateUserAvatar({required this.avatar});
}

class UpdateUserBanner extends UserEvent {
  final XFile? banner;

  UpdateUserBanner({required this.banner});
}

@immutable
abstract class UserEvent {}
