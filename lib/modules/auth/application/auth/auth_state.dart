part of 'auth_bloc.dart';

final class AuthFailed extends AuthState {
  final String message;

  AuthFailed(this.message);
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

@immutable
sealed class AuthState {}

final class BrandAuthenticated extends AuthState {
  final Brand user;

  BrandAuthenticated(this.user);
}

final class InfluencerAuthenticated extends AuthState {
  final Influencer user;

  InfluencerAuthenticated(this.user);
}

final class Unauthenticated extends AuthState {}

final class Unverified extends AuthState {
  final String email;

  Unverified(this.email);
}
