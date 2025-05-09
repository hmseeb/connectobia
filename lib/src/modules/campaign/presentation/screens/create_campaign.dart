import 'package:connectobia/src/modules/auth/data/repositories/auth_repo.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_bloc.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_event.dart';
import 'package:connectobia/src/modules/campaign/application/campaign_state.dart';
import 'package:connectobia/src/modules/campaign/data/contract_repository.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/campaign_goals_form.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/contract_details.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/custom_progress_indicator.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/navigation_buttons.dart';
import 'package:connectobia/src/modules/campaign/presentation/widgets/select_influencer.dart';
import 'package:connectobia/src/shared/data/constants/screens.dart';
import 'package:connectobia/src/shared/data/repositories/funds_repository.dart';
import 'package:connectobia/src/shared/domain/models/campaign.dart';
import 'package:connectobia/src/shared/presentation/widgets/error_box.dart';
import 'package:connectobia/src/shared/presentation/widgets/transparent_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateCampaignScreen extends StatefulWidget {
  final Campaign? campaignToEdit;

  const CreateCampaignScreen({
    super.key,
    this.campaignToEdit,
  });

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
  bool _isEditing = false;
  Campaign? _campaignToEdit;

  // For contract details
  List<String> _postTypes = [];
  DateTime? _deliveryDate;
  String _contentGuidelines = '';
  bool _confirmDetails = false;
  bool _acceptTerms = false;

  // For campaign goals
  List<String> _goals = [];

  // For influencer selection
  String? _selectedInfluencer;

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
            ShadToast(
              title: Text(_isEditing ? 'Campaign Updated' : 'Campaign Created'),
              description: Text(_isEditing
                  ? 'Your campaign has been updated successfully'
                  : 'Your campaign has been created successfully'),
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
            appBar: transparentAppBar(
                _isEditing ? 'Edit Campaign' : 'Create Campaign',
                context: context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Only use the campaign form state if available
        final campaignForm = state is CampaignFormState ? state : null;

        // Only update the text controllers with form data if they're empty
        // This prevents overwriting user edits with state data
        if (campaignForm != null) {
          debugPrint(
              'Form state update - title: ${campaignForm.title}, description: ${campaignForm.description}');

          // Only update if text controllers are empty (initial load)
          // or if we're in edit mode and we need to load existing data
          if (_campaignNameController.text.isEmpty) {
            _campaignNameController.text = campaignForm.title;
            debugPrint(
                'Updated name controller to: ${_campaignNameController.text}');
          }

          if (_campaignDescriptionController.text.isEmpty) {
            _campaignDescriptionController.text = campaignForm.description;
            debugPrint(
                'Updated description controller to: ${_campaignDescriptionController.text}');
          }

          if (_budgetController.text.isEmpty && campaignForm.budget > 0) {
            _budgetController.text = campaignForm.budget.toString();
            debugPrint(
                'Updated budget controller to: ${_budgetController.text}');
          }

          // Also update local state
          _category = campaignForm.category;
          _startDate = campaignForm.startDate;
          _endDate = campaignForm.endDate;
          _goals = campaignForm.selectedGoals;
          _selectedInfluencer = campaignForm.selectedInfluencer;
          _postTypes = campaignForm.selectedPostTypes;
          _deliveryDate = campaignForm.deliveryDate;
          _contentGuidelines = campaignForm.contentGuidelines;
          _confirmDetails = campaignForm.confirmDetails;
          _acceptTerms = campaignForm.acceptTerms;
        } else if (!_isEditing) {
          // Fallback if form state is not initialized yet
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                context.read<CampaignBloc>().state is! CampaignFormState) {
              debugPrint('Fallback: Initializing form state for new campaign');
              context.read<CampaignBloc>().add(
                    InitCampaignForm(
                      title: '',
                      description: '',
                      category: 'fashion',
                      budget: 0,
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(days: 30)),
                      goals: [],
                    ),
                  );
            }
          });
        }

        // Update validation errors from form state
        if (campaignForm != null &&
            campaignForm.stepValidations.containsKey(_currentStep)) {
          _validationErrors = campaignForm.getErrorsForStep(_currentStep);
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: transparentAppBar(
            _isEditing ? 'Edit Campaign' : 'Create Campaign',
            context: context,
            showBackButton: false,
          ),
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
                    submitLabel:
                        _isEditing ? 'Update Campaign' : 'Create Campaign',
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we're editing an existing campaign
    final routeSettings = ModalRoute.of(context)?.settings;
    debugPrint('RouteSettings: ${routeSettings?.arguments}');

    if (routeSettings?.arguments != null && !_isEditing) {
      try {
        final args = routeSettings!.arguments as Map<String, dynamic>?;
        debugPrint('Args: $args');

        if (args != null && args.containsKey('campaign')) {
          _campaignToEdit = args['campaign'] as Campaign?;
          debugPrint(
              'Campaign to edit: ${_campaignToEdit?.title}, ${_campaignToEdit?.description}');

          if (_campaignToEdit != null) {
            setState(() {
              _isEditing = true;

              // Initialize form with campaign data
              _campaignNameController.text = _campaignToEdit!.title;
              _campaignDescriptionController.text =
                  _campaignToEdit!.description;
              _budgetController.text = _campaignToEdit!.budget.toString();

              debugPrint(
                  'Set text controllers - Name: ${_campaignNameController.text}, Desc: ${_campaignDescriptionController.text}');

              _category = _campaignToEdit!.category;
              _startDate = _campaignToEdit!.startDate;
              _endDate = _campaignToEdit!.endDate;
              _goals = List.from(_campaignToEdit!.goals);
              _selectedInfluencer = _campaignToEdit!.selectedInfluencer;

              // Initialize the form state in the bloc with existing data
              context.read<CampaignBloc>().add(
                    InitCampaignForm(
                      title: _campaignToEdit!.title,
                      description: _campaignToEdit!.description,
                      category: _campaignToEdit!.category,
                      budget: _campaignToEdit!.budget,
                      startDate: _campaignToEdit!.startDate,
                      endDate: _campaignToEdit!.endDate,
                      goals: _campaignToEdit!.goals,
                      selectedInfluencer: _campaignToEdit!.selectedInfluencer,
                    ),
                  );

              // Update the form with existing data immediately
              _updateBasicDetails();

              // Update goals
              context.read<CampaignBloc>().add(UpdateCampaignGoals(_goals));

              // Update selected influencer
              if (_selectedInfluencer != null) {
                context
                    .read<CampaignBloc>()
                    .add(UpdateSelectedInfluencer(_selectedInfluencer));
              }

              // Fetch contract details for this campaign
              _fetchContractDetails();
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading campaign for editing: $e');
      }
    }
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

    // Check if we have a campaign passed directly to the widget
    if (widget.campaignToEdit != null && !_isEditing) {
      _campaignToEdit = widget.campaignToEdit;
      _isEditing = true;

      // Initialize form with campaign data
      _campaignNameController.text = _campaignToEdit!.title;
      _campaignDescriptionController.text = _campaignToEdit!.description;
      _budgetController.text = _campaignToEdit!.budget.toString();

      debugPrint(
          'Set text controllers from widget - Name: ${_campaignNameController.text}, Desc: ${_campaignDescriptionController.text}');

      _category = _campaignToEdit!.category;
      _startDate = _campaignToEdit!.startDate;
      _endDate = _campaignToEdit!.endDate;
      _goals = List.from(_campaignToEdit!.goals);
      _selectedInfluencer = _campaignToEdit!.selectedInfluencer;

      // Initialize the form state in the bloc with existing data (do this only once)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CampaignBloc>().add(
              InitCampaignForm(
                title: _campaignToEdit!.title,
                description: _campaignToEdit!.description,
                category: _campaignToEdit!.category,
                budget: _campaignToEdit!.budget,
                startDate: _campaignToEdit!.startDate,
                endDate: _campaignToEdit!.endDate,
                goals: _campaignToEdit!.goals,
                selectedInfluencer: _campaignToEdit!.selectedInfluencer,
              ),
            );

        // Update the form with existing data immediately
        _updateBasicDetails();

        // Update goals
        context.read<CampaignBloc>().add(UpdateCampaignGoals(_goals));

        // Update selected influencer
        if (_selectedInfluencer != null) {
          context
              .read<CampaignBloc>()
              .add(UpdateSelectedInfluencer(_selectedInfluencer));
        }

        // Fetch contract details for this campaign
        _fetchContractDetails();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Default initialization for new campaign
        if (mounted && _campaignToEdit != null && _isEditing) {
          // This is a double-check to make sure edit mode data is loaded
          debugPrint('Post-frame callback: ensuring edit data is loaded');
          _updateBasicDetails();
        } else if (mounted) {
          // Initialize form state for new campaign
          debugPrint('Initializing form state for new campaign');
          context.read<CampaignBloc>().add(
                InitCampaignForm(
                  title: '',
                  description: '',
                  category: 'fashion',
                  budget: 0,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 30)),
                  goals: [],
                ),
              );
        }
      });
    }
  }

  Widget _buildStepContent(CampaignFormState? formState) {
    switch (_currentStep) {
      case 1:
        // Make sure we pass the correct budget value from the form state
        int budgetValue = 0;

        // First priority: use the value from form state if available
        if (formState != null && formState.budget > 0) {
          budgetValue = formState.budget.toInt();
          debugPrint('Using budget from form state: $budgetValue');
        }
        // Second priority: use the value from the controller if not empty
        else if (_budgetController.text.isNotEmpty) {
          // Get only the digits from the formatted string
          String digitsOnly =
              _budgetController.text.replaceAll(RegExp(r'[^\d]'), '');

          // Parse as integer to avoid decimal issues
          try {
            budgetValue = int.parse(digitsOnly);
            debugPrint('Using budget from controller: $budgetValue');
          } catch (e) {
            debugPrint('Error parsing budget from controller: $e');
          }
        }

        return CampaignFormCard(
          key: _formKey,
          campaignNameController: _campaignNameController,
          campaignDescriptionController: _campaignDescriptionController,
          budgetValue: budgetValue > 0 ? budgetValue : null,
          categoryValue: (formState != null) ? formState.category : _category,
          startDateValue:
              (formState != null) ? formState.startDate : _startDate,
          endDateValue: (formState != null) ? formState.endDate : _endDate,
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
          initialGoals: _goals,
          onValidationChanged: (isValid) {
            // Validation is now handled by the bloc
          },
          onGoalsSelected: (goals) {
            _goals = goals;
            context.read<CampaignBloc>().add(UpdateCampaignGoals(goals));
          },
        );
      case 3:
        return SelectInfluencerStep(
          initialSelectedInfluencer: _selectedInfluencer,
          onSelectedInfluencersChanged: (selected) {
            final selectedId = selected.isNotEmpty ? selected.first : null;
            _selectedInfluencer = selectedId;
            context
                .read<CampaignBloc>()
                .add(UpdateSelectedInfluencer(selectedId));
          },
        );
      case 4:
        return ContractDetailsStep(
          campaignFormState: formState,
          initialPostTypes: _postTypes,
          initialDeliveryDate: _deliveryDate,
          initialGuidelines: _contentGuidelines,
          initialConfirmDetails: _confirmDetails,
          initialAcceptTerms: _acceptTerms,
          onContractDetailsChanged: (postTypes, deliveryDate, guidelines,
              confirmDetails, acceptTerms) {
            _postTypes = postTypes;
            _deliveryDate = deliveryDate;
            _contentGuidelines = guidelines;
            _confirmDetails = confirmDetails;
            _acceptTerms = acceptTerms;

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

  // Fetch contract details for the campaign being edited
  Future<void> _fetchContractDetails() async {
    if (_campaignToEdit != null) {
      try {
        // Fetch the contract for this campaign
        final contract = await ContractRepository.getContractByCampaignId(
            _campaignToEdit!.id);

        if (contract != null) {
          setState(() {
            _postTypes = contract.postType;
            _deliveryDate = contract.deliveryDate;
            _contentGuidelines = contract.guidelines;

            // Update contract details in the bloc
            context.read<CampaignBloc>().add(
                  UpdateContractDetails(
                    postTypes: _postTypes,
                    deliveryDate: _deliveryDate,
                    contentGuidelines: _contentGuidelines,
                    confirmDetails: true,
                    acceptTerms: true,
                  ),
                );
          });

          debugPrint(
              'Contract details loaded: post types: ${_postTypes.join(', ')}, delivery date: $_deliveryDate');
        } else {
          debugPrint('No contract found for campaign ${_campaignToEdit!.id}');
        }
      } catch (e) {
        debugPrint('Error loading contract details: $e');
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 1) {
      setState(() {
        // If coming back from influencer selection step, clear selection status
        // to ensure we don't have stale UI state when returning
        if (_currentStep == 3) {
          debugPrint(
              'Going back from influencer selection step, resetting selection state');
          // Reset the selected influencer in the local state
          _selectedInfluencer = null;
          // Reset the selected influencer in the bloc
          context.read<CampaignBloc>().add(ResetSelectedInfluencer());
        }

        _currentStep--;
        _validationErrors = [];

        // If returning to Step 1, ensure the budget controller and category have the latest values
        if (_currentStep == 1) {
          final state = context.read<CampaignBloc>().state;
          if (state is CampaignFormState) {
            // Update budget controller with the value from state, if budget controller is empty
            if (_budgetController.text.isEmpty && state.budget > 0) {
              // Just use the integer value to avoid any formatting issues
              _budgetController.text = state.budget.toInt().toString();
              debugPrint(
                  'Updated budget field when returning to step 1: ${_budgetController.text}');
            }

            // Update category value
            _category = state.category;
            debugPrint('Updated category when returning to step 1: $_category');
          }
        }
      });
    }
  }

  // Show a dialog with insufficient funds message and a button to navigate to wallet
  void _showInsufficientFundsDialog(
      double availableBalance, int budget, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Insufficient Funds',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You don\'t have enough funds to create this campaign.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
                'Available balance: PKR ${availableBalance.toStringAsFixed(0)}'),
            Text('Required budget: PKR $budget'),
            Text(
                'Shortfall: PKR ${(budget - availableBalance.toInt()).toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Close the dialog and navigate to wallet screen with userId
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                walletScreen,
                arguments: {'userId': userId},
              );
            },
            child: const Text('Add Funds to Wallet'),
          ),
        ],
      ),
    );
  }

  void _updateBasicDetails() {
    final budgetText = _budgetController.text.trim();

    // Parse budget as an integer to avoid decimal point issues
    int budget = 0;
    if (budgetText.isNotEmpty) {
      try {
        // Strip any non-digit characters first
        final String digitsOnly = budgetText.replaceAll(RegExp(r'[^\d]'), '');
        // Parse as integer
        budget = int.parse(digitsOnly);
      } catch (e) {
        debugPrint('Error parsing budget in _updateBasicDetails: $e');
      }
    }

    // Only update if we have a valid campaign form state
    final currentState = context.read<CampaignBloc>().state;
    if (currentState is CampaignFormState) {
      // Only update if any of the values have changed
      if (currentState.title != _campaignNameController.text ||
          currentState.description != _campaignDescriptionController.text ||
          currentState.category != _category ||
          currentState.budget != budget.toDouble() ||
          currentState.startDate != _startDate ||
          currentState.endDate != _endDate) {
        debugPrint('Updating basic details - budget: $budget');

        context.read<CampaignBloc>().add(
              UpdateCampaignBasicDetails(
                title: _campaignNameController.text,
                description: _campaignDescriptionController.text,
                category: _category,
                budget: budget.toDouble(),
                startDate: _startDate,
                endDate: _endDate,
              ),
            );
      }
    } else {
      // Always update if we don't have a valid form state yet
      debugPrint(
          'Updating basic details (no previous state) - budget: $budget');

      context.read<CampaignBloc>().add(
            UpdateCampaignBasicDetails(
              title: _campaignNameController.text,
              description: _campaignDescriptionController.text,
              category: _category,
              budget: budget.toDouble(),
              startDate: _startDate,
              endDate: _endDate,
            ),
          );
    }
  }

  void _validateAndGoToNextStep(CampaignFormState formState) {
    // Prevent multiple rapid validations (debounce)
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
      // Remove any commas or non-digit characters from the budget text
      final String digitsOnly = budgetText.replaceAll(RegExp(r'[^\d]'), '');

      // Parse budget value
      int? budget;
      if (digitsOnly.isNotEmpty) {
        try {
          budget = int.parse(digitsOnly);
        } catch (e) {
          debugPrint('Error parsing budget during validation: $e');
        }
      }

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

      // Budget must be non-null here because we checked above
      if (budget != null) {
        // Validate if brand has sufficient funds
        _validateFundsAndProceed(budget);
      }
      return;
    }

    // For final step, create the campaign directly
    if (_currentStep == 4) {
      // This is the final step, create the campaign
      context.read<CampaignBloc>().add(ValidateCurrentStep(_currentStep));

      // Only create if valid
      if (formState.isStepValid(_currentStep)) {
        if (_isEditing && _campaignToEdit != null) {
          // Pass the campaign ID when updating existing campaign
          context.read<CampaignBloc>().add(
                CreateCampaign(campaignId: _campaignToEdit!.id),
              );
        } else {
          // Create new campaign
          context.read<CampaignBloc>().add(CreateCampaign());
        }
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

    // Force immediate validation for all steps before proceeding
    final validationRequired = _currentStep == 2 || _currentStep == 3;

    if (validationRequired) {
      // For Step 2 (Goals)
      if (_currentStep == 2 && formState.selectedGoals.isEmpty) {
        setState(() {
          _validationErrors = ['At least one campaign goal must be selected'];
        });
        return;
      }

      // For Step 3 (Influencer selection)
      if (_currentStep == 3 && formState.selectedInfluencer == null) {
        setState(() {
          _validationErrors = ['Please select an influencer for your campaign'];
        });
        return;
      }
    }

    // Check if the step is valid after bloc validation
    if (!formState.isStepValid(_currentStep)) {
      // Show validation errors
      setState(() {
        _validationErrors = formState.getErrorsForStep(_currentStep);
      });
      return;
    }

    // Use a microtask to ensure state updates are processed before moving to next step
    Future.microtask(() {
      if (mounted) {
        // Always reset influencer selection state when navigating away from step 3
        // This ensures consistency with the UI state in SelectInfluencerStep
        if (_currentStep == 3) {
          if (_selectedInfluencer == null) {
            // If nothing selected, ensure the bloc state is also cleared
            context.read<CampaignBloc>().add(ResetSelectedInfluencer());
          } else {
            // Make sure the bloc state matches our local state
            context
                .read<CampaignBloc>()
                .add(UpdateSelectedInfluencer(_selectedInfluencer));
          }
        }

        setState(() {
          _currentStep++;
        });
      }
    });
  }

  void _validateFundsAndProceed(int budget) {
    setState(() {
      _validationErrors = [];
    });

    // Get the current user ID first, then get the funds
    AuthRepository.getUserId().then((userId) {
      // Get the brand's current funds
      FundsRepository.getFundsForUser(userId).then((funds) {
        // Compare budget with available balance, converting to int for clean comparison
        if (funds.availableBalance.toInt() < budget) {
          // Show insufficient funds UI with a button to add funds
          _showInsufficientFundsDialog(funds.availableBalance, budget, userId);
          return;
        }

        // Update the data before proceeding - IMPORTANT to do this before changing step
        _updateBasicDetails();

        // Use a microtask to ensure state updates are processed before moving to next step
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _currentStep++;
            });
          }
        });
      }).catchError((error) {
        setState(() {
          _validationErrors = ['Error validating funds: ${error.toString()}'];
        });
      });
    }).catchError((error) {
      setState(() {
        _validationErrors = ['Error getting user ID: ${error.toString()}'];
      });
    });
  }
}
