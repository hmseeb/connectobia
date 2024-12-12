part of 'email_verification_bloc.dart';

class EmailSubscribeEvent extends EmailVerificationEvent {
  EmailSubscribeEvent();
}

@immutable
sealed class EmailVerificationEvent {}

class EmailVerificationInitial extends EmailVerificationEvent {}

class EmailVerify extends EmailVerificationEvent {}
