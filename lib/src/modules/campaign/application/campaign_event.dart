
abstract class CampaignEvent {}

class LoadCampaigns extends CampaignEvent {}

class SearchCampaigns extends CampaignEvent {
  final String query;
  SearchCampaigns(this.query);
}
