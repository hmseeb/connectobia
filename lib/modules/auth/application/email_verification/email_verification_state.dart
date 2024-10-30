part of 'email_verification_bloc.dart';

final class EmailVerificationInitialState extends EmailVerificationState {}

@immutable
sealed class EmailVerificationState {}

final class EmailVerified extends EmailVerificationState {
  final User user;
  EmailVerified(this.user);
}
