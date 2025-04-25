import 'package:connectobia/src/modules/campaign/data/campaign_repository.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../shared/data/constants/assets.dart'; // Import the flutter_svg package
import '../../../../shared/presentation/theme/app_colors.dart';

class CampaignFormCard extends StatefulWidget {
  final TextEditingController campaignNameController;
  final TextEditingController campaignDescriptionController;
  final Function(double) onBudgetChanged;
  final Function(String) onCategoryChanged;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const CampaignFormCard({
    super.key,
    required this.campaignNameController,
    required this.campaignDescriptionController,
    required this.onBudgetChanged,
    required this.onCategoryChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  State<CampaignFormCard> createState() => _CampaignFormCardState();
}

/// A custom category selector for campaigns
class CategorySelect extends StatelessWidget {
  final Map<String, String> categories;
  final String? selectedCategory;
  final Function(String) onSelected;
  final FocusNode focusNode;

  const CategorySelect({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onSelected,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    // Using Flutter's DropdownButtonFormField instead of CustomShadSelect to avoid errors
    return DropdownButtonFormField<String>(
      value: selectedCategory ?? categories.keys.first,
      focusNode: focusNode,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
      items: categories.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      hint: const Text('Select a category'),
    );
  }
}

class _CampaignFormCardState extends State<CampaignFormCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _budgetController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'fashion';
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with image
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    AssetsPath.campaign,
                    height: 180,
                    width: 180,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campaign Name
              _buildSectionHeader('Campaign Name'),
              const SizedBox(height: 8),
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShadInputFormField(
                        controller: widget.campaignNameController,
                        placeholder: const Text('Enter a catchy campaign name'),
                        onChanged: (_) =>
                            setState(() => _showNameError = false),
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
              ),

              const SizedBox(height: 20),

              // Campaign Description
              _buildSectionHeader('Campaign Description'),
              const SizedBox(height: 8),
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
              ),

              const SizedBox(height: 20),

              // Category
              _buildSectionHeader('Category'),
              const SizedBox(height: 8),
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : ShadCard(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: CategorySelect(
                            categories: _categories,
                            selectedCategory: _selectedCategory,
                            onSelected: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                              widget.onCategoryChanged(value);
                            },
                            focusNode: _categoryFocusNode,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 20),

              // Budget
              _buildSectionHeader('Budget'),
              const SizedBox(height: 8),
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShadInputFormField(
                        controller: _budgetController,
                        placeholder:
                            const Text('How much are you willing to spend?'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefix: const Text('\$',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onChanged: (value) {
                          setState(() => _showBudgetError = false);
                          double? budget = double.tryParse(value);
                          debugPrint(
                              'Budget input changed: $value, parsed to: $budget');
                          if (budget != null) {
                            widget.onBudgetChanged(budget);
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
              ),

              const SizedBox(height: 20),

              // Timeline section header
              Row(
                children: [
                  const Icon(Icons.date_range, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Campaign Timeline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date pickers in a Row for better layout
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () => _selectStartDate(context),
                          child: AbsorbPointer(
                            child: ShadInputFormField(
                              controller: TextEditingController(
                                text: DateFormat('MMM dd, yyyy')
                                    .format(_startDate),
                              ),
                              placeholder: const Text('Select start date'),
                              suffix:
                                  const Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // End Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Date',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () => _selectEndDate(context),
                          child: AbsorbPointer(
                            child: ShadInputFormField(
                              controller: TextEditingController(
                                text:
                                    DateFormat('MMM dd, yyyy').format(_endDate),
                              ),
                              placeholder: const Text('Select end date'),
                              suffix:
                                  const Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tips section
              ShadCard(
                backgroundColor: AppColors.lightBackground.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
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
    _loadCategories();
    _budgetController.text = '0';

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
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
    final budget = double.tryParse(budgetText);
    if (budgetText.isEmpty || budget == null || budget <= 0) {
      setState(() => _showBudgetError = true);
      isValid = false;
    }

    return isValid;
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      initialDate: _endDate.isAfter(_startDate)
          ? _endDate
          : _startDate.add(const Duration(days: 1)),
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
        _startDate = picked;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
          widget.onEndDateChanged(_endDate);
        }
      });
      widget.onStartDateChanged(_startDate);
    }
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalizeFirst() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }
}
