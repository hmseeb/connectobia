part of 'influencer_onboard_bloc.dart';

class ConnectedInstagram extends InfluencerOnboardState {}

class ConnectingInstagram extends InfluencerOnboardState {}

class ConnectingInstagramFailure extends InfluencerOnboardState {
  final String message;

  ConnectingInstagramFailure(this.message);
}

final class InfluencerOnboardInitial extends InfluencerOnboardState {}

@immutable
sealed class InfluencerOnboardState {}
