part of 'influencer_profile_bloc.dart';

final class InfluencerProfileError extends InfluencerProfileState {
  final String message;

  InfluencerProfileError(this.message);
}

final class InfluencerProfileInitial extends InfluencerProfileState {}

final class InfluencerProfileLoaded extends InfluencerProfileState {
  final InfluencerProfile influencerProfile;
  final Influencer influencer;

  InfluencerProfileLoaded(
      {required this.influencerProfile, required this.influencer});
}

final class InfluencerProfileLoading extends InfluencerProfileState {}

@immutable
sealed class InfluencerProfileState {}
