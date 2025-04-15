import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/presentation/theme/app_colors.dart';

class CampaignFormCard extends StatefulWidget {
  final TextEditingController campaignNameController;
  final TextEditingController campaignDescriptionController;
  final Function(int) onBudgetChanged;
  final Function(String) onCategoryChanged;
  final int? budgetValue;
  final String? categoryValue;

  const CampaignFormCard({
    super.key,
    required this.campaignNameController,
    required this.campaignDescriptionController,
    required this.onBudgetChanged,
    required this.onCategoryChanged,
    this.budgetValue,
    this.categoryValue,
  });

  @override
  State<CampaignFormCard> createState() => _CampaignFormCardState();
}

/// Input formatter that only allows digits (no formatting)
class DigitsOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Only allow digits
    final String filteredValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If filtered value is the same as the input, return as is
    if (filteredValue == newValue.text) {
      return newValue;
    }

    // Otherwise return just the digits with the cursor at the end
    return TextEditingValue(
      text: filteredValue,
      selection: TextSelection.collapsed(offset: filteredValue.length),
    );
  }
}

class _CampaignFormCardState extends State<CampaignFormCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _budgetController = TextEditingController();
  late String _selectedCategory;
  Map<String, String> _categories = {'fashion': 'Fashion'};
  bool _isLoadingCategories = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _categoryFocusNode = FocusNode();

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Error indicators
  bool _showNameError = false;
  bool _showDescriptionError = false;
  bool _showBudgetError = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Illustration
              Center(
                child: SvgPicture.asset(
                  'assets/illustrations/campaign.svg',
                  height: 180,
                ),
              ),
              const SizedBox(height: 20),

              // Campaign Name
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campaign Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShadInputFormField(
                      controller: widget.campaignNameController,
                      placeholder: const Text('Enter campaign name'),
                      maxLength: 40,
                      onChanged: (_) => setState(() => _showNameError = false),
                    ),
                    if (_showNameError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          widget.campaignNameController.text.isEmpty
                              ? 'Campaign name is required'
                              : 'Campaign name must be 40 characters or less',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campaign Category
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isLoadingCategories
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary))
                        : _buildCategorySelector(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campaign Description
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campaign Description',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShadInputFormField(
                      controller: widget.campaignDescriptionController,
                      placeholder:
                          const Text('Describe what your campaign is about'),
                      maxLines: 3,
                      maxLength: 4000,
                      onChanged: (_) =>
                          setState(() => _showDescriptionError = false),
                    ),
                    if (_showDescriptionError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          widget.campaignDescriptionController.text.isEmpty
                              ? 'Campaign description is required'
                              : 'Campaign description must be 4000 characters or less',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Budget
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShadInputFormField(
                      controller: _budgetController,
                      placeholder: const Text('Enter campaign budget'),
                      keyboardType: TextInputType.number,
                      prefix: const Text('PKR',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      inputFormatters: [
                        DigitsOnlyFormatter(),
                      ],
                      onChanged: (value) {
                        setState(() => _showBudgetError = false);

                        // Skip empty values
                        if (value.isEmpty) return;

                        // Extract only digits
                        final String digitsOnly =
                            value.replaceAll(RegExp(r'[^\d]'), '');

                        // Only work with integer values
                        try {
                          if (digitsOnly.isNotEmpty) {
                            int budget = int.parse(digitsOnly);

                            // Check if value changed before updating
                            if (widget.budgetValue != budget) {
                              debugPrint('Budget value changed to: $budget');
                              widget.onBudgetChanged(budget);
                            }
                          }
                        } catch (e) {
                          debugPrint('Error parsing budget: $e');
                          // Don't update on parsing errors
                        }
                      },
                    ),
                    if (_showBudgetError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          'Budget must be a number greater than 0',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Campaign Dates section removed as dates will be set automatically:
              // Start date - when influencer signs the contract
              // End date - will be the delivery date

              // Tips section
              ShadCard(
                backgroundColor: AppColors.lightBackground.withOpacity(0.5),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          'Campaign Tips',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        '• Clear campaign goals help influencers understand your expectations'),
                    const Text(
                        '• Provide a reasonable budget for better proposals'),
                    const Text(
                        '• Give enough time for content creation and review'),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(CampaignFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update budget controller if the value is actually different
    if (widget.budgetValue != null &&
        widget.budgetValue != oldWidget.budgetValue) {
      final int intValue = widget.budgetValue!;
      final int? currentValue = _budgetController.text.isEmpty
          ? null
          : int.tryParse(_budgetController.text);

      // Only update if the actual numeric value is different
      if (currentValue != intValue) {
        // Set just the integer value to avoid decimal issues
        _budgetController.text = intValue.toString();
        debugPrint(
            'Updated budget field in didUpdateWidget: ${_budgetController.text}');
      }
    }

    // Update category if it changed
    if (widget.categoryValue != null &&
        widget.categoryValue != oldWidget.categoryValue) {
      setState(() {
        _selectedCategory = widget.categoryValue!;
        debugPrint('Updated category in didUpdateWidget: $_selectedCategory');
      });
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _animationController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Debug logs to trace initialization
    debugPrint(
        'CampaignFormCard initState - budgetValue: ${widget.budgetValue}, categoryValue: ${widget.categoryValue}');
    debugPrint(
        'Controller values - name: ${widget.campaignNameController.text}, description: ${widget.campaignDescriptionController.text}');

    _loadCategories();

    // Initialize budget controller with integer value only
    if (widget.budgetValue != null && widget.budgetValue! > 0) {
      _budgetController.text = widget.budgetValue!.toString();
      debugPrint('Set budget field in initState: ${_budgetController.text}');
    } else {
      _budgetController.text = '';
    }

    // Initialize other fields with proper default values
    _selectedCategory = widget.categoryValue ?? 'fashion';

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Updates for form validations
    widget.campaignNameController.addListener(_validateName);
    widget.campaignDescriptionController.addListener(_validateDescription);
    _budgetController.addListener(_validateBudget);
  }

  // Validate all form fields and show errors as needed
  bool validate() {
    bool isValid = true;

    // Validate campaign name
    if (widget.campaignNameController.text.isEmpty ||
        widget.campaignNameController.text.length > 40) {
      setState(() => _showNameError = true);
      isValid = false;
    }

    // Validate campaign description
    if (widget.campaignDescriptionController.text.isEmpty ||
        widget.campaignDescriptionController.text.length > 4000) {
      setState(() => _showDescriptionError = true);
      isValid = false;
    }

    // Validate budget
    final budgetText = _budgetController.text.trim();

    // Extract only digits
    final String digitsOnly = budgetText.replaceAll(RegExp(r'[^\d]'), '');

    final budget = digitsOnly.isEmpty ? null : int.tryParse(digitsOnly);
    if (budgetText.isEmpty || budget == null || budget <= 0) {
      setState(() => _showBudgetError = true);
      isValid = false;
    }

    return isValid;
  }

  // Separate method to build category selector to avoid setState during build
  Widget _buildCategorySelector() {
    // Convert keys to normalized form for matching
    String normalizedSelectedCategory =
        CampaignRepository.normalizeCategoryKey(_selectedCategory);

    return ShadSelect<String>(
      placeholder: Text('Select a category'),
      focusNode: _categoryFocusNode,
      minWidth: 450,
      maxHeight: 220,
      initialValue: normalizedSelectedCategory,
      options: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 6, 6, 6),
          child: Text(
            'Choose a category',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        // Use entries directly from the map to avoid any duplicates
        ..._categories.entries.map(
          (e) => ShadOption(
            value: e.key, // Use the normalized key (with underscores)
            child: SizedBox(
              width: 300,
              child: Text(
                e.value, // Display the human-readable version
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
      selectedOptionBuilder: (context, value) {
        // Using Future.microtask to avoid setState during build
        Future.microtask(() {
          // Use the selected value directly without additional normalization
          if (_selectedCategory != value) {
            setState(() {
              _selectedCategory = value;
            });
            widget.onCategoryChanged(value);
          }
        });

        return SizedBox(
          width: 300,
          child: Text(
            _categories[value] ?? value,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories = await CampaignRepository.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  void _validateBudget() {
    final budgetText = _budgetController.text.trim();

    // Extract only digits
    final String digitsOnly = budgetText.replaceAll(RegExp(r'[^\d]'), '');

    // Try to parse as integer to avoid decimal issues
    int? budget;
    try {
      if (digitsOnly.isNotEmpty) {
        budget = int.parse(digitsOnly);
      }
    } catch (e) {
      debugPrint('Error parsing budget during validation: $e');
      budget = null;
    }

    // Set error state if budget is invalid
    setState(() {
      _showBudgetError = budget == null || budget <= 0;
    });

    // Only update the budget value if it's valid and different from current
    if (budget != null && budget > 0) {
      int budgetValue = budget;
      if (widget.budgetValue != budgetValue) {
        widget.onBudgetChanged(budgetValue);
      }
    }
  }

  void _validateDescription() {
    setState(() {
      _showDescriptionError = widget.campaignDescriptionController.text.isEmpty;
    });
  }

  void _validateName() {
    setState(() {
      _showNameError = widget.campaignNameController.text.isEmpty;
    });
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalizeFirst() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }
}
