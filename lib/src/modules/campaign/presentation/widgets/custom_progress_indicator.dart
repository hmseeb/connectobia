import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const CustomProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.stepTitles = const ['Campaign', 'Goals', 'Influencer', 'Contract'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isCompleted = currentStep > index + 1;
            final isActive = currentStep == index + 1;

            return Expanded(
              child: Row(
                children: [
                  // First item doesn't need a line before it
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isCompleted || isActive
                                  ? AppColors.primary
                                  : AppColors.divider,
                              isCompleted
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Step Circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primary
                          : (isCompleted
                              ? AppColors.background
                              : AppColors.divider),
                      border: Border.all(
                        color: isCompleted || isActive
                            ? AppColors.primary
                            : AppColors.divider,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 18,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.background
                                    : AppColors.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),

                  // Line after the last item
                  if (index < totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isCompleted
                                  ? AppColors.primary
                                  : AppColors.divider,
                              isCompleted && currentStep > index + 2
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        // Step titles
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = currentStep == index + 1;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  stepTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
