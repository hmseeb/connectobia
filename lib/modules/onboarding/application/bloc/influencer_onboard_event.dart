part of 'influencer_onboard_bloc.dart';

class ConnectInstagram extends InfluencerOnboardEvent {}

@immutable
sealed class InfluencerOnboardEvent {}

class SubmitLocation extends InfluencerOnboardEvent {
  final String location;

  SubmitLocation(this.location);
}

class UpdateOnboardBool extends InfluencerOnboardEvent {
  UpdateOnboardBool();
}

class SubmitPersonalDetails extends InfluencerOnboardEvent {
  final DateTime dob;
  final String gender;

  SubmitPersonalDetails(this.dob, this.gender);
}
