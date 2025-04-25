import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int totalSteps;

  const NavigationButtons({
    super.key,
    required this.currentStep,
    required this.onPrevious,
    required this.onNext,
    this.totalSteps = 4, // Default to 4 steps for the campaign creation flow
  });

  @override
  Widget build(BuildContext context) {
    final isFinalStep = currentStep == totalSteps;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Keep space for Back button even when it's hidden
        if (currentStep > 1)
          ShadButton.secondary(
            onPressed: onPrevious,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 16),
                SizedBox(width: 4),
                Text('Back'),
              ],
            ),
          )
        else
          const SizedBox(width: 80), // Maintain space for hidden Back button

        isFinalStep
            ? ShadButton(
                onPressed: onNext,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Create Campaign'),
                    SizedBox(width: 4),
                    Icon(Icons.check_circle_outline, size: 16),
                  ],
                ),
              )
            : ShadButton.secondary(
                onPressed: onNext,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
      ],
    );
  }
}
