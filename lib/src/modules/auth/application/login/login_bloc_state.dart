part of 'login_bloc.dart';

final class BrandLoginSuccess extends LoginBlocState {
  final Brand user;
  BrandLoginSuccess(this.user);
}

final class InfluencerLoginSuccess extends LoginBlocState {
  final Influencer user;
  InfluencerLoginSuccess(this.user);
}

final class InstagramFailure extends LoginBlocState {
  final String error;

  InstagramFailure(this.error);
}

final class InstagramLoading extends LoginBlocState {}

final class LoginBlocInitial extends LoginBlocState {}

@immutable
sealed class LoginBlocState {}

final class LoginFailure extends LoginBlocState {
  final String error;

  LoginFailure(this.error);
}

final class LoginLoading extends LoginBlocState {}

final class LoginUnverified extends LoginBlocState {
  LoginUnverified();
}
