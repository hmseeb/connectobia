part of 'email_verification_bloc.dart';

final class BrandEmailVerified extends EmailVerificationState {
  final Brand brand;
  BrandEmailVerified(this.brand);
}

final class EmailVerificationInitialState extends EmailVerificationState {}

@immutable
sealed class EmailVerificationState {}

final class InfluencerEmailVerified extends EmailVerificationState {
  final Influencer influencer;
  InfluencerEmailVerified(this.influencer);
}

class EmailVerificationError extends EmailVerificationState {
  final String error;

  EmailVerificationError(this.error);
}
