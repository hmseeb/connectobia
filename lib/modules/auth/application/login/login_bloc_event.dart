part of 'login_bloc.dart';

@immutable
sealed class LoginBlocEvent {}

class LoginSubmitted extends LoginBlocEvent {
  final String email;
  final String password;

  LoginSubmitted({
    required this.email,
    required this.password,
  });
}
