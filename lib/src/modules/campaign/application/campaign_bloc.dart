import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  CampaignBloc() : super(CampaignInitial()) {
    // Event to load campaigns
    on<LoadCampaigns>((event, emit) async {
      emit(CampaignsLoading());
      try {
        List<Campaign> campaigns = await CampaignRepository.getCampaigns();
        emit(CampaignsLoaded(campaigns));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignsLoadingError(errorRepo.handleError(e)));
      }
    });

    // Event to load a specific campaign by ID
    on<LoadCampaign>((event, emit) async {
      emit(CampaignsLoading());
      try {
        Campaign campaign =
            await CampaignRepository.getCampaignById(event.campaignId);
        emit(CampaignLoaded(campaign));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignError(errorRepo.handleError(e)));
      }
    });

    // Event to update a campaign's status
    on<UpdateCampaignStatus>((event, emit) async {
      emit(CampaignsLoading());
      try {
        Campaign campaign = await CampaignRepository.updateCampaignStatus(
            event.campaignId, event.status);
        emit(CampaignUpdated(campaign));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignError(errorRepo.handleError(e)));
      }
    });

    // Event to search campaigns
    on<SearchCampaigns>((event, emit) async {
      emit(CampaignsLoading());
      try {
        List<Campaign> campaigns = await CampaignRepository.getCampaigns();
        final filteredCampaigns = campaigns
            .where((campaign) => campaign.title
                .toLowerCase()
                .contains(event.query.toLowerCase()))
            .toList();
        emit(CampaignsLoaded(filteredCampaigns));
      } catch (e) {
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignsLoadingError(errorRepo.handleError(e)));
      }
    });

    // Initialize a new campaign form
    on<InitCampaignForm>((event, emit) {
      emit(CampaignFormState());
    });

    // Update campaign basic details (Step 1)
    on<UpdateCampaignBasicDetails>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        emit(currentState.copyWith(
          title: event.title,
          description: event.description,
          category: event.category,
          budget: event.budget,
          startDate: event.startDate,
          endDate: event.endDate,
        ));
      }
    });

    // Update campaign goals (Step 2)
    on<UpdateCampaignGoals>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        emit(currentState.copyWith(
          selectedGoals: event.goals,
        ));
      }
    });

    // Update selected influencer (Step 3)
    on<UpdateSelectedInfluencer>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        emit(currentState.copyWith(
          selectedInfluencer: event.influencerId,
        ));
      }
    });

    // Update contract details (Step 4)
    on<UpdateContractDetails>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        emit(currentState.copyWith(
          selectedPostTypes: event.postTypes,
          deliveryDate: event.deliveryDate,
          contentGuidelines: event.contentGuidelines,
          confirmDetails: event.confirmDetails,
          acceptTerms: event.acceptTerms,
        ));
      }
    });

    // Validate current step
    on<ValidateCurrentStep>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        final validationResult = _validateStep(event.step, currentState);
        final updatedValidations =
            Map<int, StepValidationResult>.from(currentState.stepValidations);
        updatedValidations[event.step] = validationResult;

        emit(currentState.copyWith(
          stepValidations: updatedValidations,
        ));
      }
    });

    // Create campaign with collected data
    on<CreateCampaign>((event, emit) async {
      if (state is CampaignFormState) {
        final formState = state as CampaignFormState;

        // Validate all 4 steps
        bool allStepsValid = true;
        for (int step = 1; step <= 4; step++) {
          final validationResult = _validateStep(step, formState);
          if (!validationResult.isValid) {
            allStepsValid = false;
            break;
          }
        }

        if (!allStepsValid) {
          // Don't proceed if validation fails
          return;
        }

        emit(CampaignCreating());

        try {
          // Create the campaign object
          final campaign = Campaign(
            collectionId: 'campaigns',
            collectionName: 'campaigns',
            id: '',
            title: formState.title,
            description: formState.description,
            goals: formState.selectedGoals,
            category: formState.category,
            budget: formState.budget,
            startDate: formState.startDate,
            endDate: formState.endDate,
            status: 'active',
            brand: '', // Will be set by repository
            selectedInfluencer: formState.selectedInfluencer,
            created: DateTime.now(),
            updated: DateTime.now(),
          );

          // Save the campaign to the backend
          final createdCampaign =
              await CampaignRepository.createCampaign(campaign);
          emit(CampaignCreated(createdCampaign));
        } catch (e) {
          debugPrint('Error creating campaign: $e');
          ErrorRepository errorRepo = ErrorRepository();
          emit(CampaignCreationError(errorRepo.handleError(e)));
        }
      }
    });
  }

  // Helper method to validate each step
  StepValidationResult _validateStep(int step, CampaignFormState state) {
    List<String> errors = [];

    switch (step) {
      case 1: // Basic campaign details
        if (state.title.isEmpty) {
          errors.add('Campaign name is required');
        }
        if (state.description.isEmpty) {
          errors.add('Campaign description is required');
        }
        if (state.budget <= 0) {
          errors.add('Budget must be greater than 0');
        }
        if (state.startDate.isAfter(state.endDate)) {
          errors.add('Start date cannot be after end date');
        }
        break;

      case 2: // Campaign goals
        if (state.selectedGoals.isEmpty) {
          errors.add('At least one campaign goal must be selected');
        }
        break;

      case 3: // Influencer selection
        // Make influencer selection optional - the brand can launch a public campaign without specific influencer
        // if (state.selectedInfluencer == null) {
        //   errors.add('Please select an influencer for your campaign');
        // }
        break;

      case 4: // Contract details
        if (state.selectedPostTypes.isEmpty) {
          errors.add('Please select at least one post type');
        }
        if (!state.confirmDetails) {
          errors.add('You must confirm that all details are correct');
        }
        if (!state.acceptTerms) {
          errors.add('You must accept the terms and conditions');
        }
        break;
    }

    return StepValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
