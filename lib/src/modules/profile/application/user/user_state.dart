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

@immutable
abstract class UserState {}

class UserUpdating extends UserState {}
