import 'package:connectobia/src/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstStep = currentStep == 1;
    final isLastStep = currentStep == 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        isFirstStep
            ? ShadButton.outline(
                onPressed: onPrevious,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ShadButton.outline(
                onPressed: onPrevious,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

        // Next/Submit button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ShadButton(
            onPressed: onNext,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastStep ? 'Submit Campaign' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastStep ? Icons.check_circle : Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
