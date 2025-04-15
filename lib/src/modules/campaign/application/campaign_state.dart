import 'package:connectobia/src/shared/domain/models/campaign.dart';

/// Campaign was canceled successfully
class CampaignCanceled extends CampaignState {
  final Campaign campaign;
  CampaignCanceled(this.campaign);
}

/// Campaign cancellation failed
class CampaignCancellationError extends CampaignState {
  final String errorMessage;
  CampaignCancellationError(this.errorMessage);
}

/// State when campaign has been successfully created
class CampaignCreated extends CampaignState {
  final Campaign campaign;

  CampaignCreated(this.campaign);
}

/// State when campaign is being created
class CampaignCreating extends CampaignState {}

/// State when campaign creation failed
class CampaignCreationError extends CampaignState {
  final String errorMessage;

  CampaignCreationError(this.errorMessage);
}

/// Campaign loading error
class CampaignError extends CampaignState {
  final String message;
  CampaignError(this.message);
}

/// State to hold campaign form data throughout the creation flow
class CampaignFormState extends CampaignState {
  final String title;
  final String description;
  final String category;
  final double budget;
  final List<String> selectedGoals;
  final String? selectedInfluencer;
  final List<String> selectedPostTypes;
  final DateTime? deliveryDate;
  final String contentGuidelines;
  final bool confirmDetails;
  final bool acceptTerms;
  final Map<int, StepValidationResult> stepValidations;

  CampaignFormState({
    this.title = '',
    this.description = '',
    this.category = 'fashion',
    this.budget = 0,
    this.selectedGoals = const [],
    this.selectedInfluencer,
    this.selectedPostTypes = const [],
    this.deliveryDate,
    this.contentGuidelines = '',
    this.confirmDetails = false,
    this.acceptTerms = false,
    Map<int, StepValidationResult>? stepValidations,
  }) : stepValidations = stepValidations ?? {};

  CampaignFormState copyWith({
    String? title,
    String? description,
    String? category,
    double? budget,
    List<String>? selectedGoals,
    String? selectedInfluencer,
    List<String>? selectedPostTypes,
    DateTime? deliveryDate,
    String? contentGuidelines,
    bool? confirmDetails,
    bool? acceptTerms,
    Map<int, StepValidationResult>? stepValidations,
  }) {
    return CampaignFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      budget: budget ?? this.budget,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedInfluencer: selectedInfluencer ?? this.selectedInfluencer,
      selectedPostTypes: selectedPostTypes ?? this.selectedPostTypes,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      contentGuidelines: contentGuidelines ?? this.contentGuidelines,
      confirmDetails: confirmDetails ?? this.confirmDetails,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      stepValidations: stepValidations ?? this.stepValidations,
    );
  }

  List<String> getErrorsForStep(int step) {
    if (!stepValidations.containsKey(step)) {
      return [];
    }
    return stepValidations[step]!.errors;
  }

  bool isStepValid(int step) {
    if (!stepValidations.containsKey(step)) {
      return false;
    }
    return stepValidations[step]!.isValid;
  }
}

class CampaignInitial extends CampaignState {}

/// A single campaign loaded
class CampaignLoaded extends CampaignState {
  final Campaign campaign;
  CampaignLoaded(this.campaign);
}

class CampaignsLoaded extends CampaignState {
  final List<Campaign> campaigns;
  CampaignsLoaded(this.campaigns);
}

class CampaignsLoading extends CampaignState {}

class CampaignsLoadingError extends CampaignState {
  final String errorMessage;
  CampaignsLoadingError(this.errorMessage);
}

abstract class CampaignState {}

/// Campaign updated successfully
class CampaignUpdated extends CampaignState {
  final Campaign campaign;
  CampaignUpdated(this.campaign);
}

/// State for validation results
class StepValidationResult {
  final bool isValid;
  final List<String> errors;

  StepValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}
