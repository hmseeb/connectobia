import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_goals_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/contract_details.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/custom_progress_indicator.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/navigation_buttons.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/select_influencer.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/presentation/widgets/error_box.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _campaignDescriptionController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  int _currentStep = 1;
  String _category = 'fashion';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  // List of validation errors for the current step
  List<String> _validationErrors = [];

  // References to form widgets for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignCreated) {
          // Show success message
          ShadToaster.of(context).show(
            const ShadToast(
              title: Text('Campaign Created'),
              description: Text('Your campaign has been created successfully'),
            ),
          );

          // Navigate to campaigns list
          Navigator.pushReplacementNamed(context, campaignsScreen);
        } else if (state is CampaignCreationError) {
          // Show error message
          setState(() {
            _validationErrors = [state.errorMessage];
          });
        }
      },
      builder: (context, state) {
        // Handle loading states
        if (state is CampaignCreating) {
          return Scaffold(
            appBar: transparentAppBar('Create Campaign', context: context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Only use the campaign form state if available
        final campaignForm = state is CampaignFormState ? state : null;

        // Update the text controllers when we get new form data
        if (campaignForm != null &&
            (_campaignNameController.text != campaignForm.title ||
                _campaignDescriptionController.text !=
                    campaignForm.description)) {
          _campaignNameController.text = campaignForm.title;
          _campaignDescriptionController.text = campaignForm.description;
          if (_budgetController.text == '0' && campaignForm.budget > 0) {
            _budgetController.text = campaignForm.budget.toString();
          }

          // Also update local state
          _category = campaignForm.category;
          _startDate = campaignForm.startDate;
          _endDate = campaignForm.endDate;
        }

        // Update validation errors from form state
        if (campaignForm != null &&
            campaignForm.stepValidations.containsKey(_currentStep)) {
          _validationErrors = campaignForm.getErrorsForStep(_currentStep);
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: transparentAppBar('Create Campaign', context: context),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Show validation errors at the top
                if (_validationErrors.isNotEmpty)
                  ErrorBox(errors: _validationErrors),

                Expanded(
                  child: SingleChildScrollView(
                    child: _buildStepContent(campaignForm),
                  ),
                ),

                if (campaignForm != null) ...[
                  const SizedBox(height: 16),

                  // Navigation buttons
                  NavigationButtons(
                    currentStep: _currentStep,
                    onPrevious: _goToPreviousStep,
                    onNext: () => _validateAndGoToNextStep(campaignForm),
                  ),

                  const SizedBox(height: 10),

                  // Progress indicator
                  CustomProgressIndicator(currentStep: _currentStep),

                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _campaignNameController.dispose();
    _campaignDescriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize the campaign form
    context.read<CampaignBloc>().add(InitCampaignForm());
    _budgetController.text = '';
  }

  Widget _buildStepContent(CampaignFormState? formState) {
    switch (_currentStep) {
      case 1:
        return CampaignFormCard(
          key: _formKey,
          campaignNameController: _campaignNameController,
          campaignDescriptionController: _campaignDescriptionController,
          onBudgetChanged: (value) {
            debugPrint('Budget updated to: $value');
            _budgetController.text = value.toString();
            _updateBasicDetails();
          },
          onCategoryChanged: (value) {
            _category = value;
            _updateBasicDetails();
          },
          onStartDateChanged: (value) {
            _startDate = value;
            _updateBasicDetails();
          },
          onEndDateChanged: (value) {
            _endDate = value;
            _updateBasicDetails();
          },
        );
      case 2:
        return CampaignGoals(
          onValidationChanged: (isValid) {
            // Validation is now handled by the bloc
          },
          onGoalsSelected: (goals) {
            context.read<CampaignBloc>().add(UpdateCampaignGoals(goals));
          },
        );
      case 3:
        return SelectInfluencerStep(
          onSelectedInfluencersChanged: (selected) {
            final selectedId = selected.isNotEmpty ? selected.first : null;
            context
                .read<CampaignBloc>()
                .add(UpdateSelectedInfluencer(selectedId));
          },
        );
      case 4:
        return ContractDetailsStep(
          campaignFormState: formState,
          onContractDetailsChanged: (postTypes, deliveryDate, guidelines,
              confirmDetails, acceptTerms) {
            context.read<CampaignBloc>().add(
                  UpdateContractDetails(
                    postTypes: postTypes,
                    deliveryDate: deliveryDate,
                    contentGuidelines: guidelines,
                    confirmDetails: confirmDetails,
                    acceptTerms: acceptTerms,
                  ),
                );
          },
        );
      default:
        return const Center(child: Text('Invalid Step'));
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _validationErrors = [];
      });
    }
  }

  void _updateBasicDetails() {
    final budgetText = _budgetController.text;
    final budget = double.tryParse(budgetText) ?? 0;
    debugPrint(
        'Updating basic details with budget text: $budgetText, parsed value: $budget');

    context.read<CampaignBloc>().add(
          UpdateCampaignBasicDetails(
            title: _campaignNameController.text,
            description: _campaignDescriptionController.text,
            category: _category,
            budget: budget,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  void _validateAndGoToNextStep(CampaignFormState formState) {
    // Clear previous validation errors
    setState(() {
      _validationErrors = [];
    });

    // For step 1, validate form fields directly
    if (_currentStep == 1) {
      List<String> errors = [];

      // Check required fields
      if (_campaignNameController.text.isEmpty) {
        errors.add('Campaign name is required');
      }

      if (_campaignDescriptionController.text.isEmpty) {
        errors.add('Campaign description is required');
      }

      // Check budget
      final budgetText = _budgetController.text;
      final budget = double.tryParse(budgetText);
      debugPrint('Budget text: $budgetText, parsed value: $budget');
      if (budgetText.isEmpty || budget == null || budget <= 0) {
        errors.add('Budget must be greater than 0');
      }

      if (errors.isNotEmpty) {
        setState(() {
          _validationErrors = errors;
        });
        return;
      }

      // Update the data before proceeding
      _updateBasicDetails();

      // Move to the next step immediately after validation passes
      setState(() {
        _currentStep++;
      });
      return;
    }

    // For final step, create the campaign directly
    if (_currentStep == 4) {
      // This is the final step, create the campaign
      context.read<CampaignBloc>().add(ValidateCurrentStep(_currentStep));

      // Only create if valid
      if (formState.isStepValid(_currentStep)) {
        context.read<CampaignBloc>().add(CreateCampaign());
      } else {
        // Show validation errors
        setState(() {
          _validationErrors = formState.getErrorsForStep(_currentStep);
        });
      }
      return;
    }

    // For steps 2-3, validate current step through the bloc
    context.read<CampaignBloc>().add(ValidateCurrentStep(_currentStep));

    // Check if the step is valid after bloc validation
    if (!formState.isStepValid(_currentStep)) {
      // Show validation errors
      setState(() {
        _validationErrors = formState.getErrorsForStep(_currentStep);
      });
      return;
    }

    // If validation passed, move to the next step
    setState(() {
      _currentStep++;
    });
  }
}
