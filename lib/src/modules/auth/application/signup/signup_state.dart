part of 'signup_bloc.dart';

final class InstagramFailure extends SignupState {
  final String error;

  InstagramFailure(this.error);
}

final class InstagramLoading extends SignupState {}

final class SignupFailure extends SignupState {
  final String error;

  SignupFailure(this.error);
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

@immutable
sealed class SignupState {}

final class SignupSuccess extends SignupState {
  final String? email;
  SignupSuccess({required this.email});
}
