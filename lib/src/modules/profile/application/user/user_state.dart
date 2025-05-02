part of 'user_bloc.dart';

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class UserInitial extends UserState {}

class UserLoaded extends UserState {
  final dynamic user;

  UserLoaded(this.user);
}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final dynamic user;
  final dynamic profileData;

  UserProfileLoaded({required this.user, required this.profileData});
}

class UserReviewsLoaded extends UserState {
  final dynamic user;
  final dynamic profileData;
  final List<dynamic> reviews;
  final double averageRating;

  UserReviewsLoaded({
    required this.user,
    required this.profileData,
    required this.reviews,
    this.averageRating = 0.0,
  });
}

@immutable
abstract class UserState {}

class UserUpdating extends UserState {}
