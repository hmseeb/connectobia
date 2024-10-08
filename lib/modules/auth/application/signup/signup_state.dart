part of 'signup_bloc.dart';

final class SignupFailure extends SignupState {
  final String error;

  SignupFailure(this.error);
}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

@immutable
sealed class SignupState {}

final class SignupSuccess extends SignupState {}
