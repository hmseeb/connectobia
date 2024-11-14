part of 'auth_bloc.dart';

final class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);
}

final class AuthFailed extends AuthState {
  final String message;

  AuthFailed(this.message);
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

@immutable
sealed class AuthState {}

final class Unauthenticated extends AuthState {}

final class Unverified extends AuthState {
  final String email;

  Unverified(this.email);
}
