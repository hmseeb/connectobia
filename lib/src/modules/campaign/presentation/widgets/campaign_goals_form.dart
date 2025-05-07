import 'package:connectobia/src/shared/data/constants/assets.dart';
import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CampaignGoals extends StatefulWidget {
  final Function(bool) onValidationChanged;
  final Function(List<String>) onGoalsSelected;
  final List<String>? initialGoals;

  const CampaignGoals({
    super.key,
    required this.onValidationChanged,
    required this.onGoalsSelected,
    this.initialGoals,
  });

  @override
  State<CampaignGoals> createState() => _CampaignGoalsState();
}

class _CampaignGoalsState extends State<CampaignGoals>
    with SingleTickerProviderStateMixin {
  // Updated to match PocketBase schema goals
  late final Map<String, bool> _selectedGoals = {
    'awareness': false,
    'sales': false,
    'engagement': false,
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool get isAtLeastOneGoalSelected => _selectedGoals.values.contains(true);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              // SVG Image
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SvgPicture.asset(
                  AssetsPath.campaignGoals,
                  height: 140,
                  width: 140,
                ),
              ),
              const SizedBox(height: 16),

              // The ShadCard containing goals
              ShadCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Campaign Goals',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Select the primary goals for your campaign:',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Goal checkboxes with improved UI
                    _buildGoalItem(
                      id: 'awareness',
                      icon: Icons.visibility_outlined,
                      label: 'Increase Brand Awareness',
                      sublabel:
                          'Expand your reach and make more people familiar with your brand',
                      initialValue: _selectedGoals['awareness']!,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalItem(
                      id: 'sales',
                      icon: Icons.shopping_cart_outlined,
                      label: 'Drive Sales',
                      sublabel:
                          'Attract potential customers and boost conversion rates',
                      initialValue: _selectedGoals['sales']!,
                    ),
                    const SizedBox(height: 16),
                    _buildGoalItem(
                      id: 'engagement',
                      icon: Icons.people_outline,
                      label: 'Boost Engagement',
                      sublabel:
                          'Increase audience interaction and participation with your brand',
                      initialValue: _selectedGoals['engagement']!,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Helpful tips card
              ShadCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text(
                          'Tip',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecting clear goals helps us match you with the right influencers and measure your campaign success effectively.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize selected goals from props if provided
    if (widget.initialGoals != null && widget.initialGoals!.isNotEmpty) {
      for (var goal in widget.initialGoals!) {
        if (_selectedGoals.containsKey(goal)) {
          _selectedGoals[goal] = true;
        }
      }
      // Update parent component
      _updateValidation();
    }

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

  Widget _buildGoalItem({
    required String id,
    required IconData icon,
    required String label,
    required String sublabel,
    required bool initialValue,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedGoals[id]!;
    final cardBg = isSelected
        ? theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.dark ? 0.9 : 1.0)
        : theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final iconColor = isSelected ? AppColors.primary : textColor.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: cardBg,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedGoals[id] = !_selectedGoals[id]!;
            _updateValidation();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              ShadCheckbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _selectedGoals[id] = value;
                    _updateValidation();
                  });
                },
              ),
              const SizedBox(width: 8),

              // Icon and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 16, color: iconColor),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        sublabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateValidation() {
    widget.onValidationChanged(isAtLeastOneGoalSelected);

    // Collect all selected goals
    List<String> selectedGoals = _selectedGoals.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    widget.onGoalsSelected(selectedGoals);
  }
}
