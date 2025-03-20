import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/date_and_time.dart';
import '../../../../shared/presentation/theme/app_colors.dart';

class CampaignFormCard extends StatefulWidget {
  final TextEditingController campaignNameController;
  final TextEditingController campaignDescriptionController;
  final Function(double) onBudgetChanged;
  final Function(String) onCategoryChanged;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final double? budgetValue;
  final String? categoryValue;
  final DateTime? startDateValue;
  final DateTime? endDateValue;

  const CampaignFormCard({
    super.key,
    required this.campaignNameController,
    required this.campaignDescriptionController,
    required this.onBudgetChanged,
    required this.onCategoryChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.budgetValue,
    this.categoryValue,
    this.startDateValue,
    this.endDateValue,
  });

  @override
  State<CampaignFormCard> createState() => _CampaignFormCardState();
}

/// Input formatter that adds thousands separators to numbers
class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Only process if the input has changed and isn't empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    if (digitsOnly.length > 1 && digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    }

    // If empty after removing leading zeros, return '0'
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Parse to int
    int value = int.parse(digitsOnly);

    // Format with commas
    String formatted = _formatter.format(value);

    // Maintain cursor position relative to the digits
    int cursorPos = newValue.selection.end;
    int oldDigitCount = oldValue.text.replaceAll(RegExp(r'[^\d]'), '').length;
    int newDigitCount = digitsOnly.length;
    int commaCount = formatted.length - digitsOnly.length;

    // Adjust cursor for added/removed commas
    int newCursorPos = cursorPos;
    if (oldValue.text.isNotEmpty && oldDigitCount != newDigitCount) {
      int oldCommaCount = oldValue.text.length - oldDigitCount;
      newCursorPos += (commaCount - oldCommaCount);
    }

    // Ensure cursor position is within bounds
    newCursorPos = newCursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}

class _CampaignFormCardState extends State<CampaignFormCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _budgetController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
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
                      onChanged: (_) => setState(() => _showNameError = false),
                    ),
                    if (_showNameError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          'Campaign name is required',
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
                      onChanged: (_) =>
                          setState(() => _showDescriptionError = false),
                    ),
                    if (_showDescriptionError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                        child: Text(
                          'Campaign description is required',
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
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsFormatter(),
                      ],
                      onChanged: (value) {
                        setState(() => _showBudgetError = false);

                        // Get only the digits from the formatted string
                        String digitsOnly =
                            value.replaceAll(RegExp(r'[^\d]'), '');
                        if (digitsOnly.isEmpty) return;

                        int? budget = int.tryParse(digitsOnly);
                        debugPrint(
                            'Budget input changed: $value, parsed to: $budget');
                        if (budget != null) {
                          widget.onBudgetChanged(budget.toDouble());
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

              // Campaign Dates
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Campaign Dates',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Start Date
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectStartDate(context),
                            child: AbsorbPointer(
                              child: ShadInputFormField(
                                controller: TextEditingController(
                                  text: DateAndTime.formatDate(
                                      _startDate, 'MMM dd, yyyy'),
                                ),
                                placeholder: const Text('Start date'),
                                suffix:
                                    const Icon(Icons.calendar_today, size: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // End Date
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectEndDate(context),
                            child: AbsorbPointer(
                              child: ShadInputFormField(
                                controller: TextEditingController(
                                  text: DateAndTime.formatDate(
                                      _endDate, 'MMM dd, yyyy'),
                                ),
                                placeholder: const Text('End date'),
                                suffix:
                                    const Icon(Icons.calendar_today, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

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

    // Update budget controller if the value has changed from parent
    if (widget.budgetValue != null &&
        widget.budgetValue.toString() != _budgetController.text) {
      _budgetController.text = widget.budgetValue!.toInt().toString();
      debugPrint(
          'Updated budget field in didUpdateWidget: ${_budgetController.text}');
    }

    // Update category if it changed
    if (widget.categoryValue != null &&
        widget.categoryValue != _selectedCategory) {
      setState(() {
        _selectedCategory = widget.categoryValue!;
        debugPrint('Updated category in didUpdateWidget: $_selectedCategory');
      });
    }

    // Update dates if they changed
    if (widget.startDateValue != null && widget.startDateValue != _startDate) {
      setState(() {
        _startDate = widget.startDateValue!;
        debugPrint('Updated start date in didUpdateWidget: $_startDate');
      });
    }

    if (widget.endDateValue != null && widget.endDateValue != _endDate) {
      setState(() {
        _endDate = widget.endDateValue!;
        debugPrint('Updated end date in didUpdateWidget: $_endDate');
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

    // Initialize budget controller
    if (widget.budgetValue != null && widget.budgetValue! > 0) {
      _budgetController.text = widget.budgetValue!.toInt().toString();
      debugPrint('Set budget field in initState: ${_budgetController.text}');
    } else {
      _budgetController.text = '';
    }

    _selectedCategory = widget.categoryValue ?? 'fashion';
    _startDate = widget.startDateValue ?? DateTime.now();
    _endDate =
        widget.endDateValue ?? DateTime.now().add(const Duration(days: 7));

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
    if (widget.campaignNameController.text.isEmpty) {
      setState(() => _showNameError = true);
      isValid = false;
    }

    // Validate campaign description
    if (widget.campaignDescriptionController.text.isEmpty) {
      setState(() => _showDescriptionError = true);
      isValid = false;
    }

    // Validate budget
    final budgetText = _budgetController.text;
    final budget = int.tryParse(budgetText);
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
        ..._categories.entries.map(
          (e) => ShadOption(
            value: e.key,
            child: SizedBox(
              width: 300, // Constrain the width of the option text
              child: Text(
                e.value,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
      selectedOptionBuilder: (context, value) {
        // Using Future.microtask to avoid setState during build
        Future.microtask(() {
          String normalizedValue =
              CampaignRepository.normalizeCategoryKey(value);
          if (_selectedCategory != normalizedValue) {
            setState(() {
              _selectedCategory = normalizedValue;
            });
            widget.onCategoryChanged(normalizedValue);
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

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      widget.onEndDateChanged(_endDate);
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        // Ensure end date is after start date
        if (_endDate.isBefore(picked)) {
          _endDate = picked.add(const Duration(days: 7));
          widget.onEndDateChanged(_endDate);
        }
      });
      widget.onStartDateChanged(picked);
    }
  }

  void _validateBudget() {
    final budgetText = _budgetController.text.trim();

    // Get only the digits from the formatted string
    String digitsOnly = budgetText.replaceAll(RegExp(r'[^\d]'), '');

    final budget = int.tryParse(digitsOnly);
    setState(() {
      _showBudgetError = budget == null || budget <= 0;
    });

    if (budget != null && budget > 0) {
      widget.onBudgetChanged(budget.toDouble());
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
