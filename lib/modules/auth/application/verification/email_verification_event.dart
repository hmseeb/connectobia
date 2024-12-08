part of 'email_verification_bloc.dart';

class EmailSubscribeEvent extends EmailVerificationEvent {
  final String accountType;
  EmailSubscribeEvent({required this.accountType});
}

@immutable
sealed class EmailVerificationEvent {}

class EmailVerificationInitial extends EmailVerificationEvent {}

class EmailVerify extends EmailVerificationEvent {}
