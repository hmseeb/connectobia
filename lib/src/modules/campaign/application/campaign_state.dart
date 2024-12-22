import 'package:connectobia/src/shared/domain/models/campaign.dart';

abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignsLoading extends CampaignState {}

class CampaignsLoaded extends CampaignState {
  final List<Campaign> campaigns;
  CampaignsLoaded(this.campaigns);
}

class CampaignsLoadingError extends CampaignState {
  final String errorMessage;
  CampaignsLoadingError(this.errorMessage);
}
