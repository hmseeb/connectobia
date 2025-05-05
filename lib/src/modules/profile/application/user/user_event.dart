part of 'user_bloc.dart';

class FetchUser extends UserEvent {}

class FetchUserProfile extends UserEvent {
  final String profileId;
  final bool isBrand;

  FetchUserProfile({required this.profileId, required this.isBrand});
}

class FetchUserReviews extends UserEvent {
  final String userId;
  final bool isBrand;

  FetchUserReviews({required this.userId, required this.isBrand});
}

class RequestEmailChange extends UserEvent {
  final String newEmail;

  RequestEmailChange({required this.newEmail});
}

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

class UpdateUserState extends UserEvent {
  final dynamic user;

  UpdateUserState(this.user);
}

@immutable
abstract class UserEvent {}
