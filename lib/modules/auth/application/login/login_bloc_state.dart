part of 'login_bloc.dart';

final class LoginBlocInitial extends LoginBlocState {}

@immutable
sealed class LoginBlocState {}

final class LoginFailure extends LoginBlocState {
  final String error;

  LoginFailure(this.error);
}

final class LoginLoading extends LoginBlocState {}

final class LoginSuccess extends LoginBlocState {
  final User user;
  LoginSuccess(this.user);
}

final class LoginUnverified extends LoginBlocState {
  LoginUnverified();
}
