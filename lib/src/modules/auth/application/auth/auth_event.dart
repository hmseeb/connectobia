part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class CheckAuth extends AuthEvent {}
