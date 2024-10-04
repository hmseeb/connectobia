part of 'signup_bloc_bloc.dart';

final class SignupBlocFailure extends SignupBlocState {
  final String error;
  SignupBlocFailure(this.error);
}

final class SignupBlocInitial extends SignupBlocState {}

final class SignupBlocLoading extends SignupBlocState {}

@immutable
sealed class SignupBlocState {}

final class SignupBlocSuccess extends SignupBlocState {}

final class SignupInvalidEmail extends SignupBlocState {
  final String error;
  SignupInvalidEmail(this.error);
}

final class SignupInvalidFirstName extends SignupBlocState {
  final String error;
  SignupInvalidFirstName(this.error);
}

final class SignupInvalidLastName extends SignupBlocState {
  final String error;
  SignupInvalidLastName(this.error);
}

final class SignupInvalidPassword extends SignupBlocState {
  final String error;
  SignupInvalidPassword(this.error);
}
