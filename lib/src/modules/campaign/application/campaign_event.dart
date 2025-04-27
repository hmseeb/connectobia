abstract class CampaignEvent {}

/// Event to create the campaign with all collected data
class CreateCampaign extends CampaignEvent {
  final String? campaignId; // If provided, this is an update operation

  CreateCampaign({this.campaignId});
}

/// Event to initialize a new campaign form
class InitCampaignForm extends CampaignEvent {
  // Optional fields for editing existing campaign
  final String? title;
  final String? description;
  final String? category;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? goals;
  final String? selectedInfluencer;

  InitCampaignForm({
    this.title,
    this.description,
    this.category,
    this.budget,
    this.startDate,
    this.endDate,
    this.goals,
    this.selectedInfluencer,
  });
}

/// Event to load a specific campaign by ID
class LoadCampaign extends CampaignEvent {
  final String campaignId;
  LoadCampaign(this.campaignId);
}

// New events for campaign creation flow

class LoadCampaigns extends CampaignEvent {}

class SearchCampaigns extends CampaignEvent {
  final String query;
  SearchCampaigns(this.query);
}

/// Event to update the campaign basic details (Step 1)
class UpdateCampaignBasicDetails extends CampaignEvent {
  final String title;
  final String description;
  final String category;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;

  UpdateCampaignBasicDetails({
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });
}

/// Event to update campaign goals (Step 2)
class UpdateCampaignGoals extends CampaignEvent {
  final List<String> goals;

  UpdateCampaignGoals(this.goals);
}

/// Event to update a campaign's status
class UpdateCampaignStatus extends CampaignEvent {
  final String campaignId;
  final String status;
  UpdateCampaignStatus(this.campaignId, this.status);
}

/// Event to update contract details (Step 4)
class UpdateContractDetails extends CampaignEvent {
  final List<String> postTypes;
  final DateTime? deliveryDate;
  final String contentGuidelines;
  final bool confirmDetails;
  final bool acceptTerms;

  UpdateContractDetails({
    required this.postTypes,
    this.deliveryDate,
    required this.contentGuidelines,
    required this.confirmDetails,
    required this.acceptTerms,
  });
}

/// Event to update selected influencer (Step 3)
class UpdateSelectedInfluencer extends CampaignEvent {
  final String? influencerId;

  UpdateSelectedInfluencer(this.influencerId);
}

/// Event to validate the current step
class ValidateCurrentStep extends CampaignEvent {
  final int step;

  ValidateCurrentStep(this.step);
}
