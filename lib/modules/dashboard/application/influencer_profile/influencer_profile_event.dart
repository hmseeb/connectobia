part of 'influencer_profile_bloc.dart';

@immutable
sealed class InfluencerProfileEvent {}

final class InfluencerProfileLoad extends InfluencerProfileEvent {
  final String profileId;
  final Influencer influencer;

  InfluencerProfileLoad({required this.profileId, required this.influencer});
}
