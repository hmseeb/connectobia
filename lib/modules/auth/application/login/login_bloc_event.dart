part of 'login_bloc.dart';

@immutable
sealed class LoginBlocEvent {}

class LoginSubmitted extends LoginBlocEvent {
  final String email;
  final String password;
  final String? accountType;

  LoginSubmitted(
      {required this.email, required this.password, required this.accountType});
}

class LoginWithInstagram extends LoginBlocEvent {
  final String? accountType;
  LoginWithInstagram({required this.accountType});
}
