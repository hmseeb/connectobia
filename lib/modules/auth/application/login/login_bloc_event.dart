part of 'login_bloc.dart';

class InstagramAuth extends LoginBlocEvent {
  final String accountType;
  InstagramAuth({required this.accountType});
}

@immutable
sealed class LoginBlocEvent {}

class LoginSubmitted extends LoginBlocEvent {
  final String email;
  final String password;
  final String accountType;

  LoginSubmitted(
      {required this.email, required this.password, required this.accountType});
}
