import 'package:bloc/bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:connectobia/src/modules/campaign/data/contract_repository.dart';
import 'package:connectobia/src/shared/data/repositories/error_repo.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:flutter/material.dart';

class CampaignBloc extends Bloc<CampaignEvent, CampaignState> {
  CampaignBloc() : super(CampaignInitial()) {
    // Event to load campaigns
    on<LoadCampaigns>((event, emit) async {
      emit(CampaignsLoading());
      try {
        debugPrint('Loading campaigns from repository');
        List<Campaign> campaigns = await CampaignRepository.getCampaigns();
        debugPrint('Successfully loaded ${campaigns.length} campaigns');
        emit(CampaignsLoaded(campaigns));
      } catch (e) {
        debugPrint('Error loading campaigns: $e');
        ErrorRepository errorRepo = ErrorRepository();
        String errorMessage = errorRepo.handleError(e);
        // If there's a connectivity issue, make it more user-friendly
        if (errorMessage.contains('network') ||
            errorMessage.contains('connection') ||
            errorMessage.contains('timeout')) {
          errorMessage =
              'Network connection issue. Please check your internet and try again.';
        }
        emit(CampaignsLoadingError(errorMessage));
      }
    });

    // Event to load a specific campaign by ID
    on<LoadCampaign>((event, emit) async {
      emit(CampaignsLoading());
      try {
        debugPrint('Loading campaign with ID: ${event.campaignId}');
        Campaign campaign =
            await CampaignRepository.getCampaignById(event.campaignId);
        debugPrint(
            'Campaign loaded successfully: ${campaign.id}, ${campaign.title}');
        emit(CampaignLoaded(campaign));
      } catch (e) {
        debugPrint('Error loading campaign: $e');
        ErrorRepository errorRepo = ErrorRepository();
        String errorMessage = errorRepo.handleError(e);

        // Provide a more user-friendly message for resource not found
        if (errorMessage.contains('not found') ||
            errorMessage.contains('404')) {
          errorMessage =
              'Campaign not found. It may have been deleted or you do not have access to it.';
        }

        emit(CampaignError(errorMessage));
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
      debugPrint(
          'InitCampaignForm event received: title=${event.title}, description=${event.description}, budget=${event.budget}');

      // Create a new form state with initial values for editing if provided
      emit(CampaignFormState(
        // Use provided values or defaults
        title: event.title ?? '',
        description: event.description ?? '',
        category: event.category ?? 'fashion',
        budget: event.budget ?? 0,
        // Dates will be set automatically:
        // - Start date: when influencer signs
        // - End date: will be the delivery date
        selectedGoals: event.goals ?? [],
        selectedInfluencer: event.selectedInfluencer,
      ));

      debugPrint(
          'Emitted CampaignFormState with title=${event.title}, description=${event.description}, budget=${event.budget}');
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
          // Dates are now handled automatically
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

    // Reset selected influencer
    on<ResetSelectedInfluencer>((event, emit) {
      if (state is CampaignFormState) {
        final currentState = state as CampaignFormState;
        debugPrint(
            'Resetting selected influencer to null - previous value: ${currentState.selectedInfluencer}');
        emit(currentState.copyWith(
          selectedInfluencer: null,
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
          // Check if this is an update or a new campaign
          final isUpdate =
              event.campaignId != null && event.campaignId!.isNotEmpty;

          if (isUpdate) {
            // Update existing campaign
            debugPrint(
                'Updating existing campaign with ID: ${event.campaignId}');

            final updateData = {
              'title': formState.title,
              'description': formState.description,
              'goals': formState.selectedGoals,
              'category': formState.category,
              'budget': formState.budget,
              'selected_influencer': formState.selectedInfluencer,
            };

            final updatedCampaign = await CampaignRepository.updateCampaign(
              event.campaignId!,
              updateData,
            );

            // Update associated contract if needed
            try {
              final contract = await ContractRepository.getContractByCampaignId(
                  event.campaignId!);
              if (contract != null) {
                await ContractRepository.updateStatus(
                  contract.id,
                  'pending', // Reset to pending if changed
                );
              }
            } catch (e) {
              debugPrint('Error updating contract: $e');
              // Don't fail the campaign update if contract update fails
            }

            emit(CampaignCreated(updatedCampaign));
          } else {
            // Create new campaign
            final campaign = Campaign(
              collectionId: 'campaigns',
              collectionName: 'campaigns',
              id: '',
              title: formState.title,
              description: formState.description,
              goals: formState.selectedGoals,
              category: formState.category,
              budget: formState.budget,
              startDate: DateTime
                  .now(), // Default start date - will be updated when influencer signs
              endDate: formState.deliveryDate ??
                  DateTime.now().add(const Duration(
                      days:
                          30)), // Default to delivery date or 30 days from now
              status: 'draft', // Always set initial status to draft
              brand: '', // Will be set by repository
              selectedInfluencer: formState.selectedInfluencer,
              created: DateTime.now(),
              updated: DateTime.now(),
            );

            debugPrint('Creating campaign with initial status: draft');
            // Save the campaign to the backend with contract details
            final createdCampaign = await CampaignRepository.createCampaign(
              campaign,
              postTypes: formState.selectedPostTypes,
              deliveryDate: formState.deliveryDate,
              guidelines: formState.contentGuidelines,
            );
            emit(CampaignCreated(createdCampaign));
          }
        } catch (e) {
          debugPrint('Error creating/updating campaign: $e');
          ErrorRepository errorRepo = ErrorRepository();
          emit(CampaignCreationError(errorRepo.handleError(e)));
        }
      }
    });

    // Cancel campaign and release funds
    on<CancelCampaign>((event, emit) async {
      emit(CampaignsLoading());
      try {
        debugPrint('Cancelling campaign with ID: ${event.campaignId}');
        final canceledCampaign =
            await CampaignRepository.cancelCampaign(event.campaignId);
        debugPrint('Campaign cancelled successfully, funds released');
        emit(CampaignCanceled(canceledCampaign));
      } catch (e) {
        debugPrint('Error cancelling campaign: $e');
        ErrorRepository errorRepo = ErrorRepository();
        emit(CampaignCancellationError(errorRepo.handleError(e)));
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
        // Remove date validation since dates are now set automatically
        break;

      case 2: // Campaign goals
        if (state.selectedGoals.isEmpty) {
          errors.add('At least one campaign goal must be selected');
        }
        break;

      case 3: // Influencer selection
        // Make influencer selection required for direct campaigns
        if (state.selectedInfluencer == null) {
          errors.add('Please select an influencer for your campaign');
        }
        break;

      case 4: // Contract details
        if (state.selectedPostTypes.isEmpty) {
          errors.add('Please select at least one post type');
        }
        if (state.contentGuidelines.trim().isEmpty) {
          errors.add('Content guidelines are required');
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
