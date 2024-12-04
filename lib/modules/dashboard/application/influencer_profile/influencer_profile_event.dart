part of 'influencer_profile_bloc.dart';

@immutable
sealed class InfluencerProfileEvent {}

final class InfluencerProfileLoad extends InfluencerProfileEvent {
  final String id;

  InfluencerProfileLoad(this.id);
}
